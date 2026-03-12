{ pkgs, ... }:
{
  # Ensure the Patchmon state and config directories exist.
  systemd.tmpfiles.rules = [
    "d /var/lib/patchmon 0700 root root -"
    "d /etc/patchmon 0700 root root -"
  ];

  # Install the Patchmon agent once on boot after network is available.
  systemd.services.patchmon-install = {
    description = "Install Patchmon agent";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [
      bash
      coreutils
      curl
      gawk
      gnugrep
      gnused
      gnutar
      gzip
      procps
      util-linux
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      EnvironmentFile = "/etc/patchmon/agent.env";
    };

    script = ''
      set -euo pipefail

      marker_file="/var/lib/patchmon/installed"
      if [ -f "$marker_file" ]; then
        exit 0
      fi

      : "''${PATCHMON_API_ID:?PATCHMON_API_ID is not set in /etc/patchmon/agent.env}"
      : "''${PATCHMON_API_KEY:?PATCHMON_API_KEY is not set in /etc/patchmon/agent.env}"

      install -d -m 755 /usr/local/bin

      ${pkgs.curl}/bin/curl -fsSL "http://192.168.0.115:3399/api/v1/hosts/install" \
        -H "X-API-ID: $PATCHMON_API_ID" \
        -H "X-API-KEY: $PATCHMON_API_KEY" \
      | ${pkgs.gnused}/bin/sed '/^# Step 5: Setup service for WebSocket connection/,$d' \
      | ${pkgs.bash}/bin/sh

      test -x /usr/local/bin/patchmon-agent

      touch "$marker_file"
    '';
  };

  # Run the agent as a declarative NixOS service (instead of installer-managed unit files in /etc).
  systemd.services.patchmon-agent = {
    description = "Patchmon Agent";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "patchmon-install.service" ];
    wants = [ "network-online.target" "patchmon-install.service" ];
    requires = [ "patchmon-install.service" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "/usr/local/bin/patchmon-agent serve";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
