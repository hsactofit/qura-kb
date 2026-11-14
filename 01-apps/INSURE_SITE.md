# qura-insure-site — Repository Status

Public marketing website for Qura Insure.

Last verified: 2026-10-23

- Remote: `github.com/hsactofit/qura-insure-site`, branch `main` (latest `7148dcb`, 2026-10-17)
- Stack: Next.js 16, React 19, Tailwind 4, Framer Motion (static landing page, content in `src/data/content.ts`)
- Hosting: **unknown** (no deploy config in the repo). Likely Vercel. Confirm.
- Contributors: Himjoshi21 (Aug 2026 build), animeshDevarkar (redesign, merged by siddique), Himanshu.

## Sections

Hero, Services, Benefits, Process, CoveragePlans, Comparison, Trust, AboutUs (employee directory),
BrandIdentity, FAQ, CTA, Navbar, Footer.

## Links out

The Navbar "Login" links to `https://app.qurainsure.com`. That is presumably the client portal.
Confirm the domain and that it points at the Vercel client-panel.

## Enquiry form → CRM

The `#contact` section holds `EnquiryForm`. It posts to the site's `/api/enquiry` route, which validates,
drops honeypot hits, throttles per IP and forwards server-to-server to
`https://quracrmapi.leadrizz.com/api/v1/public/enquiries` with `X-Site-Key`. The key lives in
`src/lib/crm/config.server.ts` (env `QURA_CRM_SITE_KEY` overrides) and must equal `WEBSITE_LEAD_KEY` on the CRM.
Leads show in the CRM with source **Website form** (`WEBSITE_INQUIRY`). See SITE-1 / CRM-22.

## Gaps

- README is the create-next-app default.
- Package name is still `webapp`.
