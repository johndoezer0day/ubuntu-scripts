#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: ./docker-update-compose.sh /path/to/compose/folder"
  echo "Example: ./docker-update-compose.sh /opt/stacks/finance-app"
  exit 1
fi

STACK_DIR="$1"

cd "$STACK_DIR"

echo "Updating Docker stack in: $STACK_DIR"

docker compose pull
docker compose down
docker compose up -d
docker image prune -f

echo "Stack updated successfully."
docker compose ps