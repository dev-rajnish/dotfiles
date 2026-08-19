# ❄️ NixOS & Home Manager Dotfiles (Shoelace)

A high-performance, modular **NixOS 26.05** & **Home Manager** flake featuring the **Niri** scrollable Wayland compositor, **Stylix Base16** dynamic theming, **Fish Shell**, **Lua Template Engine**, **Kitty**, **Wayle**, **nix-ld** dynamic binary linking, **iwd** ultra-fast networking, and container virtualization.

---

## 📖 Architecture & Workflow: Single Source of Truth & Live Symlinks

This repository uses **`env/`** as the **Single Source of Truth** and **Home Manager `mkOutOfStoreSymlink`** for instant live editing:

```
┌────────────────────────────────┐         lua bin/sl-render        ┌────────────────────────────────┐
│   env/token.kv/ (*.toml)       │ ───────────────────────────────> │   config/ (~/.config)          │
│   • Single Source of Truth     │                                  │   • Direct Live Symlinks       │
│   • Themes, UI, Keybinds, Apps │ <─────────────────────────────── │   • Committed to Git repository│
└────────────────────────────────┘      config.lib.file.mkOutOfStore │   • Instant Hot Reloading      │
                                              Symlink               └────────────────────────────────┘
```

### 1. How It Works

- **`env/`**: Single source of truth. Contains modular TOML tokens (`system.toml`, `theme.toml`, `ui.toml`, `keybinds.toml`, `layout-and-window.toml`, `apps.toml`, `shell.d/`) and package manifests (`packages.nix`).
- **`config/`**: Clean, git-tracked application configurations symlinked directly to `~/.config/` via `mkOutOfStoreSymlink`.
- **`templates/`**: Mustache templates for Niri, Kitty, Fuzzel, Wayle, Swaylock, and Fish.
- **`bin/sl-render`**: Lightweight pure-Lua template renderer that parses `env/token.kv/*.toml` and renders `templates/` into `config/`.
- **`bin/theme-switcher`**: Interactive Fuzzel theme switcher that selects themes from `env/themes/`, updates `env/token.kv/theme.toml`, and regenerates configs on the fly.

---

## ⌨️ Daily Commands (`just`)

| Category                | Command             | Description                                                                              |
| :---------------------- | :------------------ | :--------------------------------------------------------------------------------------- |
| **🎨 Theming & Render** | `just render`       | Re-render all Mustache templates from `env/` tokens into `config/`                       |
|                         | `just theme [name]` | Interactive Fuzzel theme switcher or apply theme by name (e.g. `just theme tokyo-night`) |
|                         | `just themes`       | List all 15 available themes in `env/themes/`                                            |
| **❄️ System**           | `just switch`       | Rebuild and switch NixOS system (`sudo nixos-rebuild switch --flake .#nixos`)            |
|                         | `just test`         | Test configuration without adding a new bootloader entry                                 |
|                         | `just boot`         | Build system and add to bootloader menu without switching immediately                    |
|                         | `just build`        | Build NixOS system toplevel derivation (outputs `./result`)                              |
|                         | `just vm`           | Build and run a QEMU VM instance of your configuration                                   |
| **🏠 Home Manager**     | `just home`         | Switch standalone Home Manager profile (`home-manager switch --flake .#rsh`)             |
|                         | `just sync`         | Rebuild both NixOS system and Home Manager configurations                                |
| **🛠️ Code Quality**     | `just fmt`          | Format all Nix, Lua, Shell, Fish, and TOML code with `treefmt`                           |
|                         | `just check`        | Run `nix flake check` to validate evaluations and formatting                             |
|                         | `just update`       | Update flake inputs and dependencies (`nix flake update`)                                |
| **🧹 Maintenance**      | `just gc [days=7d]` | Collect old generations (default 7 days) and optimize Nix store                          |
|                         | `just clean`        | Remove temporary build symlinks (`result`, `result-*`)                                   |

---

## 🛠️ How to Configure This System

