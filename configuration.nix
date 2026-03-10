{ ... }:
{
  # Compatibility entrypoint while migrating to hosts/modules layout.
  imports = [
    ./hosts/nixos/default.nix
  ];
}

