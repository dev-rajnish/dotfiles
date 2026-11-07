{
  config,
  lib,
  pkgs,
  env,
  ...
}: {
  networking = {
    # -------------------------------------------------------------------------
    # 🏷️ System Hostname
    # -------------------------------------------------------------------------
    hostName = env.hostname;

    # -------------------------------------------------------------------------
    # 📶 Wi-Fi & Network Interface Management (HIGH-SPEED ZERO-PROBE BOOT)
    # -------------------------------------------------------------------------
    networkmanager = {
      enable = true;
      wifi.backend = "iwd"; # Ultra-fast sub-30ms startup over wpa_supplicant
      wifi.powersave = false; # Max Wi-Fi performance immediately, no power-save lag
      wifi.scanRandMacAddress = false; # Fast scan on known networks without MAC randomization overhead
      settings = {
        main = {
          dhcp = "internal";
          no-auto-default = "*";
        };
        connectivity = {
          enabled = false;
        };
        device = {
          "wifi.scan-rand-mac-address" = false;
        };
      };
    };

    # Disable standalone dhcpcd (NetworkManager manages DHCP internally)
    dhcpcd.enable = false;

    # Modern Linux NFTables Packet Filtering Engine
    nftables.enable = true;

    # -------------------------------------------------------------------------
    # 🌐 DNS Configuration (Configured Upfront - No Dynamic Probing)
    # -------------------------------------------------------------------------
    # High-performance, privacy-first DNS resolvers (Cloudflare & Google)
    nameservers = [
      "1.1.1.1" # Cloudflare Primary
      "1.0.0.1" # Cloudflare Secondary
      "8.8.8.8" # Google DNS Primary
      "8.8.4.4" # Google DNS Secondary
    ];

    # -------------------------------------------------------------------------
    # 🛡️ Firewall & Open Ports (Configured via env/features.toml)
    # -------------------------------------------------------------------------
    firewall = {
      enable = env.enableFirewall; # Controlled dynamically via env/features.toml
      allowedTCPPorts = [];
      allowedUDPPorts = [];
      allowPing = true;
    };
  };

  # ---------------------------------------------------------------------------
  # 📡 Avahi mDNS / DNS-SD Network Discovery (ENABLED)
  # ---------------------------------------------------------------------------
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ---------------------------------------------------------------------------
  # 🚀 Tailscale Mesh VPN Daemon (Configured via env/features.toml)
  # ---------------------------------------------------------------------------
  services.tailscale = {
    enable = env.enableTailscale;
    useRoutingFeatures = "client";
  };

  # ---------------------------------------------------------------------------
  # ⚡ Fast Boot: Disable wait-online services (Never block boot for IP/link)
  # ---------------------------------------------------------------------------
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;
}
