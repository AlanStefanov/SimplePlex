#!/usr/bin/env bash
# Watch descargas de películas (Radarr) y series (Sonarr) en tiempo real

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Monitoreando descargas (Radarr + Sonarr) ==="
echo "Presiona Ctrl+C para salir"
echo ""

tail -f \
  "$SCRIPT_DIR/config/sonarr/logs/sonarr.debug.txt" \
  "$SCRIPT_DIR/config/radarr/logs/radarr.debug.txt" 2>/dev/null | \
  grep --line-buffered -E \
    "SearchService.*completed|Downloaded.*ImportService|ImportApproved|EpisodeFileMoving|MovieFileMoving|CompletedDownload|reports downloaded|HardLinkOrCopy" | \
  grep --line-buffered -v "AlreadyImportedSpecification"
