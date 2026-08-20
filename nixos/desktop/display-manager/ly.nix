# =============================================================================
#  Display Manager (ly - TUI Display Manager with Rosé Pine Theme & Big UI)
# =============================================================================
{
  pkgs,
  env,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🖥️ ly Console Display Manager Configuration
  # ---------------------------------------------------------------------------
  services.displayManager = {
    ly = {
      enable = true;
      settings = {
        # 🎨 Rosé Pine Theme Colors (ANSI)
        bg = 0; # Dark base
        fg = 7; # Text
        active_fg = 5; # Iris / Rose active highlight
        border_fg = 5; # Iris / Rose border

        # 📐 Bigger UI Layout & Clock
        bigclock = true;
        blank_box = true;
        hide_borders = false;
        margin_box_h = 2;
        margin_box_v = 1;

        # 🔒 Password Display Settings (Plaintext Visible Password)
        hide_password = false;
        clear_password = false;

        # 🚫 No Animations
        animation = "none";
      };
    };
    defaultSession = "niri-uwsm";
  };
}
