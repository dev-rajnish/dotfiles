# =============================================================================
#  Display Manager & TTY Auto-Login Service
# =============================================================================
{
  lib,
  username,
  enableAutoLogin ? true,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🔑 Automatic TTY User Login (TTY1)
  # ---------------------------------------------------------------------------
  services.getty.autologinUser = lib.mkIf enableAutoLogin username;

  # ---------------------------------------------------------------------------
  # 🖥️ Optional Display Manager Selection (Disabled by default)
  # ---------------------------------------------------------------------------
  # To enable a graphical / TUI display manager instead of TTY autologin:

  # Option 1: Ly (Lightweight TUI Display Manager)
  # services.displayManager = {
  #   defaultSession = "niri";
  #   ly = {
  #     enable = true;
  #   };
  # };

  # Option 2: Greetd with tuigreet (Modern Minimalist TUI Greeter)
  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri";
  #       user = "greeter";
  #     };
  #   };
  # };

  # Option 3: SDDM (Modern Wayland / Qt Display Manager)
  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  # };
}
