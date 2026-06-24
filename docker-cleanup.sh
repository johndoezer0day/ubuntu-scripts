#!/bin/bash
set -e

echo "Docker disk usage before cleanup:"
docker system df

echo "Removing unused Docker images, containers, networks, and build cache..."
docker system prune -af

echo "Removing unused Docker volumes?"
read -p "This can delete unused database volumes. Continue? y/n: " DELETE_VOLUMES

if [[ "$DELETE_VOLUMES" == "y" || "$DELETE_VOLUMES" == "Y" ]]; then
  docker volume prune -f
fi

echo "Docker disk usage after cleanup:"
docker system df