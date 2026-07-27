{
  username,
  pkgs,
  ...
}: {
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.tmp.tmpfsHugeMemoryPages = "true";
  #boot.tmp.useTmpfs = true;
  services.udisks2.mountOnMedia = true;
  boot.tmp.useZram = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
  virtualisation.podman.enable = true;
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.kmscon = {
    enable = true;
    fonts = [
      {
        name = "Source Code Pro";
        package = pkgs.source-code-pro;
      }
    ];
    extraOptions = "--term xterm-256color";
  };

  services = {
    libinput.enable = true; # default true

    #getty.autologinUser = "${username}";

    fstrim.enable = true;

    #logind.powerKey = "ignore";

    #timesyncd.enable = true;

    udisks2.enable = true;

    upower.enable = true;

    power-profiles-daemon.enable = false;
    tlp.enable = true;
    tlp.pd.enable = true;
    tlp.settings = {
      #CPU_SCALING_GOVERNOR_ON_AC = "performanec";
      #CPU_SCALING_GOVERNOR_ON_BAT = "balanced";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 85;
    };


    #printing.enable = true;

    #blueman.enable = true;
  };

  # sound service
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
    #media-session.enable = true;
  };

  services.journald.extraConfig = ''
    SystemMaxUse=100M
    RuntimeMaxUse=50M
    MaxRetentionSec=1month
  '';
}
