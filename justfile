# =============================================================================
#  NixOS & Home Manager Dotfiles Task Runner (justfile)
# =============================================================================

# Dynamically extract host and user variables from env/system.toml (with fallbacks)
hostname := `sed -n 's/^[[:space:]]*hostname[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' env/system.toml 2>/dev/null || echo "nixos"`
username := `sed -n 's/^[[:space:]]*username[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' env/system.toml 2>/dev/null || whoami`

# Default recipe: List available commands
default:
    @just --list


# -----------------------------------------------------------------------------
# 🔄 Live Workspace & Snapshot Lock Management
# -----------------------------------------------------------------------------

# Lock current live configurations from config.live/ into git-tracked config.lock/
lock-config:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p config.lock config.live
    # 1. Unlock config.lock (temporarily grant write permissions)
    chmod -R u+rwX config.lock 2>/dev/null || true
    # 2. Sync live configuration into config.lock (respecting .gitignore)
    rsync -av --delete \
        --filter=':- .gitignore' \
        --exclude='.git' \
        config.live/ config.lock/
    # 3. Re-lock config.lock (set read-only 444 for files, 555 for directories)
    find config.lock -type d -exec chmod 555 {} +
    find config.lock -type f -exec chmod 444 {} +
    echo "✔ Live configuration locked into read-only config.lock/ (ready to commit to Git)"

# Alias for lock-config
lock: lock-config

# Restore live configuration from git-tracked config.lock/ into config.live/
restore-config:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p config.live config.lock
    # 1. Sync locked configurations to live (respecting .gitignore)
    rsync -av --delete \
        --filter=':- .gitignore' \
        --exclude='.git' \
        config.lock/ config.live/
    # 2. Ensure config.live is fully writable for live editing
    chmod -R u+rwX config.live
    echo "✔ config.live/ restored and unlocked from config.lock/"

# Alias for restore-config
restore: restore-config

# Symlink all config.live subdirectories and env into ~/.config/
link-live:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p config.live "$HOME/.config"
    for item in config.live/*; do
        if [ -e "$item" ]; then
            name=$(basename "$item")
            target="$HOME/.config/$name"
            if [ -d "$target" ] && [ ! -L "$target" ]; then
                rm -rf "$target"
            fi
            ln -sfn "$(pwd)/config.live/$name" "$target"
        fi
    done
    # Symlink env/ directly to ~/.config/env for unified live editing
    if [ -d "env" ]; then
        ln -sfn "$(pwd)/env" "$HOME/.config/env"
    fi
    echo "✔ ~/.config/ entries & ~/.config/env symlinked successfully"

# Alias for link-live
link: link-live

# -----------------------------------------------------------------------------
# ❄️ NixOS System Management
# -----------------------------------------------------------------------------

# Rebuild and switch to the new NixOS system configuration
switch: 
    sudo nixos-rebuild switch --flake .#{{hostname}}

# Alias for switch
nixos: switch

# Test configuration without adding to bootloader menu
test: 
    sudo nixos-rebuild test --flake .#{{hostname}}

# Build configuration and set as default in bootloader (without switching now)
boot: 
    sudo nixos-rebuild boot --flake .#{{hostname}}

# Build NixOS system toplevel without switching (produces ./result)
build: 
    nix build .#nixosConfigurations.{{hostname}}.config.system.build.toplevel

# Build a QEMU VM runner for testing the configuration
vm: 
    nixos-rebuild build-vm --flake .#{{hostname}}

# -----------------------------------------------------------------------------
# 🏠 Home Manager Management
# -----------------------------------------------------------------------------

# Switch to the standalone Home Manager configuration
home: 
    home-manager switch --flake .#{{username}}

# Alias for home
hm: home

# Build Home Manager activation package without switching
home-build:
    nix build .#homeConfigurations.{{username}}.activationPackage

# -----------------------------------------------------------------------------
# 🔄 Combined Operations
# -----------------------------------------------------------------------------

# Rebuild both NixOS system and Home Manager configurations
all: switch home

# Alias for all
sync: all

# -----------------------------------------------------------------------------
# 🛠️ Flake & Code Quality
# -----------------------------------------------------------------------------

# Format all Nix and configuration files using treefmt
fmt:
    nix fmt

# Run flake checks and verify build evaluations
check: 
    nix flake check

# Update all flake inputs or a specific input (e.g., `just update nixpkgs`)
update input="":
    #!/usr/bin/env bash
    if [ -z "{{input}}" ]; then
        nix flake update
    else
        nix flake update {{input}}
    fi

# Update flake lockfile
lock-flake:
    nix flake lock

# Alias for lock-flake
flake-lock: lock-flake

# -----------------------------------------------------------------------------
# 🧹 Maintenance & Clean-up
# -----------------------------------------------------------------------------

# Clean older generations (default 7 days) and optimize the Nix store
gc days="7d":
    nix-collect-garbage --delete-older-than {{days}}
    sudo nix-collect-garbage --delete-older-than {{days}}
    nix store optimise
    sudo nix store optimise

# Deduplicate and optimize the Nix store
optimise:
    nix store optimise
    sudo nix store optimise

# Remove temporary build symlinks (result, result-*)
clean:
    rm -rf result result-*

# -----------------------------------------------------------------------------
# 📜 Information & History
# -----------------------------------------------------------------------------

# List recent NixOS and Home Manager generations
generations:
    @echo "=== ❄️ NixOS Generations ==="
    sudo nixos-rebuild list-generations
    @echo ""
    @echo "=== 🏠 Home Manager Generations ==="
    home-manager generations

# Show git status of the dotfiles repository
status:
    git status -s
