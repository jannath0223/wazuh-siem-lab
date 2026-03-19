# SOC INCIDENT REPORT — EXAMPLE

| Field | Value |
|-------|-------|
| **Classification** | CONFIDENTIAL |
| **Severity** | HIGH |
| **Status** | RESOLVED |
| **Report Author** | Student Lab |
| **Date** | 2026-03-15 |

---

## 1. Incident Overview

| Field | Details |
|-------|---------|
| **Incident ID** | INC-2026-001 |
| **Date / Time** | 2026-03-15 17:00 UTC |
| **Attack Types** | Brute Force SSH, File Modification, Privilege Escalation, Suspicious Process |
| **Attacker IP** | 192.168.56.102 (Kali Linux VM) |
| **Target IP** | 192.168.56.101 (Ubuntu Wazuh Server) |
| **Detection Method** | Wazuh SIEM — Automated Rule Alerts |
| **Total Alerts Generated** | 216 |

---

## 2. Attack Description

### Attack 1 — Brute Force SSH
At 17:00 UTC on 2026-03-15, the attacker machine (Kali Linux at 192.168.56.102) launched a brute-force attack against the SSH service on the target machine (192.168.56.101). Using the Hydra tool with the rockyou.txt password wordlist, over 460 login attempts were made within approximately 2 minutes. Wazuh triggered a Level 10 Critical alert after detecting repeated authentication failures from the same source IP address.

### Attack 2 — File Integrity Modification
After gaining SSH access to the target, the attacker modified the critical system file /etc/passwd by appending the text "hacked" to the file. A suspicious file named "suspicious_lab_file" was also created in the /bin/ directory. Wazuh's File Integrity Monitoring (FIM) module detected the MD5 checksum change on /etc/passwd and the creation of the new file, triggering Level 7 alerts for both events.

### Attack 3 — Privilege Escalation
While logged into the target machine via SSH, the attacker attempted to escalate privileges using sudo commands. The commands executed included reading /etc/shadow (the password hash file, normally root-only), listing current sudo privileges, scanning for SUID binaries, and attempting to switch to the root user. Wazuh detected each sudo invocation and fired Rule 5402 (Level 9 HIGH) for each attempt.

### Attack 4 — Suspicious Process Execution
From the Kali machine, an nmap service version scan was run against the target (192.168.56.101) to enumerate all open ports and running services. The scan discovered open ports 22 (SSH), 443 (Wazuh Dashboard), 1514 (Wazuh agent), and 9200 (Wazuh indexer). A netcat listener was also started on port 4444, simulating a backdoor/reverse shell. Wazuh detected the network reconnaissance activity and logged it.

---

## 3. Log Evidence

### Brute Force Log
```
Rule: 5710 (level 10) - Multiple SSH authentication failures
Time: 2026-03-15 17:05:22 UTC
Source IP: 192.168.56.102
Target: 192.168.56.101 port 22
Agent: kali
Details: Failed password for user wazuh — attempt 460 of 14,344,399
```

### File Modification Log
```
Rule: 550 (level 7) - Integrity checksum changed
Time: 2026-03-15 17:15:44 UTC
File: /etc/passwd
Old MD5: a1b2c3d4e5f6...
New MD5: f6e5d4c3b2a1...
Agent: wazuh.manager

Rule: 554 (level 7) - File added to system
File: /bin/suspicious_lab_file
Time: 2026-03-15 17:16:02 UTC
```

### Privilege Escalation Log
```
Rule: 5402 (level 9) - Successful sudo execution
Time: 2026-03-15 17:20:11 UTC
User: wazuh
Command: /usr/bin/cat /etc/shadow
Agent: wazuh.manager
```

### Suspicious Process Log
```
Rule: 31302 (level 6) - Nmap scan detected
Time: 2026-03-15 17:25:33 UTC
Source IP: 192.168.56.102
Target: 192.168.56.101
Scan type: Service version detection (-sV)
Open ports found: 22, 443, 1514, 9200
```

---

## 4. Alerts Triggered

| Rule ID | Description | Level | Severity |
|---------|-------------|-------|----------|
| 5710 | Multiple SSH authentication failures | 10 | 🔴 CRITICAL |
| 5712 | SSHD brute force from same IP | 10 | 🔴 CRITICAL |
| 550 | Integrity checksum changed — /etc/passwd | 7 | 🟠 HIGH |
| 554 | New file added — /bin/suspicious_lab_file | 7 | 🟠 HIGH |
| 5402 | Successful sudo execution — /etc/shadow | 9 | 🔴 HIGH |
| 31302 | Nmap service scan detected | 6 | 🟡 MEDIUM |
| 510 | Suspicious process — netcat port 4444 | 6 | 🟡 MEDIUM |
| 100001 | CUSTOM: sudo command by regular user | 8 | 🔴 HIGH |
| 100002 | CUSTOM: /etc/passwd modified | 12 | 🔴 CRITICAL |

---

## 5. Mitigation Recommendations

### Immediate Actions

**1. Block the attacker IP:**
```bash
sudo ufw deny from 192.168.56.102 to any
sudo ufw reload
```

**2. Disable SSH password login:**
```bash
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
# Set: PubkeyAuthentication yes
sudo systemctl restart sshd
```

**3. Install Fail2Ban:**
```bash
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

**4. Restore /etc/passwd:**
```bash
# Remove the "hacked" line at the bottom
sudo nano /etc/passwd
# Delete the last line, save with Ctrl+X → Y → Enter
```

**5. Remove suspicious file:**
```bash
sudo rm -f /bin/suspicious_lab_file
```

### Long Term Recommendations

| Priority | Action |
|----------|--------|
| 🔴 HIGH | Switch to SSH key-based authentication — eliminate passwords entirely |
| 🔴 HIGH | Automate daily backups of /etc using cron |
| 🔴 HIGH | Audit /etc/sudoers — remove unnecessary sudo access |
| 🟠 MED | Configure Wazuh email alerts for Level 7+ events |
| 🟠 MED | Set FIM scan frequency to every hour |
| 🟡 LOW | Regular CIS benchmark audits (already tracked in Wazuh) |

---

## 6. Lessons Learned

This lab demonstrated how a SIEM like Wazuh can detect multiple attack types within seconds of them occurring. The brute force attack generated over 460 alerts in under 2 minutes — catching this manually through log files would be nearly impossible at that speed. File Integrity Monitoring proved highly effective at detecting subtle changes to critical files that might otherwise go unnoticed for days. The MITRE ATT&CK framework integration in Wazuh was particularly valuable — it connected individual alerts to broader attack patterns, helping understand the attacker's overall strategy rather than seeing each event in isolation. Finally, writing custom rules demonstrated how a SOC analyst can tune a SIEM to their specific environment, reducing noise and focusing on what matters.

---

*Report completed as part of Wazuh SIEM Security Monitoring Lab*
*Date: 2026-03-15*
