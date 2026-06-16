#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "Deteniendo servicios de descarga (Plex sigue corriendo)..."
docker compose stop transmission sonarr radarr prowlarr bazarr flaresolverr
echo "Plex activo. Para reanudar: ./start-services.sh"
