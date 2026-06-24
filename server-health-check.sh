#!/bin/bash

echo "===== HOSTNAME ====="
hostname

echo ""
echo "===== IP ADDRESSES ====="
ip -br a

echo ""
echo "===== DISK USAGE ====="
df -h

echo ""
echo "===== MEMORY ====="
free -h

echo ""
echo "===== CPU LOAD ====="
uptime

echo ""
echo "===== DOCKER VERSION ====="
docker --version 2>/dev/null || echo "Docker not installed"

echo ""
echo "===== DOCKER COMPOSE VERSION ====="
docker compose version 2>/dev/null || echo "Docker Compose not installed"

echo ""
echo "===== RUNNING CONTAINERS ====="
docker ps 2>/dev/null || echo "Docker not available"

echo ""
echo "===== FAILED SYSTEMD SERVICES ====="
systemctl --failed