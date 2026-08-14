# =============================================================================
#  System-wide Programs, nix-ld Dynamic Linker & Core Services
# =============================================================================
{
  pkgs,
  pkgList,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 1. 🌐 System-wide Environment Variables
  # ---------------------------------------------------------------------------
  environment.variables = {
    MAN_DISABLE_CACHE = 1; # Disable man cache regeneration for faster rebuilds
  };

  # ---------------------------------------------------------------------------
  # 2. ❄️ System-wide Core Packages (Imported from pkg-list.nix -> systemCore)
  # ---------------------------------------------------------------------------
  environment.systemPackages = (pkgList pkgs).systemCore;

  # ---------------------------------------------------------------------------
  # 3. 🛠️ System Program Enablements & Integrations
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
  # 4. 🐚 Provide /bin/bash for scripts with hardcoded #!/bin/bash shebangs
  # ---------------------------------------------------------------------------
  system.activationScripts.binbash = {
    text = ''
      mkdir -m 0755 -p /bin
      ln -sfn ${pkgs.bash}/bin/bash /bin/bash
    '';
  };

  # ---------------------------------------------------------------------------
  # 5. 📡 System Service Enablements
  # ---------------------------------------------------------------------------
  services = {
    # Display Manager (Commented out for manual clean TTY login)
    # displayManager = {
    #   defaultSession = "niri";
    #   ly.enable = true;
    # };

    # Avahi mDNS / DNS-SD Network Discovery
    avahi.enable = true;
  };
}
