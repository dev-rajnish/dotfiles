{
  env,
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.mySystem.apps.helium;
in {
  options.mySystem.apps.helium = {
    enable = lib.mkEnableOption "helium config";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = {
      config,
      pkgs,
      ...
    }: let
      version = "0.15.5.1";

      heliumSrc = pkgs.fetchurl {
        url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
        hash = "sha256-UC2LpmlRl7V+LRhojqg5VlS7VpMpE99m4/7yiH1KAM4=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        pname = "helium";
        inherit version;
        src = heliumSrc;
      };

      heliumPkg = pkgs.appimageTools.wrapType2 {
        pname = "helium";
        inherit version;
        src = heliumSrc;

        extraPkgs = pkgs:
          with pkgs; [
            nss
            nspr
            libdrm
            mesa
            alsa-lib
            vulkan-loader
            libGL
            libglvnd
            wayland
            libxkbcommon
            pciutils
            gtk3
          ];

        extraInstallCommands = ''
          mkdir -p $out/share/applications $out/share/icons/hicolor/512x512/apps
          if [ -f ${appimageContents}/helium.desktop ]; then
            cp ${appimageContents}/helium.desktop $out/share/applications/helium.desktop
            substituteInPlace $out/share/applications/helium.desktop \
              --replace-fail "Exec=helium" "Exec=$out/bin/helium --ozone-platform-hint=auto --enable-features=UseOzonePlatform,OverlayScrollbar --force-dark-mode"
          fi
          if [ -f ${appimageContents}/helium.png ]; then
            cp ${appimageContents}/helium.png $out/share/icons/hicolor/512x512/apps/helium.png
          fi
        '';

        meta = with lib; {
          description = "Lightweight, privacy-first Chromium browser by imputnet (AppImage)";
          homepage = "https://github.com/imputnet/helium";
          license = licenses.gpl3Only;
          platforms = ["x86_64-linux"];
          mainProgram = "helium";
        };
      };
    in {
      home.packages = [
        heliumPkg
      ];
    };
  };
}
