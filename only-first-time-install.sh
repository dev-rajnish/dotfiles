#!/usr/bin/env bash
# =============================================================================
#  NixOS & Dotfiles First-Time Bootstrap Installer
# =============================================================================
set -euo pipefail

# -----------------------------------------------------------------------------
# 01. Parse CLI Arguments & Flags
# -----------------------------------------------------------------------------
AUTO_YES=false
RUN_HM=false

show_help() {
  cat <<'EOF'
Usage: ./only-first-time-install.sh [OPTIONS]

Options:
  -y, --yes, --non-interactive  Auto-accept detected settings and proceed without prompting
  --hm, --home-manager          Run standalone home-manager switch after nixos-rebuild
  -h, --help                    Show this help message and exit

Description:
  Automates first-time installation and hardware detection for any user and host.
  Captures username, hostname, repository path, GPU drivers, chassis type, and timezone,
  updates 0-system-vars.nix, stages flake files, and executes nixos-rebuild.
EOF
}

for arg in "$@"; do
  case "$arg" in
  -y | --yes | --non-interactive)
    AUTO_YES=true
    ;;
  --hm | --home-manager)
    RUN_HM=true
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  *)
    echo ":: Warning: Unknown argument '$arg' (ignoring)"
    ;;
  esac
done

# Resolve repository root directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VARS_FILE="$REPO_ROOT/0-system-vars.nix"
HARDWARE_TARGET="$REPO_ROOT/nixos/hardware-configuration.nix"
HARDWARE_SOURCE="/etc/nixos/hardware-configuration.nix"

echo "============================================================================="
echo "   ❄️  NixOS & Home Manager Bootstrap Installer"
echo "============================================================================="

# -----------------------------------------------------------------------------
# 02. Smart Hardware & Environment Auto-Detection
# -----------------------------------------------------------------------------
# 1. User detection (Resolve real user if run via sudo)
DETECTED_USER="${SUDO_USER:-$(id -un)}"
[ "$DETECTED_USER" = "root" ] && DETECTED_USER="$(whoami)"

# 2. Hostname detection
DETECTED_HOST="$(hostname -s 2>/dev/null || cat /etc/hostname 2>/dev/null || echo "nixos")"

# 3. Dotfiles Path relative to user home directory
USER_HOME="${HOME:-/home/$DETECTED_USER}"
if [ -n "${SUDO_USER:-}" ] && [ -d "/home/$SUDO_USER" ]; then
  USER_HOME="/home/$SUDO_USER"
fi

if [[ $REPO_ROOT == "$USER_HOME/"* ]]; then
  DETECTED_DOTDIR="${REPO_ROOT#$USER_HOME/}"
else
  DETECTED_DOTDIR="_ws/dotfiles"
fi

# 4. GPU Detection via PCI bus / DRM
DETECTED_GPU="generic"
GPU_DESC="Standard Display / Virtual GPU"
if lspci 2>/dev/null | grep -Ei "vga|3d|display" | grep -Ei "amd|radeon|ati" >/dev/null; then
  DETECTED_GPU="amd"
  GPU_DESC="$(lspci 2>/dev/null | grep -Ei "vga|3d|display" | grep -Ei "amd|radeon|ati" | head -n1)"
elif lspci 2>/dev/null | grep -Ei "vga|3d|display" | grep -Ei "intel" >/dev/null; then
  DETECTED_GPU="intel"
  GPU_DESC="$(lspci 2>/dev/null | grep -Ei "vga|3d|display" | grep -Ei "intel" | head -n1)"
elif lspci 2>/dev/null | grep -Ei "vga|3d|display" | grep -Ei "nvidia" >/dev/null; then
  DETECTED_GPU="nvidia"
  GPU_DESC="$(lspci 2>/dev/null | grep -Ei "vga|3d|display" | grep -Ei "nvidia" | head -n1)"
fi

# 5. Device Type Detection (Laptop / Desktop / VM)
DETECTED_DEVICE="desktop"
CHASSIS_TYPE="$(cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo "")"
if systemd-detect-virt >/dev/null 2>&1; then
  DETECTED_DEVICE="vm"
  DEVICE_DESC="Virtual Machine ($(systemd-detect-virt 2>/dev/null))"
elif [ -d "/sys/class/power_supply" ] && ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
  DETECTED_DEVICE="laptop"
  DEVICE_DESC="Laptop (Battery present, Chassis type: $CHASSIS_TYPE)"
elif [[ $CHASSIS_TYPE =~ ^(8|9|10|11|14|30|31|32)$ ]]; then
  DETECTED_DEVICE="laptop"
  DEVICE_DESC="Laptop (Chassis type: $CHASSIS_TYPE)"
else
  DEVICE_DESC="Desktop PC (Chassis type: $CHASSIS_TYPE)"
fi

# 6. Timezone Detection
DETECTED_TZ="$(timedatectl show -p Timezone --value 2>/dev/null || true)"
if [ -z "$DETECTED_TZ" ] && [ -L /etc/localtime ]; then
  DETECTED_TZ="$(readlink -f /etc/localtime | sed -n "s/.*zoneinfo\///p")"
