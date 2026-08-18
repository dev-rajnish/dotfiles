# =============================================================================
#  NixOS & Home Manager Dotfiles Task Runner (justfile)
# =============================================================================

# Dynamically extract host and user variables from 0-system-vars.nix (with fallbacks)
hostname := `sed -n 's/^[[:space:]]*hostname[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' 0-system-vars.nix 2>/dev/null || echo "nixos"`
username := `sed -n 's/^[[:space:]]*username[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' 0-system-vars.nix 2>/dev/null || whoami`

# Default recipe: List available commands
default:
    @just --list


# -----------------------------------------------------------------------------
# 🦀 Rust Dotfiles System Tools
# -----------------------------------------------------------------------------

# Build optimized release binaries for the Rust toolset in user/bin-rs
build-tools:
    cargo build --release --manifest-path user/bin-rs/Cargo.toml
    cp user/bin-rs/target/release/{loader,wallpaper,power-menu,update-agy,dot,installer,y} home-manager/scripts/ 2>/dev/null || true


# -----------------------------------------------------------------------------
# 🔄 Live Workspace & Snapshot Lock Management
# -----------------------------------------------------------------------------

# Lock current live configurations from config.live/ into git-tracked config.lock/
lock-config:
    @mkdir -p config.lock config.live
    @rsync -av --delete \
        --exclude='.git' \
        --exclude='*.bak' \
        --exclude='*.lock' \
        --exclude='__pycache__' \
        config.live/ config.lock/
    @echo "✔ Live configuration locked into config.lock/ (ready to commit to Git)"

# Alias for lock-config
lock: lock-config

# Restore live configuration from git-tracked config.lock/ into config.live/
restore-config:
    @mkdir -p config.live config.lock
    @rsync -av --delete config.lock/ config.live/
    @echo "✔ config.live/ restored from config.lock/"

# Alias for restore-config
restore: restore-config

# Symlink all config.live subdirectories into ~/.config/
link-live:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p config.live "$HOME/.config"
    for item in config.live/*; do
        if [ -e "$item" ]; then
            name=$(basename "$item")
            ln -sfn "$(pwd)/config.live/$name" "$HOME/.config/$name"
        fi
    done
    echo "✔ ~/.config/ entries symlinked to config.live/"

# Alias for link-live
link: link-live

# -----------------------------------------------------------------------------
# ❄️ NixOS System Management
# -----------------------------------------------------------------------------

# Fetch latest Antigravity CLI version and update home-manager/pkgs/antigravity-cli.nix
update-agy:
    @./user/bin-rs/target/release/update-agy 2>/dev/null || ./home-manager/scripts/update-agy

# Run health diagnostics on system and dotfiles
doctor:
    @./user/bin-rs/target/release/dot doctor 2>/dev/null || ./home-manager/scripts/dot doctor

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
update input="": update-agy
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
