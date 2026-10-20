# qura-kb — Repository Status

Knowledge-base service and the central project-tracking repository (this repo).

Last verified: 2026-10-20

- Remote: `github.com/hsactofit/qura-kb`
- Branch: `main`
- Stack: TBD (service not yet implemented)
- Tracking boundary: **this repo holds the project-management documentation**

## Purpose and responsibilities

Two roles:
1. **Central project tracking** for the whole Qura ecosystem — this documentation
   set (gist, issue register, roadmap, completion log, blockers, architecture,
   per-repo status). This is the current active role.
2. **Future standalone KB service** for the Qura ecosystem. The agreed near-term
   scope is architecture and project tracking; implementing insurance knowledge
   features is explicitly deferred until a later, approved phase.

## Current state (evidence)

- Git history shows a single commit: `32335d9` "Add project title to README.md"
  (2026-10-20, Himanshu).
- Before this documentation work, the repo contained only `.gitignore` and a
  near-empty `README.md` (project title only).
- No service code, architecture spec, tests, or CI exist yet.
- This matches the stated context that qura-kb began almost empty and Kiro began
  scaffolding its architecture/tracking.

## Architecture

Not yet defined. No stack, service boundaries, data model, or integration with
the portal has been decided or committed. See `BLOCKERS_AND_RISKS.md` for the
open decisions required before KB service implementation can start.

## Implemented and verified

- None (service). The only committed artifact is the README title.
- Project-tracking documentation (this set) is now present in the repo.

## Backlog / planned

- Decide KB service scope, stack and whether/how it integrates with the portal.
- Author an architecture spec for the KB service.
- Scaffold the service (repo structure, CI, tests) once scope is agreed.
- Keep the project-tracking docs current as the source of truth.

## Dependencies

- Senior decisions on scope and stack (blocking service work).
- The ecosystem architecture in `ARCHITECTURE_OVERVIEW.md` and the status of the
  portal repos (so KB can reference accurate upstream state).

## Next actions

- Confirm the KB service scope and stack with the senior.
- Establish the architecture document and initial scaffolding plan.
- Maintain `PROJECT_GIST.md`, `ISSUE_REGISTER.md`, `ROADMAP.md`,
  `COMPLETION_LOG.md` and `BLOCKERS_AND_RISKS.md` as work proceeds.
