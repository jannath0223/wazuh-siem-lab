#!/bin/bash
# ============================================================
# Attack 4: Suspicious Process Execution
# Run on: Kali Linux
# Usage: bash attack4_suspicious.sh <TARGET_IP>
#
# What it does:
#   Runs tools that look suspicious to a SIEM — port scanners
#   and network listeners that normal computers shouldn't run.
#
# What Wazuh detects:
#   Rule 31302 - Nmap scan detected (Level 6)
#   Rule 510   - Suspicious process / netcat (Level 6)
# ============================================================

TARGET_IP="${1:-192.168.56.101}"

echo ""
echo "=============================================="
echo "  Attack 4: Suspicious Process Execution"
echo "  Target: $TARGET_IP"
echo "  ⚠  Lab use only!"
echo "=============================================="
echo ""

# Install nmap if not present
if ! command -v nmap &>/dev/null; then
    echo "[*] Installing nmap..."
    sudo apt-get install nmap -y
fi

# Step 1: Port scan the target
echo "[*] Step 1: Running nmap service scan..."
echo "[*] This maps all open ports and services on the target"
echo ""
nmap -sV "$TARGET_IP" -oN /tmp/nmap_results.txt
echo ""
echo "[✓] Nmap scan complete → triggers Rule 31302 in Wazuh"
echo "[*] Scan results saved to /tmp/nmap_results.txt"

echo ""
# Step 2: Start netcat listener (simulates backdoor)
echo "[*] Step 2: Starting Netcat listener (simulates backdoor)..."
echo "[*] Will auto-close after 10 seconds"
timeout 10 nc -lvp 4444 &
NC_PID=$!
sleep 3
echo "[✓] Netcat backdoor simulated → triggers Rule 510"

# Clean up
sleep 3
kill $NC_PID 2>/dev/null || true
wait $NC_PID 2>/dev/null || true

echo ""
echo "=============================================="
echo "[✓] Suspicious process simulation complete!"
echo ""
echo "Check Wazuh dashboard → Security Events"
echo "Look for Rule 31302 (nmap) and Rule 510 (netcat)"
echo "=============================================="
