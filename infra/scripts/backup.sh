#!/bin/bash
# Postgres + upload-volume backups.
#
#   backup.sh daily              every DB + globals + upload volumes (02:30 nightly)
#   backup.sh predeploy <db>     one DB, taken by deploy.sh before a schema-touching deploy
#
# Output: $QURA_ROOT/backups/{daily,predeploy}/  (custom-format pg_dump, restorable
# with scripts/restore.sh). Retention: daily 14 days, predeploy last 20 per DB.
# Optional off-machine copy: set BACKUP_RCLONE_REMOTE in $QURA_ROOT/backup.env.
set -uo pipefail
QURA_LOG_TAG=backup
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
[ -f "$QURA_ROOT/backup.env" ] && source "$QURA_ROOT/backup.env"

kind="${1:-daily}"; shift || true
dir="$QURA_ROOT/backups/$kind"
mkdir -p "$dir"
stamp="$(date '+%Y%m%d-%H%M%S')"
ensure_docker || { log "ERROR docker unavailable"; exit 1; }

dump_db() {
  local db="$1" out="$dir/$1-$stamp.dump"
  if compose exec -T postgres pg_dump -U postgres -Fc "$db" > "$out" \
     && compose exec -T postgres pg_restore -l < "$out" >/dev/null; then
    log "$kind: $db -> $(basename "$out") ($(du -h "$out" | cut -f1))"
  else
    rm -f "$out"; log "ERROR $kind dump of $db failed"; return 1
  fi
}

rc=0
if [ "$kind" = "predeploy" ]; then
  dump_db "$1" || rc=1
  ls -1t "$dir/$1-"*.dump 2>/dev/null | tail -n +21 | xargs rm -f
  exit $rc
fi

while IFS='|' read -r -u 3 _ _ _ db; do
  [ "$db" != "-" ] && { dump_db "$db" || rc=1; }
done 3< <(services)
compose exec -T postgres pg_dumpall -U postgres --globals-only > "$dir/globals-$stamp.sql" || rc=1

# Named volumes holding user uploads.
for vol in $(docker volume ls -q --filter label=com.docker.compose.project=qura | grep -v pgdata); do
  docker run --rm -v "$vol:/data:ro" postgres:16-alpine tar czf - -C /data . > "$dir/$vol-$stamp.tgz" \
    && log "$kind: volume $vol ($(du -h "$dir/$vol-$stamp.tgz" | cut -f1))" || rc=1
done

find "$dir" -type f -mtime +14 -delete

if [ -n "${BACKUP_RCLONE_REMOTE:-}" ] && command -v rclone >/dev/null; then
  rclone copy "$dir" "$BACKUP_RCLONE_REMOTE/$(hostname -s)/daily" --max-age 25h \
    && log "offsite copy -> $BACKUP_RCLONE_REMOTE" || { log "ERROR offsite copy failed"; rc=1; }
fi
exit $rc
