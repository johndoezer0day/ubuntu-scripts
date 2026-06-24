------------------------------------------------------------------------------------------------------
# Install git if needed
sudo apt update
sudo apt install -y git

# Clone your repository
git clone https://github.com/johndoezer0day/ubuntu-scripts.git
------------------------------------------------------------------------------------------------------


# Ubuntu VM Bootstrap Toolkit

Automated Ubuntu Server bootstrap process for homelab, development, Docker, and application servers.

---

# Features

The bootstrap script automatically:

* Sets hostname
* Configures static IP address
* Configures DNS servers
* Installs Docker Engine
* Installs Docker Compose
* Installs common admin tools
* Configures UFW firewall
* Restricts SSH access to your LAN
* Optionally enables RDP access
* Creates standard folder structure
* Validates networking and DNS
* Optionally disables unnecessary services
* Optionally cleans cloned Docker containers
* Reboots automatically

---

# Included Files

```txt
ubuntu-vm-bootstrap.sh
update-server.sh
docker-cleanup.sh
docker-update-compose.sh
backup-compose-stack.sh
server-health-check.sh
README.md
```

---

# Quick Start

## 1. Login to New VM

```bash
ssh username@ip-address
```

---

## 2. Install Git

```bash
sudo apt update
sudo apt install -y git
```

---

## 3. Clone Repository

```bash
git clone https://github.com/johndoezer0day/ubuntu-scripts.git
```

---

## 4. Enter Repository

```bash
cd ubuntu-scripts
```

---

## 5. Make Scripts Executable

```bash
chmod +x *.sh
```

Verify:

```bash
ls -lah
```

---

## 6. Run Bootstrap

```bash
sudo ./ubuntu-vm-bootstrap.sh
```

---

# Bootstrap Questions

The script will ask for:

```txt
Hostname
Static IP
Gateway
DNS Servers
SSH Allowed Subnet
Enable RDP
Disable Avahi/CUPS
Clean Docker Containers
```

Example:

```txt
Hostname:
finance-appdev1

Static IP:
192.x.x.X/24

Gateway:
192.x.x.1

DNS Servers:
192.x.x.x,1.1.1.1

SSH Allowed Subnet:
192.x.x.x/24

Enable RDP:
y

Disable Avahi/CUPS:
y

Clean Docker Containers:
y
```

---

# Reconnect After Reboot

```bash
ssh username@new-ip-address
```

---

# Post Bootstrap Validation

Verify hostname:

```bash
hostnamectl
```

Verify networking:

```bash
ip -br a
```

Verify DNS:

```bash
ping google.com
```

Verify internet:

```bash
ping 1.1.1.1
```

Verify updates:

```bash
sudo apt update
sudo apt list --upgradable
```

Verify Docker:

```bash
docker --version
docker compose version
```

Verify Docker functionality:

```bash
docker run hello-world
```

Verify firewall:

```bash
sudo ufw status numbered
```

Verify listening ports:

```bash
sudo ss -tulpn
```

---

# Standard Folder Structure

The bootstrap script automatically creates:

```txt
/opt
├── backups
├── logs
├── scripts
└── stacks
```

Recommended application layout:

```txt
/opt/stacks
└── application-name
    ├── app
    ├── backups
    ├── data
    ├── docker-compose.yml
    └── .env
```

Example:

```txt
/opt/stacks/application-name
├── app
├── backups
├── data
├── docker-compose.yml
└── .env
```

---

# Security Baseline

Recommended firewall result:

```txt
22/tcp   SSH   LAN only
3389/tcp RDP   LAN only (optional)
```

All other inbound ports should remain blocked until required.

Examples:

```bash
sudo ufw status numbered
```

```txt
22/tcp   ALLOW IN 192.x.x.x/24
3389/tcp ALLOW IN 192.x.x.x/24
```

---

# VM Snapshot Recommendation

After validation:

1. Confirm updates completed
2. Confirm Docker works
3. Confirm firewall rules
4. Confirm DNS resolution

Create a VM snapshot:

```txt
Server-Baseline
```

Examples:

```txt
Finance-App-Secure-Baseline
Docker-Host-Baseline
Ubuntu-App-Server-Baseline
```

---

# Common Commands

## Update Server

```bash
./update-server.sh
```

---

## Health Check

```bash
./server-health-check.sh
```

---

## Docker Cleanup

```bash
./docker-cleanup.sh
```

---

## Update Docker Stack

```bash
./docker-update-compose.sh /opt/stacks/application-name
```

Example:

```bash
./docker-update-compose.sh /opt/stacks/application-name
```

---

## Backup Docker Stack

```bash
./backup-compose-stack.sh /opt/stacks/application-name
```

Example:

```bash
./backup-compose-stack.sh /opt/stacks/application-name
```

---

# Notes

* GitHub access requires outbound internet only.
* SSH should be restricted to trusted networks.
* DNS should always include a backup resolver.
* Take a VM snapshot before deploying production applications.
* Keep application data outside containers using Docker volumes.
* Store secrets in `.env` files and never commit them to GitHub.
