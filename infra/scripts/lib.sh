#!/bin/bash
# Shared helpers for every Qura infra script. Source it; don't run it.

export QURA_ROOT="${QURA_ROOT:-$HOME/qura-server}"
export QURA_INFRA="${QURA_INFRA:-$QURA_ROOT/repos/qura-kb/infra}"
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export DOCKER_CLI_HINTS=false

QURA_COMPOSE_FILE="$QURA_INFRA/compose/docker-compose.yml"
QURA_COMPOSE_ENV="$QURA_ROOT/compose.env"
QURA_LOG_DIR="$QURA_ROOT/logs"
QURA_STATE_DIR="$QURA_ROOT/state"

# Colima VM size (macOS only). 3 GB keeps ~5 GB for macOS on an 8 GB machine.
COLIMA_CPUS="${COLIMA_CPUS:-4}"
COLIMA_MEMORY_GB="${COLIMA_MEMORY_GB:-3}"
COLIMA_DISK_GB="${COLIMA_DISK_GB:-60}"

log() {
  local line
  line="$(date '+%Y-%m-%d %H:%M:%S') [${QURA_LOG_TAG:-qura}] $*"
  echo "$line"
  mkdir -p "$QURA_LOG_DIR" && echo "$line" >> "$QURA_LOG_DIR/${QURA_LOG_TAG:-qura}.log"
}

compose() {
  docker compose -f "$QURA_COMPOSE_FILE" --env-file "$QURA_COMPOSE_ENV" "$@"
}

# TAG variable name for a service: crm-server -> TAG_CRM_SERVER
tag_var() {
  echo "TAG_$(echo "$1" | tr '[:lower:]-' '[:upper:]_')"
}

get_var() {
  [ -f "$QURA_COMPOSE_ENV" ] || return 0
  grep -E "^$1=" "$QURA_COMPOSE_ENV" | tail -1 | cut -d= -f2-
}

set_var() {
  local key="$1" value="$2" tmp
  touch "$QURA_COMPOSE_ENV"
  tmp="$(mktemp)"
  grep -vE "^$key=" "$QURA_COMPOSE_ENV" > "$tmp" || true
  echo "$key=$value" >> "$tmp"
  mv "$tmp" "$QURA_COMPOSE_ENV"
}

# Prints "name|repo|branch|db" for each registered service.
services() {
  grep -vE '^\s*(#|$)' "$QURA_INFRA/services.conf" | tr -d ' '
}

is_macos() { [ "$(uname -s)" = "Darwin" ]; }

ensure_docker() {
  docker info >/dev/null 2>&1 && return 0
  if is_macos; then
    log "docker not reachable; starting colima"
    colima start --cpu "$COLIMA_CPUS" --memory "$COLIMA_MEMORY_GB" --disk "$COLIMA_DISK_GB" \
      --vm-type vz --mount-type virtiofs >> "$QURA_LOG_DIR/colima.log" 2>&1
  fi
  docker info >/dev/null 2>&1
}

# Services that have a built image and should be running, plus infra services.
runnable_services() {
  echo postgres
  local name
  while IFS='|' read -r -u 3 name _; do
    [ -n "$(get_var "$(tag_var "$name")")" ] && echo "$name"
  done 3< <(services)
  [ "$(get_var COMPOSE_PROFILES)" = "tunnel" ] && echo cloudflared
  return 0
}

# Brings every runnable service up without building or touching the others.
apply_stack() {
  # shellcheck disable=SC2046
  compose up -d --no-build --no-deps --remove-orphans $(runnable_services)
}
