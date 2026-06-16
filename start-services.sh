#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "Iniciando servicios de descarga..."
docker compose start transmission sonarr radarr prowlarr bazarr flaresolverr
echo "Servicios iniciados."
