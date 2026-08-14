#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
#  Copy Hardware Configuration for New Machine Install
# =============================================================================

# Resolve repository root directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_FILE="$REPO_ROOT/nixos/hardware-configuration.nix"
SOURCE_FILE="/etc/nixos/hardware-configuration.nix"

echo ":: Checking for hardware configuration at $SOURCE_FILE..."

if [ ! -f "$SOURCE_FILE" ]; then
  echo ":: $SOURCE_FILE not found, generating hardware configuration..."
  if command -v nixos-generate-config >/dev/null 2>&1; then
    nixos-generate-config --show-hardware-config | tee "$TARGET_FILE" >/dev/null
  else
    echo "Error: Neither $SOURCE_FILE exists nor nixos-generate-config is available." >&2
    exit 1
  fi
else
  # Read file content with cat and write with tee to avoid copying file permissions
  if [ -r "$SOURCE_FILE" ]; then
    cat "$SOURCE_FILE" | tee "$TARGET_FILE" >/dev/null
  else
    sudo cat "$SOURCE_FILE" | tee "$TARGET_FILE" >/dev/null
  fi
fi

# Ensure correct user write permissions on the copied file
chmod 644 "$TARGET_FILE"

echo ":: Successfully copied hardware configuration to $TARGET_FILE (content only, no permissions copied)"

sudo nixos-rebuild switch --flake .#nixos