fi
[ -z "$DETECTED_TZ" ] && DETECTED_TZ="Asia/Kolkata"

# 7. Theme & Polarity from current vars
CURRENT_THEME="$(sed -n 's/^[[:space:]]*theme[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$VARS_FILE" 2>/dev/null || echo "ayu-dark")"
CURRENT_POLARITY="$(sed -n 's/^[[:space:]]*polarity[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$VARS_FILE" 2>/dev/null || echo "dark")"

# -----------------------------------------------------------------------------
# 03. Present Detected Values & Interactive Confirmation
# -----------------------------------------------------------------------------
FINAL_USER="$DETECTED_USER"
FINAL_HOST="$DETECTED_HOST"
FINAL_DOTDIR="$DETECTED_DOTDIR"
FINAL_GPU="$DETECTED_GPU"
FINAL_DEVICE="$DETECTED_DEVICE"
FINAL_TZ="$DETECTED_TZ"
FINAL_THEME="$CURRENT_THEME"
FINAL_POLARITY="$CURRENT_POLARITY"

echo ""
echo "🔍 Auto-Detected System Configuration:"
echo "-----------------------------------------------------------------------------"
echo "  [1] Username:       $FINAL_USER"
echo "  [2] Hostname:       $FINAL_HOST"
echo "  [3] Dotfiles Path:  $FINAL_DOTDIR (relative to \$HOME)"
echo "  [4] GPU Driver:     $FINAL_GPU ($GPU_DESC)"
echo "  [5] Device Type:    $FINAL_DEVICE ($DEVICE_DESC)"
echo "  [6] Timezone:       $FINAL_TZ"
echo "  [7] Base16 Theme:   $FINAL_THEME ($FINAL_POLARITY)"
echo "-----------------------------------------------------------------------------"

if [ "$AUTO_YES" = false ]; then
  read -rp "Apply these settings and proceed with installation? [Y/n/c(ustom)]: " CONFIRM_CHOICE
  CONFIRM_CHOICE="${CONFIRM_CHOICE:-y}"

  case "$CONFIRM_CHOICE" in
  [yY] | [yY][eE][sS])
    echo ":: Using detected values."
    ;;
  [cC] | [cC][uU][sS][tT][oO][mM])
    echo ""
    echo ":: Enter custom settings (Press Enter to keep detected default):"
    read -rp "  Username [$FINAL_USER]: " IN_USER
    FINAL_USER="${IN_USER:-$FINAL_USER}"

    read -rp "  Hostname [$FINAL_HOST]: " IN_HOST
    FINAL_HOST="${IN_HOST:-$FINAL_HOST}"

    read -rp "  Dotfiles Subdirectory [$FINAL_DOTDIR]: " IN_DOTDIR
    FINAL_DOTDIR="${IN_DOTDIR:-$FINAL_DOTDIR}"

    read -rp "  GPU Driver (amd/intel/nvidia/generic) [$FINAL_GPU]: " IN_GPU
    FINAL_GPU="${IN_GPU:-$FINAL_GPU}"

    read -rp "  Device Type (laptop/desktop/vm) [$FINAL_DEVICE]: " IN_DEVICE
    FINAL_DEVICE="${IN_DEVICE:-$FINAL_DEVICE}"

    read -rp "  Timezone [$FINAL_TZ]: " IN_TZ
    FINAL_TZ="${IN_TZ:-$FINAL_TZ}"

    read -rp "  Base16 Theme [$FINAL_THEME]: " IN_THEME
    FINAL_THEME="${IN_THEME:-$FINAL_THEME}"
    ;;
  *)
    echo ":: Installation aborted by user."
    exit 0
    ;;
  esac
fi

# -----------------------------------------------------------------------------
# 04. In-Place Update of 0-system-vars.nix
# -----------------------------------------------------------------------------
echo ""
echo ":: Updating 0-system-vars.nix with configured system parameters..."

if [ -f "$VARS_FILE" ]; then
  sed -i \
    -e "s|^[[:space:]]*username[[:space:]]*=.*|  username = \"$FINAL_USER\";|" \
    -e "s|^[[:space:]]*hostname[[:space:]]*=.*|  hostname = \"$FINAL_HOST\";|" \
    -e "s|^[[:space:]]*dotfilesDir[[:space:]]*=.*|  dotfilesDir = \"$FINAL_DOTDIR\";|" \
    -e "s|^[[:space:]]*gpuDriver[[:space:]]*=.*|  gpuDriver = \"$FINAL_GPU\";|" \
    -e "s|^[[:space:]]*deviceType[[:space:]]*=.*|  deviceType = \"$FINAL_DEVICE\";|" \
    -e "s|^[[:space:]]*timeZone[[:space:]]*=.*|  timeZone = \"$FINAL_TZ\";|" \
    -e "s|^[[:space:]]*theme[[:space:]]*=.*|  theme = \"$FINAL_THEME\";|" \
    "$VARS_FILE"
  echo ":: 0-system-vars.nix successfully updated."
