# nixos-config

My personal NixOS system configuration.

## Current Setup

This is a traditional NixOS configuration using `configuration.nix` with the following setup:

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
  - Automatic system updates (daily, no auto-reboot)

### Installed Packages
- **Development**: VSCode, GitHub Copilot CLI, git
- **Browsers**: Firefox, Brave
- **Productivity**: Obsidian, 1Password
- **Utilities**: vim, wget, curl, htop, tree, unzip

## Future Plans

### Migration to Flakes
Planning to rebuild this configuration using Nix flakes for:
- **Reproducibility**: Lock dependencies with `flake.lock` for consistent builds
- **Modularity**: Better organization with reusable modules
- **Composability**: Easier to share and compose configurations
- **Modern tooling**: Use `nix develop` shells and cleaner CLI interface

### Expansion Goals
- Home Manager integration for user-level configuration
- Separate modules for different system components
- Declarative dotfiles management
- Multiple machine configurations in one repo
- Development environment shells per-project

## Usage

To rebuild the system after making changes:
```bash
sudo nixos-rebuild switch
```

To update and rebuild:
```bash
sudo nixos-rebuild switch --upgrade
```