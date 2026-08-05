{config, ...}: {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Web & Web Schemes
      "text/html" = "librewolf.desktop";
      "text/xml" = "librewolf.desktop";
      "application/xhtml+xml" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";

      # Documents & PDF
      "application/pdf" = "org.pwmt.zathura.desktop";
      "application/postscript" = "org.pwmt.zathura.desktop";
      "application/epub+zip" = "org.pwmt.zathura.desktop";

      # File Manager & Directories
      "inode/directory" = "yazi.desktop";

      # Video Formats
      "video/mp4" = "io.github.celluloid_player.Celluloid.desktop";
      "video/mkv" = "io.github.celluloid_player.Celluloid.desktop";
      "video/webm" = "io.github.celluloid_player.Celluloid.desktop";
      "video/x-matroska" = "io.github.celluloid_player.Celluloid.desktop";
      "video/avi" = "io.github.celluloid_player.Celluloid.desktop";
      "video/quicktime" = "io.github.celluloid_player.Celluloid.desktop";

      # Audio Formats
      "audio/mpeg" = "vlc.desktop";
      "audio/mp3" = "vlc.desktop";
      "audio/flac" = "vlc.desktop";
      "audio/wav" = "vlc.desktop";
      "audio/ogg" = "vlc.desktop";
      "audio/aac" = "vlc.desktop";

      # Image Formats
      "image/jpeg" = "gimp.desktop";
      "image/png" = "imv";
      "image/gif" = "gimp.desktop";
      "image/webp" = "gimp.desktop";
      "image/svg+xml" = "gimp.desktop";

      # Archive Formats
      "application/zip" = "yazi.desktop";
      "application/x-tar" = "yazi.desktop";
      "application/x-gzip" = "yazi.desktop";
      "application/x-7z-compressed" = "yazi.desktop";
      "application/x-rar" = "yazi.desktop";
    };
  };
}
