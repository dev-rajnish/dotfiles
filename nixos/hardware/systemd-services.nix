{
  systemd.services."systemd-backlight@".enable = false;
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "3s";
  };
}
