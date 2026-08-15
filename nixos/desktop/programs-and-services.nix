# =============================================================================
#  System-wide Programs, nix-ld Dynamic Linker & Core Services
# =============================================================================
{
  pkgs,
  pkgList,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🌐 System-wide Environment Variables
  # ---------------------------------------------------------------------------
  environment.variables = {
    MAN_DISABLE_CACHE = 1; # Disable man cache regeneration for faster rebuilds
  };

  # ---------------------------------------------------------------------------
  # ❄️ System-wide Core Packages (Imported from pkg-list.nix -> systemCore)
  # ---------------------------------------------------------------------------
  environment.systemPackages = (pkgList pkgs).systemCore;

  # ---------------------------------------------------------------------------
  # 🔤 System Fonts & Typography (Imported from pkg-list.nix -> fonts)
  # ---------------------------------------------------------------------------
  fonts = {
    fontconfig.enable = true;
    fontDir.enable = true;
    packages = (pkgList pkgs).fonts;
  };

  # ---------------------------------------------------------------------------
  # 🛠️ System Program Enablements & Integrations
  # ---------------------------------------------------------------------------
  programs = {
    # Nix Helper CLI (`nh os switch`, etc.)
    nh.enable = true;

    # Niri Wayland Compositor Session
    niri.enable = true;

    # LocalSend Local File Sharing Protocol
    localsend.enable = true;

    # Dynamic Linker for unpatched ELF binaries (Mason LSPs, formatters, npm)
    nix-ld = {
      enable = true;
      libraries = (pkgList pkgs).nixLd;
    };

    # Direnv shell environment loader
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  # ---------------------------------------------------------------------------
  # 🐚 Provide /bin/bash for scripts with hardcoded #!/bin/bash shebangs
  # ---------------------------------------------------------------------------
  system.activationScripts.binbash = {
    text = ''
      mkdir -m 0755 -p /bin
      ln -sfn ${pkgs.bash}/bin/bash /bin/bash
    '';
  };
}
