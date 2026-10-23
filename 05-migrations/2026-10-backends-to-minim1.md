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
- [ ] Cloudflare tunnel + hostnames
- [ ] **CRM data**: decide whether to copy Aiven `defaultdb` (demo or real data?) or start clean.
      Copying: `pg_dump --no-owner --no-acl -Fc -n public "<aiven url>" > aiven.dump`, restore into a scratch DB,
      `ALTER SCHEMA public RENAME TO crm`, dump that and `pg_restore --clean -n crm` into `qura_main` as `qura_crm`,
      then `compose restart crm-server` (`db push` adds the new portal columns) and spot-check counts.
- [ ] Real secrets in env files (R2, OpenAI, Smartflo, CORS)
- [ ] Vercel: client-panel `vercel.json` rewrite + env; CRM panel project + `API_URL`
- [ ] Smartflo webhook URL → `https://quracrmapi.leadrizz.com/api/v1/integrations/smartflo/webhooks`
- [ ] Smoke test both portals end-to-end (this is tracking item X-1)
- [ ] Decommission the Render services; retire the Aiven DB once a final dump is archived

## Rollback

Until Render is decommissioned, rolling back means pointing the CRM panel's `API_URL` back at Render.
