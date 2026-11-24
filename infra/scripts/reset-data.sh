#!/bin/bash
# ONE-OFF, DESTRUCTIVE: wipe all Qura business data and leave a single CRM Super Admin.
#
#   reset-data.sh <admin-email> "<Admin Name>"
#
# Run on the server that hosts qura_main (hs-minim1). It:
#   1. backs up qura_main + both upload volumes (restore: scripts/restore.sh qura_main <dump>)
#   2. stops client-server and crm-server so no sync runs mid-wipe
#   3. in ONE transaction: empties every CRM business table and every client-portal user table,
#      DELETES every CRM login (admins included), clears the assignment matrix, creates the new admin
#   4. empties the upload volumes, starts the servers, prints row counts
#
# Kept: crm.dispositions, crm.system_settings (minus assignment_matrix),
#       client.master_data, client.announcements, alembic_version.
# TRUNCATE is used WITHOUT CASCADE on purpose: if a table not listed here references one that is,
# Postgres refuses and the whole transaction rolls back, nothing is deleted.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
QURA_LOG_TAG=reset-data

email="${1:?usage: reset-data.sh <admin-email> \"<Admin Name>\"}"
name="${2:?usage: reset-data.sh <admin-email> \"<Admin Name>\"}"

echo "This DELETES all leads, customers, policies, claims, tasks, calls, portal users and uploaded files"
echo "in qura_main, and DELETES every CRM login. Only the new admin $email will exist."
read -r -p 'Type DELETE ALL QURA DATA to continue: ' confirm
[ "$confirm" = "DELETE ALL QURA DATA" ] || { echo "Aborted."; exit 1; }

read -r -s -p "New password for $email (min 12 chars): " pw; echo
read -r -s -p "Repeat password: " pw2; echo
[ "$pw" = "$pw2" ] || { echo "Passwords differ."; exit 1; }
[ "${#pw}" -ge 12 ] || { echo "Password too short."; exit 1; }

# bcrypt hash made by the CRM's own bcryptjs; password goes in on stdin, never on a command line.
hash="$(printf '%s' "$pw" | compose exec -T crm-server node -e \
  "let s='';process.stdin.on('data',d=>s+=d).on('end',()=>require('bcryptjs').hash(s,10).then(h=>console.log(h)))")"
unset pw pw2
[[ "$hash" == \$2* ]] || { echo "Could not hash the password."; exit 1; }

stamp="$(date +%Y%m%d-%H%M%S)"
bdir="$QURA_ROOT/backups/predeploy"
log "backup qura_main"
"$QURA_INFRA/scripts/backup.sh" predeploy qura_main
log "backup upload volumes"
compose exec -T client-server tar czf - -C /data/storage . > "$bdir/client_storage-pre-reset-$stamp.tgz"
compose exec -T crm-server    tar czf - -C /data/storage . > "$bdir/crm_storage-pre-reset-$stamp.tgz"
ls -lh "$bdir" | tail -5

log "stop app servers"
compose stop client-server crm-server

log "wipe database"
compose exec -T postgres psql -U postgres -d qura_main -v ON_ERROR_STOP=1 \
  -v email="$email" -v name="$name" -v hash="$hash" <<'SQL'
BEGIN;
TRUNCATE crm.audit_events, crm.activities, crm.calls, crm.tasks, crm.quotes, crm.opportunities,
         crm.document_extractions, crm.documents, crm.claims, crm.leads, crm.servicing_tickets,
         crm.grievances, crm.policies, crm.contacts, crm.accounts;
TRUNCATE client.ticket_messages, client.support_tickets, client.claim_documents, client.claims,
         client.policies, client.assets, client.family_members, client.kyc_documents,
         client.transactions, client.notifications, client.audit_logs, client.stored_files,
         client.password_reset_tokens, client.invites, client.user_settings, client.user_profiles,
         client.users;
DELETE FROM crm.users;
DELETE FROM crm.system_settings WHERE key = 'assignment_matrix';
UPDATE crm.system_settings SET updated_by = NULL;
INSERT INTO crm.users (id, email, name, password_hash, role, is_active, updated_at)
VALUES (gen_random_uuid(), lower(:'email'), :'name', :'hash', 'SUPER_ADMIN', true, now());
COMMIT;
SQL

log "empty upload volumes"
compose run --rm --no-deps -T --entrypoint sh client-server -c 'find /data/storage -mindepth 1 -delete'
compose run --rm --no-deps -T --entrypoint sh crm-server    -c 'find /data/storage -mindepth 1 -delete'

log "start app servers"
compose start client-server crm-server

compose exec -T postgres psql -U postgres -d qura_main -c "
SELECT 'crm.leads' t, count(*) FROM crm.leads UNION ALL
SELECT 'crm.accounts', count(*) FROM crm.accounts UNION ALL
SELECT 'crm.policies', count(*) FROM crm.policies UNION ALL
SELECT 'client.users', count(*) FROM client.users UNION ALL
SELECT 'client.policies', count(*) FROM client.policies;"
compose exec -T postgres psql -U postgres -d qura_main -c \
  "SELECT email, name, role, is_active FROM crm.users ORDER BY email;"
log "done; backups in $bdir (*$stamp*)"
