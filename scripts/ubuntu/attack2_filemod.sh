#!/bin/bash
# ============================================================
# Attack 2: File Integrity Modification
# Run on: Ubuntu Server (SSH in from Kali first)
# Usage: bash attack2_filemod.sh
#
# What it does:
#   Modifies critical system files to trigger Wazuh FIM alerts.
#   FIM = File Integrity Monitoring — Wazuh watches for any
#   changes to important files and raises alarms.
#
# What Wazuh detects:
#   Rule 550  - Integrity checksum changed (Level 7)
#   Rule 553  - File deleted (Level 7)
#   Rule 554  - File added (Level 7)
# ============================================================

echo ""
echo "=============================================="
echo "  Attack 2: File Integrity Modification"
echo "  Run on: Ubuntu Server"
echo "  ⚠  Lab use only!"
echo "=============================================="
echo ""

# Backup original files first
echo "[*] Backing up original files..."
sudo cp /etc/passwd /tmp/passwd.original.bak
sudo cp /etc/hosts /tmp/hosts.original.bak
echo "[✓] Backups saved to /tmp/"

echo ""
echo "[*] Step 1: Modifying /etc/passwd (critical system file)..."
echo "# LAB TEST - $(date)" | sudo tee -a /etc/passwd > /dev/null
echo "[✓] /etc/passwd modified → triggers Rule 550"

echo ""
echo "[*] Step 2: Creating suspicious file in /bin..."
sudo touch /bin/suspicious_lab_file
echo "[✓] /bin/suspicious_lab_file created → triggers Rule 554"

echo ""
echo "[*] Step 3: Modifying /etc/hosts..."
echo "# LAB MODIFICATION - $(date)" | sudo tee -a /etc/hosts > /dev/null
echo "[✓] /etc/hosts modified → triggers Rule 550"

echo ""
echo "=============================================="
echo "[✓] File modification complete!"
echo ""
echo "Note: FIM alerts may take a few minutes to appear."
echo "Check Wazuh dashboard → Security Events → filter: syscheck"
echo "=============================================="

echo ""
read -p "Restore original files now? (y/n): " RESTORE
if [ "$RESTORE" = "y" ]; then
    sudo cp /tmp/passwd.original.bak /etc/passwd
    sudo cp /tmp/hosts.original.bak /etc/hosts
    sudo rm -f /bin/suspicious_lab_file
    echo "[✓] All files restored to original state"
fi
