# =============================================================================
#  Home Manager User Packages Module
#  Auto-generated from tokens/pkgs/hm-pkgs.toml via MiniJinja (bin/pkg-render)
# =============================================================================
{
  pkgs,
  env,
  ...
}: {
  home-manager.users.${env.username} = {
    home.packages = with pkgs; [
      # cliCore
      neovim
      yazi
      fd
      fzf
      tree-sitter
      # cliMonitoring
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
      # cliFileOps
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
      # cliArchive
      ouch
      p7zip
      unrar
      zip
      # cliShells
      fish
      # cliVisuals
      cava
      cbonsai
      cmatrix
      glow
      zellij
      # cliMedia
      gpu-screen-recorder
      imv
      # cliHardware
      android-tools
      # guiBrowsers
      google-chrome
      # guiEditors
      vscodium-fhs
      antigravity-fhs
      zed-editor-fhs
      # guiMedia
      mpv
      pwvucontrol
      # guiDocuments
      readest
      zathura
      # guiDesktopUtils
      kitty
      handlr-regex
      nwg-displays
      file-roller
      seahorse
      (nemo-with-extensions.override {extensions = [nemo-fileroller nemo-emblems nemo-python];})
      # windowManager
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
      # virtualization
      appimage-run
      squashfsTools
      distrobox
      usbredir
      usbutils
      virt-viewer
      virtiofsd
      # programmingLang
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
      # devPkg
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
    programs.home-manager.enable = true;
    programs.nix-index.enable = true;
    programs.man.enable = false;
    manual.manpages.enable = false;
  };
}
