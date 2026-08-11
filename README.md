# ❄️ NixOS & Home Manager Dotfiles

A modular, reproducible **NixOS 26.05** and **Home Manager** flake configuration featuring the **Niri** scrollable-tiling Wayland compositor, **Stylix** theming, **Podman**, **Waydroid**, and **QEMU/KVM** virtualization.

---

## ✨ Key Features

- **Single Source of Truth (`pkg-list.nix`)**: All system, CLI, GUI, virtualization, and FHS packages declared in one central file.
- **Out-of-Store Live Symlinking**: Automatic live symlinking from `dot_config/*` into `~/.config/*` via `mkOutOfStoreSymlink` — instant configuration changes without rebuilding.
- **Niri Wayland Compositor**: Scrollable-tiling layout with custom keybindings, gestures, and wallpaper integration.
- **Virtualization & Containerization**:
  - **Podman**: Rootless OCI container support with Docker compatibility.
  - **Waydroid**: Android LXC container integration with `nftables` networking.
  - **QEMU / KVM & Libvirt**: VirtioFS host-guest filesystem sharing, SPICE USB passthrough, and TPM support (`swtpm`).
- **FHS Environment (`fhs.nix`)**: Isolated FHS environment for running un-patched Linux binaries seamlessly.
- **Automated Store Optimization**: Weekly garbage collection (`--delete-older-than 7d`) and automatic store hardlinking.

---

## 📂 Repository Structure

```
.
├── flake.nix
├── var.nix
├── pkg-list.nix
├── README.md
│
├── nixos/
│   ├── configuration.nix
│   ├── hardware-configuration.nix
│   │
│   ├── core/
│   │   ├── networking.nix
│   │   ├── nix-settings.nix
│   │   ├── time-and-locale.nix
│   │   └── users.nix
│   │
│   ├── desktop/
│   │   ├── fonts.nix
│   │   ├── kmonad.nix
│   │   ├── programs-and-services.nix
│   │   ├── system-packages.nix
│   │   └── xdg-portals.nix
│   │
│   ├── hardware/
│   │   ├── amd-igpu.nix
│   │   └── boot-and-services.nix
│   │
│   └── virtualization/
│       └── containers-and-vms.nix
│
├── home-manager/
│   ├── home.nix
│   │
│   ├── fhs-env/
│   │   └── fhs.nix
│   │
│   ├── modules/
│   │   ├── git.nix
│   │   ├── programs-and-services.nix
│   │   ├── stylix.nix
│   │   └── xdg-config-symlinks.nix
│   │
│   └── pkgs/
│       ├── default-apps.nix
│       ├── packages.nix
│       └── zen-browser.nix
│
└── dot_config/
    ├── btop/
    ├── fish/
    ├── fuzzel/
    ├── kitty/
    ├── niri/
    ├── nvim/
    ├── waybar/
    └── ...
```

---

## 🚀 Quick Start & Usage

### 1. Fresh Machine Installation

On a newly installed NixOS system, clone the repository, copy the generated hardware configuration, and activate the system & user environments:

```bash
# 1. Navigate to dotfiles
cd dotfiles

# 2. Copy target machine's hardware configuration
cat /etc/nixos/hardware-configuration.nix > nixos/hardware-configuration.nix

# 3. Build and switch to NixOS system configuration
sudo nixos-rebuild switch --flake .#nixos

# 4. Apply standalone Home Manager configuration
home-manager switch --flake .#rsh
```

### 2. Existing Machine Updates

```bash
# Rebuild and switch NixOS system configuration
sudo nixos-rebuild switch --flake .#nixos

# Apply standalone Home Manager configuration
home-manager switch --flake .#rsh
```

### 3. Format Code & Run Flake Checks

```bash
# Format all Nix and Markdown files
nix fmt

# Evaluate and verify flake outputs
nix flake check
```

---

## 🛠️ Management & Workflow

- **Adding New Packages**: Open [`pkg-list.nix`](pkg-list.nix) and add the package name to the relevant category (`cli`, `gui`, `systemCore`, `virtualization`, etc.).
- **Editing Application Configurations**: Edit any file inside `dot_config/<app>/` — changes apply live immediately without rebuilding NixOS or Home Manager.
- **Updating Flake Inputs**: Run `nix flake update`.
