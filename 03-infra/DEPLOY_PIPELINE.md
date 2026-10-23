# Deploy pipeline (push to `main` → live)

Pull-based: the server polls GitHub, so there are no webhooks, CI secrets or open ports.
Script: `infra/scripts/deploy.sh`, run every 60 s by `com.qura.deploy` (launchd) or
`qura-deploy.timer` (systemd).

```
push to main
   │  (≤60 s)
   ▼
deploy.sh ── git fetch (read-only deploy key per repo)
   │  new commit?  no → skip      already failed? → skip until a newer commit
   ▼
docker compose build  →  image qura/<svc>:<sha12>        build fails → keep old, log FAILED
   ▼
pg_dump <db> → backups/predeploy/                        dump fails → abort
   ▼
TAG_<SVC>=<sha12> in compose.env → compose up -d <svc>   (migrations run on start)
   ▼
wait for Docker health "healthy" (≤240 s)
   ├── healthy   → state/<svc>.sha = commit, prune old images (keep current + previous)
   └── unhealthy → TAG back to previous, restart it, state/<svc>.failed = commit   (ROLLED BACK)
```

Each run also:
- **Self-updates infra**: pulls `qura-kb` main. If `infra/` changed, it re-applies the compose stack.
  Changes to launchd/systemd templates need `bootstrap.sh` to be re-run (logged as NOTICE).
- **Watchdog**: restarts containers Docker reports `unhealthy`, and recreates any service that
  should be running but isn't.

Typical timings on hs-minim1: poll ≤60 s, Python rebuild ~1 min (cached deps), Node rebuild
~2–3 min, health ≤40 s.

## Where to look

- `~/qura-server/logs/deploy.log`: one line per event (`deploying`, `OK`, `FAILED`, `ROLLED BACK`) plus build output.
- `infra/scripts/status.sh`: live and failed commit per service.

## Manual controls

`deploy.sh <svc> --force` rebuilds and redeploys the current commit, and also retries a failed one.
To pause or resume, see `runbooks/operations.md`.

## Known limits / next steps

- No notifications yet. Next step: a Slack or e-mail webhook on `FAILED` / `ROLLED BACK` lines.
- Tests aren't run before deploy. `qura-client-server` has GitHub Actions CI; enforce branch
  protection ("CI must pass before merge to main") so only green commits reach `main`.
- Frontends are deployed by Vercel's own Git integration, not by this pipeline.
