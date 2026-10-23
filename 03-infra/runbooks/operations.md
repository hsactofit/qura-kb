# Runbook — Day-to-day operations & troubleshooting

All commands run on the server (`ssh minim1`) from `~/qura-server/repos/qura-kb/infra`.
`source scripts/lib.sh` gives you the `compose` wrapper (right file + env).

## Look

| Need | Command |
|---|---|
| Everything at a glance | `scripts/status.sh` |
| Service logs | `source scripts/lib.sh; compose logs -f --tail 100 crm-server` |
| Deploy history | `tail -50 ~/qura-server/logs/deploy.log` |
| Boot / backup logs | `~/qura-server/logs/{boot,backup}.log` |
| SQL shell | `compose exec postgres psql -U postgres -d qura_main` (tables are `client.*` and `crm.*`) |
| End-to-end check | `python3 infra/tests/e2e_policy_flow.py --client … --crm … --crm-email qa-bot@qurainsure.com --crm-password <env/qa.env> --pdf x.pdf` (26 checks; creates throwaway `e2e-*@example.com` clients) |
| From the laptop | `ssh -L 5432:127.0.0.1:5432 minim1` then any SQL client on `localhost:5432` |

## Act

| Need | Command |
|---|---|
| Redeploy current commit | `scripts/deploy.sh crm-server --force` |
| Retry a commit that failed | same; failed commits aren't retried automatically until a new commit lands |
| Restart a service | `compose restart crm-server` |
| Change secrets | edit `~/qura-server/env/crm-server.env`, then `compose up -d --no-deps --force-recreate crm-server` |
| Pause auto-deploy | `sudo launchctl bootout system /Library/LaunchDaemons/com.qura.deploy.plist` |
| Resume auto-deploy | `sudo launchctl bootstrap system /Library/LaunchDaemons/com.qura.deploy.plist` |
| Manual backup | `scripts/backup.sh daily` |
| Restore | `runbooks/restore-backup.md` |
| Add hostname | edit `servers/<host>/tunnel.conf`, then `scripts/tunnel-setup.sh` |

## Common problems

**`docker: Cannot connect to the Docker daemon`**: the Colima VM is down. Run `colima start`
(or `scripts/boot.sh`), then `colima status`. If it won't start, `colima stop -f && colima start`.

**Deploy log shows `FAILED build`**: the commit doesn't build. The previous version keeps
running. Read the build output in `deploy.log`, fix it, and push again.

**Deploy log shows `FAILED health … ROLLED BACK`**: the commit started but never got healthy
(bad env, migration error, a destructive Prisma change). Read `compose logs <svc>` for the failed
container in `deploy.log`.

**`clone failed (deploy key added on GitHub?)`**: add the key from `~/.ssh/qura_deploy_<svc>.pub`
to the repo. Test it with `ssh -T git@github-<svc>`.

**Tunnel 502 / 1033**: check `compose logs cloudflared`. A 502 means the tunnel is up but the
service is down. 1033 means cloudflared isn't running: `compose up -d --no-deps cloudflared`.

**Memory pressure**: run `docker stats` and lower or raise `mem_limit` in compose. The VM size is set
by `COLIMA_MEMORY_GB` in `lib.sh` (change it, then `colima stop && colima start --memory N`).
Close Chrome on the mini; it is the biggest memory user outside the VM.

**Disk**: `docker system df`. The deployer keeps only the current and previous image per service
and prunes build cache older than 7 days.
