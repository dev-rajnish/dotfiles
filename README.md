# ❄️ NixOS & Home Manager Flake Config (Shoelace)

![NixOS](https://img.shields.io/badge/NixOS-26.05-blue?logo=nixos)
![Home Manager](https://img.shields.io/badge/Home--Manager-26.05-red?logo=nixos)
![Wayland](https://img.shields.io/badge/Wayland-Niri-orange)
![Theming](https://img.shields.io/badge/Theme-Stylix%20Base16-purple)
![Task Runner](https://img.shields.io/badge/Runner-Just-brightgreen)

---

## ✨ Key Features & Highlights

- **NixOS 26.05 Flake**: Fully reproducible system and Home Manager architecture.
- **Single Source of Truth (`env/`)**: Unified TOML identity tokens for system options, typography, layouts, and apps.
- **Niri Wayland Compositor**: Scrollable column tiling layout with UWSM session execution.
- **Pure-Lua Template Engine (`sl-render`)**: Fast Mustache renderer parsing TOML tokens into `config/`.
- **Dynamic Base16 Theming**: 15 pre-configured color schemes selectable via Fuzzel (`just theme`).
- **Live Symlinks (`mkOutOfStoreSymlink`)**: Instant dotfile updates without store rebuilding.
- **Central Package Manifest (`env/packages.nix`)**: Categorized user and system Nix package listings.
- **Modern Shell Suite**: Fish shell, Starship prompt, custom completions, and `Distrobox` integration.
- **Comprehensive Hardware & Virtualization**: AMD GPU, PipeWire audio, Kanata remapper, `iwd` Wi-Fi, AppImage & Libvirt QEMU/KVM support.

---

## 🚀 Installation Guide

### 1. Installation on a Fresh NixOS Minimal ISO

> [!IMPORTANT]
> Ensure active internet connection before starting (`iwctl` for Wi-Fi or wired Ethernet).

- **Step 1: Partition & Format Disks**

  ```bash
  # Partition disk (e.g. /dev/nvme0n1 or /dev/sda)
  sudo parted /dev/nvme0n1 -- mklabel gpt
  sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
  sudo parted /dev/nvme0n1 -- set 1 boot on
  sudo parted /dev/nvme0n1 -- mkpart primary ext4 512MiB 100%

  # Format partitions
  sudo mkfs.fat -F32 -n boot /dev/nvme0n1p1
  sudo mkfs.ext4 -L nixos /dev/nvme0n1p2
  ```

- **Step 2: Mount Storage**

  ```bash
  sudo mount /dev/disk/by-label/nixos /mnt
  sudo mkdir -p /mnt/boot
  sudo mount /dev/disk/by-label/boot /mnt/boot
  ```

- **Step 3: Generate Hardware Config & Clone Flake**

  ```bash
  sudo nixos-generate-config --root /mnt
  sudo git clone https://github.com/your-username/shoelace.git /mnt/etc/nixos/shoelace
  cd /mnt/etc/nixos/shoelace
  ```

- **Step 4: Copy Hardware & Edit Identity Tokens**

  ```bash
  # Copy generated hardware profile
  sudo cp /mnt/etc/nixos/hardware-configuration.nix nixos/hardware/hardware-configuration.nix

  # Configure hostname, username, and user identity
  nano env/tokens/system.toml
  ```

- **Step 5: Execute System Installation**

  ```bash
  # Install NixOS system using Flake output
  sudo nixos-install --flake .#nixos

  # Reboot into installed system
  sudo reboot
  ```

---

### 2. Installation on a Running NixOS System

> [!NOTE]
> Backup any existing `~/.config` files prior to applying configuration.

- **Step 1: Clone Repository**

  ```bash
  git clone https://github.com/your-username/shoelace.git ~/shoelace
  cd ~/shoelace
  ```

- **Step 2: Update System Identity Tokens**

  ```bash
  # Edit hostname and username tokens to match target system
  $EDITOR env/tokens/system.toml
  ```

- **Step 3: Build & Switch Configuration**

  ```bash
  # Rebuild NixOS system
  just switch

  # Apply standalone Home Manager profile
  just home

  # Or rebuild both system and user space concurrently
  just sync
  ```

- **Step 4: Render Application Templates & Set Theme**
  ```bash
  just render
  just theme tokyo-night
  ```

---

## 📖 User Guide

### 1. First-Time Setup & Post-Installation

- **Validate Flake & Render Templates**:

  ```bash
  just check
  just render
  ```

- **Select Initial Color Theme**:

  ```bash
  just theme catppuccin-mocha
  ```

- **Verify User Environment**:
  - Open terminal (`Kitty`) to launch `Fish` shell with `Starship` prompt.
  - Verify executable helper scripts in `bin/` (`sl-render`, `theme-switcher`, `power-menu`).

---

### 2. Daily Life Usage & Task Runner (`just`)

- **🎨 Theming & Template Rendering**:
  - `just render`: Re-render Mustache templates from `env/tokens/` into `config/`.
  - `just theme`: Launch interactive Fuzzel theme selector menu.
  - `just theme [name]`: Apply specific theme directly (e.g. `just theme tokyo-night`).
  - `just themes`: List all 15 available Base16 color themes in `env/themes/`.

- **❄️ NixOS System Management**:
  - `just switch`: Rebuild and switch NixOS system configuration (`sudo nixos-rebuild switch --flake .#nixos`).
  - `just test`: Test configuration build without adding a new bootloader entry.
  - `just boot`: Build system and set as bootloader default without switching live.
  - `just build`: Test build NixOS system toplevel derivation (outputs `./result`).
  - `just vm`: Build and launch QEMU virtual machine instance of configuration.

- **🏠 Home Manager Management**:
  - `just home`: Apply standalone Home Manager user profile (`home-manager switch --flake .#rsh`).
  - `just home-build`: Build Home Manager activation package without switching.
  - `just sync`: Rebuild both NixOS system and Home Manager concurrently.

- **🛠️ Code Quality & Maintenance**:
  - `just fmt`: Format Nix, Lua, Shell, Fish, and TOML code via `treefmt` (`nix fmt`).
  - `just check`: Run `nix flake check` to evaluate system syntax and formatting health.
  - `just update [input]`: Update all flake inputs or a specific input (e.g. `just update nixpkgs`).
  - `just gc`: Delete Nix store generations older than 7 days and optimize store hard links.
  - `just clean`: Remove temporary build symlinks (`result*`).

---

### 3. How to Edit & Customize Your Config

- **Editing System Tokens (`env/tokens/`)**:
  - `system.toml`: Hostname, username, user description, locale, time zone.
  - `apps.toml`: Default application preferences (terminal, editor, browser, viewer).
  - `theme.toml`: Active theme selection and polarity (`dark` / `light`).
  - `ui.toml`: Fonts, icon packs, cursor theme, and scaling factors.
  - `keybinds.toml`: Keybindings for compositor and application shortcuts.
  - `layout-and-window.toml`: Gaps, borders, window rules, and opacity.

- **Editing Live Application Dotfiles (`config/`)**:
  - Direct target configs live in `config/` (`fish/`, `kitty/`, `niri/`, `yazi/`, `swaylock/`, etc.).
  - Symlinked live to `~/.config/` via `mkOutOfStoreSymlink` for instant changes without rebuilds.

- **Modifying Configuration Templates (`env/templates/`)**:
  - Edit Mustache templates (`*.mustache`) to customize generated output structure.
  - Run `just render` to populate updated configurations into `config/`.

- **Adding New Nix Packages (`env/packages.nix`)**:
  - Open `env/packages.nix`.
  - Append package attribute names to `systemPackages` or `userPackages`.
  - Apply changes via `just sync`.

- **Adding Custom System or User Modules**:
  - System modules: Create `.nix` file in `nixos/` and reference in `nixos/configuration.nix`.
  - User modules: Create `.nix` file in `home-manager/modules/` and reference in `home-manager/home.nix`.

---

## 📂 Repository Structure (Depth 2)

```
.
├── bin/                       # Executable helper scripts
│   ├── power-menu             # Wayland session logout / power menu script
│   ├── sl-render              # Pure Lua Mustache template renderer engine
│   └── theme-switcher         # Fuzzel interactive Base16 theme switcher
├── config/                    # Live application dotfiles (symlinked directly to ~/.config)
│   ├── autostart-script       # Startup script launcher for desktop apps
│   ├── fastfetch/             # System information display configuration
│   ├── fish/                  # Fish shell config & completion scripts
│   ├── fuzzel/                # Wayland application launcher settings
│   ├── glow/                  # Terminal Markdown previewer settings
│   ├── kitty/                 # Kitty terminal emulator configuration
│   ├── niri/                  # Niri Wayland compositor settings & window rules
│   ├── nvim/                  # Neovim text editor configuration
│   ├── qutebrowser/           # Declarative Qutebrowser configuration
│   ├── starship.toml          # Cross-shell prompt layout configuration
│   ├── swayidle/              # Idle daemon and screen dimming rules
│   ├── swaylock/              # Screen locker styling configuration
│   ├── Thunar/                # Graphical file manager settings
│   ├── wayle/                 # Wayle status bar configuration
│   ├── waypaper/              # Wayland wallpaper manager settings
│   ├── wlogout/               # Wayland logout menu configuration
│   ├── xfce4/                 # XFCE desktop framework configuration
│   └── yazi/                  # Yazi terminal file manager configuration
├── env/                       # Single Source of Truth configuration system
│   ├── default.nix            # Environment loader parsing TOML token files
│   ├── packages.nix           # Categorized Nix system and user package manifests
│   ├── shoelace.config        # Template engine configuration parameters
│   ├── shoelace.toml          # Central template rendering map
│   ├── templates/             # Mustache templates rendered into config/
│   ├── themes/                # Base16 color palette library (15 themes)
│   └── tokens/                # Modular TOML configuration tokens
├── home-manager/              # Home Manager user-level configuration
│   ├── home.nix               # User profile entrypoint module
│   ├── modules/               # Stylix, symlinking, shell & app modules
│   └── pkgs/                  # Custom Nix package derivations
├── nixos/                     # NixOS system-level configuration
│   ├── configuration.nix      # NixOS system entrypoint module
│   ├── core/                  # Core settings, user accounts & fish shell
│   ├── desktop/               # Desktop portals, Polkit, Kanata & Greetd
│   ├── hardware/              # GPU, PipeWire, Bluetooth & bootloader modules
│   └── virtualization/        # AppImage, Distrobox & Libvirt QEMU settings
├── flake.lock                 # Immutable lockfile for flake dependencies
├── flake.nix                  # Flake entrypoint mapping nixos & home configs
├── justfile                   # Daily task runner recipes
└── README.md                  # Project documentation and guide
```

---

## 🤝 Thank You!

> [!TIP]
> **Thank you for using Shoelace NixOS & Home Manager Flake Config!**
>
> - Feedback, issues, and star contributions are warmly welcomed! 🚀✨
