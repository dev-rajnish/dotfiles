# =============================================================================
#  Custom Packages & Overlays Flake Module (modules/flake/pkgs.nix)
#  Exposes custom packages via `perSystem.packages` and `flake.overlays.default`
# =============================================================================
{...}: {
  flake.overlays.default = final: prev: {
    antigravity-cli = final.callPackage ../pkgs/antigravity.nix {};
    agy = final.antigravity-cli;
    helium = final.callPackage ../pkgs/helium.nix {};
    plain-app = final.callPackage ../pkgs/plain-app.nix {};
    shoelace-bin = final.callPackage ../pkgs/shoelace-bin.nix {};
  };

  perSystem = {pkgs, ...}: {
    packages = {
      antigravity-cli = pkgs.callPackage ../pkgs/antigravity.nix {};
      agy = pkgs.callPackage ../pkgs/antigravity.nix {};
      helium = pkgs.callPackage ../pkgs/helium.nix {};
      plain-app = pkgs.callPackage ../pkgs/plain-app.nix {};
      shoelace-bin = pkgs.callPackage ../pkgs/shoelace-bin.nix {};
    };
  };
}
