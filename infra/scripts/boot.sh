#!/bin/bash
# Run at machine boot (launchd com.qura.boot / systemd qura-boot). No login needed.
# Starts the Docker VM, then every built service + the tunnel.
set -uo pipefail
QURA_LOG_TAG=boot
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

log "boot: starting"
for i in 1 2 3 4 5; do
  ensure_docker && break
  log "boot: docker not ready (attempt $i); retrying in 20s"
  sleep 20
done
docker info >/dev/null 2>&1 || { log "ERROR boot: docker never came up"; exit 1; }
apply_stack >> "$QURA_LOG_DIR/boot.log" 2>&1
log "boot: stack up: $(docker ps --format '{{.Names}}' | tr '\n' ' ')"
