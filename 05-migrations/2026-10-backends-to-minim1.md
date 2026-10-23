# Migration — Backends to hs-minim1 (2026-10)

Status: **In progress** · Decision: [ADR-001](../06-decisions/ADR-001-self-host-backends-on-mac-mini.md)

## From → to

| Piece | Before | After |
|---|---|---|
| CRM API | Render `qura-crm-server` (web service) | hs-minim1 `crm-server`, `https://quracrmapi.leadrizz.com` |
| CRM panel | Render `qura-panel` | Vercel (`API_URL=https://quracrmapi.leadrizz.com`) |
| CRM DB | Aiven `non-prod-server-actofit` / `defaultdb` (shared, non-prod) | hs-minim1 `qura_main`, schema `crm` |
| Client API | not deployed | hs-minim1 `client-server`, `https://quraapi.leadrizz.com` |
| Client DB | not provisioned | hs-minim1 `qura_main`, schema `client` |
| Client panel | Vercel | Vercel + `/api/client/*` rewrite to the tunnel |

## Steps

- [x] Server built; both APIs healthy on empty DBs (2026-10-23)
- [x] Shared `qura_main` + portal↔CRM sync deployed; e2e 26/26 on hs-minim1; backup→restore round trip OK (2026-10-23)
- [ ] Deploy keys on GitHub → auto-deploy active
- [x] Cloudflare tunnel + hostnames (tunnel `qura-hs-minim1`; both APIs healthy publicly, 2026-10-23)
- [x] **CRM data**: Aiven `public` copied into `qura_main.crm` (test data in `crm` and `client` cleared first); all 18 table counts match (2026-10-23).
      Backups: `~/qura-server/backups/manual/` (`qura_main-before-aiven-*`, `aiven-defaultdb-*`). The one Aiven document's file is not in the `qura` R2 bucket.
- [ ] Real secrets in env files: R2 + OpenAI done 2026-10-23; Smartflo, CORS open
- [ ] Vercel: client-panel `vercel.json` rewrite + env; CRM panel project + `API_URL`
- [ ] Smartflo webhook URL → `https://quracrmapi.leadrizz.com/api/v1/integrations/smartflo/webhooks`
- [ ] Smoke test both portals end-to-end (this is tracking item X-1)
- [ ] Decommission the Render services; retire the Aiven DB once a final dump is archived

## Rollback

Until Render is decommissioned, rolling back means pointing the CRM panel's `API_URL` back at Render.
