# =============================================================================
#  System Base Configuration Module (modules/nixos/system.nix)
#  Manages user accounts, locale & time, nix daemon settings, and cache overlay
# =============================================================================
{
  config,
  lib,
  pkgs,
  env,
  ...
}: let
  features = env.features or {};
  cacheMode = features.cacheMode or "overlayfs";
  cacheSize = features.cacheTmpfsSize or "4G";
  user = env.username;
  homeDir = "/home/${user}";
  cacheDir = "${homeDir}/.cache";
  lowerDir = "${homeDir}/.cache-lower";
  runDir = "/run/user-cache/${user}";
  upperDir = "${runDir}/upper";
  workDir = "${runDir}/work";
in {
  # ---------------------------------------------------------------------------
  # 👤 User Accounts & Permissions
  # ---------------------------------------------------------------------------
  users.groups.adbusers = {};
  users.users = {
    ${env.username} = {
      isNormalUser = true;
      initialPassword = env.username;
      shell = pkgs.fish;
      ignoreShellProgramCheck = true;
      description = env.username;
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "render"
        "input"
        "podman"
        "seat"
        "adbusers"
        "kvm"
        "libvirtd"
        "audio"
      ];
    };
    root = {
      initialPassword = "nixos";
    };
  };

  # ---------------------------------------------------------------------------
  # 🌐 Time & Regional Locale Preferences
  # ---------------------------------------------------------------------------
  time.timeZone = env.timeZone;
  environment.variables = {
    LANG = env.defaultLocale;
    LC_ALL = env.defaultLocale;
    NIXPKGS_ALLOW_UNFREE = "1";
  };
  i18n = {
    defaultLocale = env.defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = "en_IN";
      LC_IDENTIFICATION = "en_IN";
      LC_MEASUREMENT = "en_IN";
      LC_MONETARY = "en_IN";
      LC_NAME = "en_IN";
      LC_NUMERIC = "en_IN";
      LC_PAPER = "en_IN";
      LC_TELEPHONE = "en_IN";
      LC_TIME = "en_IN";
    };
  };

  # ---------------------------------------------------------------------------
  # ⚙️ Nix Settings, Flakes & Performance Tuning
  # ---------------------------------------------------------------------------
  nixpkgs.hostPlatform = env.system;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = ["root" "@wheel"];
    auto-optimise-store = true;
    pure-eval = false;
    max-jobs = "auto";
    cores = env.buildCores;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    always-allow-substitutes = true;
    use-xdg-base-directories = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than ${env.autoGcOlderThan}";
  };

  documentation = {
    enable = false;
    man.enable = false;
    man.cache.enable = false;
    nixos.enable = false;
    doc.enable = false;
    info.enable = false;
  };

  # ---------------------------------------------------------------------------
  # ⚡ Cache Storage (OverlayFS / RAM tmpfs ~/.cache)
  # ---------------------------------------------------------------------------
  fileSystems = lib.mkIf (cacheMode == "tmpfs") {
    "${cacheDir}" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "mode=0700"
        "uid=${user}"
        "gid=users"
        "size=${cacheSize}"
        "x-gvfs-hide"
      ];
      neededForBoot = false;
    };
  };

  systemd.services."user-cache-overlay" = lib.mkIf (cacheMode == "overlayfs") {
    description = "User ~/.cache OverlayFS in RAM (SSD Write-Protection)";
    wantedBy = ["multi-user.target" "graphical.target"];
    before = ["display-manager.service" "greetd.service" "user@1000.service"];
    after = ["local-fs.target"];
    unitConfig = {
      ConditionPathExists = homeDir;
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "mount-cache-overlay" ''
        set -euo pipefail
        if [ ! -d "${lowerDir}" ]; then
          if [ -d "${cacheDir}" ] && [ ! -L "${cacheDir}" ]; then
            mv "${cacheDir}" "${lowerDir}"
          else
            mkdir -p "${lowerDir}"
          fi
          chown -R ${user}:users "${lowerDir}"
          chmod 0700 "${lowerDir}"
        fi
        mkdir -p "${cacheDir}"
        chown ${user}:users "${cacheDir}"
        chmod 0700 "${cacheDir}"
        mkdir -p "${upperDir}" "${workDir}"
        chown -R ${user}:users "${runDir}"
        chmod 0700 "${upperDir}" "${workDir}"
        if ! ${pkgs.util-linux}/bin/mountpoint -q "${cacheDir}"; then
          ${pkgs.util-linux}/bin/mount -t overlay overlay \
            -o lowerdir="${lowerDir}",upperdir="${upperDir}",workdir="${workDir}" \
            "${cacheDir}"
          echo "✔ OverlayFS mounted on ${cacheDir} (Writes redirected to RAM)"
        fi
      '';
      ExecStop = pkgs.writeShellScript "unmount-cache-overlay" ''
        if ${pkgs.util-linux}/bin/mountpoint -q "${cacheDir}"; then
          ${pkgs.util-linux}/bin/umount -l "${cacheDir}" || true
        fi
        rm -rf "${runDir}" || true
      '';
    };
  };

  environment.systemPackages = lib.mkIf (cacheMode == "overlayfs") [
    (pkgs.writeShellScriptBin "sync-cache-to-disk" ''
      echo "Syncing in-memory upper cache to persistent SSD lower layer..."
      ${pkgs.rsync}/bin/rsync -av --update "${upperDir}/" "${lowerDir}/"
      echo "✔ Cache synced to ${lowerDir}"
    '')
  ];

  # ---------------------------------------------------------------------------
  # 📱 System Utility Programs
  # ---------------------------------------------------------------------------
  programs.localsend.enable = true;
}
