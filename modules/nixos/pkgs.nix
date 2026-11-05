# =============================================================================
#  Host-Level Packages, Fonts & Dynamic Linker (modules/nixos/pkgs.nix)
# =============================================================================
{
  pkgs,
  lib,
  ...
}: let
  categories = {
    core = {
      enable = true;
      pkgs = with pkgs; [
        curl
        wget
        git
        home-manager
        just
        unzip
        seatd
        xwayland-satellite
        starship
        zoxide
        direnv
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
  # ---------------------------------------------------------------------------
  # 📦 System-Wide Core Packages
  # ---------------------------------------------------------------------------
  environment.systemPackages = enabledPackages;

  # ---------------------------------------------------------------------------
  # 🔤 Fonts & Typography
  # ---------------------------------------------------------------------------
  fonts = {
    fontconfig.enable = true;
    fontDir.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      inter
      noto-fonts-color-emoji
    ];
  };

  # ---------------------------------------------------------------------------
  # 🔗 nix-ld Dynamic Linker Libraries for Unpatched Binaries
  # ---------------------------------------------------------------------------
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      bzip2
      glibc
      stdenv.cc.cc.lib
      xz
      zlib
      zstd
      icu
      libxml2
      systemd
      util-linux
      libkrb5
      libpsl
      openssl
      curl
      nghttp2
      dbus
      glib
      libffi
      libGL
      libglvnd
      libxkbcommon
      mesa
      vulkan-loader
      wayland
      alsa-lib
      libpulseaudio
      fontconfig
      freetype
      expat
      nss
      nspr
      libuv
      fuse3
      libX11
      libXcursor
      libXext
      libXfixes
      libXi
      libXinerama
      libXrandr
      libXrender
      libXtst
      libxcb
    ];
  };
}
