{ ... }:
{
  # Automatic garbage collection.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Automatic system upgrades.
  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    allowReboot = false;
    flake = "/etc/nixos";
    flags = [ "--update-input" "nixpkgs" "-L" ];
  };
}
