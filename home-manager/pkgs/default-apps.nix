{
  config,
  pkgs,
  ...
}: let
  browser = "zen-beta.desktop";
  pdfViewer = "org.pwmt.zathura.desktop";
  fileManager = "pcmanfm-qt.desktop";
  videoPlayer = "mpv.desktop";
  audioPlayer = "vlc.desktop";
  imageViewer = "imv.desktop";

  # PlainApp PWA Hotspot Script & Launcher
  plainAppName = "plainapp";
  plainAppScript = pkgs.writeShellScriptBin plainAppName ''
    gateway_ip=$(ip route show | awk '/default/ {print $3}')

    if [ -z "$gateway_ip" ]; then
      notify-send "PlainApp Error" "Not connected to phone hotspot!"
      exit 1
    fi

    exec zen-beta \
      "https://$gateway_ip:8443"
  '';

  plainAppDesktop = pkgs.makeDesktopItem {
    name = plainAppName;
    desktopName = "PlainApp";
    exec = "${plainAppScript}/bin/${plainAppName}";
    icon = "mobile";
    categories = ["Network" "Utility"];
  };
in {
  home.packages = [
    plainAppScript
    plainAppDesktop
  ];

  # Override imv.desktop to unhide
  # in application launcher
  xdg.desktopEntries.imv = {
    name = "imv";
    genericName = "Image Viewer";
    comment = "Fast Image Viewer";
    exec = "imv %F";
    icon = "multimedia-photo-viewer";
    terminal = false;
    categories = ["Graphics" "2DGraphics" "Viewer"];
    mimeType = [
      "image/png"
      "image/jpeg"
      "image/jpg"
      "image/gif"
      "image/webp"
      "image/svg+xml"
      "image/bmp"
      "image/tiff"
      "image/avif"
      "image/heif"
      "image/jxl"
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Web Browsers
      "text/html" = browser;
      "text/xml" = browser;
      "application/xhtml+xml" = browser;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/about" = browser;
      "x-scheme-handler/unknown" = browser;

      # PDF & Documents
      "application/pdf" = pdfViewer;
      "application/postscript" = pdfViewer;
      "application/epub+zip" = pdfViewer;

      # File Manager
      "inode/directory" = fileManager;

      # Video Players
      "video/mp4" = videoPlayer;
      "video/mkv" = videoPlayer;
      "video/webm" = videoPlayer;
      "video/x-matroska" = videoPlayer;
      "video/avi" = videoPlayer;
      "video/quicktime" = videoPlayer;

      # Audio Players
      "audio/mpeg" = audioPlayer;
      "audio/mp3" = audioPlayer;
      "audio/flac" = audioPlayer;
      "audio/wav" = audioPlayer;
      "audio/ogg" = audioPlayer;
      "audio/aac" = audioPlayer;

      # Image Viewers
      "image/jpeg" = imageViewer;
      "image/png" = imageViewer;
      "image/gif" = imageViewer;
      "image/webp" = imageViewer;
      "image/svg+xml" = imageViewer;

      # Archive Managers
      "application/zip" = fileManager;
      "application/x-tar" = fileManager;
      "application/x-gzip" = fileManager;
      "application/x-7z-compressed" = fileManager;
      "application/x-rar" = fileManager;
    };
  };
}
