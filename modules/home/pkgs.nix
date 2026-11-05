# =============================================================================
#  Home Manager Categorized Packages Module (home/pkgs.nix)
#  Single Source of Truth for User CLI & GUI Packages
#  Toggle individual categories with `enable = true / false`.
# =============================================================================
{
  pkgs,
  lib,
  env,
  ...
}: let
  categories = {
    cliCore = {
      enable = true;
      pkgs = with pkgs; [
        neovim
        yazi
        fd
        fzf
        tree-sitter
      ];
    };

    cliMonitoring = {
      enable = true;
      pkgs = with pkgs; [
        alsa-utils
        btop
        duf
        dust
        fastfetch
        fatrace
        gdu
        htop
        iotop
        lm_sensors
        ncdu
        nvme-cli
        pciutils
        powertop
        radeontop
        smartmontools
        sysstat
      ];
    };

    cliFileOps = {
      enable = true;
      pkgs = with pkgs; [
        bat
        choose
        eza
        file
        libsecret
        minijinja
        ripgrep
        rsync
        sd
        stow
        tldr
        entr
      ];
    };

    cliArchive = {
      enable = true;
      pkgs = with pkgs; [
        ouch
        p7zip
        unrar
        zip
      ];
    };

    cliShells = {
      enable = true;
      pkgs = with pkgs; [
        fish
      ];
    };

    cliVisuals = {
      enable = true;
      pkgs = with pkgs; [
        cava
        cbonsai
        cmatrix
        glow
        zellij
      ];
    };

    cliMedia = {
      enable = true;
      pkgs = with pkgs; [
        gpu-screen-recorder
        imv
      ];
    };

    cliHardware = {
      enable = true;
      pkgs = with pkgs; [
        android-tools
      ];
    };

    guiBrowsers = {
      enable = true;
      pkgs = with pkgs; [
        google-chrome
      ];
    };

    guiEditors = {
      enable = true;
      pkgs = with pkgs; [
        vscodium-fhs
        antigravity-fhs
        zed-editor-fhs
      ];
    };

    guiMedia = {
      enable = true;
      pkgs = with pkgs; [
        mpv
        pwvucontrol
      ];
    };

    guiDocuments = {
      enable = true;
      pkgs = with pkgs; [
        readest
        zathura
      ];
    };

    guiDesktopUtils = {
      enable = true;
      pkgs = with pkgs; [
        kitty
        handlr-regex
        nwg-displays
        file-roller
        seahorse
        (nemo-with-extensions.override {
          extensions = [
            nemo-fileroller
            nemo-emblems
            nemo-python
          ];
        })
      ];
    };

    windowManager = {
      enable = true;
      pkgs = with pkgs; [
        nirius
        wlr-randr
        fuzzel
        mpvpaper
        swaybg
        waypaper
        brightnessctl
        pamixer
        playerctl
        swayidle
        swaylock-effects
        wlogout
        libnotify
        wayle
        cliphist
        grim
        nwg-clipman
        slurp
        wev
        wl-clipboard
      ];
    };

    programmingLang = {
      enable = env.enableProgrammingLang or true;
      pkgs = with pkgs; [
        python3
        python3Packages.pip
        python3Packages.virtualenv
        uv
        nodejs_22
        bun
        deno
        go
        rustup
        musl
        clang
        mold
        zig
        luajit
        alejandra
        shfmt
        shellcheck
        stylua
        ruff
        prettier
        clang-tools
      ];
    };

    devPkg = {
      enable = env.enableDevPkg or true;
      pkgs = with pkgs; [
        gh
        delta
        difftastic
        lazygit
        exercism
        rustlings
        httpie
        cloudflared
        wrangler
        cmake
        ninja
        gnumake
        pkg-config
        sqlite
        jq
        jnv
      ];
    };

    fhsEnv = {
      enable = true;
      pkgs = [
        (pkgs.buildFHSEnv {
          name = "fhs-env";
          targetPkgs = pkgs:
            with pkgs; [
              cmake
              gcc
              glibc.dev
              gnumake
              libxml2.dev
              openssl.dev
              pkg-config
              zlib.dev
            ];
          runScript = pkgs.writeScript "fhs-entry" ''
            if [ $# -eq 0 ]; then
              exec "''${SHELL:-bash}"
            else
              exec "$@"
            fi
          '';
        })
      ];
    };
  };

  enabledPackages = lib.flatten (
    builtins.map
    (cat:
      if cat.enable
      then cat.pkgs
      else [])
    (builtins.attrValues categories)
  );
in {
  home.packages = enabledPackages;
  home.sessionPath = ["$HOME/.local/bin"];
}
