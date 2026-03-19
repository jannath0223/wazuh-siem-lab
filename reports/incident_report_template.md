# SOC INCIDENT REPORT

| Field | Value |
|-------|-------|
| **Classification** | CONFIDENTIAL |
| **Severity** | HIGH |
| **Status** | RESOLVED |
| **Report Author** | [Your Name] |
| **Date** | [YYYY-MM-DD] |

---

## 1. Incident Overview

| Field | Details |
|-------|---------|
| **Incident ID** | INC-[YEAR]-001 |
| **Date / Time** | [YYYY-MM-DD HH:MM UTC] |
| **Attack Types** | Brute Force, File Modification, Privilege Escalation, Suspicious Process |
| **Attacker IP** | [Kali IP] |
| **Target IP** | [Ubuntu IP] |
| **Detection Method** | Wazuh SIEM — Automated Rule Alerts |
| **Total Alerts Generated** | [Number from dashboard] |

---

## 2. Attack Description

### Attack 1 — Brute Force SSH
[Describe what happened in your own words. When did it start? How many attempts? What tool was used?]

Example:
> At [TIME], the attacker machine (Kali at [IP]) launched a brute-force attack against the SSH service on the target ([IP]). Using Hydra with the rockyou.txt wordlist, over [NUMBER] login attempts were made. Wazuh triggered a Level 10 alert after detecting repeated failures from the same source IP.

### Attack 2 — File Integrity Modification
[Describe what files were changed and how Wazuh detected it]

### Attack 3 — Privilege Escalation
[Describe the sudo commands run and what Wazuh detected]

### Attack 4 — Suspicious Process Execution
[Describe the nmap scan and netcat listener, and Wazuh's response]

---

## 3. Log Evidence

> Paste your actual log lines from the Wazuh dashboard here.
> Go to: Security Events → Events tab → Click any alert → Copy the raw log

### Brute Force Log
```
[Paste log line here]
Rule: 5710 (level 10)
Source IP: [Kali IP]
```

### File Modification Log
```
[Paste log line here]
Rule: 550 (level 7)
File: /etc/passwd
```

### Privilege Escalation Log
```
[Paste log line here]
Rule: 5402 (level 9)
User: [username]
Command: [command run]
```

### Suspicious Process Log
```
[Paste log line here]
Rule: 31302 (level 6)
Source: [Kali IP]
```

---

## 4. Alerts Triggered

| Rule ID | Description | Level | Severity |
|---------|-------------|-------|----------|
| 5712 | SSHD brute force detected | 10 | 🔴 CRITICAL |
| 550 | Integrity checksum changed — /etc/passwd | 7 | 🟠 HIGH |
| 554 | New file added — /bin/ | 7 | 🟠 HIGH |
| 5402 | Successful sudo execution | 9 | 🔴 HIGH |
| 31302 | Nmap port scan detected | 6 | 🟡 MEDIUM |
| 510 | Suspicious process — netcat | 6 | 🟡 MEDIUM |

---

## 5. Mitigation Recommendations

### Immediate Actions

**1. Block the attacker IP:**
```bash
sudo ufw deny from [ATTACKER_IP] to any
sudo ufw reload
```

**2. Disable SSH password authentication (use keys instead):**
```bash
sudo nano /etc/ssh/sshd_config
# Change: PasswordAuthentication no
sudo systemctl restart sshd
```

**3. Install Fail2Ban to auto-block brute force:**
```bash
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

**4. Restore modified files:**
```bash
# Remove the line added by attacker
sudo nano /etc/passwd   # Delete last line
sudo rm /bin/suspicious_lab_file
```

**5. Audit sudo users:**
```bash
sudo cat /etc/sudoers
sudo -l -U [username]
```

### Long Term Recommendations

| Priority | Action |
|----------|--------|
| 🔴 HIGH | Use SSH key authentication only — disable password login |
| 🔴 HIGH | Enable automatic backups of /etc directory |
| 🔴 HIGH | Apply least privilege — only give sudo to who needs it |
| 🟠 MED | Set up Wazuh email alerts for Level 7+ events |
| 🟠 MED | Enable hourly FIM scans instead of default 12 hours |
| 🟡 LOW | Regular security audits using CIS benchmarks |

---

## 6. Screenshots

| File | Description |
|------|-------------|
| `screenshots/dashboard_overview.png` | Wazuh dashboard with alert count |
| `screenshots/attack1_bruteforce.png` | Brute force alert details |
| `screenshots/attack2_filemod.png` | File integrity alert |
| `screenshots/attack3_privesc.png` | Privilege escalation alert |
| `screenshots/attack4_suspicious.png` | Nmap/netcat alert |
| `screenshots/mitre_attack_map.png` | MITRE ATT&CK mapping |

---

## 7. Lessons Learned

[Write 3-5 sentences about what you learned from this lab]

---

*Report completed as part of Wazuh SIEM Security Monitoring Lab*
