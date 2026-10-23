# Portal ↔ CRM sync (shared `qura_main`)

Why one database: [ADR-002](../06-decisions/ADR-002-one-database-shared-by-portal-and-crm.md).
Verified end to end with `infra/tests/e2e_policy_flow.py` (26 checks) locally and on hs-minim1 (2026-10-23).

## The flows

| What happens | Where it starts | What the other side gets | Who moves it |
|---|---|---|---|
| Client signs up (open sign-up, optional mobile) | `client.users` | Linked to an existing CRM customer with the same email/mobile, else new account + contact + lead (`source CLIENT_PORTAL`, auto-assigned to the agent with the fewest open leads) + "welcome call" task | CRM sync |
| Client uploads a policy (AI reads it) | `client.policies` + file in `client_storage` | Policy (`source CLIENT_PORTAL`, unverified) + document (`client:` key, same file) + extraction (needs review) + HIGH "verify" task for the owner; open leads move to POLICY_RECEIVED | CRM sync |
| Advisor verifies it (Portal Inbox → verify page) | `crm.policies.verified_at` | Portal policy becomes **advisor_verified** with the advisor's values and summary; notification "Policy verified" | Portal sync |
| Advisor uploads/adds a policy for a portal client | `crm.policies` on a linked account | Portal policy `policy_source=advisor`; downloadable (bytes fetched from the CRM internal endpoint); notification | Portal sync |
| Client asks: renewal / call back / question / claim help | `client.support_tickets` (+ `policy_id`) | Task in the owner's My Day + Portal Inbox (`related_type CLIENT_TICKET`); renewal also opens a RENEWAL opportunity | CRM sync |
| Advisor replies / resolves (Portal Inbox, or completing the task) | `crm.activities` type `CLIENT_REPLY`, task status | Ticket message from "<advisor> (Qura advisor)"; ticket in_progress/resolved; notifications | Portal sync |
| Client files a claim with documents | `client.claims` + `claim_documents` | Claim (INTIMATED) + documents + URGENT task for the handler | CRM sync |
| Claims desk updates status | `crm.claims.status` / remarks | Portal claim status + timeline entry + notification | Portal sync |
| Client's advisor | `crm.accounts.owner_user_id` | Portal "Your Qura advisor" card and sidebar | read live |

Sync interval: 10 s each way (`QURA_CRM_SYNC_INTERVAL_SECONDS`, `CLIENT_SYNC_INTERVAL_SECONDS`).
Managers can force a CRM pass from the Portal Inbox ("Sync now").

## Link columns (change these only in a coordinated release)

| Column | Meaning |
|---|---|
| `crm.accounts.client_user_id` | portal user ↔ CRM customer |
| `crm.policies.client_policy_id`, `crm.policies.source` | CRM policy that mirrors a portal upload |
| `crm.claims.client_claim_id` | CRM claim filed on the portal |
| `client.policies.crm_policy_id`, `crm_synced_at` | portal policy ↔ CRM policy + last CRM `updated_at` applied |
| `client.claims.crm_claim_id`, `crm_synced_at` | same for claims |
| `client.ticket_messages.external_ref` | CRM activity id of a synced advisor reply |
| `crm.tasks.related_type = 'CLIENT_TICKET'`, `related_id` | task created from a portal request |
| `client.policies.details` = `crm.policies.details->'coverage'` | the full AI reading (shape in `coverage.py` / `coverage.ts`) |

Code: portal `app/modules/crm_sync/`, CRM `src/services/clientSync.ts`, `src/routes/portal.ts`.

## Files

- Portal uploads: volume `qura_client_storage`, mounted **read-only** in the CRM at `/data/client-storage`;
  CRM document `object_key` = `client:<storage_key>`.
- CRM uploads: R2 when the four `R2_*` vars are set, else volume `qura_crm_storage` (`local:` keys).
- Portal → CRM bytes: `GET /internal/documents/:id/content` with `X-Internal-Token` (shared `QURA_INTERNAL_TOKEN`),
  Docker network only; requests carrying Cloudflare headers are refused.

## AI policy reading

Both servers read PDFs with OpenAI (portal: `QURA_OPENAI_API_KEY`, CRM: `OPENAI_API_KEY`) into the same
shape: plan, insured/members, vehicle, key features (room rent, co-pay, deductible, NCB, add-ons),
benefits, exclusions, waiting periods, claim support (helpline, email, steps) and a plain-language summary.
Scanned PDFs are sent as files. Without a key the portal asks the client for the main fields and the CRM
falls back to text rules; the advisor completes the rest when verifying.
