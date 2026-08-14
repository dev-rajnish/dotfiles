# =============================================================================
#  Networking & Firewall Configuration
# =============================================================================
{hostname, ...}: {
  networking = {
    # System Hostname
    hostName = hostname;

    # Modern Linux NFTables Packet Filtering Engine
    nftables.enable = true;

    # NetworkManager with WPA Supplicant Wi-Fi Backend
    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
    };
  };
}
