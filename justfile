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
        bin/wallpaper assets/wallpaper.jpg
    else
        bin/wallpaper "{{image}}"
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

# Preview package and closure differences between current system and new build
diff:
    @echo "🔍 Building NixOS toplevel and calculating closure diff..."
    @nix build .#nixosConfigurations.{{hostname}}.config.system.build.toplevel --no-link
    @nix store diff-closures /run/current-system $(nix path-info .#nixosConfigurations.{{hostname}}.config.system.build.toplevel)

# Build a QEMU VM runner for testing the configuration
vm:
    nixos-rebuild build-vm --flake .#{{hostname}}


# -----------------------------------------------------------------------------
# 🏠 Home Manager Management
# -----------------------------------------------------------------------------

# Switch to the standalone Home Manager configuration (pre-rendering templates)
home: render
    home-manager switch --flake .#{{username}}

# Build Home Manager activation package without switching
home-build:
    nix build .#homeConfigurations.{{username}}.activationPackage

# Rebuild both NixOS system and Home Manager configurations (pre-rendering templates)
sync: render
    sudo nixos-rebuild switch --flake .#{{hostname}}
    home-manager switch --flake .#{{username}}


# -----------------------------------------------------------------------------
# 🛠️ Flake & Code Quality
# -----------------------------------------------------------------------------

# Format all Nix, Lua, Shell, Fish, and TOML files using treefmt
fmt:
    nix fmt

# Run allsettings TOML syntax validation and flake check
check:
    python3 -c "import tomllib, glob; [tomllib.load(open(f, 'rb')) for f in glob.glob('allsettings/*.toml')]; print('✔ All allsettings TOML tokens valid')"
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

# Prune broken legacy symlinks in ~/.config
clean-symlinks:
    find ~/.config -xtype l -delete
    @echo "✔ Pruned broken symlinks from ~/.config"

# Prune stale Home Manager backup files and directories in ~/.config
clean-backups:
    find ~/.config -maxdepth 1 \( -name "*.hm.backup-*" -o -name "*.backup" -o -name "*-bak" \) -exec rm -rf {} +
    @echo "✔ Cleaned stale backup files from ~/.config"


