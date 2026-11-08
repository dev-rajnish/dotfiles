# =============================================================================
#  PlainApp Launcher Package (pkgs/plain-app.nix)
#  Fast desktop launcher and hotspot connector for PlainApp
# =============================================================================
{
  writeShellScriptBin,
  makeDesktopItem,
  symlinkJoin,
  browser ? "firefox-devedition",
}: let
  plainAppName = "plainapp";

  plainAppScript = writeShellScriptBin plainAppName ''
    gateway_ip=$(ip route show | awk '/default/ {print $3}')

    if [ -z "$gateway_ip" ]; then
      notify-send "PlainApp Error" "Not connected to phone hotspot!"
      exit 1
    fi

    exec ${browser} "https://$gateway_ip:8443"
  '';

  plainAppDesktop = makeDesktopItem {
    name = plainAppName;
    desktopName = "PlainApp";
    exec = "${plainAppScript}/bin/${plainAppName}";
    icon = "mobile";
    categories = ["Network" "Utility"];
  };
in
  symlinkJoin {
    name = "plain-app";
    paths = [
      plainAppScript
      plainAppDesktop
    ];
  }
