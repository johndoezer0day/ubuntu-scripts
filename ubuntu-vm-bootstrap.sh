#!/bin/bash
set -e

read -p "Enter new hostname: " NEW_HOSTNAME
read -p "Enter static IP with CIDR, example 192.168.1.50/24: " STATIC_IP
read -p "Enter gateway IP, example 192.168.1.1: " GATEWAY
read -p "Enter DNS servers, example 192.168.1.1,1.1.1.1: " DNS_SERVERS

echo "Setting hostname..."
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

echo "Updating OS and apps..."
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

echo "Installing base tools..."
sudo apt install -y \
  curl \
  wget \
  git \
  nano \
  htop \
  net-tools \
  ca-certificates \
  gnupg \
  lsb-release \
  ufw \
  fail2ban \
  qemu-guest-agent

echo "Installing Docker from official Docker repo..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "Adding Docker apt repository..."
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Enabling Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Adding current user to docker group..."
sudo usermod -aG docker "$USER"

echo "Creating standard project folders..."
sudo mkdir -p /opt/stacks
sudo mkdir -p /opt/backups
sudo chown -R "$USER":"$USER" /opt/stacks /opt/backups

echo "Setting basic firewall..."
sudo ufw allow OpenSSH
sudo ufw --force enable

echo "Finding network interface..."
IFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)

echo "Detected interface: $IFACE"

echo "Writing Netplan static IP config..."
sudo tee /etc/netplan/01-static-ip.yaml > /dev/null <<EOF
network:
  version: 2
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

echo "Applying network settings..."
sudo netplan apply

echo "Bootstrap complete."
echo "The server will reboot in 10 seconds."
echo "After reboot, SSH back in using the new static IP."
sleep 10
sudo reboot
