# 03 — Infrastructure

Where everything runs, how it gets there, and how to operate it. The code behind these
docs is in [`../infra/`](../infra/).

## Topology

```
 Browser ──► Vercel ── Qura-client-panel (SPA) ──rewrite /api/client/*──┐
         ──► Vercel ── Qura-crrm-panel (Next.js) ──proxy /api/v1/*──────┤
         ──► qura-insure-site (marketing)                               │ HTTPS
                                                                        ▼
                                                      Cloudflare edge (DNS, TLS, WAF)
                                                                        │ outbound-only tunnel
 ┌────────────── hs-minim1 (Mac mini M1, 8 GB) ─────────────────────────┼───────────┐
 │ Colima VM (4 CPU / 3 GB)                                             ▼           │
 │   cloudflared ──► client-server :8787 (FastAPI) ──┐                              │
 │               └─► crm-server    :4000 (Express) ──┼──► postgres:16 (volume)      │
 │                                                   │     ├ qura_client            │
 │   volume qura_client_storage (uploads)            │     └ qura_crm               │
 │ launchd: boot · deploy every 60s · backup 02:30   │                              │
 └──────────────────────────────────────────────────────────────────────────────────┘
 External: Cloudflare R2 (CRM files) · OpenAI (extraction) · Smartflo (telephony) · GitHub (source)
```

## Inventory

| Component | Where | Deployed by | Doc |
|---|---|---|---|
| client-server (Client Portal API) | hs-minim1 | auto, on push to `main` | [services/client-server.md](services/client-server.md) |
| crm-server (CRM API) | hs-minim1 | auto, on push to `main` | [services/crm-server.md](services/crm-server.md) |
| Postgres 16 | hs-minim1 | compose | [services/postgres.md](services/postgres.md) |
| Cloudflare Tunnel | hs-minim1 → Cloudflare | compose | [services/cloudflare-tunnel.md](services/cloudflare-tunnel.md) |
| Qura-client-panel | Vercel | Vercel Git integration | [../01-apps/CLIENT_PANEL.md](../01-apps/CLIENT_PANEL.md) |
| Qura-crrm-panel | Vercel (moving from Render) | Vercel Git integration | [../01-apps/CRM_PANEL.md](../01-apps/CRM_PANEL.md) |
| qura-insure-site | TBD | TBD | [../01-apps/INSURE_SITE.md](../01-apps/INSURE_SITE.md) |
| Legacy: CRM API + panel on Render, CRM DB on Aiven (non-prod) | Render / Aiven | — | [../05-migrations/](../05-migrations/) |

## Servers

| Server | Role | Doc |
|---|---|---|
| hs-minim1 | production backends | [servers/hs-minim1.md](servers/hs-minim1.md) |

## How-to

- [DEPLOY_PIPELINE.md](DEPLOY_PIPELINE.md): push → live, rollback
- [BACKUPS.md](BACKUPS.md): what is backed up, where, and for how long
- [runbooks/new-server-setup.md](runbooks/new-server-setup.md)
- [runbooks/add-new-service.md](runbooks/add-new-service.md)
- [runbooks/operations.md](runbooks/operations.md): day-to-day work and troubleshooting
- [runbooks/restore-backup.md](runbooks/restore-backup.md)
- [AGENT_PROMPTS.md](AGENT_PROMPTS.md): prompts for running this work with Claude Code
- [CHANGELOG.md](CHANGELOG.md): every infra change, newest first

## Rules

1. No secrets in git. They live only in `~/qura-server/env/*.env` on each server.
2. Every infra change goes through `qura-kb/infra/` plus a CHANGELOG line.
3. Take a backup before touching data. The deployer does this automatically for deploys.
4. One service = one `services.conf` line + one Dockerfile + one compose block + one doc.
