{
  config,
  lib,
  pkgs,
  env,
  ...
}:
let
  cfg = config.mySystem.system.cache-storage;
in {
  options.mySystem.system.cache-storage = {
    enable = lib.mkEnableOption "cache-storage config";
  };

  config = lib.mkIf cfg.enable (
    let
  features = env.features or {};
  cacheMode = features.cacheMode or "overlayfs"; # "overlayfs" | "tmpfs" | "disk"
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
  # 1. Pure Tmpfs Mode (100% In-Memory ~/.cache)
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

  # ---------------------------------------------------------------------------
  # 2. OverlayFS Mode (Read from SSD .cache-lower, Write 100% to RAM tmpfs)
  # ---------------------------------------------------------------------------
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

        # Ensure baseline lower directory exists on SSD
        if [ ! -d "${lowerDir}" ]; then
          if [ -d "${cacheDir}" ] && [ ! -L "${cacheDir}" ]; then
            mv "${cacheDir}" "${lowerDir}"
          else
            mkdir -p "${lowerDir}"
          fi
          chown -R ${user}:users "${lowerDir}"
          chmod 0700 "${lowerDir}"
        fi

        # Ensure target mountpoint exists
        mkdir -p "${cacheDir}"
        chown ${user}:users "${cacheDir}"
        chmod 0700 "${cacheDir}"

        # Create upper and work dirs in RAM (/run tmpfs)
        mkdir -p "${upperDir}" "${workDir}"
        chown -R ${user}:users "${runDir}"
        chmod 0700 "${upperDir}" "${workDir}"

        # Mount OverlayFS if not already mounted
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

  # Helper sync script in environment for optional manual persist
  environment.systemPackages = lib.mkIf (cacheMode == "overlayfs") [
    (pkgs.writeShellScriptBin "sync-cache-to-disk" ''
      echo "Syncing in-memory upper cache to persistent SSD lower layer..."
      ${pkgs.rsync}/bin/rsync -av --update "${upperDir}/" "${lowerDir}/"
      echo "✔ Cache synced to ${lowerDir}"
    '')
  ];
}
  );
}
