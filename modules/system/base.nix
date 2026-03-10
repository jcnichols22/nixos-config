{ pkgs, ... }:
{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Define a user account.
  users.users.josh = {
    isNormalUser = true;
    description = "josh";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # per-user packages
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Enable flakes and modern Nix CLI.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    vim
    wget
    _1password-gui
    tailscale
    vscode
    brave
    github-copilot-cli
    obsidian
    htop
    curl
    unzip
    tree
    git
  ];

  # Enable Tailscale.
  services.tailscale.enable = true;
}
