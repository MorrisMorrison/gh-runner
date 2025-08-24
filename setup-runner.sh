#!/bin/bash
set -euo pipefail

# === CONFIG ===
GITHUB_OWNER="MorrisMorrison" # org or username
GITHUB_REPO="schist"          # repo name (or leave empty for org-wide runner)
RUNNER_NAME="netcup-runner"
RUNNER_DIR="$HOME/actions-runner"
TOKEN="$1" # pass the runner token as first argument
# =============

if [ -z "$TOKEN" ]; then
  echo "Usage: $0 <RUNNER_TOKEN>"
  exit 1
fi

# Install dependencies
sudo apt-get update
sudo apt-get install -y curl tar jq

# Create runner dir
mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"

# Download latest runner
LATEST=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name)
echo "Downloading GitHub Actions Runner $LATEST..."
curl -L -o actions-runner.tar.gz "https://github.com/actions/runner/releases/download/$LATEST/actions-runner-linux-x64-${LATEST:1}.tar.gz"
tar xzf ./actions-runner.tar.gz
rm actions-runner.tar.gz

# Configure runner
if [ -n "$GITHUB_REPO" ]; then
  REPO_URL="https://github.com/$GITHUB_OWNER/$GITHUB_REPO"
else
  REPO_URL="https://github.com/$GITHUB_OWNER"
fi

./config.sh --unattended --url "$REPO_URL" --token "$TOKEN" --name "$RUNNER_NAME"

# Install systemd service
sudo ./svc.sh install
sudo systemctl daemon-reload

# Add restart policy
sudo mkdir -p /etc/systemd/system/actions.runner.*.service.d
cat <<EOF | sudo tee /etc/systemd/system/actions.runner.*.service.d/override.conf
[Service]
Restart=always
RestartSec=10
EOF

# Reload + enable
sudo systemctl daemon-reload
sudo systemctl enable --now actions.runner.$GITHUB_OWNER-$GITHUB_REPO.$RUNNER_NAME.service

echo "✅ Runner setup complete and will auto-restart on crash."
