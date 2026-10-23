# Service — postgres

| | |
|---|---|
| Image | `postgres:16-alpine` |
| Data | Docker named volume `qura_pgdata` inside the Colima VM disk. It survives container rebuilds, `compose down`, reboots and Colima restarts. It is **only** lost with `colima delete` or `docker volume rm` |
| Access | Containers: `postgres:5432`. Mac: `127.0.0.1:5432` (loopback only). Laptop: `ssh -L 5432:127.0.0.1:5432 minim1` |
| Superuser | `postgres`, password in `~/qura-server/env/postgres.env` |
| Databases | **`qura_main`**: schema `client` (owner `qura_client`) and `crm` (owner `qura_crm`), cross-schema read-only grants, `PUBLIC` revoked. Applied by `postgres/shared-db.sql` (init + `scripts/db-setup.sh` on every boot when the file changes). Legacy `qura_client` / `qura_crm` DBs hold only pre-launch test data (INFRA-16) |
| Tuning (8 GB host, 768 MB container) | `shared_buffers=256MB`, `effective_cache_size=768MB`, `work_mem=8MB`, `maintenance_work_mem=64MB`, `max_connections=60`, `wal_compression=on`, slow-query log ≥1 s |
| Backups | see `../BACKUPS.md` |

New databases are added with an init line plus a one-off `CREATE` on an existing server. See
`runbooks/add-new-service.md` §4.

**Danger**: `colima delete` wipes the VM disk and with it every volume. Take a backup first and copy
it off the VM: `backups/` lives on the Mac, outside the VM, so it is safe.
