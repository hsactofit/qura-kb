#!/bin/bash
# Restore one database from a dump made by backup.sh.
#
#   restore.sh <db> <path/to/file.dump> [--yes]
#
# Stops the services using the DB, takes a safety dump of the current state,
# drops + recreates the DB (same owner), restores, and starts services again.
set -euo pipefail
QURA_LOG_TAG=restore
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

db="${1:?usage: restore.sh <db> <file.dump> [--yes]}"
file="${2:?usage: restore.sh <db> <file.dump> [--yes]}"
[ -f "$file" ] || { echo "no such file: $file"; exit 1; }
if [ "${3:-}" != "--yes" ]; then
  read -r -p "Replace ALL data in '$db' with $(basename "$file")? Type the db name: " ans
  [ "$ans" = "$db" ] || { echo "aborted"; exit 1; }
fi

users=()
while IFS='|' read -r -u 3 name _ _ sdb; do [ "$sdb" = "$db" ] && users+=("$name"); done 3< <(services)

"$QURA_INFRA/scripts/backup.sh" predeploy "$db"
[ ${#users[@]} -gt 0 ] && compose stop "${users[@]}"
owner="$(compose exec -T postgres psql -U postgres -tAc "SELECT pg_get_userbyid(datdba) FROM pg_database WHERE datname='$db'")"
compose exec -T postgres psql -U postgres -v ON_ERROR_STOP=1 \
  -c "DROP DATABASE IF EXISTS $db WITH (FORCE);" -c "CREATE DATABASE $db OWNER ${owner:-postgres};"
if [ "$db" = "qura_main" ]; then
  # Shared database: keep each schema's owner (qura_client / qura_crm) and re-apply grants.
  compose exec -T postgres pg_restore -U postgres -d "$db" < "$file"
  "$QURA_INFRA/scripts/db-setup.sh"
else
  compose exec -T postgres pg_restore -U postgres -d "$db" --no-owner --role="${owner:-postgres}" < "$file"
fi
[ ${#users[@]} -gt 0 ] && compose up -d --no-build --no-deps "${users[@]}"
log "restored $db from $(basename "$file")"
