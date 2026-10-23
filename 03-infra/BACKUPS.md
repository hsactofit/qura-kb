# Backups

| Layer | Protects against | How |
|---|---|---|
| Docker named volume `qura_pgdata` | container crash or rebuild, reboot | data lives outside containers |
| Pre-deploy dump (`backups/predeploy/`) | bad migration in a new release | `backup.sh predeploy <db>` before every deploy, last 20 kept |
| Nightly dump (`backups/daily/`) | data mistakes, corrupted volume, VM loss | 02:30 `pg_dump -Fc` of every DB + roles + upload volumes, 14 days kept, each dump verified with `pg_restore -l` |
| **Off-machine copy** | disk failure, theft, fire | **NOT YET CONFIGURED** (see below) |

`backups/` is on the Mac's own disk, outside the Colima VM, so a broken or deleted VM doesn't
take the backups with it. A dead SSD still would.

## Off-site copy (recommended next step)

`backup.sh` already supports it. Install `rclone`, configure a remote (Cloudflare R2 fits: no
egress fees), then:

```bash
echo 'BACKUP_RCLONE_REMOTE=r2:qura-backups' > ~/qura-server/backup.env
```

The nightly run then copies the new files off-site.

## Restore

See `runbooks/restore-backup.md`. **Test a restore monthly** into a scratch DB:

```bash
compose exec -T postgres createdb -U postgres restore_test
compose exec -T postgres pg_restore -U postgres -d restore_test --no-owner < backups/daily/qura_crm-<stamp>.dump
compose exec -T postgres dropdb -U postgres restore_test
```
