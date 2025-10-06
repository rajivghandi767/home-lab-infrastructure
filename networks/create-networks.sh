#!/bin/bash
# Create all Docker Networks for Home Lab Infrastructure

set -e

echo "Creating Docker Networks for Home Lab Infrastructure..."

# Define networks
NETWORKS=(
    "core"           # NPM, Pihole, Vault
    "management"     # Jenkins, Portainer, Watchtower
    "database"       # Postgres Dev, pgAdmin, postgres-exporter
    "monitoring"     # Prometheus, Grafana, Node-Exporters, Alertmanager
    "media"          # Jellyfin
    "portfolio"      # Portfolio Website
    "trivia"         # Country Trivia App
)

# Create each network if it doesn't exist
for network in "${NETWORKS[@]}"; do
    if docker network inspect "$network" >/dev/null 2>&1; then
        echo "✓ Network '$network' already exists"
    else
        docker network create "$network" --driver bridge
        echo "✓ Created network '$network'"
    fi
done

echo ""
echo "Network creation complete!"
echo ""
echo "Created Networks:"
docker network ls | grep -E "core|management|database|monitoring|media|portfolio|trivia"