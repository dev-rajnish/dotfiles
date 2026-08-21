{ config,  lib, 
  pkgs,
  env,
  ...
}:
let
  cfg = config.mySystem.system.networking;
in {
  options.mySystem.system.networking = {
    enable = lib.mkEnableOption "networking config";
  };

  config = lib.mkIf cfg.enable (
    {
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

    # Optional: Systemd-Resolved DNS-over-TLS (Uncomment to enable secure encrypted DNS)
    # services.resolved = {
    #   enable = true;
    #   dnssec = "allow-downgrade";
    #   domains = [ "~." ];
    #   fallbackDns = [ "1.1.1.1" "9.9.9.9" ];
    #   extraConfig = ''
    #     DNSOverTLS=yes
    #   '';
    # };

    # -------------------------------------------------------------------------
    # 🛡️ Firewall & Open Ports (Configured via env/features.toml)
    # -------------------------------------------------------------------------
    firewall = {
      enable = env.enableFirewall; # Controlled dynamically via env/features.toml

      # Inbound TCP Ports
      allowedTCPPorts = [
        # 22    # SSH Remote Shell
        # 80    # HTTP Web Server
        # 443   # HTTPS Secure Web Server
        # 53317 # LocalSend File Sharing
        # 8384  # Syncthing Web GUI
        # 22000 # Syncthing Sync Listening
      ];

      # Inbound UDP Ports
      allowedUDPPorts = [
        # 53317 # LocalSend Discovery
        # 22000 # Syncthing Sync Listening
        # 21027 # Syncthing Local Discovery
        # 51820 # WireGuard VPN Default Port
      ];

      # Inbound Port Ranges
      # allowedTCPPortRanges = [ { from = 8000; to = 8080; } ];
      # allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

      # Allow ping packets (ICMP echo requests)
      allowPing = true;
    };

    # -------------------------------------------------------------------------
    # 🔒 VPN Subsystems (DISABLED / Templates)
    # -------------------------------------------------------------------------
    # WireGuard VPN Interface Example (Commented Out)
    # wireguard.interfaces = {
    #   wg0 = {
    #     ips = [ "10.100.0.2/24" ];
    #     listenPort = 51820;
    #     privateKeyFile = "/root/wireguard-keys/private.key";
    #     peers = [
    #       {
    #         publicKey = "<SERVER_PUBLIC_KEY>";
    #         allowedIPs = [ "0.0.0.0/0" "::/0" ];
    #         endpoint = "vpn.example.com:51820";
    #         persistentKeepalive = 25;
    #       }
    #     ];
    #   };
    # };

    # -------------------------------------------------------------------------
    # 🌐 Proxy & Custom Host Overrides (DISABLED / Templates)
    # -------------------------------------------------------------------------
    # proxy.default = "http://127.0.0.1:7890";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # extraHosts = ''
    #   127.0.0.1 mylocaldev.local
    # '';
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
  );
}
