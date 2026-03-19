#!/bin/bash
# ============================================================
# Wazuh SIEM — Automated Docker Installation Script
# Run on: Ubuntu Server 24.04
# Usage: bash install_wazuh_docker.sh
# ============================================================

set -e

echo ""
echo "=============================================="
echo "  Wazuh SIEM — Docker Installer"
echo "  Target: Ubuntu Server 24.04"
echo "=============================================="
echo ""

# Step 1: Update system
echo "[1/6] Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y
echo "✓ System updated"

# Step 2: Install Docker
echo ""
echo "[2/6] Installing Docker and Docker Compose..."
sudo apt-get install docker.io docker-compose git -y
echo "✓ Docker installed"

# Step 3: Start Docker
echo ""
echo "[3/6] Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker
echo "✓ Docker started and enabled"

# Step 4: Clone Wazuh Docker repo
echo ""
echo "[4/6] Downloading Wazuh Docker files..."
cd ~
git clone https://github.com/wazuh/wazuh-docker.git -b v4.7.5
cd wazuh-docker/single-node
echo "✓ Wazuh Docker files downloaded"

# Step 5: Generate certificates
echo ""
echo "[5/6] Generating SSL certificates..."
sudo docker-compose -f generate-indexer-certs.yml run --rm generator
echo "✓ Certificates generated"

# Step 6: Start Wazuh
echo ""
echo "[6/6] Starting Wazuh (this takes 10-15 minutes)..."
sudo docker-compose up -d
echo "✓ Wazuh containers started"

# Final check
echo ""
echo "=============================================="
echo "  Checking container status..."
echo "=============================================="
sudo docker ps

echo ""
echo "=============================================="
echo "✓ Installation Complete!"
echo ""
echo "Access your dashboard at:"
echo "  https://$(hostname -I | awk '{print $1}')"
echo ""
echo "  Username: admin"
echo "  Password: SecretPassword"
echo "=============================================="
