# nixos-config

My personal NixOS system configuration.

## Current Setup

This repo now supports **Nix flakes** while keeping the existing `configuration.nix` structure.

## Repository Layout

```text
.
├── flake.nix
├── configuration.nix                  # compatibility import
├── hardware-configuration.nix
├── hosts/
│   └── nixos/
│       └── default.nix                # host-specific settings
└── modules/
    ├── desktop/
    │   └── plasma.nix
    ├── services/
    │   ├── tailscale.nix
    │   └── patchmon.nix
    └── system/
        ├── base.nix
        └── maintenance.nix
```

### System

- **Desktop Environment**: KDE Plasma 6 (Wayland)
- **Display Manager**: SDDM
- **Kernel**: Latest Linux kernel (`linuxPackages_latest`)
- **Bootloader**: systemd-boot with EFI

### Key Features

- **Networking**: NetworkManager + Tailscale VPN with automatic subnet routing
  - Home (`ChosenWAN`): direct LAN access, no exit node
  - Away: subnet routes accepted via Tailscale, giving access to home LAN (`192.168.0/24`, `192.168.10/24`, `192.168.50/24`)
  - DNS managed by Tailscale MagicDNS → AdGuard
- **Monitoring**: Patchmon agent installation via systemd one-shot service with runtime credentials from `/etc/patchmon/agent.env`
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
nix --extra-experimental-features 'nix-command flakes' flake update
```

### Rebuild with flakes

```bash
sudo nixos-rebuild switch --flake .#nixos
```

### Patchmon secret setup

Create a root-only environment file before rebuilding:

```bash
sudo install -d -m 700 /etc/patchmon
sudo tee /etc/patchmon/agent.env >/dev/null <<'EOF'
PATCHMON_API_ID=patchmon_daeec9653c02d39d
PATCHMON_API_KEY=REPLACE_WITH_YOUR_KEY
EOF
sudo chmod 600 /etc/patchmon/agent.env
```

Run once after rebuild (or reboot):

```bash
sudo systemctl start patchmon-install.service
sudo systemctl status patchmon-install.service
```

### Patchmon troubleshooting (NixOS)

- If `nixos-rebuild switch --flake .#nixos` says `patchmon.nix` does not exist, stage the new file first:

```bash
git add modules/services/patchmon.nix hosts/nixos/default.nix README.md
```

- If installer logs show `401`, your key is invalid/placeholder. Update `/etc/patchmon/agent.env` and restart:

```bash
sudo systemctl restart patchmon-install.service
sudo journalctl -u patchmon-install.service -n 100 --no-pager
```

- NixOS keeps `/etc/systemd/system` declarative/read-only. This config intentionally lets NixOS manage `patchmon-agent.service`.

- Verify healthy state:

```bash
sudo systemctl is-active patchmon-install.service
sudo systemctl is-active patchmon-agent.service
sudo systemctl status patchmon-install.service patchmon-agent.service --no-pager
```

### Add another host

1. Create `hosts/<hostname>/default.nix`.
2. Add `nixosConfigurations.<hostname>` in `flake.nix`.
3. Rebuild with `sudo nixos-rebuild switch --flake .#<hostname>`.

### Update inputs and rebuild

```bash
nix --extra-experimental-features 'nix-command flakes' flake update
sudo nixos-rebuild switch --flake .#nixos
```

### Optional: enable flakes for user-level `nix` commands

```bash
mkdir -p ~/.config/nix
printf 'experimental-features = nix-command flakes\n' >> ~/.config/nix/nix.conf
```

### Optional checks

```bash
nix flake show
nix flake check
```
