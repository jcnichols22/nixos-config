# nixos-config

My personal NixOS system configuration.

## Current Setup

This repo now supports **Nix flakes** while keeping the existing `configuration.nix` structure.

### System
- **Desktop Environment**: KDE Plasma 6 (Wayland)
- **Display Manager**: SDDM
- **Kernel**: Latest Linux kernel (`linuxPackages_latest`)
- **Bootloader**: systemd-boot with EFI

### Key Features
- **Networking**: NetworkManager + Tailscale VPN
- **Audio**: PipeWire with ALSA and PulseAudio compatibility
- **Maintenance**: 
  - Automatic garbage collection (weekly, keeps last 30 days)
  - Automatic system updates (daily, flake-based, no auto-reboot)

### Installed Packages
- **Development**: VSCode, GitHub Copilot CLI, git
- **Browsers**: Firefox, Brave
- **Productivity**: Obsidian, 1Password
- **Utilities**: vim, wget, curl, htop, tree, unzip

## Future Plans

### Flake Benefits
- **Reproducibility**: Lock dependencies with `flake.lock` for consistent builds
- **Modularity**: Better organization with reusable modules
- **Composability**: Easier to share and compose configurations
- **Modern tooling**: Cleaner CLI and explicit inputs

### Expansion Goals
- Home Manager integration for user-level configuration
- Separate modules for different system components
- Declarative dotfiles management
- Multiple machine configurations in one repo
- Development environment shells per-project

## Usage

### First time (generate lock file)
```bash
nix flake update
```

### Rebuild with flakes
```bash
sudo nixos-rebuild switch --flake .#nixos
```

### Update inputs and rebuild
```bash
nix flake update
sudo nixos-rebuild switch --flake .#nixos
```

### Optional checks
```bash
nix flake show
nix flake check
```