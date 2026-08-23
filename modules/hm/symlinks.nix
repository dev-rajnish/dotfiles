{
  env,
  lib,
  config,
  ...
}: let
  cfg = config.mySystem.hm.symlinks;
in {
  options.mySystem.hm.symlinks = {
    enable = lib.mkEnableOption "symlinks config";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = {config, ...}: let
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
        "waypaper".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/waypaper";
        "glow".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/glow";
        "starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/starship.toml";
        "Thunar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/Thunar";
        "autostart-script".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/autostart-script";
        "nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/nvim";
        "background".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/background";
      };
    };
  };
}
