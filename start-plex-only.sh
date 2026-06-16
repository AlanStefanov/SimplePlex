#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "[+] Modo liviano: iniciando SOLO Plex..."
docker compose up -d plex

echo "[+] Verificando Plex..."
sleep 2
docker compose ps plex --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "[+] Plex corriendo. Resto de servicios detenidos."
echo "    Plex: http://$(hostname -I 2>/dev/null | awk '{print $1}'):32400"
echo ""
echo "[+] Para volver al stack completo: docker compose up -d"
