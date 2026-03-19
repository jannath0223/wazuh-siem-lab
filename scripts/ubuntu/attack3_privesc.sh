#!/bin/bash
# ============================================================
# Attack 3: Privilege Escalation
# Run on: Ubuntu Server (SSH in from Kali first)
# Usage: bash attack3_privesc.sh
#
# What it does:
#   Simulates a regular user trying to gain root/admin powers.
#   Uses sudo commands and scans for SUID binaries.
#
# What Wazuh detects:
#   Rule 5402 - Successful sudo execution (Level 9)
#   Rule 5403 - Sudo failure / wrong password (Level 5)
# ============================================================

echo ""
echo "=============================================="
echo "  Attack 3: Privilege Escalation"
echo "  Run on: Ubuntu Server"
echo "  ⚠  Lab use only!"
echo "=============================================="
echo ""
echo "[*] Current user: $(whoami)"
echo ""

# Step 1: Try to read shadow file
echo "[*] Step 1: Attempting to read /etc/shadow..."
sudo cat /etc/shadow 2>&1 | head -3
echo "[✓] sudo attempt logged → triggers Rule 5402"

echo ""
# Step 2: Check what sudo powers this user has
echo "[*] Step 2: Listing sudo privileges..."
sudo -l 2>&1 || true
echo "[✓] Privilege enumeration logged"

echo ""
# Step 3: Scan for SUID binaries (privilege escalation recon)
echo "[*] Step 3: Scanning for SUID binaries (common attacker recon)..."
find / -perm -4000 -type f 2>/dev/null | head -15
echo "[✓] SUID scan complete"

echo ""
# Step 4: Attempt to become root (will timeout after 3 seconds)
echo "[*] Step 4: Attempting sudo su - (auto-exits after 3 seconds)..."
timeout 3 sudo su - 2>/dev/null || true
echo "[✓] Root escalation attempt logged → triggers Rule 5402"

echo ""
echo "=============================================="
echo "[✓] Privilege escalation simulation complete!"
echo ""
echo "Check Wazuh dashboard → Security Events → filter: sudo"
echo "Look for Rule 5402 (Level 9 HIGH)"
echo "=============================================="
