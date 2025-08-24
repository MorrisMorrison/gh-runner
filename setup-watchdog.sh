#!/bin/bash
set -euo pipefail

RUNNER_SERVICE="actions.runner.MorrisMorrison-schist.netcup-runner.service"

# Create watchdog script
sudo tee /usr/local/bin/check-runner.sh >/dev/null <<'EOF'
#!/bin/bash
SERVICE="'"$RUNNER_SERVICE"'"

if ! systemctl is-active --quiet "$SERVICE"; then
  echo "$(date): $SERVICE not active, restarting..." >> /var/log/runner-watchdog.log
  systemctl restart "$SERVICE"
fi
EOF

sudo chmod +x /usr/local/bin/check-runner.sh

# Create watchdog service
sudo tee /etc/systemd/system/runner-watchdog.service >/dev/null <<'EOF'
[Unit]
Description=Watchdog for GitHub Actions Runner

[Service]
Type=oneshot
ExecStart=/usr/local/bin/check-runner.sh
EOF

# Create watchdog timer
sudo tee /etc/systemd/system/runner-watchdog.timer >/dev/null <<'EOF'
[Unit]
Description=Run GitHub Actions Runner watchdog every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Reload + enable
sudo systemctl daemon-reload
sudo systemctl enable --now runner-watchdog.timer

echo "✅ Watchdog installed. It will check the runner every 5 minutes."
