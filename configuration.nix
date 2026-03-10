# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
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

  # Enable the X11/Wayland stack (KDE Plasma 6 uses Wayland by default).
  services.xserver.enable = true;

  # Enable KDE Plasma 6 desktop.
  services.desktopManager.plasma6.enable = true;

  # Use SDDM as the display manager for Plasma 6.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # Wayland session by default
  };

  # Remove GNOME (was previously enabled).
  # services.displayManager.gdm.enable = true;
  # services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
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

  # Allow unfree packages
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

  # Enable Tailscale
  services.tailscale.enable = true;

  # Keep Tailscale exit-node usage in sync with the current Wi-Fi network.
  systemd.services.tailscale-exit-node = {
    description = "Configure Tailscale exit node based on Wi-Fi SSID";
    after = [ "network-online.target" "tailscaled.service" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ssid="$(${pkgs.networkmanager}/bin/nmcli -t -f active,ssid dev wifi | ${pkgs.gnugrep}/bin/grep '^yes:' | ${pkgs.coreutils}/bin/cut -d: -f2- || true)"

        if [ "$ssid" = "ChosenWAN" ]; then
          ${pkgs.tailscale}/bin/tailscale set --exit-node=
        else
          ${pkgs.tailscale}/bin/tailscale set \
            --exit-node=100.89.118.43 \
            --exit-node-allow-lan-access=true \
            --accept-routes=true
        fi
      '';
    };
  };

  systemd.timers.tailscale-exit-node = {
    description = "Re-evaluate Tailscale exit node policy";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "tailscale-exit-node.service";
      OnBootSec = "2min";
      OnUnitActiveSec = "2min";
    };
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Automatic system upgrades
  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    allowReboot = false;
    flake = "/etc/nixos";
    flags = [ "--update-input" "nixpkgs" "-L" ];
  };

  # This value should match the release you first installed, not a future one.
  system.stateVersion = "24.11"; # Adjust to your actual installed version.

}

