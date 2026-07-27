{pkgs, ...}: {
  stylix = {
    enable = true;
    #autoEnable = true;

    # helios, jabuti, tender, darkmoss, codeschool
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

    # Default background wallpaper
    #image = pkgs.runCommand "default-wallpaper.png" { buildInputs = [ pkgs.imagemagick ]; } ''
    #  convert -size 1920x1080 canvas:'#1e1e2e' $out
    #'';
    targets.firefox.profileNames = ["default"];
    #targets.wofi.enable = true;
    #targets.swaync.enable = true;
    #targets.kitty.variant256Colors = true;

    cursor.size = 32;
    cursor.name = "Bibata-Modern-Ice";
    cursor.package = pkgs.bibata-cursors;

    icons.enable = true;
    icons.package = pkgs.tela-circle-icon-theme;
    icons.dark = "tela-circle-icon-theme";
    icons.light = "tela-circle-icon-theme";

    #opacity.terminal = 0.90;
    #fonts.sizes.terminal = 12;

    fonts.emoji = {
      name = "Noto Color Emoji";
      package = pkgs.noto-fonts-color-emoji;
    };

    fonts.monospace = {
      name = "Noto Sans Mono";
      package = pkgs.noto-fonts;
    };

    fonts.serif = {
      name = "Noto Serif";
      package = pkgs.noto-fonts;
    };

    fonts.sansSerif = {
      name = "Noto Sans";
      package = pkgs.noto-fonts;
    };
  };
}
