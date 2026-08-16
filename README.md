# ❄️ NixOS & Home Manager Dotfiles

A high-performance, modular **NixOS 26.05** & **Home Manager** flake featuring the **Niri** scrollable Wayland compositor, **Stylix Base16** dynamic theming, **Fish**, **Kitty**, **Wayle**, **nix-ld** dynamic binary linking, and container virtualization.

---

## 💿 Fresh NixOS Installation Guide (UEFI + `cfdisk`)

Follow this step-by-step guide to install NixOS from a standard [NixOS Minimal ISO](https://nixos.org/download.html).

### 1. Identify Your Target Disk

```bash
lsblk
# Example target disk: /dev/nvme0n1 (or /dev/sda)
```

### 2. Partition with `cfdisk`

```bash
cfdisk /dev/nvme0n1
```

Create a **GPT** partition table with the following layout:

- **Partition 1 (EFI Boot)**: Size `1G` ➔ Type: `EFI System`
- **Partition 2 (Optional Swap)**: Size `8G` (or `16G`) ➔ Type: `Linux swap`
- **Partition 3 (Root Filesystem)**: Size `Remaining Space` ➔ Type: `Linux filesystem`
- Select **[ Write ]**, type `yes`, then **[ Quit ]**.

### 3. Format Partitions

```bash
# Format EFI System Partition
mkfs.fat -F 32 -n boot /dev/nvme0n1p1

# (Optional) Format and enable Swap
mkswap -L swap /dev/nvme0n1p2
swapon /dev/nvme0n1p2

# Format Root (ext4)
mkfs.ext4 -L nixos /dev/nvme0n1p3
```

### 4. Mount Filesystems

```bash
# Mount Root
mount /dev/disk/by-label/nixos /mnt

# Mount EFI Boot Partition
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

### 5. Generate Hardware Configuration & Clone Dotfiles

```bash
# 1. Generate baseline hardware config
nixos-generate-config --root /mnt

# 2. Enter nix-shell with git
nix-shell -p git

# 3. Clone dotfiles repository into target user home
mkdir -p /mnt/home/rsh/_ws
git clone https://github.com/dev-rajnish/dotfiles.git /mnt/home/rsh/_ws/dotfiles
cd /mnt/home/rsh/_ws/dotfiles

# 4. Copy generated hardware configuration into the flake
cp /mnt/etc/nixos/hardware-configuration.nix nixos/hardware-configuration.nix
```

### 6. Install NixOS

```bash
# Install system via flake (replaces hostname if customized in 0-system-vars.nix)
nixos-install --flake .#nixos

# Set your user password when prompted, then reboot
reboot
```

---

## ⚡ Setup on an Existing NixOS System

If you already have a running NixOS installation:

```bash
# 1. Clone dotfiles
git clone https://github.com/dev-rajnish/dotfiles.git ~/_ws/dotfiles
cd ~/_ws/dotfiles

# 2. Run automated bootstrap installer
./only-first-time-install.sh
```

> **Note**: The installer auto-detects your user, hostname, GPU driver, chassis type, and timezone, opens `0-system-vars.nix` in your editor for a quick review, copies `/etc/nixos/hardware-configuration.nix`, and builds the system.

---

## 🛠️ How to Interact With & Configure This Repo

### 1. Global System Manifest ([`0-system-vars.nix`](0-system-vars.nix))

The single source of truth for your system profile:

- **System & User**: `username`, `hostname`, `dotfilesDir`
- **Theme & Polarity**: `theme = "ayu-dark"` (Base16 scheme), `polarity = "dark"`
- **Default Apps**: `terminal = "kitty"`, `browser = "librewolf"`, `pdfViewer = "readest"`, `editor = "nvim"`
- **Feature Toggles**: `enableWaydroid`, `enableLibvirt`, `enableBluetooth`, `enableTailscale`, `enableFirewall`

### 2. Package Management ([`1-package-manifest.nix`](1-package-manifest.nix))

Add or remove packages categorized cleanly by purpose:

- `systemCore` (essential tools & shell runtimes)
- `cli` (terminal utilities, finders, diagnostics)
- `gui` (desktop apps, media players, utilities)
- `devPkg` / `programmingLang` (toolchains, compilers, linters, formatters)
- `nixLd` (libraries for running unpatched dynamic binaries & Mason LSPs)

### 3. Desktop Tokens & Fonts ([`2-desktop-theme-vars.nix`](2-desktop-theme-vars.nix))

Customize font families, desktop font scaling, border radii, gaps, and terminal opacity.

### 4. User Shell Scripts ([`home-manager/scripts/`](home-manager/scripts/))

Drop any executable `*.sh` script into `home-manager/scripts/`. It is automatically compiled into your `$PATH` preserving its exact `.sh` name (e.g. `power-menu.sh`, `clipboard.sh`, `sleep.sh`).

### 5. Live Dotfile Editing ([`dot_config/`](dot_config/))

All subfolders in `dot_config/` are live out-of-store symlinked to `~/.config/`. Any edit to Niri keybinds, Kitty, Fish, Fuzzel, Wayle, or Yazi takes effect immediately without rebuilding.

---

## ⌨️ Routine Task Commands (`just`)

This repository includes a `justfile` task runner for daily operations:

| Command                      | Description                                                                   |
| :--------------------------- | :---------------------------------------------------------------------------- |
| `just switch` / `just nixos` | Rebuild and switch NixOS system (`sudo nixos-rebuild switch --flake .#nixos`) |
| `just hm` / `just home`      | Switch user Home Manager configuration (`home-manager switch --flake .#rsh`)  |
| `just fmt`                   | Format all Nix, Fish, Lua, TOML, and Shell files via `treefmt`                |
| `just check`                 | Run `nix flake check` to validate build outputs and formatting                |
| `just update`                | Update flake inputs and Antigravity CLI                                       |
| `just gc`                    | Collect garbage and optimize Nix store                                        |
| `just generations`           | View recent NixOS and Home Manager generation history                         |

---

## 📂 Architecture Map

```
.
├── 0-system-vars.nix          # Global system manifest & feature toggles
├── 1-package-manifest.nix     # Categorized system & user package sets
├── 2-desktop-theme-vars.nix   # XDG geometry, typography, opacity & fallback colors
├── flake.nix                  # Flake entrypoint & outputs
├── justfile                   # Daily task runner
├── only-first-time-install.sh # Interactive bootstrap installer
│
├── nixos/                     # ❄️ NixOS system modules
│   ├── core/                  # User accounts, networking, locale, nix settings
│   ├── desktop/               # Greetd login, Kanata remap, Polkit, portals
│   ├── hardware/              # AMD GPU, PipeWire audio, Bluetooth, bootloader
│   └── virtualization/        # Waydroid, Podman/Distrobox, Libvirt QEMU/KVM
│
├── home-manager/              # 🏠 User environment modules
│   ├── dynamic-theming/       # Base16 live generators (Kitty, Niri, Fuzzel, Yazi)
│   ├── modules/               # Mime apps, live symlinks, custom scripts, FHS
│   ├── scripts/               # Packaged user shell scripts (*.sh)
│   └── pkgs/                  # Custom derivations (Antigravity CLI, LibreWolf, Zen)
│
└── dot_config/                # ⚙️ Live-symlinked workspace configs (~/.config)
```
