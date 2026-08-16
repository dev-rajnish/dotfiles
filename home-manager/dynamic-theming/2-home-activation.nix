# =============================================================================
#  Dynamic Theming: Home Activation Live Synchronizer
# =============================================================================
{
  config,
  lib,
  pkgs,
  dotfilesDir ? "_ws/dotfiles",
  xdgVars ? import ../../2-desktop-theme-vars.nix,
  ...
}: let
  # 1. Resolve Tokens & Palette
  tokens = import ./1-theme-tokens.nix {
    inherit config dotfilesDir xdgVars;
  };
  inherit (tokens) colors dotConfigPath;

  # 2. Import Modular App Generators
  cssGen = import ./vars-css.nix {inherit pkgs tokens;};
  kittyGen = import ./kitty.nix {inherit pkgs tokens;};
  niriGen = import ./niri.nix {inherit pkgs tokens;};
  fuzzelGen = import ./fuzzel.nix {inherit pkgs tokens;};
  fishGen = import ./fish.nix {inherit pkgs tokens;};
  swaylockGen = import ./swaylock.nix {inherit pkgs tokens;};
  swayidleGen = import ./swayidle.nix {inherit pkgs tokens;};
  wayleGen = import ./wayle.nix {inherit pkgs tokens;};
  yaziGen = import ./yazi.nix {inherit pkgs tokens;};
in {
  # ---------------------------------------------------------------------------
  # 🚀 Live Activation Generator
  # Populates generated files into workspace dot_config without breaking live symlinks
  # ---------------------------------------------------------------------------
  home.activation.generateLiveVars = lib.hm.dag.entryAfter ["writeBoundary"] ''
    TARGET_DIR="${dotConfigPath}"
    if [ -d "$TARGET_DIR" ]; then
      mkdir -p "$TARGET_DIR/colors" \
               "$TARGET_DIR/kitty" \
               "$TARGET_DIR/niri/niri.d" \
               "$TARGET_DIR/fuzzel" \
               "$TARGET_DIR/wlogout" \
               "$TARGET_DIR/fish/functions" \
               "$TARGET_DIR/wayle/themes" \
               "$TARGET_DIR/swayidle" \
               "$TARGET_DIR/swaylock" \
               "$TARGET_DIR/yazi"

      cp -f "${cssGen.varsCss}" "$TARGET_DIR/colors/vars.css"
      cp -f "${cssGen.varsCss}" "$TARGET_DIR/wlogout/colors.css"
      cp -f "${cssGen.varsCss}" "$TARGET_DIR/wlogout/vars.css"
      cp -f "${cssGen.shellColors}" "$TARGET_DIR/colors/colors.sh"
      cp -f "${kittyGen.kittyColors}" "$TARGET_DIR/kitty/colors.conf"
      cp -f "${kittyGen.kittyColors}" "$TARGET_DIR/colors/kitty.conf"
      cp -f "${kittyGen.kittyFonts}" "$TARGET_DIR/kitty/fonts.conf"
      cp -f "${niriGen.niriAppearance}" "$TARGET_DIR/niri/niri.d/appearance.kdl"
      cp -f "${niriGen.niriAppearance}" "$TARGET_DIR/colors/niri.kdl"
      cp -f "${fuzzelGen.fuzzelVars}" "$TARGET_DIR/fuzzel/vars.ini"
      cp -f "${fuzzelGen.fuzzelColors}" "$TARGET_DIR/fuzzel/colors.ini"
      cp -f "${fishGen.fishColors}" "$TARGET_DIR/fish/functions/colors.fish"
      cp -f "${wayleGen.waylePalette}" "$TARGET_DIR/wayle/themes/dynamic.toml"
      cp -f "${wayleGen.waylePaletteJson}" "$TARGET_DIR/wayle/themes/dynamic.json"
      cp -f "${swayidleGen.swayidleConfig}" "$TARGET_DIR/swayidle/config"
      cp -f "${swaylockGen.swaylockConfig}" "$TARGET_DIR/swaylock/config"
      cp -f "${yaziGen.yaziTheme}" "$TARGET_DIR/yazi/theme.toml"

      if [ -f "$TARGET_DIR/wayle/runtime.toml" ]; then
        sed -i \
          -e 's|^bg = ".*"|bg = "${colors.bgDark}"|' \
          -e 's|^surface = ".*"|surface = "${colors.bg}"|' \
          -e 's|^elevated = ".*"|elevated = "${colors.bgCard}"|' \
          -e 's|^fg = ".*"|fg = "${colors.fg}"|' \
          -e 's|^fg-muted = ".*"|fg-muted = "${colors.fgMuted}"|' \
          -e 's|^primary = ".*"|primary = "${colors.blue}"|' \
          -e 's|^red = ".*"|red = "${colors.red}"|' \
          -e 's|^yellow = ".*"|yellow = "${colors.yellow}"|' \
          -e 's|^green = ".*"|green = "${colors.green}"|' \
          -e 's|^blue = ".*"|blue = "${colors.cyan}"|' \
          "$TARGET_DIR/wayle/runtime.toml" 2>/dev/null || true
      fi

      chmod 644 "$TARGET_DIR/colors/"* \
                "$TARGET_DIR/kitty/"* \
                "$TARGET_DIR/niri/niri.d/appearance.kdl" \
                "$TARGET_DIR/fuzzel/"* \
                "$TARGET_DIR/wlogout/colors.css" \
                "$TARGET_DIR/wlogout/vars.css" \
                "$TARGET_DIR/fish/functions/colors.fish" \
                "$TARGET_DIR/wayle/themes/"* \
                "$TARGET_DIR/swayidle/config" \
                "$TARGET_DIR/swaylock/config" \
                "$TARGET_DIR/yazi/theme.toml" 2>/dev/null || true
    fi
  '';
}
