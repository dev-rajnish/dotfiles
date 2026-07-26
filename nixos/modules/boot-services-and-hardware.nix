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
  zramSwap.enable = true;
  #zramSwap.memoryPercent = 50;
  zramSwap.algorithm = "zstd";
  zramSwap.memoryPercent = 50;
  virtualisation.podman.enable = true;
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
 services.kmscon.enable = true;
   services.kmscon.fonts = [ { name = "Source Code Pro"; package = pkgs.source-code-pro; } ];
    services.kmscon.extraOptions = "--term xterm-256color";
      services.kmscon.package = pkgs.kmscon;
  services = {
    libinput.enable = true; # default true

    #getty.autologinUser = "${username}";

    fstrim.enable = true;

    #logind.powerKey = "ignore";

    #timesyncd.enable = true;

    udisks2.enable = true;

    upower.enable = true;

    #tlp.enable = true;

    printing.enable = true;

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

  # hardware services
  hardware = {
    uinput.enable = true;
  };

  ### Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;
 services.displayManager.sddm.enable = true;
  ### DisplayManager
  services.displayManager.sddm.wayland.enable = true;
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "${username}";

  services.journald.extraConfig = ''
    SystemMaxUse=100M
    RuntimeMaxUse=50M
    MaxRetentionSec=1month
  '';
}
