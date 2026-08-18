# ❄️ NixOS & Home Manager Dotfiles

A high-performance, modular **NixOS 26.05** & **Home Manager** flake featuring the **Niri** scrollable Wayland compositor, **Stylix Base16** dynamic theming, **Fish/Nushell/Bash**, **Kitty**, **Wayle**, **nix-ld** dynamic binary linking, **iwd** ultra-fast networking, and container virtualization.

---

## 📖 User Guide: The `config.live` & `config.lock` Workflow

This repository uses the **Live Workspace & Snapshot Lock Pattern** to give you instant hot-reloading for desktop configuration without polluting your Git working tree.

```
┌────────────────────────────────┐         just lock-config         ┌────────────────────────────────┐
│   config.live/ (~/.config)     │ ───────────────────────────────> │   config.lock/                 │
│   • Live editable workspace    │                                  │   • Clean reference snapshot   │
│   • Ignored by Git (.gitignore)│ <─────────────────────────────── │   • Committed to Git repository│
└────────────────────────────────┘        just restore-config       └────────────────────────────────┘
```

### 1. How It Works

- **`config.live/`**: Your live working directory, symlinked directly to `~/.config/`. Any edit to Niri keybinds, Kitty colors, Fuzzel, Wayle, or Yazi takes effect **instantly**. Because it is in `.gitignore`, runtime cache files and dynamic themes will **never** dirty your Git tree.
- **`config.lock/`**: The clean, authoritative configuration snapshot tracked and committed in Git.

### 2. Daily Workflow

1. **Live Editing**: Edit configs in `~/.config/<app>` or `config.live/<app>`. Changes apply immediately in your active session.
2. **Locking Changes to Git**: When you are happy with your tweaks and want to commit them:
   ```bash
   just lock-config   # (or `just lock`) Syncs config.live -> config.lock
   git add config.lock
   git commit -m "feat(ui): update niri keybinds and kitty config"
   ```
3. **Restoring / Fresh Setup**: If you ever want to revert experimental changes or set up on a fresh machine:
   ```bash
   just restore-config # (or `just restore`) Restores config.live from config.lock
   just link-live      # (or `just link`) Symlinks ~/.config to config.live
   ```

---

## ⌨️ Routine Task Commands (`just`)

This repository includes a comprehensive `justfile` task runner for daily operations:

| Category            | Command                              | Description                                                                            |
| :------------------ | :----------------------------------- | :------------------------------------------------------------------------------------- |
| **🔄 Config Sync**  | `just lock-config` (or `lock`)       | Snapshot clean live configs from `config.live/` to git-tracked `config.lock/`          |
|                     | `just restore-config` (or `restore`) | Overwrite/restore `config.live/` from git-tracked `config.lock/`                       |
|                     | `just link-live` (or `link`)         | Symlink all `config.live/` subfolders into `~/.config/`                                |
| **❄️ System**       | `just switch` (or `nixos`)           | Rebuild and switch NixOS system (`sudo nixos-rebuild switch --flake .#nixos`)          |
|                     | `just test`                          | Test configuration without adding a new bootloader entry                               |
|                     | `just boot`                          | Build system and add to bootloader menu without switching immediately                  |
|                     | `just build`                         | Build NixOS system toplevel derivation (outputs `./result`)                            |
|                     | `just vm`                            | Build and run a QEMU VM instance of your configuration                                 |
| **🏠 Home Manager** | `just home` (or `hm`)                | Switch standalone Home Manager profile (`home-manager switch --flake .#rsh`)           |
|                     | `just home-build`                    | Build Home Manager activation package                                                  |
|                     | `just sync` (or `all`)               | Rebuild both NixOS system and Home Manager configurations                              |
| **🦀 Rust Tools**   | `just build-tools`                   | Compile release binaries for the Rust toolset in `user/bin-rs`                         |
|                     | `just doctor`                        | Run comprehensive system and dotfiles health diagnostics                               |
|                     | `just update-agy`                    | Fetch and update Antigravity CLI version                                               |
| **🛠️ Code Quality** | `just fmt`                           | Format all Nix, Shell, TOML, and Rust code with `treefmt` (`alejandra`, `shfmt`, etc.) |
|                     | `just check`                         | Run `nix flake check` to validate evaluations and formatting                           |
|                     | `just update`                        | Update flake inputs and dependencies (`nix flake update`)                              |
|                     | `just lock-flake`                    | Update `flake.lock`                                                                    |
| **🧹 Maintenance**  | `just gc [days=7d]`                  | Collect old generations (default 7 days) and optimize Nix store                        |
|                     | `just optimise`                      | Deduplicate and hardlink identical Nix store files                                     |
|                     | `just clean`                         | Remove temporary build symlinks (`result`, `result-*`)                                 |
|                     | `just generations`                   | List recent NixOS and Home Manager generation history                                  |

---

## 🛠️ How to Configure This System

### 1. Global System Manifest ([`0-system-vars.nix`](0-system-vars.nix))

The single source of truth for your system profile:

