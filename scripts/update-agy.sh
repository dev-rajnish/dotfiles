#!/usr/bin/env bash
set -euo pipefail

# Resolve repository root directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGY_NIX="$REPO_ROOT/home-manager/pkgs/agy.nix"

if [ ! -f "$AGY_NIX" ]; then
  echo "Error: $AGY_NIX not found." >&2
  exit 1
fi

echo ":: Checking for Antigravity CLI updates..."

MANIFEST_URL="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_amd64.json"

MANIFEST=$(curl -fsSL "$MANIFEST_URL" 2>/dev/null || true)
if [ -z "$MANIFEST" ]; then
  echo ":: Warning: Could not reach Antigravity release server, skipping update check."
  exit 0
fi

NEW_VER=$(echo "$MANIFEST" | sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
NEW_URL=$(echo "$MANIFEST" | sed -n 's/.*"url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
NEW_SHA512=$(echo "$MANIFEST" | sed -n 's/.*"sha512"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

if [ -n "$NEW_VER" ] && [ -n "$NEW_SHA512" ]; then
  NEW_HASH=$(nix hash convert --hash-algo sha512 --to sri "$NEW_SHA512")
  CUR_VER=$(sed -n 's/.*version = "\([^"]*\)".*/\1/p' "$AGY_NIX")

  if [ "$CUR_VER" != "$NEW_VER" ]; then
    echo ":: Updating Antigravity CLI ($CUR_VER -> $NEW_VER)..."
    sed -i "s|version = \".*\"|version = \"$NEW_VER\"|" "$AGY_NIX"
    sed -i "s|url = \".*\"|url = \"$NEW_URL\"|" "$AGY_NIX"
    sed -i "s|hash = \".*\"|hash = \"$NEW_HASH\"|" "$AGY_NIX"
    echo ":: Successfully updated home-manager/pkgs/agy.nix to $NEW_VER"
  else
    echo ":: Antigravity CLI is up to date (v$CUR_VER)"
  fi
fi
