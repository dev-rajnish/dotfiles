# =============================================================================
#  XDG Default Applications & MIME Type Associations
# =============================================================================
{
  config,
  pkgs,
  browser,
  fileManager,
  pdfViewer,
  videoPlayer,
  audioPlayer,
  imageViewer,
  ...
}: let
  # Default Desktop Application Handlers (Populated dynamically from 0-var.nix)
  defaultBrowser = "${browser}.desktop";
  defaultPdfViewer = "${pdfViewer}.desktop";
  defaultFileManager = "${fileManager}.desktop";
  defaultVideoPlayer = "${videoPlayer}.desktop";
  defaultAudioPlayer = "${audioPlayer}.desktop";
  defaultImageViewer = "${imageViewer}.desktop";
in {
  # ---------------------------------------------------------------------------
  # 🖼️ Desktop Entry Overrides (Unhide IMV in Application Launcher)
  # ---------------------------------------------------------------------------
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

  # ---------------------------------------------------------------------------
  # 📄 XDG Default MIME Type Associations (Single Source of Truth: 0-var.nix)
  # ---------------------------------------------------------------------------
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Web Browsers & URL Schemes
      "text/html" = defaultBrowser;
      "text/xml" = defaultBrowser;
      "application/xhtml+xml" = defaultBrowser;
      "x-scheme-handler/http" = defaultBrowser;
      "x-scheme-handler/https" = defaultBrowser;
      "x-scheme-handler/about" = defaultBrowser;
      "x-scheme-handler/unknown" = defaultBrowser;

      # PDF & Document Viewers
      "application/pdf" = defaultPdfViewer;
      "application/postscript" = defaultPdfViewer;
      "application/epub+zip" = defaultPdfViewer;

      # File Manager & Directories
      "inode/directory" = defaultFileManager;

      # Video Players
      "video/mp4" = defaultVideoPlayer;
      "video/mkv" = defaultVideoPlayer;
      "video/webm" = defaultVideoPlayer;
      "video/x-matroska" = defaultVideoPlayer;
      "video/avi" = defaultVideoPlayer;
      "video/quicktime" = defaultVideoPlayer;

      # Audio Players
      "audio/mpeg" = defaultAudioPlayer;
      "audio/mp3" = defaultAudioPlayer;
      "audio/flac" = defaultAudioPlayer;
      "audio/wav" = defaultAudioPlayer;
      "audio/ogg" = defaultAudioPlayer;
      "audio/aac" = defaultAudioPlayer;

      # Image Viewers
      "image/jpeg" = defaultImageViewer;
      "image/png" = defaultImageViewer;
      "image/gif" = defaultImageViewer;
      "image/webp" = defaultImageViewer;
      "image/svg+xml" = defaultImageViewer;

      # Archive Handlers
      "application/zip" = defaultFileManager;
      "application/x-tar" = defaultFileManager;
      "application/x-gzip" = defaultFileManager;
      "application/x-7z-compressed" = defaultFileManager;
      "application/x-rar" = defaultFileManager;
    };
  };
}
