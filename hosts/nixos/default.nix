{ ... }:
{
  imports = [
    ../../hardware-configuration.nix
    ../../modules/system/base.nix
    ../../modules/desktop/plasma.nix
    ../../modules/system/maintenance.nix
    ../../modules/services/tailscale.nix
  ];

  networking.hostName = "nixos";

  # Keep this aligned with the first NixOS release installed on this host.
  system.stateVersion = "24.11";
}
