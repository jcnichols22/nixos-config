{ pkgs, ... }:
{
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
}
