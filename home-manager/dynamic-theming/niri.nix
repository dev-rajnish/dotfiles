# =============================================================================
#  Dynamic Theming: Niri Window Manager Appearance
# =============================================================================
{
  pkgs,
  tokens,
}: let
  inherit (tokens) colors appearance;

  niriAppearance = pkgs.writeText "appearance.kdl" ''
    // Auto-generated from Stylix base16 theme & 2-desktop-theme-vars.nix - Do not edit manually
    layout {
        gaps ${toString appearance.gaps.inner}
        background-color "${colors.bgDark}"

        border {
            width ${toString appearance.borderWidth}
            active-color "${colors.borderFocus}"
            inactive-color "${colors.border}"
            urgent-color "${colors.red}"
        }

        focus-ring {
            width ${toString appearance.borderWidth}
            active-color "${colors.borderFocus}"
            inactive-color "${colors.border}"
            urgent-color "${colors.red}"
        }

        shadow {
            color "#00000080"
        }

        tab-indicator {
            active-color "${colors.borderFocus}"
            inactive-color "${colors.border}"
            urgent-color "${colors.red}"
        }

        insert-hint {
            color "${colors.borderFocus}80"
        }
    }

    overview {
        backdrop-color "${colors.bgDark}e0"
    }
  '';
in {
  inherit niriAppearance;
}
