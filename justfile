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
# ❄️ NixOS System Management
# -----------------------------------------------------------------------------

# Fetch latest Antigravity CLI version and update home-manager/pkgs/antigravity-cli.nix
update-agy:
    @./home-manager/scripts/update-agy.sh

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
lock:
    nix flake lock

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
