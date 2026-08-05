{pkgs, ...}: {
  # Desktop Graphical User Interface (GUI) Applications & Utilities
  home.packages = with pkgs; [
    # Terminal Emulators
    kitty

    # Web Browsers
    librewolf-bin
    qutebrowser
    chromium

    # Media & Graphics
    vlc
    mpv

    # Files , Document & PDF Viewers
    pcmanfm-qt
    zathura

    # System & Display Management GUIs
    nwg-displays
    process-viewer
  ];
}
