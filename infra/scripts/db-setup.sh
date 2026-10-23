#!/bin/bash
# Apply postgres/shared-db.sql to the running postgres container (idempotent).
# Called by bootstrap.sh, boot.sh and deploy.sh; safe to run by hand any time.
set -uo pipefail
QURA_LOG_TAG=${QURA_LOG_TAG:-db-setup}
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

for i in $(seq 1 30); do
  compose exec -T postgres pg_isready -U postgres -q 2>/dev/null && break
  sleep 2
done
if compose exec -T postgres psql -q -U postgres -d postgres -f /qura/shared-db.sql >/dev/null; then
  log "db-setup: qura_main schemas and grants applied"
else
  log "ERROR db-setup: shared-db.sql failed"; exit 1
fi
