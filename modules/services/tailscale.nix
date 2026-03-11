{ pkgs, ... }:
let
  homeSSID = "ChosenWAN";

  # Runs on every NetworkManager connection event.
  # At home: clear any exit node so routing is direct.
  # Away:    ensure subnet routes from the exit node are accepted,
  #          giving LAN access to 192.168.0/24, 192.168.10/24, 192.168.50/24.
  dispatcherScript = pkgs.writeShellScript "99-tailscale-routes" ''
    ACTION="$2"

    case "$ACTION" in
      up|down|connectivity-change) ;;
      *) exit 0 ;;
    esac

    # Give NM a moment to settle before querying SSID
    sleep 1

    if ! ${pkgs.tailscale}/bin/tailscale status &>/dev/null; then
      exit 0
    fi

    CURRENT_SSID=$(${pkgs.networkmanager}/bin/nmcli -t -f active,ssid dev wifi 2>/dev/null \
      | grep '^yes:' | cut -d: -f2 | head -1)

    if [ "$CURRENT_SSID" = "${homeSSID}" ]; then
      # Home — clear any previously set exit node
      ${pkgs.tailscale}/bin/tailscale set --exit-node= 2>/dev/null || true
    else
      # Away — make sure subnet routes from the exit node are accepted
      ${pkgs.tailscale}/bin/tailscale set --accept-routes 2>/dev/null || true
    fi
  '';
in
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    # Enables kernel routing features needed to use subnet routes / exit nodes
    useRoutingFeatures = "client";
    # Accept advertised subnet routes (192.168.0/24, 192.168.10/24, 192.168.50/24)
    # and let Tailscale manage DNS (MagicDNS → 100.100.100.100 → AdGuard)
    extraUpFlags = [ "--accept-routes" "--accept-dns" ];
  };

  networking.networkmanager.dispatcherScripts = [{
    source = dispatcherScript;
    type = "basic";
  }];
}
