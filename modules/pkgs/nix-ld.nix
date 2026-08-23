# =============================================================================
#  nix-ld Dynamic Linker Libraries Module
#  Auto-generated from tokens/pkgs/nix-ld.toml via MiniJinja (bin/pkg-render)
# =============================================================================
{pkgs, ...}: {
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
