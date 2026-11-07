# =============================================================================
#  Custom Packages & Overlays Flake Module (modules/flake/pkgs.nix)
#  Exposes custom packages via `perSystem.packages` and `flake.overlays.default`
# =============================================================================
{...}: let
  customPackages = pkgs: {
    antigravity-cli = pkgs.callPackage ../pkgs/antigravity.nix {};
    agy = pkgs.callPackage ../pkgs/antigravity.nix {};
    helium = pkgs.callPackage ../pkgs/helium.nix {};
    plain-app = pkgs.callPackage ../pkgs/plain-app.nix {};
    shoelace-bin = pkgs.callPackage ../pkgs/shoelace-bin.nix {};
  };
in {
  flake.overlays.default = final: prev: customPackages final;

  perSystem = {pkgs, ...}: {
    packages = customPackages pkgs;
  };
}
