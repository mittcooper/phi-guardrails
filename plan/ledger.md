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
| C05 | E02 | accepted | — | implementer-5 (picked @ 33b1145) |
| C06 | E02 | accepted | — | implementer-6 |
| C07 | E02 | accepted | — | implementer-7 (picked @ e975383) |
| C08 | E02 | accepted | — | implementer-8 (picked @ fd33f41) |
| C09 | E02 | accepted | C08 | implementer-9 (picked @ c29bd1c) |
| C10 | E02 | accepted | — | implementer-10 (picked @ 5d9e8bf) |
| C11 | E02 | accepted | C09 | implementer-11 (picked @ 6838e75) |
| C12 | E06 | todo | — | — |
| C13 | E06 | todo | — | — |
| C14 | E06 | todo | — | — |
| C15 | E06 | todo | C13 | — |
| C16 | E06 | todo | C15 | — |
| C17 | E06 | todo | C16 | — |
| C18 | E06 | todo | C17 | — |
| C20 | E03 | todo | — | — |
| C21 | E03 | todo | C20 | — |
| C22 | E03 | todo | C21 | — |
| C23 | E03 | todo | C22 | — |
| C24 | E03 | todo | C23 (Q-31 ruled — D-70) | — |
| C25 | E03 | todo | C24 | — |
| C26 | E03 | todo | C25 | — |
| C27 | E03 | todo | C26 | — |

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
- **C12** — probe script headless exit 0, both observations printed; decision-log entry recorded (D-70 expected); `bash tools/build-image.sh && bash tools/verify.sh` stays green, run count unchanged from the pick-time accepted set (no product change)
- **C13** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 2 `PCKNoIsNilIfTrueRuleTest` + every previously accepted suite listed — membership + floor, never an exact ceiling)
- **C14** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 3 `PCKCodeCruftBuiltInTest` + every previously accepted suite listed)
- **C15** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 4 `PCKLintRuleCheckTest` + every previously accepted suite listed)
- **C16** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 5 `PCKKitTest` + every previously accepted suite listed)
- **C17** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 6 new `PCKKitTest` + every previously accepted suite listed)
- **C18** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; all 22 E06 kit tests + every previously accepted suite, ≥46 run — the E06 exit-checkpoint leg 1; see `plan/04-epics/E06-coding-kit-lint/chunks.md` §checkpoint)
- **C20** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 7 `PGRScratchFixturesTest` + accepted siblings + 5 smoke tests listed)
- **C21** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 7 `PGRConfigurationTest` + accepted siblings + 5 smoke tests listed)
- **C22** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 10 `PGRConfigurationTest` + accepted siblings + 5 smoke tests listed)
- **C23** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 15 `PGRConfigurationTest` + accepted siblings + 5 smoke tests listed)
- **C24** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 21 `PGRConfigurationTest` + accepted siblings + 5 smoke tests listed)
- **C25** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 27 `PGRConfigurationTest` + accepted siblings + 5 smoke tests listed)
- **C26** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 30 `PGRConfigurationTest` + accepted siblings + 5 smoke tests listed)
- **C27** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 35 `PGRConfigurationTest` + 7 `PGRScratchFixturesTest` + accepted siblings + 5 smoke tests — 66 run when no parallel-track (E06) suite has landed yet; accepted E06 suites add to the count; see `plan/04-epics/E03-configuration-scope-law/chunks.md` §checkpoint)

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

**E02: ACCEPTED 2026-07-24.** All seven chunks accepted; exit checkpoint filled in
(`plan/04-epics/E02-sdk-vocabulary/chunks.md`, three legs green on head `5f2fc60`:
24/24 named suite incl. P-CANFIX-DEFAULT · D-66/D-67 infra arms · CI run 30075643532).
E02's interface digest — the full SDK surface tabled in that file (PGRVerdict,
PGRFinding, PGRRegistrationSpec, the four errors, the check protocol, the two-message
kit protocol) — is hereby frozen; amendments need a decision-sheet entry. The entry
checks of E03 and E06 can pass. Not a milestone boundary (E02 is M1's first epic) —
formal mining deferred to the M1 close; one recurring correction filed now under
operating rule 9 (B-13, PharoDebug.log debris).

**E06 rows (C12–C18) added by the third Prompt-4 run (2026-07-25).** E06
`accepted` when all seven rows are `accepted` and the exit checkpoint in
`plan/04-epics/E06-coding-kit-lint/chunks.md` is filled in (22-test named kit
suite + 24 accepted tests green · B-03 probe leg recorded · CI leg, on one head
commit) — at which point E06's interface digest (the coding kit's block schema,
registration naming/order, `PCKKit`, `PCKLintRuleCheck rule:packages:`, the two
catalog registrations, the D-41 enforcement point — tabled in that file)
freezes, and the entry checks of E07 and E08 can pass. Commit expectations are
stated per work order (D-67). [P] eligibility (disjoint manifests): C12 C13 C14;
orchestrator runs them serialized — the COMMIT preconditions (clean tree at
spawn) and the shared `.build/work` verify image make shared-tree concurrency
unsound; disjointness stands as the reviewer's cross-check. E06 itself runs
beside E03/E04/E05 per the frozen roadmap (disjoint packages).

**E03 rows (C20–C27) added by the fourth Prompt-4 run (2026-07-25; Gate 4
pending).** Numbering: the concurrent E06 cut (same day, papers on disk first)
claimed C12–C18; chunk IDs are corpus-global and never collide or reuse, so E03
took C20–C27 (C19 left unused — a gap, not a hole; the near-miss is reported to
the owner). E03 `accepted` when all eight rows are `accepted` and the exit
checkpoint in `plan/04-epics/E03-configuration-scope-law/chunks.md` is filled in
(named 42-test suite green with accepted siblings, 66 run · D-67 precheck
discipline · CI leg, on one head commit) — at which point E03's interface digest
(caller surface `fromString:`/`fromFile:` + the version-2 artifact schema + the
specified-but-internal readers E04 consumes, tabled in that file) freezes, and
E04's entry check can pass. No `[P]` in this epic: C21–C27 share one class file
pair, C20 is their fixture root — strictly serial picks. C24 rides Q-31's
recommendation (decision sheet, veto-open); a veto amends C24 by its own chunk,
not by silent edit.

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
