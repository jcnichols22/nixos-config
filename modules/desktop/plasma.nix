{ ... }:
{
  # Enable the X11/Wayland stack (KDE Plasma 6 uses Wayland by default).
  services.xserver.enable = true;

  # Enable KDE Plasma 6 desktop.
  services.desktopManager.plasma6.enable = true;

  # Use SDDM as the display manager for Plasma 6.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Configure keymap in X11.
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
  };
}
