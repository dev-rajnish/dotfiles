# ❄️ NixOS & Home Manager Dotfiles

A high-performance, modular **NixOS 26.05** and **Home Manager** flake configuration powered by the **Niri** scrollable-tiling Wayland compositor, **Stylix Tokyo Night** theming, **nix-ld** dynamic linking, sandboxed **FHS development environments**, and robust **Virtualization** (Podman, Waydroid, QEMU/KVM).

---

## ✨ System Architecture & Highlights

| Subsystem            | Technology / Feature                          | Description                                                                        |
| :------------------- | :-------------------------------------------- | :--------------------------------------------------------------------------------- |
| **Compositor**       | [Niri](https://github.com/YaLTeR/niri)        | Modern scrollable-tiling Wayland compositor with gesture navigation                |
| **Shell & Terminal** | Fish + Starship + Kitty                       | Fast, intelligent terminal with auto-suggestions and Atuin history                 |
| **Status Bar**       | [Wayle](https://github.com/dev-rajnish/wayle) | Modular, customizable Wayland status panel                                         |
| **Theming**          | [Stylix](https://github.com/danth/stylix)     | Tokyo Night dark theme with GTK3, Qt6ct, Tela-Circle icons & Bibata cursor         |
| **Dynamic Linker**   | `nix-ld`                                      | Direct host support for unpatched ELF binaries (Mason LSPs, formatters, npm)       |
| **Sandboxed Dev**    | `buildFHSEnv`                                 | Isolated traditional Linux hierarchy (`/usr/include`, `/lib64`) for Rustup & Cargo |
| **Browser Suite**    | LibreWolf & Zen Browser                       | Declarative GPU-accelerated LibreWolf (permanent cookies) + Zen Browser            |
| **GPU Optimization** | AMD Radeon 680M (Rembrandt)                   | Early KMS, 32-bit acceleration & PSR screen flicker fix (`dcdebugmask=0x10`)       |
| **Live Symlinks**    | Out-of-Store Linking                          | `dot_config/*` directly linked to `~/.config/*` for instantaneous live editing     |
| **Virtualization**   | Podman, Waydroid & QEMU/KVM                   | Rootless Docker-compatible containers, Android LXC, & VirtIO-FS Libvirt VMs        |

---

## 📂 Repository Structure

```
.
├── flake.nix                          # Flake inputs, treefmt definitions & system outputs
├── 0-var.nix                          # Single source of truth for user/host metadata
├── 1-pkg-list.nix                     # Categorized package lists for NixOS, HM & nix-ld
├── justfile                           # Task runner for building, formatting, and maintenance
├── only-first-time-install.sh         # Bootstrap script for initial NixOS installations
├── README.md
│
├── nixos/
│   ├── configuration.nix              # Main NixOS entrypoint (dynamic module loader)
│   ├── hardware-configuration.nix     # Host-specific disk and hardware settings
│   │
│   ├── core/                          # Core system services
│   │   ├── dotfiles.nix               # Automatic fallback dotfiles installer
│   │   ├── networking.nix             # Hostname, NetworkManager & NFTables firewall
│   │   ├── nix-settings.nix           # Flake flags, binary caches & automatic weekly GC
│   │   ├── time-and-locale.nix        # Timezone (Asia/Kolkata) & locale configurations
│   │   └── users.nix                  # User accounts, groups & Fish default shell
│   │
│   ├── desktop/                       # Desktop environment & UI foundations
│   │   ├── fonts.nix                  # TTY font (ter-v28b) & desktop Nerd Fonts
│   │   ├── kmonad.nix                 # Low-level keyboard layer manager
│   │   ├── programs-and-services.nix  # nix-ld runtime, system packages & direnv
│   │   └── xdg-portals.nix            # GNOME/GTK desktop portals for screen capture & pickers
│   │
│   ├── hardware/                      # Hardware-level drivers & kernel settings
│   │   ├── amd-igpu.nix               # AMD GPU drivers, VA-API acceleration & PSR flicker fix
│   │   └── boot-and-services.nix      # Systemd-boot EFI, ZRAM swap, PipeWire & power management
│   │
│   └── virtualization/                # Virtualization and container engines
│       └── containers-and-vms.nix     # Podman, Waydroid, QEMU/KVM Libvirt & VM testing variant
│
├── home-manager/
│   ├── home.nix                       # Main Home Manager entrypoint (dynamic module loader)
│   │
│   ├── modules/                       # Reusable user modules & configurations
│   │   ├── fhs.nix                    # Sandboxed FHS environment for Rust toolchains
│   │   ├── git.nix                    # Git user credentials & store helper
│   │   ├── programs-and-services.nix  # Consolidated hmPackages, Eza, Zoxide, Atuin & Wayle
│   │   ├── stylix.nix                 # Tokyo Night Stylix palette, GTK3 & Qt6ct theming
│   │   └── xdg-live-config-symlinks.nix # Out-of-store live symlink engine (~/.config)
│   │
│   └── pkgs/                          # Standalone custom package derivations
│       ├── agy.nix                    # Antigravity CLI (Agentic AI Coding Assistant)
│       ├── default-apps.nix           # XDG default MIME handlers & PlainApp launcher
│       ├── librewolf.nix              # Declarative LibreWolf with extensions & permanent cookies
│       ├── obs.nix                    # OBS Studio with Wayland & AMD VA-API plugins
│       └── zen-browser.nix            # Zen Browser beta with Catppuccin theme
│
├── scripts/
│   ├── copy-hardware.sh               # Hardware configuration copier (cat | tee)
│   └── update-agy.sh                  # Automated updater for Antigravity CLI package
│
└── dot_config/                        # Live-symlinked user configuration files
    ├── fish/                          # Fish shell configuration, aliases & functions
    ├── fuzzel/                        # Fast Wayland application launcher
    ├── kitty/                         # GPU-accelerated terminal emulator
    ├── niri/                          # Niri compositor config (modular .kdl files)
    ├── nvim/                          # Neovim configuration (LazyVim / Mason)
    ├── waybar/ & wayle/               # Status bar widgets and styling
    └── ...
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

## 🛠️ Customization & Live Editing

- **Adding Packages**: Edit [`1-pkg-list.nix`](1-pkg-list.nix). All packages automatically propagate to NixOS (`systemCore`) or Home Manager (`hmPackages`).
- **Live Dotfiles Editing**: All directories in `dot_config/*` are live-symlinked to `~/.config/*`. Any edit saved in `dot_config/` takes effect immediately without rebuilding!
- **Unpatched Binaries & LSPs**: Mason and precompiled tools run directly on the host via `nix-ld`.
- **Sandboxed Builds**: Run `fhs-env` or launch tools inside `~/.local/bin/fhs-env/` for isolated traditional Linux builds.
