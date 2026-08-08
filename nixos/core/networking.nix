{hostname, ...}: {
  networking = {
    hostName = hostname;

    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
    };
  };
  services.avahi.enable = true;
}
