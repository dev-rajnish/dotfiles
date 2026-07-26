{pkgs, ...}: {
  stylix = {
    enable = true;
    autoEnable = true;

    # helios, jabuti, tender, darkmoss, codeschool
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/helios.yaml";

    #image = ./gruv-astro.png;

    #targets.wofi.enable = true;
    #targets.swaync.enable = true;
    #targets.kitty.variant256Colors = true;

    cursor.size = 32;
    cursor.name = "Bibata-Modern-Ice";
    cursor.package = pkgs.bibata-cursors;

    iconTheme.enable = true;
    iconTheme.package = pkgs.tela-circle-icon-theme;
    iconTheme.dark = "tela-circle-icon-theme";
    iconTheme.light = "tela-circle-icon-theme";

    opacity.terminal = 0.90;
    fonts.sizes.terminal = 12;

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
