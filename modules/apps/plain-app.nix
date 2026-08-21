{ env,  config,  lib, 
  pkgs,
  browser,
  ...
}:
let
  cfg = config.mySystem.apps.plain-app;
in {
  options.mySystem.apps.plain-app = {
    enable = lib.mkEnableOption "plain-app config";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = { config, ... }: (
    let
  plainAppName = "plainapp";
  plainAppScript = pkgs.writeShellScriptBin plainAppName ''
    gateway_ip=$(ip route show | awk '/default/ {print $3}')

    if [ -z "$gateway_ip" ]; then
      notify-send "PlainApp Error" "Not connected to phone hotspot!"
      exit 1
    fi

    exec ${browser} \
      "https://$gateway_ip:8443"
  '';

  plainAppDesktop = pkgs.makeDesktopItem {
    name = plainAppName;
    desktopName = "PlainApp";
    exec = "${plainAppScript}/bin/${plainAppName}";
    icon = "mobile";
    categories = ["Network" "Utility"];
  };
in {
  # ---------------------------------------------------------------------------
  # 📦 PlainApp Packages
  # ---------------------------------------------------------------------------
  home.packages = [
    plainAppScript
    plainAppDesktop
  ];
}
  );
  };
}
