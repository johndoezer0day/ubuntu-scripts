# Install git if needed
sudo apt update
sudo apt install -y git

# Clone your repository
git clone https://github.com/johndoezer0day/ubuntu-scripts.git

# Enter the folder
cd ubuntu-scripts

# Make scripts executable
chmod +x *.sh

# Run bootstrap
sudo ./ubuntu-vm-bootstrap.sh

---------------------# Quick Start - New Ubuntu VM

## 1. Login

SSH to the new VM:

```bash
ssh username@ip-address
```

## 2. Create Scripts Folder

```bash
mkdir -p ~/ubuntu-scripts
cd ~/ubuntu-scripts
```

## 3. Copy Scripts

Copy the following files into the folder:

```txt
ubuntu-vm-bootstrap.sh
update-server.sh
docker-cleanup.sh
docker-update-compose.sh
backup-compose-stack.sh
server-health-check.sh
```

## 4. Make Scripts Executable

```bash--------------------------------
chmod +x *.sh
```

Verify:

```bash
ls -lah
```

## 5. Run Bootstrap

```bash
sudo ./ubuntu-vm-bootstrap.sh
```

The script will ask for:

```txt
Hostname
Static IP
Gateway
DNS Servers
```

Example:

```txt
application-name
192.168.1.50/24
192.168.1.1
192.168.1.10,1.1.1.1
```

## 6. Wait For Reboot

The VM will reboot automatically.

## 7. Reconnect

```bash
ssh username@new-ip-address
```

## 8. Verify Installation

```bash
hostname

ip a

docker --version

docker compose version
```

## 9. Run Health Check

```bash
cd ~/ubuntu-scripts

./server-health-check.sh
```

## 10. Create Standard Project Folder

```bash
sudo mkdir -p /opt/stacks
sudo mkdir -p /opt/backups

sudo chown -R $USER:$USER /opt/stacks
sudo chown -R $USER:$USER /opt/backups
```

## Common Commands

Update Server:

```bash
./update-server.sh
```

Health Check:

```bash
./server-health-check.sh
```

Docker Cleanup:

```bash
./docker-cleanup.sh
```

Update Docker Stack:

```bash
./docker-update-compose.sh /opt/stacks/application-name
```

Backup Docker Stack:

```bash
./backup-compose-stack.sh /opt/stacks/application-name
```
