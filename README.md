# 🛡️ Wazuh SIEM — Complete Security Monitoring Lab

> A complete, beginner-friendly guide to building your own Security Operations Center (SOC) using Wazuh SIEM across three virtual machines.

![Wazuh](https://img.shields.io/badge/Wazuh-4.7.5-blue?style=for-the-badge)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-orange?style=for-the-badge)
![Kali](https://img.shields.io/badge/Kali-Linux-557C94?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Level](https://img.shields.io/badge/Level-Beginner%20Friendly-yellow?style=for-the-badge)

---

## 📖 Table of Contents

1. [What is This Lab?](#-what-is-this-lab)
2. [Lab Architecture](#-lab-architecture)
3. [Requirements](#-requirements)
4. [Phase 1 — VirtualBox & Network Setup](#phase-1--virtualbox--network-setup)
5. [Phase 2 — Ubuntu Server Setup](#phase-2--ubuntu-server-setup)
6. [Phase 3 — Install Wazuh via Docker](#phase-3--install-wazuh-via-docker)
7. [Phase 4 — Kali Linux Setup & Agent Install](#phase-4--kali-linux-setup--agent-install)
8. [Phase 5 — Connecting the Agent](#phase-5--connecting-the-agent)
9. [Phase 6 — Attack Simulations](#phase-6--attack-simulations)
10. [Phase 7 — Reading the Dashboard](#phase-7--reading-the-dashboard)
11. [Phase 8 — Custom Detection Rules](#phase-8--custom-detection-rules)
12. [Phase 9 — SOC Incident Report](#phase-9--soc-incident-report)
13. [Repository Structure](#-repository-structure)
14. [Contributing](#-contributing)
15. [License](#-license)

---

## 🎯 What is This Lab?

This lab teaches you how real-world **Security Operations Centers (SOCs)** detect and respond to cyber attacks. You will:

- Build a 3-machine virtual lab on your own computer
- Install **Wazuh SIEM** — the same tool used by professionals worldwide
- Simulate 4 real attack types against your own machines
- Watch Wazuh detect every attack in real time
- Write a professional **SOC Incident Report**

> 💡 **SIEM** stands for Security Information and Event Management. Think of it as a security camera system for computers — it watches everything and raises an alarm when something suspicious happens.

---

## 🗺️ Lab Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Your Computer (Host)                     │
│                                                             │
│  ┌─────────────────┐   ┌─────────────────┐  ┌───────────┐  │
│  │   Kali Linux    │   │  Ubuntu Server  │  │  (Option) │  │
│  │   ATTACKER      │──▶│  Wazuh Manager  │◀─│  Windows  │  │
│  │ 192.168.56.102  │   │ 192.168.56.101  │  │  Target   │  │
│  └─────────────────┘   └────────┬────────┘  └───────────┘  │
│                                 │                            │
│                    ┌────────────▼────────────┐              │
│                    │   Wazuh Dashboard        │              │
│                    │ https://192.168.56.101   │              │
│                    └─────────────────────────┘              │
│                                                             │
│              Host-Only Network: 192.168.56.0/24             │
└─────────────────────────────────────────────────────────────┘
```

| Machine | Role | IP Address |
|---------|------|-----------|
| Ubuntu Server | Wazuh Manager (the brain) | 192.168.56.101 |
| Kali Linux | Attacker + Agent | 192.168.56.102 |

---

## 📋 Requirements

### Hardware
| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 8 GB | 16 GB |
| Disk Space | 80 GB free | 120 GB free |
| CPU | Dual-core | Quad-core |
| CPU Virtualisation | VT-x or AMD-V must be enabled in BIOS | |

### Software to Download
| Software | Download Link | Purpose |
|----------|--------------|---------|
| VirtualBox | https://www.virtualbox.org/wiki/Downloads | Run virtual machines |
| Ubuntu Server 24.04 | https://ubuntu.com/download/server | Wazuh Manager |
| Kali Linux | https://www.kali.org/get-kali/ | Attacker machine |

---

## Phase 1 — VirtualBox & Network Setup

### 1.1 Install VirtualBox
Download and install VirtualBox from the link above. Use all default settings during installation.

### 1.2 Create a Host-Only Network
This is the private network your VMs will use to talk to each other.

1. Open VirtualBox
2. Click **File → Host Network Manager** (or **Tools → Network**)
3. Click **Create**
4. Set the IP to `192.168.56.1` with mask `255.255.255.0`
5. Enable DHCP server

### 1.3 Create the Ubuntu Server VM

1. Click **New** in VirtualBox
2. Fill in:
   - **Name:** `Wazuh-Server`
   - **Type:** Linux
   - **Version:** Ubuntu (64-bit)
3. **RAM:** 4096 MB (4 GB)
4. **Disk:** 40 GB (VDI, Dynamically allocated)
5. Attach Ubuntu ISO: Settings → Storage → Empty disc → Choose ISO file

**Network Settings for Ubuntu VM:**
- Adapter 1: **NAT** (for internet access)
- Adapter 2: **Host-only Adapter** → VirtualBox Host-Only Ethernet Adapter

### 1.4 Create the Kali Linux VM

1. Click **New** in VirtualBox
2. Fill in:
   - **Name:** `Kali`
   - **Type:** Linux
   - **Version:** Debian (64-bit)
3. **RAM:** 2048 MB (2 GB)
4. **Disk:** 30 GB
5. Attach Kali ISO

**Network Settings for Kali VM:**
- Adapter 1: **NAT** (for internet access)
- Adapter 2: **Host-only Adapter** → VirtualBox Host-Only Ethernet Adapter

---

## Phase 2 — Ubuntu Server Setup

### 2.1 Install Ubuntu Server
Boot the Ubuntu VM and follow the installer:
- Choose **"Install Ubuntu Server"**
- Set your username (example: `wazuh`) and a password you will remember
- When asked about additional packages, enable **OpenSSH server**
- Complete installation and reboot

### 2.2 First Login & System Update
Log in with your username and password, then update the system:

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

> ⚠️ When typing your password in Ubuntu terminal, nothing will appear on screen — this is normal! Just type and press Enter.

### 2.3 Check Your IP Address

```bash
ip a
```

Look for the line under `enp0s3` that shows `inet 192.168.56.xxx` — this is your Wazuh Manager IP. Write it down!

Expected output example:
```
2: enp0s3: ...
    inet 192.168.56.101/24 ...   ← This is your Manager IP
3: enp0s8: ...
    inet 10.0.3.15/24 ...        ← This is your internet (NAT) IP
```

### 2.4 Enable Copy-Paste Between Host and VM
In VirtualBox menu: **Devices → Shared Clipboard → Bidirectional**

> 💡 To paste inside Ubuntu terminal, use **Right Click → Paste** (not Ctrl+V)

---

## Phase 3 — Install Wazuh via Docker

> We use Docker because it works reliably on Ubuntu 24.04 and installs all Wazuh components automatically.

### 3.1 Install Docker

```bash
sudo apt-get install docker.io docker-compose -y
```

### 3.2 Start Docker

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### 3.3 Download Wazuh Docker Files

```bash
git clone https://github.com/wazuh/wazuh-docker.git -b v4.7.5
```

### 3.4 Go Into the Folder

```bash
cd wazuh-docker/single-node
```

### 3.5 Generate Certificates

```bash
sudo docker-compose -f generate-indexer-certs.yml run --rm generator
```

### 3.6 Start Wazuh (This takes 10–15 minutes)

```bash
sudo docker-compose up -d
```

You will see lots of "Pull complete" messages — this is normal. Wait for it to finish.

### 3.7 Verify All 3 Containers Are Running

```bash
sudo docker ps
```

Expected output — all 3 should show **Up**:
```
CONTAINER ID   IMAGE                          STATUS
xxxxxxxxxxxx   wazuh/wazuh-dashboard:4.7.5   Up 2 minutes
xxxxxxxxxxxx   wazuh/wazuh-indexer:4.7.5     Up 2 minutes
xxxxxxxxxxxx   wazuh/wazuh-manager:4.7.5     Up 2 minutes
```

### 3.8 Access the Wazuh Dashboard

Open your **host computer browser** and go to:
```
https://192.168.56.101
```

- Accept the security warning (click Advanced → Proceed)
- **Username:** `admin`
- **Password:** `SecretPassword`

✅ You should see the Wazuh dashboard!

---

## Phase 4 — Kali Linux Setup & Agent Install

### 4.1 Boot Kali and Fix DNS
Start your Kali VM and open a terminal, then fix DNS so internet works:

```bash
sudo rm -f /usr/share/keyrings/wazuh.gpg 2>/dev/null
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo tee /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
```

### 4.2 Test Internet

```bash
ping -c 3 8.8.8.8
```

You should see replies — if yes, internet is working ✅

### 4.3 Add Wazuh Repository

```bash
wget -qO - https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --dearmor -o /usr/share/keyrings/wazuh.gpg
sudo chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee /etc/apt/sources.list.d/wazuh.list
```

### 4.4 Install Wazuh Agent

```bash
sudo apt-get update && sudo WAZUH_MANAGER='192.168.56.101' apt-get install wazuh-agent -y
```

> ⚠️ Replace `192.168.56.101` with your actual Ubuntu Server IP if different.

### 4.5 Configure the Agent

Write a clean configuration file pointing to your manager:

```bash
sudo bash -c 'cat > /var/ossec/etc/ossec.conf << EOF
<ossec_config>
  <client>
    <server>
      <address>192.168.56.101</address>
      <port>1514</port>
      <protocol>tcp</protocol>
    </server>
  </client>
  <logging>
    <log_format>plain</log_format>
  </logging>
</ossec_config>
EOF'
```

### 4.6 Start the Agent

```bash
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

### 4.7 Verify Agent is Running

```bash
sudo systemctl status wazuh-agent
```

You should see **active (running)** ✅

---

## Phase 5 — Connecting the Agent

### 5.1 Check Dashboard
Go to `https://192.168.56.101` in your browser.

You should now see:
- **Active agents: 1** ✅
- Agent named **kali** with a green dot 🟢

### 5.2 Enable SSH on Ubuntu
Go back to your Ubuntu terminal and run:

```bash
sudo apt-get install openssh-server -y
sudo systemctl start ssh
sudo systemctl enable ssh
```

Verify SSH is running:
```bash
sudo systemctl status ssh
```

You should see **active (running)** and **Server listening on port 22** ✅

---

## Phase 6 — Attack Simulations

> ⚠️ **IMPORTANT:** Only run these attacks in your own virtual lab. Never target real systems or systems you don't own. This is illegal and unethical.

### Attack 1 — 🔨 Brute Force SSH

**What it is:** Trying thousands of passwords automatically until one works, like trying every key on a keyring.

**What Wazuh detects:** Rule IDs `5710`, `5711`, `5712` — Level 10 CRITICAL

Run from **Kali terminal:**

```bash
# Decompress the password wordlist
sudo gunzip /usr/share/wordlists/rockyou.txt.gz

# Run the brute force attack
hydra -l wazuh -P /usr/share/wordlists/rockyou.txt ssh://192.168.56.101 -t 4 -V
```

Let it run for **1-2 minutes** then press **Ctrl+C** to stop.

---

### Attack 2 — 📁 File Integrity Modification

**What it is:** Secretly changing important system files — like a burglar moving things around in your house.

**What Wazuh detects:** Rule IDs `550`, `553`, `554` — Level 7 HIGH

First, SSH into Ubuntu from Kali:
```bash
ssh wazuh@192.168.56.101
```

Then run these on the Ubuntu machine:
```bash
# Modify a critical system file
echo 'hacked' | sudo tee -a /etc/passwd

# Create a suspicious file in /bin
sudo touch /bin/suspicious_file
```

---

### Attack 3 — 🔑 Privilege Escalation

**What it is:** A regular user trying to gain admin/root powers they shouldn't have.

**What Wazuh detects:** Rule IDs `5402`, `5403` — Level 9 HIGH

Run these while still SSH'd into Ubuntu:
```bash
# Try to read the shadow file (requires root)
sudo cat /etc/shadow

# Try to become root
sudo su -

# Scan for SUID binaries (privilege escalation technique)
find / -perm -4000 2>/dev/null
```

Press **Ctrl+C** after the find command runs for a few seconds.

---

### Attack 4 — 🕵️ Suspicious Process Execution

**What it is:** Running hacker tools that a normal computer should never run.

**What Wazuh detects:** Rule IDs `510`, `511`, `31302` — Level 6 MEDIUM

Type `exit` to leave the SSH session, then run from **Kali terminal:**
```bash
# Port scan the target (maps all open services)
nmap -sV 192.168.56.101

# Start a netcat listener (simulates a backdoor)
nc -lvp 4444 &

# Stop the listener after a few seconds
kill %1
```

---

## Phase 7 — Reading the Dashboard

After running all attacks, open `https://192.168.56.101` in your browser.

### 7.1 View Security Events
1. Click **☰ menu → Security Events**
2. Click the **Events** tab
3. You will see a table of all alerts with timestamps
4. The graph shows alert spikes when attacks happened

### 7.2 Filter Alerts by Attack Type

In the search bar, type these filters one at a time:

| Filter | Shows |
|--------|-------|
| `authentication_failed` | Brute force SSH alerts |
| `syscheck` | File modification alerts |
| `syslog` | Privilege escalation alerts |

### 7.3 View MITRE ATT&CK Mapping
1. Click **Modules** at top
2. Click **MITRE ATT&CK**
3. See how your attacks map to real-world hacker techniques!

### 7.4 Screenshots to Take
Save these for your report:
- [ ] Dashboard overview showing total alerts and spike graph
- [ ] Brute force alert details
- [ ] File integrity alert details
- [ ] Privilege escalation alert
- [ ] MITRE ATT&CK mapping view

---

## Phase 8 — Custom Detection Rules

You can write your own rules to detect specific activity. These rules go in:
`/var/ossec/etc/rules/local_rules.xml`

### 8.1 SSH Into Ubuntu Manager

```bash
ssh wazuh@192.168.56.101
```

### 8.2 Add Custom Rules

```bash
sudo bash -c 'cat > /var/ossec/etc/rules/local_rules.xml << EOF
<group name="custom_lab_rules,">

  <!-- Rule: Alert on ANY sudo command -->
  <rule id="100001" level="8">
    <if_sid>5402</if_sid>
    <match>sudo</match>
    <description>CUSTOM: User executed a sudo command</description>
    <group>privilege_escalation</group>
  </rule>

  <!-- Rule: Alert on /etc/passwd modification -->
  <rule id="100002" level="12">
    <if_sid>550</if_sid>
    <field name="syscheck.path">/etc/passwd</field>
    <description>CUSTOM: CRITICAL - /etc/passwd was modified!</description>
    <group>critical_file_change</group>
  </rule>

  <!-- Rule: Alert on new file in /bin -->
  <rule id="100003" level="10">
    <if_sid>554</if_sid>
    <field name="syscheck.path">/bin/</field>
    <description>CUSTOM: Suspicious new file created in /bin!</description>
    <group>suspicious_file</group>
  </rule>

</group>
EOF'
```

### 8.3 Reload Rules

```bash
sudo docker exec single-node_wazuh.manager_1 /var/ossec/bin/wazuh-control restart
```

### 8.4 Test Your Custom Rules
Run one of the attacks again — your custom rule should now appear in the dashboard with your custom description!

---

## Phase 9 — SOC Incident Report

After completing all attacks and capturing screenshots, fill in the incident report template located at:

📄 [`reports/incident_report_template.md`](reports/incident_report_template.md)

A complete example report is at:

📄 [`reports/example_completed_report.md`](reports/example_completed_report.md)

### What Your Report Must Include:
1. **Incident Overview** — date, IPs, attack types
2. **Attack Description** — what happened in plain English
3. **Log Evidence** — actual log lines copied from Wazuh
4. **Alerts Triggered** — table of rule IDs and levels
5. **Mitigation Recommendations** — how to prevent this

---

## 📁 Repository Structure

```
wazuh-siem-lab/
│
├── README.md                          ← This guide
├── LICENSE                            ← MIT License
├── .gitignore                         ← Git ignore rules
│
├── scripts/
│   ├── ubuntu/
│   │   ├── install_wazuh_docker.sh    ← Automated Wazuh install
│   │   ├── attack2_filemod.sh         ← File modification attack
│   │   └── attack3_privesc.sh         ← Privilege escalation attack
│   └── kali/
│       ├── setup_agent.sh             ← Agent install & configure
│       ├── attack1_bruteforce.sh      ← SSH brute force attack
│       └── attack4_suspicious.sh      ← Suspicious process attack
│
├── rules/
│   └── local_rules.xml               ← Custom Wazuh detection rules
│
├── reports/
│   ├── incident_report_template.md   ← Blank template to fill in
│   └── example_completed_report.md   ← Completed example report
│
└── screenshots/                       ← Add your screenshots here
    └── README.txt
```

---

## 🤝 Contributing

Pull requests are welcome! If you find a bug or have an improvement:

1. Fork this repository
2. Create a branch: `git checkout -b fix/your-fix-name`
3. Commit your changes: `git commit -m "Fix: description"`
4. Push: `git push origin fix/your-fix-name`
5. Open a Pull Request

---

## ⚠️ Disclaimer

This project is for **educational purposes only**. All attacks must be performed exclusively in your own isolated virtual lab environment. Never use these techniques against systems you do not own or have explicit written permission to test. Unauthorized access to computer systems is a criminal offence in most countries.

---

## 📄 License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

---

*Built for cybersecurity students learning SIEM, threat detection, and SOC operations.*
