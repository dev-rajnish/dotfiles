# =============================================================================
#  Home Manager Out-Of-Store Symlinks (Live Editable Workspace)
# =============================================================================
{config, ...}: let
  dotfilesDir = "${config.home.homeDirectory}/shoelace";
in {
  xdg.configFile = {
    "kitty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/kitty";
    "niri".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/niri";
    "fuzzel".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/fuzzel";
    "wayle".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/wayle";
    "swaylock".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/swaylock";
    "swayidle".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/swayidle";
    "fish".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/fish";
    "yazi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/yazi";
    "fastfetch".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/fastfetch";
    "wlogout".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/wlogout";
    "waypaper".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/waypaper";
    "glow".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/glow";
    "starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/starship.toml";
    "Thunar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/Thunar";
    "xfce4".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/xfce4";
    "autostart-script".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/autostart-script";
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/nvim";
    "qutebrowser".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/qutebrowser";
  };
}
