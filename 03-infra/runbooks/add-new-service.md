# Runbook — Add a new backend service

Goal: a new repo gets auto-deployed on every push to `main`, with its own DB,
secrets, health check, backups and (optionally) a public hostname.

Everything below is a change in `qura-kb` (pushed to `main`) plus three one-time
steps on the server. Example service: `notify-server` from `hsactofit/qura-notify`.

## 1. Register it — `infra/services.conf`

```
notify-server|hsactofit/qura-notify|main|qura_notify     # or "-" if no database
```

## 2. Dockerfile — `infra/docker/notify-server.Dockerfile`

Built with the service repo as context. Requirements:
- Listen on `0.0.0.0:<port>`; run as a non-root user.
- Run schema migrations on start (they are covered by the pre-deploy backup).
- Expose a cheap health endpoint (ideally one that checks the DB).

Copy the closest existing Dockerfile (`client-server` = Python, `crm-server` = Node).

## 3. Compose service — `infra/compose/docker-compose.yml`

Copy the `crm-server` block and change: name, `image: qura/notify-server:${TAG_NOTIFY_SERVER:-latest}`,
`build.context: ${QURA_ROOT}/repos/notify-server`, dockerfile, `env_file`, port,
healthcheck, `mem_limit` (start at 256–512m; check `status.sh` after a day).
The tag variable is always `TAG_` + name upper-cased with `-` → `_`.

## 4. Database (if any) — `infra/postgres/init/01-create-databases.sh`

Add `create qura_notify qura_notify "${QURA_NOTIFY_DB_PASSWORD}"` and the password
line to `infra/env/postgres.env.example`. Init scripts only run on an **empty**
volume, so on an existing server also run once:

```bash
P=$(openssl rand -hex 24); echo "QURA_NOTIFY_DB_PASSWORD=$P" >> ~/qura-server/env/postgres.env
cd ~/qura-server/repos/qura-kb/infra && source scripts/lib.sh
compose exec -T postgres psql -U postgres -c "CREATE ROLE qura_notify LOGIN PASSWORD '$P'" -c "CREATE DATABASE qura_notify OWNER qura_notify"
```

## 5. Env template — `infra/env/notify-server.env.example`

Use `__SECRET__` for generated secrets and `__PG_QURA_NOTIFY_DB_PASSWORD__` for the
DB password. Never put real keys in git.

## 6. Public hostname (optional) — `infra/servers/<host>/tunnel.conf`

```
notify-api.<domain>        notify-server:<port>
```

## 7. Docs

- New file `03-infra/services/notify-server.md` (copy `crm-server.md`).
- Add a row to the inventory in `03-infra/README.md` and a line in `03-infra/CHANGELOG.md`.

## 8. On the server (one time)

```bash
ssh minim1
cd ~/qura-server/repos/qura-kb && git pull          # or wait ≤60 s for auto-update
infra/scripts/bootstrap.sh                          # renders env + prints the new deploy key
# add that key at https://github.com/hsactofit/qura-notify/settings/keys (read-only)
vi ~/qura-server/env/notify-server.env              # real API keys, if any
infra/scripts/deploy.sh notify-server --force       # first deploy (later: automatic)
infra/scripts/tunnel-setup.sh                       # only if a hostname was added
infra/scripts/status.sh
```

## Done when

`status.sh` shows the container `healthy` with `live=<sha>`, the public hostname
answers, and a test push to the repo's `main` is live within ~2–5 minutes.
