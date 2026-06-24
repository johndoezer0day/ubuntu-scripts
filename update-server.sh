#!/bin/bash
set -e

echo "Updating package lists..."
sudo apt update

echo "Upgrading installed packages..."
sudo apt upgrade -y

echo "Removing unused packages..."
sudo apt autoremove -y

echo "Cleaning package cache..."
sudo apt autoclean

echo "Update complete."
read -p "Reboot now? y/n: " REBOOT

if [[ "$REBOOT" == "y" || "$REBOOT" == "Y" ]]; then
  sudo reboot
fi