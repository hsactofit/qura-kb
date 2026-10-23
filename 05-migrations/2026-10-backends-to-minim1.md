# Migration — Backends to hs-minim1 (2026-10)

Status: **In progress** · Decision: [ADR-001](../06-decisions/ADR-001-self-host-backends-on-mac-mini.md)

## From → to

| Piece | Before | After |
|---|---|---|
| CRM API | Render `qura-crm-server` (web service) | hs-minim1 `crm-server`, `https://crm-api.<domain>` |
| CRM panel | Render `qura-panel` | Vercel (`API_URL=https://crm-api.<domain>`) |
| CRM DB | Aiven `non-prod-server-actofit` / `defaultdb` (shared, non-prod) | hs-minim1 Postgres `qura_crm` |
| Client API | not deployed | hs-minim1 `client-server`, `https://client-api.<domain>` |
| Client DB | not provisioned | hs-minim1 Postgres `qura_client` |
| Client panel | Vercel | Vercel + `/api/client/*` rewrite to the tunnel |

## Steps

- [x] Server built; both APIs healthy on empty DBs (2026-10-23)
- [ ] Deploy keys on GitHub → auto-deploy active
- [ ] Cloudflare tunnel + hostnames
- [ ] **CRM data**: decide whether to copy Aiven `defaultdb` (demo or real data?) or start clean.
      If copying: `pg_dump --no-owner --no-acl -Fc "<aiven url>" > aiven.dump` → `restore.sh qura_crm aiven.dump`
      → `compose restart crm-server` (`db push` reconciles) → spot-check counts.
- [ ] Real secrets in env files (R2, OpenAI, Smartflo, CORS)
- [ ] Vercel: client-panel `vercel.json` rewrite + env; CRM panel project + `API_URL`
- [ ] Smartflo webhook URL → `https://crm-api.<domain>/api/v1/integrations/smartflo/webhooks`
- [ ] Smoke test both portals end-to-end (this is tracking item X-1)
- [ ] Decommission the Render services; retire the Aiven DB once a final dump is archived

## Rollback

Until Render is decommissioned, rolling back means pointing the CRM panel's `API_URL` back at Render.
