#!/usr/bin/env bash
set -euo pipefail

echo "Creando estructura de directorios..."
mkdir -p config/{plex,transmission,sonarr,radarr,prowlarr,bazarr}
mkdir -p data/{tv,movies,downloads,torrents/{watch,complete,incomplete}}
mkdir -p transcode

echo "Asignando permisos (PUID=${PUID:-1000}:PGID=${PGID:-1000})..."
chown -R "${PUID:-1000}:${PGID:-1000}" config data transcode

echo "Done."
echo ""
echo "Antes de levantar:"
echo "  1. Editar .env y poner PLEX_CLAIM (obtener en https://plex.tv/claim)"
echo "  2. Ajustar PUID/PGID si tu usuario no es 1000 (correr 'id' para ver)"
echo "  3. Ejecutar: docker compose up -d"
echo "  4. Configurar Sonarr/Radarr/Prowlarr/Bazarr (una vez vía web, después anda solo)"
