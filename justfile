# =============================================================================
#  NixOS & Home Manager Dotfiles Task Runner (justfile)
# =============================================================================

# Dynamically extract host and user variables from allsettings/system.toml
hostname := `sed -n 's/^[[:space:]]*hostname[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' allsettings/system.toml 2>/dev/null | head -n 1`
username := `sed -n 's/^[[:space:]]*username[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' allsettings/system.toml 2>/dev/null | head -n 1`

# Default recipe: List available commands
default:
    @just --list

# Bootstrap fresh installation: render all templates directly into config/
bootstrap:
    ./bin/sl-render
    @echo "✔ System dotfiles rendered successfully"


# -----------------------------------------------------------------------------
# 📄 Template & Theme Management (Jinja Engine)
# -----------------------------------------------------------------------------

# Render all Jinja templates into config/
render:
    ./bin/sl-render


# Switch desktop theme interactively or by name (e.g. `just theme tokyo-night`)
theme name="":
    #!/usr/bin/env bash
    if [ -z "{{name}}" ]; then
        bin/theme-switcher
    else
        bin/theme-switcher --set "{{name}}"
    fi

# List all available desktop themes
themes:
    bin/theme-switcher --list

# Cache and set active wallpaper image (e.g. `just wallpaper assets/wallpaper.jpg`)
wallpaper image="":
    #!/usr/bin/env bash
    if [ -z "{{image}}" ]; then
        bin/cache-wallpaper assets/wallpaper.jpg
    else
        bin/cache-wallpaper "{{image}}"
    fi


# -----------------------------------------------------------------------------
# ❄️ NixOS System Management
# -----------------------------------------------------------------------------

# Rebuild and switch to the new NixOS system configuration
switch:
    sudo nixos-rebuild switch --flake .#{{hostname}}

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

# Build Home Manager activation package without switching
home-build:
    nix build .#homeConfigurations.{{username}}.activationPackage

# Rebuild both NixOS system and Home Manager configurations
sync:
    sudo nixos-rebuild switch --flake .#{{hostname}}
    home-manager switch --flake .#{{username}}


# -----------------------------------------------------------------------------
# 🛠️ Flake & Code Quality
# -----------------------------------------------------------------------------

# Format all Nix, Lua, Shell, Fish, and TOML files using treefmt
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

# Clean up build artifacts, GC roots, and result symlinks
clean:
    rm -rf result result-*
    echo "✔ Temporary build artifacts and result links cleaned"

# Run Nix garbage collection and optimize the /nix/store
gc:
    nix-collect-garbage --delete-older-than 7d
    nix store optimise
    echo "✔ Nix store garbage collected and hard-links optimized"

# Symlink contents of config/ to ~/.config/ (standalone outside HM)
symlink:
    bin/config-sync config-symlink-to-xdgconfig

# Prune broken legacy symlinks in ~/.config
clean-symlinks:
    find ~/.config -xtype l -delete
    @echo "✔ Pruned broken symlinks from ~/.config"

