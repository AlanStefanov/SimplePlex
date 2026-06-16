#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "[+] Creando directorios para medios y descargas..."
mkdir -p data/{tv,movies,downloads,torrents/{watch,complete,incomplete}}
mkdir -p config/{plex,transmission,sonarr,radarr,prowlarr,bazarr} transcode

echo "[+] Iniciando todos los servicios (Plex + descargas)..."
docker compose up -d

echo "[+] Verificando servicios..."
sleep 3
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "[+] Stack completo levantado."
echo "    Plex:          http://$(hostname -I 2>/dev/null | awk '{print $1}'):32400"
echo "    Transmission:  http://localhost:9091"
echo "    Sonarr:        http://localhost:8989"
echo "    Radarr:        http://localhost:7878"
echo "    Prowlarr:      http://localhost:9696"
echo "    Bazarr:        http://localhost:6767"
