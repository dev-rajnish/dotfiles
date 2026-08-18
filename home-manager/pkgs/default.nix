# =============================================================================
#  Home Manager Package Integrations Entrypoint
# =============================================================================
{
  imports = [
    ./antigravity-cli.nix
    ./librewolf.nix
    ./obs.nix
    ./plain-app.nix
    ./zen-browser.nix
  ];
}
