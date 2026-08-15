# ❄️ NixOS & Home Manager Dotfiles

A high-performance, modular **NixOS 26.05** and **Home Manager** flake configuration powered by the **Niri** scrollable-tiling Wayland compositor, **Tokyo Night** aesthetic styling, **nix-ld** dynamic linking, sandboxed **FHS development environments**, and robust **Virtualization** (Podman, Waydroid, QEMU/KVM).

---

## ✨ System Architecture & Highlights

| Subsystem                | Technology / Feature                             | Description                                                                             |
| :----------------------- | :----------------------------------------------- | :-------------------------------------------------------------------------------------- |
| **Compositor**           | [Niri](https://github.com/YaLTeR/niri)           | Scrollable-tiling Wayland compositor with gesture navigation & animations               |
| **Shell & Terminal**     | Fish + Starship + Kitty                          | Blazing fast terminal with Tokyo Night theme, Atuin shell sync & Zoxide jumping         |
| **Status Bar**           | [Wayle](https://github.com/dev-rajnish/wayle)    | Modern, customizable Wayland status panel                                               |
| **Application Launcher** | [Fuzzel](https://codeberg.org/dnkl/fuzzel)       | Sharp 0px Tokyo Night app launcher with instant fuzzy search                            |
| **Session / Power Menu** | [Wlogout](https://github.com/ArtsyMacaw/wlogout) | Custom 6-column sharp power menu (Back, Lock, Logout, Suspend, Reboot, Shutdown)        |
| **Theming**              | [Stylix](https://github.com/danth/stylix)        | Tokyo Night Dark theme with GTK3, Qt, Tela-Circle icons & Bibata Modern cursors         |
| **Dynamic Linker**       | `nix-ld`                                         | Native host support for unpatched ELF binaries (Mason LSPs, Electron, UV, AppImages)    |
| **Sandboxed Dev**        | `buildFHSEnv`                                    | Isolated traditional Linux hierarchy (`/usr/include`, `/lib64`) for C-libraries & tools |
| **Toolchains & Dev**     | Rust, Python, JS/TS, Zig, Go                     | `rustup` minimal profile + `clippy`, `uv`, `nodejs_22`, `bun`, `deno`, formatters       |
| **Browser Suite**        | LibreWolf & Zen Browser                          | Default GPU-accelerated LibreWolf with persistent cookies + Zen Browser Beta            |
| **GPU Optimization**     | AMD Radeon 680M (Rembrandt)                      | Early KMS, Vulkan/VA-API acceleration & PSR screen flicker fix                          |
| **Live Symlinks**        | Out-of-Store Linking                             | `dot_config/*` directly linked to `~/.config/*` for instantaneous live editing          |
| **Virtualization**       | Podman, Waydroid & QEMU/KVM                      | Rootless containers, Android LXC environment & VirtIO-FS Libvirt virtual machines       |

---

## 📂 Repository Structure

```
.
├── flake.nix                          # Flake inputs, treefmt definitions & system outputs
├── 0-var.nix                          # Global variables & feature toggles (Single Source of Truth)
├── 1-pkg-list.nix                     # Modular package lists (CLI, GUI, Dev, Languages, nix-ld)
├── justfile                           # Task runner for building, formatting, testing and switching
├── only-first-time-install.sh         # Bootstrap script for initial NixOS installations
├── README.md
│
├── nixos/
│   ├── configuration.nix              # Main NixOS entrypoint (dynamic module loader)
│   ├── hardware-configuration.nix     # Host-specific disk and hardware partitions
│   │
│   ├── core/                          # Core system services
│   │   ├── dotfiles.nix               # Fallback dotfiles installer
│   │   ├── networking.nix             # NetworkManager, Avahi mDNS, Cloudflare DNS & NFTables
│   │   ├── nix-settings.nix           # Flakes flags, binary caches & automatic weekly GC
│   │   ├── time-and-locale.nix        # Timezone (Asia/Kolkata) & locale configurations
│   │   └── users.nix                  # User accounts, permission groups & Fish default shell
│   │
│   ├── desktop/                       # Desktop environment & UI foundations
│   │   ├── display-manager.nix        # Display manager configurations (Ly, Greetd, SDDM)
│   │   ├── kmonad.nix                 # Low-level keyboard layer remap daemon
│   │   ├── only-polkit-no-keyring.nix # Polkit authentication agent & passwordless udisks2
│   │   ├── programs-and-services.nix  # nix-ld runtime, system packages & direnv
│   │   └── xdg-portals.nix            # GNOME/GTK desktop portals for screen capture & pickers
│   │
│   ├── hardware/                      # Hardware-level drivers & kernel settings
│   │   ├── amd-igpu.nix               # AMD GPU drivers, VA-API acceleration & PSR flicker fix
│   │   ├── bluetooth.nix              # BlueZ daemon, battery reporting & Blueman integration
│   │   ├── boot-kernel-and-services.nix # Systemd-boot EFI, ZRAM swap, PipeWire & audio
│   │   └── disable-lid.nix            # Laptop lid-close action suppression
│   │
│   └── virtualization/                # Virtualization and container engines
│       └── containers-and-vms.nix     # Podman, Waydroid, QEMU/KVM Libvirt & VM testing variant
│
├── home-manager/
│   ├── home.nix                       # Main Home Manager entrypoint (dynamic module loader)
│   │
│   ├── modules/                       # Reusable user modules & configurations
│   │   ├── fhs.nix                    # Sandboxed FHS environment for C-headers & builds
│   │   ├── git.nix                    # Git user credentials & credential helper
│   │   ├── programs-and-services.nix  # hmPackages, Eza, Zoxide, Atuin & Wayle services
│   │   ├── stylix.nix                 # Tokyo Night Stylix palette, GTK3 & Qt6ct theming
│   │   ├── xdg-live-config-symlinks.nix # Out-of-store live symlink engine (~/.config)
│   │   └── xdg-mime-apps.nix          # XDG default applications & MIME type associations
│   │
│   └── pkgs/                          # Standalone custom package derivations
│       ├── agy.nix                    # Antigravity CLI (Agentic AI Coding Assistant)
│       ├── librewolf.nix              # Declarative LibreWolf with extensions & persistent cookies
│       ├── obs.nix                    # OBS Studio with Wayland & AMD VA-API hardware plugins
│       ├── plain-app.nix              # PlainApp PWA hotspot helper & desktop launcher
│       └── zen-browser.nix            # Zen Browser Beta with Catppuccin theme
│
├── scripts/
│   ├── copy-hardware.sh               # Hardware configuration copier (cat | tee)
│   └── update-agy.sh                  # Automated updater for Antigravity CLI package
│
└── dot_config/                        # Live-symlinked user configuration files (~/.config)
    ├── autostart-script/              # WM startup and background session scripts
    ├── fastfetch/                     # Fastfetch logo and hardware specs layout
    ├── fish/                          # Fish shell configuration, themes & functions
    ├── fuzzel/                        # Sharp Tokyo Night application launcher
    ├── kitty/                         # GPU-accelerated terminal emulator & keymaps
    ├── niri/                          # Niri compositor config (modular .kdl files)
    ├── nvim/                          # Neovim configuration (LazyVim / Mason / Treesitter)
    ├── qutebrowser/                   # Keyboard-driven browser configuration
    ├── wayle/                         # Status bar layout and widgets
    ├── wlogout/                       # Sharp 6-column power and lock menu
    ├── yazi/                          # Terminal file manager configuration & flavors
    └── colors/                        # Modular Tokyo Night color definitions across formats
```

---

## 🚀 Quick Start & Usage

### 1. Fresh Machine Installation

On a newly installed NixOS system:

```bash
# 1. Clone your dotfiles
git clone https://github.com/dev-rajnish/dotfiles.git ~/_ws/dotfiles
cd ~/_ws/dotfiles

# 2. Bootstrap system & user environment
./only-first-time-install.sh
```

### 2. Daily Workflow with `just`

The configuration includes a `justfile` task runner for all routine operations:

| Command                      | Description                                                                        |
| :--------------------------- | :--------------------------------------------------------------------------------- |
| `just`                       | List all available recipes                                                         |
| `just switch` / `just nixos` | Rebuild and switch NixOS system (`sudo nixos-rebuild switch --flake .#nixos`)      |
| `just home` / `just hm`      | Switch standalone Home Manager configuration (`home-manager switch --flake .#rsh`) |
| `just all` / `just sync`     | Rebuild and activate both NixOS system and Home Manager                            |
| `just test`                  | Test configuration in memory without adding to bootloader                          |
| `just boot`                  | Build configuration and set as default for next boot                               |
| `just vm`                    | Launch a fast QEMU VM instance to test the flake in isolation                      |
| `just fmt`                   | Format all Nix, Fish, Lua, TOML, and Shell files via `treefmt`                     |
| `just check`                 | Run `nix flake check` to validate build outputs and formatting                     |
| `just update [input]`        | Update Antigravity CLI and flake inputs                                            |
| `just gc [days]`             | Collect garbage and optimize Nix store (default `7d`)                              |
| `just generations`           | View recent NixOS and Home Manager generation history                              |

---

## 🛠️ Customization & System Tuning

- **Single Source of Truth ([`0-var.nix`](0-var.nix))**: Manage system users, hostnames, default applications (`browser = "librewolf"`, `terminal = "kitty"`), and feature toggles (`enableProgrammingLang`, `enableDevPkg`, `enableWaydroid`, `enableLibvirt`, `enableBluetooth`, `enableTailscale`, `enableFirewall`) in one place.
- **Categorized Packages ([`1-pkg-list.nix`](1-pkg-list.nix))**: Clean modular package management across system core, CLI tools, GUI apps, programming languages, formatters, and development tools.
- **Live Dotfiles Symlinking**: All directories in `dot_config/*` are live-symlinked to `~/.config/*`. Any edit saved in `dot_config/` takes effect immediately without rebuilding!
- **Unpatched Binaries & LSPs**: Precompiled binaries, Mason LSPs, and tools run natively on the host via comprehensive `nix-ld` shared library bindings.
- **Sandboxed FHS Environment**: Run `fhs-env` for isolated traditional Linux headers (`/usr/include`, `/usr/lib`) when compiling C-bound libraries.