- **System & User**: `username`, `hostname`, `dotfilesDir`
- **Hardware Profile**: `deviceType = "laptop"`, `gpuDriver = "amd"`, `enableKanata = true`
- **Theme & Polarity**: `theme = "catppuccin-mocha"`, `polarity = "dark"`
- **Default Applications**: `terminal = "kitty"`, `editor = "codium"`, `browser = "google-chrome"`, `fileManager = "thunar"`
- **Feature Toggles**: `enableAppImage`, `enableWaydroid`, `enableLibvirt`, `enableBluetooth`, `enableTailscale`, `enableFirewall`

### 2. Package Manifest ([`1-package-manifest.nix`](1-package-manifest.nix))

Structured package sets categorized by purpose:

- `systemCore` (essential shell runtimes, just, git, zoxide, direnv)
- `cliCore` / `cliMonitoring` / `cliFileOps` / `cliArchive` (fastfetch, btop, bat, eza, ripgrep, ouch)
- `gui` (desktop applications, media players, document viewers)
- `devPkg` / `programmingLang` (Python, Node, Go, Rust, Zig, Lua, formatters)
- `virtualization` (AppImage runner, Distrobox, QEMU/KVM virtiofs tools)

### 3. XDG Tokens & Typography ([`2-xdg-config-vars.nix`](2-xdg-config-vars.nix))

Customize font families (Mono, Sans, Serif), font sizes for terminal/launcher/bar, border radii, and workspace gaps.

---

## 💿 Fresh NixOS Installation Guide (UEFI + `cfdisk`)

Follow this guide to install NixOS from a standard [NixOS Minimal ISO](https://nixos.org/download.html).

### 1. Partition with `cfdisk`

```bash
cfdisk /dev/nvme0n1
```

Create a **GPT** partition table:

- **Partition 1 (EFI Boot)**: `1G` ➔ Type: `EFI System`
- **Partition 2 (Optional Swap)**: `8G` (or `16G`) ➔ Type: `Linux swap`
- **Partition 3 (Root Filesystem)**: `Remaining Space` ➔ Type: `Linux filesystem`
- Select **[ Write ]**, type `yes`, then **[ Quit ]**.

### 2. Format & Mount Partitions

```bash
# Format Partitions
mkfs.fat -F 32 -n boot /dev/nvme0n1p1
mkswap -L swap /dev/nvme0n1p2 && swapon /dev/nvme0n1p2
mkfs.ext4 -L nixos /dev/nvme0n1p3

# Mount Filesystems
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

### 3. Clone Dotfiles & Install

```bash
# 1. Generate baseline hardware config
nixos-generate-config --root /mnt

# 2. Clone dotfiles repository into target user home
mkdir -p /mnt/home/rsh/_ws
nix-shell -p git --run "git clone https://github.com/dev-rajnish/dotfiles.git /mnt/home/rsh/_ws/dotfiles"
cd /mnt/home/rsh/_ws/dotfiles

# 3. Copy generated hardware configuration into the flake
cp /mnt/etc/nixos/hardware-configuration.nix nixos/hardware-configuration.nix

# 4. Install NixOS
nixos-install --flake .#nixos

# 5. Set user password when prompted, then reboot
reboot
```

---

## 📂 Architecture Map

```
.
├── 0-system-vars.nix          # Global system manifest & feature toggles
├── 1-package-manifest.nix     # Categorized system & user package sets
├── 2-xdg-config-vars.nix      # XDG geometry, typography, opacity & tokens
├── flake.nix                  # Flake entrypoint & outputs
├── justfile                   # Daily task runner
│
├── nixos/                     # ❄️ NixOS system modules (Static default.nix structure)
│   ├── configuration.nix      # System entrypoint
│   ├── core/                  # User accounts, fast networking (iwd), locale, nix settings
│   ├── desktop/               # Greetd login, Kanata keyboard remap, Polkit, portals
│   ├── hardware/              # AMD GPU, PipeWire audio, Bluetooth, bootloader
│   └── virtualization/        # AppImage runner, Distrobox, Libvirt QEMU/KVM
│
├── home-manager/              # 🏠 User environment modules (Static default.nix structure)
│   ├── home.nix               # User entrypoint
│   ├── modules/               # Stylix, Wallust, Mime defaults, Packages, Services
│   └── pkgs/                  # Custom derivations (Antigravity CLI, LibreWolf, Zen)
│
├── config.lock/               # 🔒 Git-tracked authoritative configuration snapshot
│   ├── kitty/                 # Terminal emulator config
│   ├── niri/                  # Scrollable Wayland compositor rules & keybinds
│   ├── labwc/                 # Stacking Wayland compositor config
│   ├── wayle/                 # Status bar & widgets
│   ├── wallust/               # Dynamic theming templates
│   └── ...                    # Fuzzel, Yazi, Starship, Swaylock, Wlogout, Fastfetch
│
├── config.live/               # ⚡ Live local workspace (git-ignored, symlinked to ~/.config)
└── user/                      # 🛠️ Custom CLI tools, environment KV pairs & Rust toolset
```
