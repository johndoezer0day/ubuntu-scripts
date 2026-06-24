#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: ./backup-compose-stack.sh /path/to/compose/folder"
  echo "Example: ./backup-compose-stack.sh /opt/stacks/finance-app"
  exit 1
fi

STACK_DIR="$1"
STACK_NAME=$(basename "$STACK_DIR")
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="/opt/backups/$STACK_NAME-$DATE"

echo "Creating backup folder: $BACKUP_DIR"
sudo mkdir -p "$BACKUP_DIR"

echo "Backing up stack folder..."
sudo rsync -a "$STACK_DIR/" "$BACKUP_DIR/"

echo "Backup created at:"
echo "$BACKUP_DIR"