{ ... }:
{
  imports = [
    ../../hardware-configuration.nix
    ../../modules/system/base.nix
    ../../modules/desktop/plasma.nix
    ../../modules/services/tailscale-exit-node.nix
    ../../modules/system/maintenance.nix
  ];

  networking.hostName = "nixos";

  # Keep this aligned with the first NixOS release installed on this host.
  system.stateVersion = "24.11";
}
