#!/bin/bash
set -e

echo "===================================================="
echo " Ubuntu VM Bootstrap Script"
echo "===================================================="
echo ""

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script with sudo:"
  echo "sudo ./ubuntu-vm-bootstrap.sh"
  exit 1
fi

REAL_USER="${SUDO_USER:-$USER}"

read -p "Enter new hostname: " NEW_HOSTNAME
read -p "Enter static IP with CIDR, example 192.168.60.50/24: " STATIC_IP
read -p "Enter gateway IP, example 192.168.60.1: " GATEWAY
read -p "Enter DNS servers, comma-separated, example 192.168.60.20,1.1.1.1: " DNS_SERVERS
read -p "Enter LAN subnet allowed for SSH, example 192.168.60.0/24: " SSH_SUBNET
read -p "Allow RDP port 3389 from LAN subnet? y/n: " ENABLE_RDP
read -p "Disable Avahi and CUPS services? y/n: " DISABLE_EXTRA_SERVICES
read -p "Clean stopped Docker containers from cloned VM? y/n: " CLEAN_DOCKER_CONTAINERS

echo ""
echo "Setting hostname..."
hostnamectl set-hostname "$NEW_HOSTNAME"

echo ""
echo "Initial OS update..."
apt update
apt upgrade -y
apt autoremove -y

echo ""
echo "Installing base tools..."
apt install -y \
  curl \
  wget \
  git \
  nano \
  vim \
  htop \
  tree \
  jq \
  net-tools \
  dnsutils \
  ca-certificates \
  gnupg \
  lsb-release \
  ufw \
  fail2ban \
  qemu-guest-agent \
  cifs-utils \
  nfs-common

echo ""
echo "Installing Docker from official Docker repo..."
install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
fi

chmod a+r /etc/apt/keyrings/docker.asc

echo ""
echo "Adding Docker apt repository..."
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo ""
echo "Enabling Docker..."
systemctl enable docker
systemctl start docker

echo ""
echo "Adding $REAL_USER to docker group..."
usermod -aG docker "$REAL_USER"

echo ""
echo "Creating standard project folders..."
mkdir -p /opt/stacks
mkdir -p /opt/backups
mkdir -p /opt/scripts
mkdir -p /opt/logs
chown -R "$REAL_USER":"$REAL_USER" /opt/stacks /opt/backups /opt/scripts /opt/logs

echo ""
echo "Finding network interface..."
IFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)

if [ -z "$IFACE" ]; then
  echo "ERROR: Could not detect default network interface."
  exit 1
fi

echo "Detected interface: $IFACE"

echo ""
echo "Writing Netplan static IP config..."
tee /etc/netplan/01-static-ip.yaml > /dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $IFACE:
      dhcp4: no
      addresses:
        - $STATIC_IP
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
        addresses: [${DNS_SERVERS}]
EOF

echo ""
echo "Applying network settings..."
netplan apply

echo ""
echo "Waiting for networking to settle..."
sleep 10

echo ""
echo "Testing gateway connectivity..."
if ping -c 2 "$GATEWAY" >/dev/null 2>&1; then
  echo "Gateway reachable: $GATEWAY"
else
  echo "WARNING: Gateway test failed: $GATEWAY"
fi

echo ""
echo "Testing internet connectivity by IP..."
if ping -c 2 1.1.1.1 >/dev/null 2>&1; then
  echo "Internet by IP is working."
else
  echo "WARNING: Internet by IP failed."
fi

echo ""
echo "Testing DNS..."
if getent hosts google.com >/dev/null 2>&1; then
  echo "DNS is working."
else
  echo "WARNING: DNS lookup failed."
  echo "Check your DNS entry:"
  echo "$DNS_SERVERS"
fi

echo ""
echo "Running final apt update after network/DNS configuration..."
apt update

echo ""
echo "Configuring firewall..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

ufw allow from "$SSH_SUBNET" to any port 22 proto tcp comment 'SSH LAN Only'

if [[ "$ENABLE_RDP" == "y" || "$ENABLE_RDP" == "Y" ]]; then
  ufw allow from "$SSH_SUBNET" to any port 3389 proto tcp comment 'RDP LAN Only'
fi

ufw --force enable
ufw reload

echo ""
echo "Firewall rules:"
ufw status numbered

if [[ "$DISABLE_EXTRA_SERVICES" == "y" || "$DISABLE_EXTRA_SERVICES" == "Y" ]]; then
  echo ""
  echo "Disabling unnecessary services..."
  systemctl disable --now avahi-daemon 2>/dev/null || true
  systemctl disable --now cups 2>/dev/null || true
fi

if [[ "$CLEAN_DOCKER_CONTAINERS" == "y" || "$CLEAN_DOCKER_CONTAINERS" == "Y" ]]; then
  echo ""
  echo "Existing Docker containers:"
  docker ps -a || true

  echo ""
  echo "Removing stopped containers..."
  docker container prune -f || true
fi

echo ""
echo "Server validation summary:"
echo "Hostname:"
hostname

echo ""
echo "IP addresses:"
ip -br a

echo ""
echo "Docker version:"
docker --version

echo ""
echo "Docker Compose version:"
docker compose version

echo ""
echo "Listening ports:"
ss -tulpn || true

echo ""
echo "Bootstrap complete."
echo "Recommended next steps after reboot:"
echo "1. SSH back in using the static IP."
echo "2. Run: sudo ufw status numbered"
echo "3. Run: sudo ss -tulpn"
echo "4. Run: docker run hello-world"
echo "5. Run: sudo apt list --upgradable"
echo "6. Take a VM snapshot."
echo ""
echo "The server will reboot in 15 seconds."
sleep 15
reboot