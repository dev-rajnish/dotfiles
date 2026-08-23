# =============================================================================
#  System-Wide Core Packages Module
#  Auto-generated from tokens/pkgs/system.toml via MiniJinja (bin/pkg-render)
# =============================================================================
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    curl
    wget
    git
    home-manager
    just
    unzip
    seatd
    xwayland-satellite
    starship
    zoxide
    direnv
  ];
}
