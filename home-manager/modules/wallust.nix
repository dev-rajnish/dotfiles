# =============================================================================
#  Wallust Theming Engine (Stylix Generates Colors -> Wallust Manages Apps)
# =============================================================================
{
  config,
  pkgs,
  lib,
  ...
}: let
  # Extract dynamic Base16 palette from Stylix and format as Pywal/Wallust JSON
  c = config.lib.stylix.colors;
  stylixColorschemeJson = builtins.toJSON {
    special = {
      background = "#${c.base00}";
      foreground = "#${c.base05}";
      cursor = "#${c.base05}";
    };
    colors = {
      color0 = "#${c.base00}";
      color1 = "#${c.base08}";
      color2 = "#${c.base0B}";
      color3 = "#${c.base0A}";
      color4 = "#${c.base0D}";
      color5 = "#${c.base0E}";
      color6 = "#${c.base0C}";
      color7 = "#${c.base05}";
      color8 = "#${c.base03}";
      color9 = "#${c.base08}";
      color10 = "#${c.base0B}";
      color11 = "#${c.base09}";
      color12 = "#${c.base0D}";
      color13 = "#${c.base0E}";
      color14 = "#${c.base0C}";
      color15 = "#${c.base07}";
    };
  };
in {
  # ---------------------------------------------------------------------------
  # 📦 Wallust Binary Package
  # ---------------------------------------------------------------------------
  home.packages = [
    pkgs.wallust
  ];

  # ---------------------------------------------------------------------------
  # 🚀 Live Wallust Template Generation on Activation
  # ---------------------------------------------------------------------------
  home.activation.wallustTheme =
    lib.hm.dag.entryAfter ["linkGeneration"]
    /*
    bash
    */
    ''
          # Write Stylix-generated palette to stylix.jsonc
          cat << 'EOF' > "$HOME/.config/wallust/colorschemes/stylix.jsonc"
      ${stylixColorschemeJson}
      EOF
      chmod 644 "$HOME/.config/wallust/colorschemes/stylix.jsonc"

          # Apply colorscheme via Wallust to render all templates
          ${pkgs.wallust}/bin/wallust cs "$HOME/.config/wallust/colorschemes/stylix.jsonc"
    '';
}
