#!/bin/bash
# ============================================================
# Wazuh Agent Setup Script for Kali Linux
# Run on: Kali Linux VM
# Usage: bash setup_agent.sh <MANAGER_IP>
# Example: bash setup_agent.sh 192.168.56.101
# ============================================================

MANAGER_IP="${1:-192.168.56.101}"

echo ""
echo "=============================================="
echo "  Wazuh Agent Setup — Kali Linux"
echo "  Manager IP: $MANAGER_IP"
echo "=============================================="
echo ""

# Step 1: Fix DNS
echo "[1/5] Fixing DNS..."
sudo chattr -i /etc/resolv.conf 2>/dev/null || true
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo tee /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
echo "✓ DNS fixed"

# Step 2: Test internet
echo ""
echo "[2/5] Testing internet connection..."
if ping -c 2 8.8.8.8 &>/dev/null; then
    echo "✓ Internet working"
else
    echo "✗ No internet — check VirtualBox network adapter (should be NAT)"
    exit 1
fi

# Step 3: Add Wazuh repo
echo ""
echo "[3/5] Adding Wazuh repository..."
sudo rm -f /usr/share/keyrings/wazuh.gpg
wget -qO - https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --dearmor -o /usr/share/keyrings/wazuh.gpg
sudo chmod 644 /usr/share/keyrings/wazuh.gpg
sudo rm -f /etc/apt/sources.list.d/wazuh.list
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee /etc/apt/sources.list.d/wazuh.list
echo "✓ Repository added"

# Step 4: Install agent
echo ""
echo "[4/5] Installing Wazuh agent..."
sudo apt-get update -y
sudo WAZUH_MANAGER="$MANAGER_IP" apt-get install wazuh-agent -y
echo "✓ Agent installed"

# Step 5: Configure and start
echo ""
echo "[5/5] Configuring and starting agent..."
sudo bash -c "cat > /var/ossec/etc/ossec.conf << EOF
<ossec_config>
  <client>
    <server>
      <address>$MANAGER_IP</address>
      <port>1514</port>
      <protocol>tcp</protocol>
    </server>
  </client>
  <logging>
    <log_format>plain</log_format>
  </logging>
</ossec_config>
EOF"

sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
echo "✓ Agent started"

echo ""
echo "=============================================="
echo "✓ Setup Complete!"
echo ""
echo "Check agent status:"
echo "  sudo systemctl status wazuh-agent"
echo ""
echo "Check dashboard at:"
echo "  https://$MANAGER_IP"
echo "  (Active agents should show 1)"
echo "=============================================="
