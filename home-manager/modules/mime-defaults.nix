# =============================================================================
#  XDG Default Applications & MIME Type Associations
# =============================================================================
{
  config,
  pkgs,
  lib,
  env,
  ...
}: let
  toDesktop = app:
    if lib.hasSuffix ".desktop" app
    then app
    else "${app}.desktop";

  # Default Desktop Application Handlers (Populated dynamically from env/apps.toml)
  defaultEditor = toDesktop env.editor;
  defaultBrowser = toDesktop env.browser;
  defaultPdfViewer = toDesktop env.pdfViewer;
  defaultFileManager = toDesktop env.fileManager;
  defaultVideoPlayer = toDesktop env.videoPlayer;
  defaultAudioPlayer = toDesktop env.audioPlayer;
  defaultImageViewer = toDesktop env.imageViewer;

  # Mappings from Application Handler -> List of MIME types
  mimeMap = {
    # 📝 Text, Code, Serialization & Dotfiles (nvim.desktop)
    "${defaultEditor}" = [
      "text/plain"
      "text/markdown"
      "text/x-markdown"
      "text/x-log"
      "text/x-patch"
      "text/x-diff"
      "text/x-readme"
      "text/x-changelog"
      "text/x-copying"
      "text/x-install"
      "text/x-setext"
      "text/x-bibtex"
      "text/x-authors"
      "text/english"
      "text/troff"
      "text/uri-list"
      "text/richtext"
      "text/csv"
      "text/tab-separated-values"
      "text/spreadsheet"

      # Config, Serialization & Dotfiles
      "application/json"
      "application/x-json"
      "application/x-ndjson"
      "application/manifest+json"
      "application/schema+json"
      "application/yaml"
      "application/x-yaml"
      "text/yaml"
      "text/x-yaml"
      "application/toml"
      "application/x-toml"
      "text/toml"
      "text/x-toml"
      "application/xml"
      "application/x-xml"
      "text/xml"
      "application/x-ini"
      "text/x-ini"
      "application/x-config"
      "text/x-config"
      "text/x-env"

      # Shell Scripts & Shell Configs
      "application/x-shellscript"
      "application/x-sh"
      "application/x-bash"
      "application/x-zsh"
      "application/x-fishscript"
      "text/x-shellscript"
      "text/x-script.sh"
      "text/x-fish"
      "text/x-zsh"

      # Compiled, Scripting & Functional Languages
      "text/x-c"
      "text/x-csrc"
      "text/x-chdr"
      "text/x-c++"
      "text/x-c++src"
      "text/x-c++hdr"
      "text/x-csharp"
      "text/x-dsrc"
      "text/x-python"
      "text/x-python3"
      "text/x-script.python"
      "application/x-python-code"
      "text/x-ruby"
      "application/x-ruby"
      "text/x-perl"
      "application/x-perl"
      "text/x-php"
      "application/x-php"
      "text/x-lua"
      "application/x-lua"
      "text/rust"
      "text/x-rust"
      "text/x-rustsrc"
      "application/rls-services+xml"
      "text/x-go"
      "text/x-golang"
      "text/x-zig"
      "text/x-nix"
      "application/x-nix"

      # Web Development & Styles
      "text/javascript"
      "application/javascript"
      "application/x-javascript"
      "text/typescript"
      "application/typescript"
      "text/x-typescript"
      "application/x-typescript"
      "text/jsx"
      "text/tsx"
      "application/x-tiled-tsx"
      "text/css"
      "text/x-scss"
      "text/x-sass"
      "text/x-less"

      # Java / Kotlin / Scala / Functional Languages
      "text/x-java"
      "text/x-java-source"
      "text/x-kotlin"
      "text/x-scala"
      "text/x-haskell"
      "text/x-ocaml"
      "text/x-erlang"
      "text/x-elixir"
      "text/x-clojure"
      "text/x-lisp"
      "text/x-scheme"
      "text/x-rsrc"
      "text/x-r"
      "text/x-julia"

      # Build Systems, Databases, Assembly & System Units
      "text/x-makefile"
      "text/x-cmake"
      "text/x-meson"
      "text/x-sql"
      "application/sql"
      "application/x-sql"
      "text/x-assembly"
      "text/x-asm"
      "text/x-systemd-unit"
      "text/x-dockerfile"

      # Empty & Unspecified Text Files
      "inode/x-empty"
      "application/x-zerosize"
    ];

    # 🌐 Web Browsers & URL Schemes (librewolf.desktop)
    "${defaultBrowser}" = [
      "text/html"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
      "x-scheme-handler/chrome"
      "x-scheme-handler/ftp"
    ];

    # 📄 PDF & Document Viewers (readest.desktop / zathura.desktop)
    "${defaultPdfViewer}" = [
      "application/pdf"
      "application/x-pdf"
      "application/postscript"
      "application/epub+zip"
      "application/oxps"
      "application/vnd.comicbook+zip"
      "application/vnd.comicbook-rar"
      "application/x-cbr"
      "application/x-cbz"
      "application/x-djvu"
      "image/vnd.djvu"
      "application/x-mobipocket-ebook"
      "application/vnd.amazon.ebook"
      "application/vnd.amazon.mobi8-ebook"
      "application/x-fictionbook+xml"
    ];

    # 📁 File Manager & Archive Handlers (thunar.desktop)
    "${defaultFileManager}" = [
      "inode/directory"
      "application/zip"
      "application/x-zip"
      "application/x-zip-compressed"
      "application/x-tar"
      "application/x-gzip"
      "application/gzip"
      "application/x-bzip"
      "application/x-bzip2"
      "application/x-bzip-compressed-tar"
      "application/x-xz"
      "application/x-xz-compressed-tar"
      "application/x-7z-compressed"
      "application/x-rar"
      "application/x-rar-compressed"
      "application/x-compressed-tar"
      "application/zstd"
      "application/x-zstd"
      "application/x-zstd-compressed-tar"
      "application/x-cpio"
      "application/x-iso9660-image"
      "application/x-archive"
    ];

    # 🎬 Video Players (mpv.desktop)
    "${defaultVideoPlayer}" = [
      "video/mp4"
      "video/mkv"
      "video/webm"
      "video/x-matroska"
      "video/avi"
      "video/x-msvideo"
      "video/quicktime"
      "video/x-flv"
      "video/x-ms-wmv"
      "video/mpeg"
      "video/ogg"
      "video/3gpp"
      "video/3gpp2"
      "video/x-ogm+ogg"
      "video/mp2t"
      "video/vnd.avi"
      "video/divx"
      "video/x-theora+ogg"
      "video/x-anim"
    ];

    # 🎵 Audio Players (vlc.desktop)
    "${defaultAudioPlayer}" = [
      "audio/mpeg"
      "audio/mp3"
      "audio/flac"
      "audio/wav"
      "audio/x-wav"
      "audio/ogg"
      "audio/x-ogg"
      "audio/aac"
      "audio/m4a"
      "audio/x-m4a"
      "audio/opus"
      "audio/x-matroska"
      "audio/webm"
      "audio/mp4"
      "audio/x-flac"
      "audio/x-vorbis+ogg"
      "audio/x-speex"
      "audio/midi"
      "audio/x-midi"
    ];

    # 🖼️ Image Viewers (imv.desktop)
    "${defaultImageViewer}" = [
      "image/jpeg"
      "image/png"
      "image/gif"
      "image/webp"
      "image/svg+xml"
      "image/bmp"
      "image/x-bmp"
      "image/x-ms-bmp"
      "image/tiff"
      "image/avif"
      "image/heif"
      "image/heic"
      "image/jxl"
      "image/x-icon"
      "image/vnd.microsoft.icon"
      "image/x-tga"
      "image/x-portable-pixmap"
      "image/x-portable-bitmap"
      "image/x-portable-graymap"
    ];
  };
in {
  # ---------------------------------------------------------------------------
  # 📄 XDG Default MIME Type Associations (Single Source of Truth: env/apps.toml)
  # ---------------------------------------------------------------------------
  xdg.mimeApps = {
    enable = true;
    defaultApplications = lib.concatMapAttrs (app: mimes: lib.genAttrs mimes (_: app)) mimeMap;
  };
}
