# Status Rules and Definitions

This document defines the vocabulary used across all Qura project-tracking
documents in `qura-kb/`. Apply these definitions consistently in
`ISSUE_REGISTER.md`, `ROADMAP.md`, `COMPLETION_LOG.md` and `PROJECT_GIST.md`.

Last verified: 2026-10-20

## Issue status values

| Status | Meaning |
|---|---|
| `Backlog` | Identified work with no committed plan or target date. Not scheduled. |
| `Planned` | Agreed to be done; may have a target date but work has not started. |
| `Open` | Active, acknowledged work item that is ready to be worked on. |
| `In Progress` | Work has started and is partially done. |
| `Blocked` | Cannot proceed until a dependency, decision or external input is resolved. |
| `Completed` | Work is finished and backed by evidence (see verification levels). |
| `Cancelled` | Deliberately dropped; will not be done. |

## Verification levels

A commit alone does NOT mean a feature is complete. Each completed or in-progress
item is tagged with the highest verification level it has actually reached:

| Level | Meaning | Evidence required |
|---|---|---|
| `L0 Code written` | Source exists in the repo. | Commit / file path. |
| `L1 Tests pass` | Automated tests exercise the code and pass. | Test run output; test file paths. |
| `L2 Manually verified` | A human exercised the behaviour at runtime (real DB, browser, live service). | Named person + what they did. |
| `L3 Accepted` | The senior reviewed and accepted the work. | Explicit sign-off. |

Important nuance for this ecosystem:
- The backend test suite runs against an **in-memory fake database layer**
  (`tests/fakes.py`), not live PostgreSQL. So backend `L1` does **not** imply the
  real Postgres schema, constraints, or migrations were executed.
- The frontend test suite runs in `jsdom` with stubbed `fetch` and covers the
  transport client, one helper, and the demo adapter — not the feature screens
  end-to-end against a live backend.
- No end-to-end run of frontend against live backend against live PostgreSQL has
  been evidenced. Treat such integration as **not verified** (max `L1`) unless a
  named person records an `L2` runtime check.

## Confirmed vs provisional entries

- **Confirmed**: backed by repository evidence (code, tests, migrations, README,
  git history) or an explicit statement from the senior.
- **Provisional** (prefixed `P-` in IDs and marked `provisional`): an inferred
  follow-up or recommendation produced during this analysis. Provisional items
  do **not** carry invented official IDs, owners, priorities or dates. Treat them
  as suggestions awaiting confirmation.

## Dates

- `Created Date` / `Completed Date` / target dates are recorded only when backed
  by evidence (git commit dates, documented sign-off, etc.).
- Use `TBD` where no agreed date exists. Never invent a date.
- `Target Date` (planned) is always kept separate from `Completed Date` (actual).

## Evidence sources used

Git history and commit dates, repository READMEs, source files, Alembic
migrations, the automated test suites and their pass/fail output, and explicit
statements from the senior. Runtime/manual verification is only claimed where a
named person is recorded as having performed it.

## Owners

Git commit authors observed: `Himanshu`, `parthdevinnovator`,
`Mohammed Ahmed Anjarwala`, plus Kiro-assisted work. "Owner" fields name the
person responsible for an item only where that is known; otherwise `TBD`.
