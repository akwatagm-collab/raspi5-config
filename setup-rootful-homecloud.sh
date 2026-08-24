#!/bin/bash
set -e 

### Podman Rootful + Quadlet デプロイ用設定

BASE_DIR="/home/akwata/homecloud"
SYSTEMD_QUADLET_DIR="/etc/containers/systemd" 

echo "🚀 Deploying homecloud configs to $SYSTEMD_QUADLET_DIR..." 

cd "$BASE_DIR" 

### Quadletファイルを安全に同期・配置

sudo cp ./quadlets/*.{container,network,volume} "$SYSTEMD_QUADLET_DIR/"
sudo chown root:root "$SYSTEMD_QUADLET_DIR"/* 

### systemd デーモンをリロードしQuadletを検知

sudo systemctl daemon-reload 

echo "✅ Deployment complete. Run 'sudo systemctl start ' to start."
