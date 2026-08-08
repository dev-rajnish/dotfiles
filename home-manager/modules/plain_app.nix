{
  config,
  pkgs,
  ...
}: let
  appName = "plainapp";

  # Yeh script automatically phone (gateway) ka active IP dhoond legi
  pwaScript = pkgs.writeShellScriptBin appName ''
    gateway_ip=$(ip route show | awk '/default/ {print $3}')

    if [ -z "$gateway_ip" ]; then
      notify-send "PlainApp Error" "Not connected to phone hotspot!"
      exit 1
    fi

    exec zen-beta \
      "https://$gateway_ip:8443"
  '';

  pwaDesktop = pkgs.makeDesktopItem {
    name = appName;
    desktopName = "PlainApp";
    exec = "${pwaScript}/bin/${appName}";
    icon = "mobile";
    categories = ["Network" "Utility"];
  };
in {
  home.packages = [
    pwaScript
    pwaDesktop
  ];
}