fi

# -----------------------------------------------------------------------------
# 05. Hardware Configuration Sync
# -----------------------------------------------------------------------------
echo ":: Checking hardware configuration..."

if [ ! -f "$HARDWARE_SOURCE" ]; then
  echo ":: $HARDWARE_SOURCE not found, generating hardware configuration..."
  if command -v nixos-generate-config >/dev/null 2>&1; then
    nixos-generate-config --show-hardware-config | tee "$HARDWARE_TARGET" >/dev/null
  else
    echo ":: Error: Neither $HARDWARE_SOURCE exists nor nixos-generate-config is available." >&2
    exit 1
  fi
else
  if [ -r "$HARDWARE_SOURCE" ]; then
    cat "$HARDWARE_SOURCE" | tee "$HARDWARE_TARGET" >/dev/null
  else
    sudo cat "$HARDWARE_SOURCE" | tee "$HARDWARE_TARGET" >/dev/null
  fi
fi

chmod 644 "$HARDWARE_TARGET"
echo ":: Hardware configuration synchronized to $HARDWARE_TARGET"

# -----------------------------------------------------------------------------
# 06. Manual Review in Default Editor (Before Starting Installation)
# -----------------------------------------------------------------------------
if [ "$AUTO_YES" = false ]; then
  TARGET_EDITOR="${EDITOR:-${VISUAL:-}}"
  if [ -z "$TARGET_EDITOR" ]; then
    for ed in nvim nano vim vi; do
      if command -v "$ed" >/dev/null 2>&1; then
        TARGET_EDITOR="$ed"
        break
      fi
    done
  fi

  if [ -n "$TARGET_EDITOR" ]; then
    echo ""
    echo ":: Ready to review 0-system-vars.nix before starting installation..."
    echo ":: (Review settings, make any manual tweaks, then save & exit the editor to proceed)"
    read -rp "Press [Enter] to open with '$TARGET_EDITOR' (or type your editor name): " USER_CHOSEN_ED

    if [ -n "$USER_CHOSEN_ED" ]; then
      if command -v "$USER_CHOSEN_ED" >/dev/null 2>&1; then
        TARGET_EDITOR="$USER_CHOSEN_ED"
      else
        echo ":: Warning: Editor '$USER_CHOSEN_ED' not found, falling back to '$TARGET_EDITOR'."
      fi
    fi

    echo ":: Opening 0-system-vars.nix with '$TARGET_EDITOR'..."
    "$TARGET_EDITOR" "$VARS_FILE"

    # Re-extract hostname and username in case user modified them in editor
    NEW_HOST="$(sed -n 's/^[[:space:]]*hostname[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$VARS_FILE" 2>/dev/null || echo "")"
    [ -n "$NEW_HOST" ] && FINAL_HOST="$NEW_HOST"

    NEW_USER="$(sed -n 's/^[[:space:]]*username[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$VARS_FILE" 2>/dev/null || echo "")"
    [ -n "$NEW_USER" ] && FINAL_USER="$NEW_USER"
  fi
fi

# -----------------------------------------------------------------------------
# 07. Git Flake Staging (Required for Nix Flakes)
# -----------------------------------------------------------------------------
echo ":: Staging repository files for Nix flake evaluation..."
git -C "$REPO_ROOT" add -A

# -----------------------------------------------------------------------------
# 08. NixOS System Rebuild & Switch
# -----------------------------------------------------------------------------
echo ""
echo ":: Rebuilding and switching NixOS system for host '$FINAL_HOST'..."
sudo nixos-rebuild switch --flake "$REPO_ROOT#$FINAL_HOST"

# -----------------------------------------------------------------------------
# 08. Optional Standalone Home Manager Switch
# -----------------------------------------------------------------------------
if [ "$RUN_HM" = true ]; then
  echo ""
  echo ":: Explicit Home Manager switch requested (--hm)..."
  if command -v home-manager >/dev/null 2>&1; then
    home-manager switch --flake "$REPO_ROOT#$FINAL_USER"
  elif nix run nixpkgs#home-manager -- switch --flake "$REPO_ROOT#$FINAL_USER" 2>/dev/null; then
    echo ":: Home Manager switch completed via nix run."
  else
    echo ":: Note: home-manager command not yet in PATH; initial session was built by nixos-rebuild."
  fi
fi

# -----------------------------------------------------------------------------
# 09. Completion Summary
# -----------------------------------------------------------------------------
echo ""
echo "============================================================================="
echo "   ✨ Installation and System Switch Complete!"
echo "============================================================================="
echo "  • User Profile: $FINAL_USER"
echo "  • Host Profile: $FINAL_HOST"
echo "  • Theme:        $FINAL_THEME ($FINAL_POLARITY)"
echo ""
echo "  💡 Routine Daily Commands:"
echo "     just switch   # Rebuild NixOS system"
echo "     just hm       # Switch user Home Manager environment"
echo "     just fmt      # Format dotfiles with treefmt"
echo "============================================================================="
