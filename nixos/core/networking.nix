{hostname, ...}: {
  networking = {
    hostName = hostname;
    nftables.enable = true;

    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
    };
  };
}