### Unified Environment System ([`env/`](env/))

All system settings, design tokens, default applications, and package sets are modularized inside `env/`:

- **[`env/default.nix`](env/default.nix)**: Single entrypoint loader merging all `env/token.kv/*.toml` into `env`.
- **[`env/token.kv/system.toml`](env/token.kv/system.toml)**: Host platform, user identity, and locale.
- **[`env/token.kv/apps.toml`](env/token.kv/apps.toml)**: Default desktop application handlers (terminal, editor, browser, viewer, player).
- **[`env/token.kv/theme.toml`](env/token.kv/theme.toml)**: Active desktop theme palette and dark/light polarity.
- **[`env/token.kv/ui.toml`](env/token.kv/ui.toml)**: Typography, sizes, cursor, and icon theme.
- **[`env/token.kv/keybinds.toml`](env/token.kv/keybinds.toml)**: Global desktop & compositor keybindings.
- **[`env/token.kv/layout-and-window.toml`](env/token.kv/layout-and-window.toml)**: Window rules, border radii, gaps, and opacity.
- **[`env/token.kv/shell.d/`](env/token.kv/shell.d/)**: Shell aliases, environment variables, and PATH entries.
- **[`env/packages.nix`](env/packages.nix)**: Categorized Nix package manifest for system and user packages.
- **[`env/themes/`](env/themes/)**: 15 pre-configured desktop themes (Catppuccin, Tokyo Night, Gruvbox, Rosé Pine, Nord, Dracula, etc.).

---

## 📂 Architecture Map

```
.
├── bin/                       # 🚀 Clean Lua & Shell executable helper scripts
│   ├── sl-render              # Pure Lua TOML + Mustache template renderer
│   ├── theme-switcher         # Interactive Fuzzel theme switcher
│   └── power-menu             # Wayland power and session menu
│
├── config/                    # 📂 Authoritative dotfiles (symlinked to ~/.config via mkOutOfStoreSymlink)
│   ├── fish/                  # Fish shell config & conf.d/
│   ├── fuzzel/                # Fuzzel application launcher config
│   ├── kitty/                 # Kitty terminal emulator config
│   ├── niri/                  # Niri Wayland compositor config & window rules
│   ├── nvim/                  # Neovim configuration
│   ├── qutebrowser/           # Qutebrowser configuration
│   ├── swaylock/              # Swaylock lock screen config
│   ├── wayle/                 # Wayle status bar config
│   ├── yazi/                  # Yazi terminal file manager
│   ├── wlogout/               # Wlogout session menu
│   └── starship.toml          # Cross-shell Starship prompt
│
├── env/                       # 🌐 Single Source of Truth
│   ├── default.nix            # Nix environment loader
│   ├── packages.nix           # Consolidated system & user package manifest
│   ├── themes/                # Theme palette library (15 TOML themes)
│   └── token.kv/              # Modular TOML configuration tokens
│
├── templates/                 # 📄 Mustache templates rendered into config/
│   ├── fish/
│   ├── fuzzel/
│   ├── kitty/
│   ├── niri/
│   ├── swaylock/
│   └── wayle/
│
├── home-manager/              # 🏠 User environment modules
│   ├── home.nix               # User entrypoint
│   ├── modules/               # Stylix, Symlinks (mkOutOfStoreSymlink), Shell, Packages
│   └── pkgs/                  # Custom package derivations
│
├── nixos/                     # ❄️ NixOS system modules
│   ├── configuration.nix      # System entrypoint
│   ├── core/                  # User accounts, fish shell default, networking, nix settings
│   ├── desktop/               # Greetd login, Kanata keyboard remap, Polkit, portals
│   ├── hardware/              # AMD GPU, PipeWire audio, Bluetooth, bootloader
│   └── virtualization/        # AppImage runner, Distrobox, Libvirt QEMU/KVM
│
├── flake.nix                  # Flake entrypoint & outputs
└── justfile                   # Daily task runner
```
