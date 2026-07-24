# Ledger — chunk state (the orchestrator's only mutable state)

*Created by Prompt 4's first run (E01); format per the amended method (f9bb7f9):
status table + per-chunk verify list. One row per chunk: status ∈
`todo / in-progress / review / accepted`. Everything else in `plan/` is
append-or-frozen.*

| ID | Epic | Status | Depends-on | Assignee |
|---|---|---|---|---|
| C01 | E01 | accepted | — | implementer-1 |
| C02 | E01 | accepted | C01 | implementer-2 |
| C03 | E01 | accepted | C02 (Q-29 ruled — D-64) | implementer-3 |
| C04 | E01 | accepted | C03 | implementer-4 |
| C05 | E02 | todo | — | — |
| C06 | E02 | todo | — | — |
| C07 | E02 | todo | — | — |
| C08 | E02 | todo | — | — |
| C09 | E02 | todo | C08 | — |
| C10 | E02 | todo | — | — |
| C11 | E02 | todo | C09 | — |

## Verify commands

- **C01** — `bash tools/install.sh && bash tools/probe-m0.sh` (exit 0; install run twice)
- **C02** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0, 5 tests run)
- **C03** — `gh run list --workflow=ci.yml --limit 1` → `completed success`; `tools/verify.sh` and `tools/probe-m0.sh` green on same commit
- **C04** — the M0 exit checkpoint, three legs on one commit: see `plan/04-epics/E01-build-test-harness/chunks.md` §checkpoint
- **C05** — `bash tools/install.sh` twice (exit 0, checksum lines) · tamper arm exits ≠0 naming file + checksums · `bash tools/build-image.sh && bash tools/verify.sh` green
- **C06** — `bash tools/precheck.sh` four arms (clean→0+HEAD · ledger-only→0 · untracked→1 · modified→1) · `bash tools/build-image.sh && bash tools/verify.sh` green
- **C07** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 3 `PGRSdkErrorsTest` + 5 smoke tests listed)
- **C08** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 3 `PGRFindingTest` + 5 smoke tests listed)
- **C09** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 7 `PGRVerdictTest` + accepted siblings + 5 smoke tests listed)
- **C10** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 2 `PGRRegistrationSpecTest` + 5 smoke tests listed)
- **C11** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 3 `PGRCheckSkeletonTest` + 1 `PGRKitSkeletonTest` + accepted siblings + 5 smoke tests listed)

## Epic acceptance

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
working-tree/commit hygiene); B-10/B-11 already filed.

**E02 rows (C05–C11) added by the second Prompt-4 run (2026-07-23; Gate 4 approved,
commit `3d718b4` — owner notice).** E02 `accepted` when all seven rows are `accepted`
and the exit checkpoint in `plan/04-epics/E02-sdk-vocabulary/chunks.md` is filled in
(named SDK suite green · D-66/D-67 infra legs · CI leg, on one head commit) — at which
point E02's interface digest (the full SDK surface: vocabulary constructors + readers,
the check protocol, the two-message kit protocol — tabled in that file) freezes, and
the entry checks of E03 and E06 can pass. Commit expectations are stated per work
order (D-67). [P] eligibility (validator-confirmed disjoint manifests): C05 C06 C07
C08 C10; orchestrator runs them serialized — the work orders' COMMIT preconditions
(clean tree at spawn) and the shared `.build/work` verify image make shared-tree
concurrency unsound; disjointness stands as the reviewer's cross-check.
