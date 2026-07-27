{
  system = "x86_64-linux";

  username = "rsh";
  hostname = "nixos";

  # Keyboard Path
  keyboardPath = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";

  # GitHub Details
  ghUsername = "dev-rajnish";
  ghEmail = "dev.rajnish@proton.me";

  # NixOS & Home Manager State Versions
  systemVersion = "26.05";
  homeVersion = "26.05";
}
