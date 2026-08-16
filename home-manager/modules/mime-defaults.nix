# =============================================================================
#  XDG Default Applications & MIME Type Associations
# =============================================================================
{
  config,
  pkgs,
  lib,
  editor,
  browser,
  fileManager,
  pdfViewer,
  videoPlayer,
  audioPlayer,
  imageViewer,
  ...
}: let
  toDesktop = app:
    if lib.hasSuffix ".desktop" app
    then app
    else "${app}.desktop";

  # Default Desktop Application Handlers (Populated dynamically from 0-system-vars.nix)
  defaultEditor = toDesktop editor;
  defaultBrowser = toDesktop browser;
  defaultPdfViewer = toDesktop pdfViewer;
  defaultFileManager = toDesktop fileManager;
  defaultVideoPlayer = toDesktop videoPlayer;
  defaultAudioPlayer = toDesktop audioPlayer;
  defaultImageViewer = toDesktop imageViewer;
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
      # 📝 Text, Code, Dotfiles & Programming Languages (nvim.desktop)
      "text/plain" = defaultEditor;
      "text/markdown" = defaultEditor;
      "text/x-markdown" = defaultEditor;
      "text/x-log" = defaultEditor;
      "text/x-patch" = defaultEditor;
      "text/x-diff" = defaultEditor;
      "text/x-readme" = defaultEditor;
      "text/x-changelog" = defaultEditor;
      "text/x-copying" = defaultEditor;
      "text/x-install" = defaultEditor;
      "text/x-setext" = defaultEditor;
      "text/x-bibtex" = defaultEditor;
      "text/x-authors" = defaultEditor;
      "text/english" = defaultEditor;
      "text/troff" = defaultEditor;
      "text/uri-list" = defaultEditor;
      "text/richtext" = defaultEditor;
      "text/csv" = defaultEditor;
      "text/tab-separated-values" = defaultEditor;
      "text/spreadsheet" = defaultEditor;

      # Config, Serialization & Dotfiles (JSON, YAML, TOML, XML, INI, ENV)
      "application/json" = defaultEditor;
      "application/x-json" = defaultEditor;
      "application/x-ndjson" = defaultEditor;
      "application/manifest+json" = defaultEditor;
      "application/schema+json" = defaultEditor;
      "application/yaml" = defaultEditor;
      "application/x-yaml" = defaultEditor;
      "text/yaml" = defaultEditor;
      "text/x-yaml" = defaultEditor;
      "application/toml" = defaultEditor;
      "application/x-toml" = defaultEditor;
      "text/toml" = defaultEditor;
      "text/x-toml" = defaultEditor;
      "application/xml" = defaultEditor;
      "application/x-xml" = defaultEditor;
      "text/xml" = defaultEditor;
      "application/x-ini" = defaultEditor;
      "text/x-ini" = defaultEditor;
      "application/x-config" = defaultEditor;
      "text/x-config" = defaultEditor;
      "text/x-env" = defaultEditor;

      # Shell Scripts & Shell Configs
      "application/x-shellscript" = defaultEditor;
      "application/x-sh" = defaultEditor;
      "application/x-bash" = defaultEditor;
      "application/x-zsh" = defaultEditor;
      "application/x-fishscript" = defaultEditor;
      "text/x-shellscript" = defaultEditor;
      "text/x-script.sh" = defaultEditor;
      "text/x-fish" = defaultEditor;
      "text/x-zsh" = defaultEditor;

      # C / C++ / C# / D
      "text/x-c" = defaultEditor;
      "text/x-csrc" = defaultEditor;
      "text/x-chdr" = defaultEditor;
      "text/x-c++" = defaultEditor;
      "text/x-c++src" = defaultEditor;
      "text/x-c++hdr" = defaultEditor;
      "text/x-csharp" = defaultEditor;
      "text/x-dsrc" = defaultEditor;

      # Python / Ruby / Perl / PHP / Lua
      "text/x-python" = defaultEditor;
      "text/x-python3" = defaultEditor;
      "text/x-script.python" = defaultEditor;
      "application/x-python-code" = defaultEditor;
      "text/x-ruby" = defaultEditor;
      "application/x-ruby" = defaultEditor;
      "text/x-perl" = defaultEditor;
      "application/x-perl" = defaultEditor;
      "text/x-php" = defaultEditor;
      "application/x-php" = defaultEditor;
      "text/x-lua" = defaultEditor;
      "application/x-lua" = defaultEditor;

      # Rust / Go / Zig / Nix
      "text/rust" = defaultEditor;
      "text/x-rust" = defaultEditor;
      "text/x-rustsrc" = defaultEditor;
      "application/rls-services+xml" = defaultEditor;
      "text/x-go" = defaultEditor;
      "text/x-golang" = defaultEditor;
      "text/x-zig" = defaultEditor;
      "text/x-nix" = defaultEditor;
      "application/x-nix" = defaultEditor;

      # JavaScript / TypeScript / Web Development Styles
      "text/javascript" = defaultEditor;
      "application/javascript" = defaultEditor;
      "application/x-javascript" = defaultEditor;
      "text/typescript" = defaultEditor;
      "application/typescript" = defaultEditor;
      "text/x-typescript" = defaultEditor;
      "application/x-typescript" = defaultEditor;
      "text/jsx" = defaultEditor;
      "text/tsx" = defaultEditor;
      "application/x-tiled-tsx" = defaultEditor;
      "text/css" = defaultEditor;
      "text/x-scss" = defaultEditor;
      "text/x-sass" = defaultEditor;
      "text/x-less" = defaultEditor;

      # Java / Kotlin / Scala / Functional Languages
      "text/x-java" = defaultEditor;
      "text/x-java-source" = defaultEditor;
      "text/x-kotlin" = defaultEditor;
      "text/x-scala" = defaultEditor;
      "text/x-haskell" = defaultEditor;
      "text/x-ocaml" = defaultEditor;
      "text/x-erlang" = defaultEditor;
      "text/x-elixir" = defaultEditor;
      "text/x-clojure" = defaultEditor;
      "text/x-lisp" = defaultEditor;
      "text/x-scheme" = defaultEditor;
      "text/x-rsrc" = defaultEditor;
      "text/x-r" = defaultEditor;
      "text/x-julia" = defaultEditor;

      # Build Systems, Databases, Assembly & System Units
      "text/x-makefile" = defaultEditor;
      "text/x-cmake" = defaultEditor;
      "text/x-meson" = defaultEditor;
      "text/x-sql" = defaultEditor;
      "application/sql" = defaultEditor;
      "application/x-sql" = defaultEditor;
      "text/x-assembly" = defaultEditor;
      "text/x-asm" = defaultEditor;
      "text/x-systemd-unit" = defaultEditor;
      "text/x-dockerfile" = defaultEditor;

      # Empty & Unspecified Text Files
      "inode/x-empty" = defaultEditor;
      "application/x-zerosize" = defaultEditor;

      # 🌐 Web Browsers & URL Schemes (librewolf.desktop)
      "text/html" = defaultBrowser;
      "application/xhtml+xml" = defaultBrowser;
      "x-scheme-handler/http" = defaultBrowser;
      "x-scheme-handler/https" = defaultBrowser;
      "x-scheme-handler/about" = defaultBrowser;
      "x-scheme-handler/unknown" = defaultBrowser;
      "x-scheme-handler/chrome" = defaultBrowser;
      "x-scheme-handler/ftp" = defaultBrowser;

      # 📄 PDF & Document Viewers (org.pwmt.zathura.desktop)
      "application/pdf" = defaultPdfViewer;
      "application/x-pdf" = defaultPdfViewer;
      "application/postscript" = defaultPdfViewer;
      "application/epub+zip" = defaultPdfViewer;
      "application/oxps" = defaultPdfViewer;
      "application/vnd.comicbook+zip" = defaultPdfViewer;
      "application/vnd.comicbook-rar" = defaultPdfViewer;
      "application/x-cbr" = defaultPdfViewer;
      "application/x-cbz" = defaultPdfViewer;
      "application/x-djvu" = defaultPdfViewer;
      "image/vnd.djvu" = defaultPdfViewer;
      "application/x-mobipocket-ebook" = defaultPdfViewer;
      "application/vnd.amazon.ebook" = defaultPdfViewer;
      "application/vnd.amazon.mobi8-ebook" = defaultPdfViewer;
      "application/x-fictionbook+xml" = defaultPdfViewer;

      # 📁 File Manager & Directories (pcmanfm-qt.desktop)
      "inode/directory" = defaultFileManager;

      # 🎬 Video Players (mpv.desktop)
      "video/mp4" = defaultVideoPlayer;
      "video/mkv" = defaultVideoPlayer;
      "video/webm" = defaultVideoPlayer;
      "video/x-matroska" = defaultVideoPlayer;
      "video/avi" = defaultVideoPlayer;
      "video/x-msvideo" = defaultVideoPlayer;
      "video/quicktime" = defaultVideoPlayer;
      "video/x-flv" = defaultVideoPlayer;
      "video/x-ms-wmv" = defaultVideoPlayer;
      "video/mpeg" = defaultVideoPlayer;
      "video/ogg" = defaultVideoPlayer;
      "video/3gpp" = defaultVideoPlayer;
      "video/3gpp2" = defaultVideoPlayer;
      "video/x-ogm+ogg" = defaultVideoPlayer;
      "video/mp2t" = defaultVideoPlayer;
      "video/vnd.avi" = defaultVideoPlayer;
      "video/divx" = defaultVideoPlayer;
      "video/x-theora+ogg" = defaultVideoPlayer;
      "video/x-anim" = defaultVideoPlayer;

      # 🎵 Audio Players (vlc.desktop)
      "audio/mpeg" = defaultAudioPlayer;
      "audio/mp3" = defaultAudioPlayer;
      "audio/flac" = defaultAudioPlayer;
      "audio/wav" = defaultAudioPlayer;
      "audio/x-wav" = defaultAudioPlayer;
      "audio/ogg" = defaultAudioPlayer;
      "audio/x-ogg" = defaultAudioPlayer;
      "audio/aac" = defaultAudioPlayer;
      "audio/m4a" = defaultAudioPlayer;
      "audio/x-m4a" = defaultAudioPlayer;
      "audio/opus" = defaultAudioPlayer;
      "audio/x-matroska" = defaultAudioPlayer;
      "audio/webm" = defaultAudioPlayer;
      "audio/mp4" = defaultAudioPlayer;
      "audio/x-flac" = defaultAudioPlayer;
      "audio/x-vorbis+ogg" = defaultAudioPlayer;
      "audio/x-speex" = defaultAudioPlayer;
      "audio/midi" = defaultAudioPlayer;
      "audio/x-midi" = defaultAudioPlayer;

      # 🖼️ Image Viewers (imv.desktop)
      "image/jpeg" = defaultImageViewer;
      "image/png" = defaultImageViewer;
      "image/gif" = defaultImageViewer;
      "image/webp" = defaultImageViewer;
      "image/svg+xml" = defaultImageViewer;
      "image/bmp" = defaultImageViewer;
      "image/x-bmp" = defaultImageViewer;
      "image/x-ms-bmp" = defaultImageViewer;
      "image/tiff" = defaultImageViewer;
      "image/avif" = defaultImageViewer;
      "image/heif" = defaultImageViewer;
      "image/heic" = defaultImageViewer;
      "image/jxl" = defaultImageViewer;
      "image/x-icon" = defaultImageViewer;
      "image/vnd.microsoft.icon" = defaultImageViewer;
      "image/x-tga" = defaultImageViewer;
      "image/x-portable-pixmap" = defaultImageViewer;
      "image/x-portable-bitmap" = defaultImageViewer;
      "image/x-portable-graymap" = defaultImageViewer;

      # 📦 Archive Handlers & Compressed Files (pcmanfm-qt.desktop)
      "application/zip" = defaultFileManager;
      "application/x-zip" = defaultFileManager;
      "application/x-zip-compressed" = defaultFileManager;
      "application/x-tar" = defaultFileManager;
      "application/x-gzip" = defaultFileManager;
      "application/gzip" = defaultFileManager;
      "application/x-bzip" = defaultFileManager;
      "application/x-bzip2" = defaultFileManager;
      "application/x-bzip-compressed-tar" = defaultFileManager;
      "application/x-xz" = defaultFileManager;
      "application/x-xz-compressed-tar" = defaultFileManager;
      "application/x-7z-compressed" = defaultFileManager;
      "application/x-rar" = defaultFileManager;
      "application/x-rar-compressed" = defaultFileManager;
      "application/x-compressed-tar" = defaultFileManager;
      "application/zstd" = defaultFileManager;
      "application/x-zstd" = defaultFileManager;
      "application/x-zstd-compressed-tar" = defaultFileManager;
      "application/x-cpio" = defaultFileManager;
      "application/x-iso9660-image" = defaultFileManager;
      "application/x-archive" = defaultFileManager;
    };
  };
}
