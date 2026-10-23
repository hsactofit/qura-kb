# Runbook — Restore from backup

Backups live on the server in `~/qura-server/backups/`:

| Folder | What | When | Kept |
|---|---|---|---|
| `daily/<db>-YYYYMMDD-HHMMSS.dump` | `pg_dump -Fc` of each service DB | 02:30 nightly | 14 days |
| `daily/globals-*.sql` | roles (passwords hashed) | nightly | 14 days |
| `daily/qura_client_storage-*.tgz` | uploaded documents volume | nightly | 14 days |
| `predeploy/<db>-*.dump` | DB right before a deploy | each deploy | last 20 per DB |

## Restore a database

```bash
ssh minim1
cd ~/qura-server/repos/qura-kb/infra
ls -lt ~/qura-server/backups/predeploy ~/qura-server/backups/daily | head
scripts/restore.sh qura_crm ~/qura-server/backups/daily/qura_crm-20261024-023000.dump
```

`restore.sh` asks you to type the DB name, takes a safety dump of the current
state, stops the services that use the DB, drops + recreates it, restores, and
starts them again.

## Roll back a bad deploy (code only)

The deployer already rolls back automatically when health fails. To pin a
specific older build by hand:

```bash
source scripts/lib.sh
docker images qura/crm-server          # tags = commit SHAs (current + previous kept)
set_var TAG_CRM_SERVER <old-tag> && compose up -d --no-deps crm-server
```

The next push to `main` deploys again as normal.

## Restore the uploads volume

```bash
source scripts/lib.sh && compose stop client-server
docker run --rm -v qura_client_storage:/data -v ~/qura-server/backups/daily:/b:ro postgres:16-alpine \
  sh -c 'rm -rf /data/* && tar xzf /b/qura_client_storage-<stamp>.tgz -C /data'
compose up -d --no-deps client-server
```

## Lost the whole machine

1. Set up a new server: `new-server-setup.md`.
2. Copy the latest `daily/` folder over (from the off-site copy, once configured).
3. `restore.sh` each DB, restore the volume, then `tunnel-setup.sh`.
