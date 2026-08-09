{config, ...}: let
  browser = "zen-beta.desktop";
  pdfViewer = "org.pwmt.zathura.desktop";
  fileManager = "pcmanfm-qt.desktop";
  videoPlayer = "mpv.desktop";
  audioPlayer = "vlc.desktop";
  imageViewer = "imv.desktop";
in {
  # Override imv.desktop (upstream sets NoDisplay=true by default) so it appears in Fuzzel
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
      # Web & Web Schemes
      "text/html" = browser;
      "text/xml" = browser;
      "application/xhtml+xml" = browser;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/about" = browser;
      "x-scheme-handler/unknown" = browser;

      # Documents & PDF
      "application/pdf" = pdfViewer;
      "application/postscript" = pdfViewer;
      "application/epub+zip" = pdfViewer;

      # File Manager & Directories
      "inode/directory" = fileManager;

      # Video Formats
      "video/mp4" = videoPlayer;
      "video/mkv" = videoPlayer;
      "video/webm" = videoPlayer;
      "video/x-matroska" = videoPlayer;
      "video/avi" = videoPlayer;
      "video/quicktime" = videoPlayer;

      # Audio Formats
      "audio/mpeg" = audioPlayer;
      "audio/mp3" = audioPlayer;
      "audio/flac" = audioPlayer;
      "audio/wav" = audioPlayer;
      "audio/ogg" = audioPlayer;
      "audio/aac" = audioPlayer;

      # Image Formats
      "image/jpeg" = imageViewer;
      "image/png" = imageViewer;
      "image/gif" = imageViewer;
      "image/webp" = imageViewer;
      "image/svg+xml" = imageViewer;

      # Archive Formats
      "application/zip" = fileManager;
      "application/x-tar" = fileManager;
      "application/x-gzip" = fileManager;
      "application/x-7z-compressed" = fileManager;
      "application/x-rar" = fileManager;
    };
  };
}
