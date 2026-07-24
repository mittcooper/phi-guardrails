# Ledger — chunk state (the orchestrator's only mutable state)

*Created by Prompt 4's first run (E01). One row per chunk: status ∈
`todo / in-progress / review / accepted`. Everything else in `plan/` is
append-or-frozen.*

| ID | Epic | Status | Depends-on | Assignee | Verify command |
|---|---|---|---|---|---|
| C01 | E01 | accepted | — | implementer-1 | `bash tools/install.sh && bash tools/probe-m0.sh` (exit 0; install run twice) |
| C02 | E01 | accepted | C01 | implementer-2 | `bash tools/build-image.sh && bash tools/verify.sh` (exit 0, 5 tests run) |
| C03 | E01 | accepted | C02 (Q-29 ruled — D-64) | implementer-3 | `gh run list --workflow=ci.yml --limit 1` → `completed success`; `tools/verify.sh` and `tools/probe-m0.sh` green on same commit |
| C04 | E01 | accepted | C03 | implementer-4 | on one commit: `bash tools/build-image.sh && bash tools/verify.sh` (exit 0, 5 tests) · `bash tools/probe-m0.sh` exit 0 · `gh run list --workflow=ci.yml --limit 1` → `completed success` · D-63 answers all four probe bullets |

**Epic acceptance:** E01 `accepted` when all four rows are `accepted` and the exit
checkpoint in `plan/04-epics/E01-build-test-harness/chunks.md` is filled in — at
which point E01's interface digest (the naming tree) freezes and E02's entry check
can pass.

**E01: ACCEPTED 2026-07-23.** All four chunks accepted; exit checkpoint filled in
(`chunks.md`, three legs green on head `a92faf6`); the interface digest — the 21-directory
`src/` inventory and the baseline's ten group names with exact memberships — is hereby
frozen (witnessed by `PGRBaselineSmokeTest`). Full accumulated suite re-run at the M0
milestone boundary by the orchestrator: `tools/verify.sh` 5/5 · `tools/probe-m0.sh` ALL
PASS · hosted-load probe exit 0 (5/5) · CI run 30067111092 `completed success`. Milestone
mining swept C01–C04 reports/reviews: one repeat proposed to the backlog (B-12,
working-tree/commit hygiene); B-10/B-11 already filed. E02 work orders do not exist yet —
next Prompt 4 run (human-gated) decomposes E02.
