#!/bin/bash
# Cloudflare Tunnel for this server (locally-managed tunnel, routed by DNS).
#
#   tunnel-setup.sh            create/refresh the tunnel from servers/<host>/tunnel.conf
#   tunnel-setup.sh login      only print the Cloudflare login URL (one-time, per server)
#
# Flow: `cloudflared tunnel login` (a human opens the URL and picks the zone) ->
# tunnel "qura-<host>" is created -> one CNAME per hostname in tunnel.conf ->
# config.yml is rendered -> the cloudflared container starts (compose profile "tunnel").
# Re-run after editing tunnel.conf to add hostnames; it is idempotent.
set -euo pipefail
QURA_LOG_TAG=tunnel
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

host="$(hostname -s | tr '[:upper:]' '[:lower:]')"
tunnel="qura-$host"
map="$QURA_INFRA/servers/$host/tunnel.conf"
cert="$HOME/.cloudflared/cert.pem"

if [ ! -f "$cert" ] || [ "${1:-}" = "login" ]; then
  echo "Open the URL below, sign in to Cloudflare and authorise the zone (domain):"
  cloudflared tunnel login
  [ "${1:-}" = "login" ] && exit 0
fi
[ -f "$map" ] || { echo "missing $map (lines: <hostname> <service>:<port>)"; exit 1; }

if ! cloudflared tunnel info "$tunnel" >/dev/null 2>&1; then
  cloudflared tunnel create "$tunnel"
  log "created tunnel $tunnel"
fi
id="$(cloudflared tunnel list --name "$tunnel" --output json | python3 -c 'import json,sys; print(json.load(sys.stdin)[0]["id"])')"

install -m 644 "$HOME/.cloudflared/$id.json" "$QURA_ROOT/cloudflared/credentials.json"

{
  echo "# Rendered by tunnel-setup.sh from $map — edit that file, not this one."
  echo "tunnel: $id"
  echo "credentials-file: /etc/cloudflared/credentials.json"
  echo "no-autoupdate: true"
  echo "ingress:"
  grep -vE '^\s*(#|$)' "$map" | while read -r hostname target; do
    echo "  - hostname: $hostname"
    echo "    service: http://$target"
  done
  echo "  - service: http_status:404"
} > "$QURA_ROOT/cloudflared/config.yml"
chmod 644 "$QURA_ROOT/cloudflared/config.yml"

grep -vE '^\s*(#|$)' "$map" | while read -r hostname _; do
  cloudflared tunnel route dns --overwrite-dns "$tunnel" "$hostname" && log "dns $hostname -> $tunnel"
done

set_var COMPOSE_PROFILES tunnel
compose up -d --no-deps --force-recreate cloudflared
log "tunnel $tunnel ($id) running"
