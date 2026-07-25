# Ledger — chunk state (the orchestrator's only mutable state)

*Created by Prompt 4's first run (E01); format per the amended method (f9bb7f9):
status table + per-chunk verify list. One row per chunk: status ∈
`todo / in-progress / review / accepted`. Everything else in `plan/` is
append-or-frozen.*

*ID convention (D-73): chunks cut from E04 onward carry epic-qualified IDs
`E##-C##` — the counter local to the epic, so concurrent cuts cannot collide.
C01–C27 (E01/E02/E06/E03) are grandfathered bare IDs; C19 is a documented gap
from the collision D-73 answers. No ID is ever renamed or reused.*

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
| C12 | E06 | accepted | — | implementer-12 (picked @ 3c1680a) |
| C13 | E06 | accepted | — | implementer-13 (picked @ 69701b9; fix 1 accepted) |
| C14 | E06 | accepted | — | implementer-14 (picked @ 22b6209) |
| C15 | E06 | accepted | C13 | implementer-15 (picked @ 1eea635) |
| C16 | E06 | accepted | C15 | implementer-16 (picked @ 94863ba; advisory: exact class pin in PCKKitTest, carried to C17) |
| C17 | E06 | accepted | C16 | implementer-17 (picked @ e8932f0) |
| C18 | E06 | accepted | C17 | implementer-18 (picked @ e2f763f) |
| C20 | E03 | accepted | — | implementer-20 (picked @ cb9fc49) |
| C21 | E03 | accepted | C20 | implementer-21 (picked @ ce29378) |
| C22 | E03 | accepted | C21 | implementer-22 (picked @ 6e8189d) |
| C23 | E03 | accepted | C22 | implementer-23 (picked @ 6db98df) |
| C24 | E03 | accepted | C23 (Q-31 ruled — D-70) | implementer-24 (picked @ bada692) |
| C25 | E03 | accepted | C24 | implementer-25 (picked @ fce05ee) |
| C26 | E03 | accepted | C25 | implementer-26 (picked @ 7297ef9) |
| C27 | E03 | accepted | C26 | implementer-27 (picked @ 0b1186c) |
| E04-C01 | E04 | accepted | — | implementer-E04-C01 (picked @ 38cbbbd; accepted @ 3d7a477, 95 run) |
| E04-C02 | E04 | accepted | E04-C01 | implementer-E04-C02 (picked @ cda0e03; accepted @ 79b1839, 101 run) |
| E04-C03 | E04 | accepted | E04-C02 | implementer-E04-C03 (picked @ aa38715; accepted @ 1843b58, 106 run; advisory: PGRRegistry comment's "before wrapping (C04)" claim to be made true by C04) |
| E04-C04 | E04 | accepted | E04-C03 | implementer-E04-C04 (picked @ 890e9b0; accepted @ f369239, 112 run; C03 advisory discharged) |
| E04-C05 | E04 | accepted | E04-C04 | implementer-E04-C05 (picked @ a444cd6; fix 1 accepted @ 9127e31, 114 run) |
| E08-C01 | E08 | todo | — | — |
| E08-C02 | E08 | todo | — | — |
| E08-C03 | E08 | todo | E08-C01, E08-C02 | — |
| E08-C04 | E08 | todo | E08-C03 | — |
| E08-C05 | E08 | todo | E08-C01, E08-C04 | — |
| E07-C01 | E07 | todo | — | — |
| E07-C02 | E07 | todo | E07-C01 | — |
| E07-C03 | E07 | todo | E07-C02 | — |
| E07-C04 | E07 | todo | E07-C03 | — |
| E07-C05 | E07 | todo | E07-C04 | — |
| E07-C06 | E07 | todo | E07-C05 | — |

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
- **E04-C01** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 7 `PGRScratchCheckFixturesTest` + every previously accepted suite, ≥95 run — membership + floor, never an exact ceiling)
- **E04-C02** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 6 `PGRRegistrationTest` + 7 `PGRScratchCheckFixturesTest` + every previously accepted suite, ≥101 run — membership + floor)
- **E04-C03** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 5 `PGRRegistryTest` + accepted E04 siblings + every previously accepted suite, ≥106 run — membership + floor)
- **E04-C04** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 11 `PGRRegistryTest` + accepted E04 siblings + every previously accepted suite, ≥112 run — membership + floor)
- **E04-C05** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 13 `PGRRegistryTest` + 6 `PGRRegistrationTest` + 7 `PGRScratchCheckFixturesTest` + every previously accepted suite, ≥114 run — the E04 exit-checkpoint leg 1; see `plan/04-epics/E04-registry-kit-handoff-conformance/chunks.md` §checkpoint)
- **E08-C01** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; the new `testTraitProvidedMethodLintedAtUsingClassPackage` + every previously accepted suite, ≥89 run — membership + floor, never an exact ceiling)
- **E08-C02** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 3 `PCKFixCommandTest` + every previously accepted suite, ≥91 run — membership + floor)
- **E08-C03** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 6 `PCKFixCommandTest` + every previously accepted suite, ≥95 run — membership + floor)
- **E08-C04** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 9 `PCKFixCommandTest` + every previously accepted suite, ≥98 run — membership + floor)
- **E08-C05** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 8 `PCKLintRuleCheckTest` + 3 `PCKNoIsNilIfTrueRuleTest` + 9 `PCKFixCommandTest` + every previously accepted suite, ≥102 run — the E08 exit-checkpoint leg 1; see `plan/04-epics/E08-fix-command/chunks.md` §checkpoint)
- **E07-C01** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 5 `PCKBehavioralFixturesTest` + every previously accepted suite, ≥93 run — membership + floor, never an exact ceiling; the four fixture classes appear in no test-run line)
- **E07-C02** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 3 `PCKSuiteRunCacheTest` + every previously accepted suite, ≥96 run — membership + floor)
- **E07-C03** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 3 `PCKTestSuiteCheckTest` + every previously accepted suite, ≥99 run — membership + floor)
- **E07-C04** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 3 `PCKNoSkippedTestsMetaRuleTest` incl. both P-GATE-SKIP tests + every previously accepted suite, ≥102 run — membership + floor)
- **E07-C05** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 4 new + 8 amended `PCKKitTest` and 4 `PCKTestSuiteCheckTest` + every previously accepted suite, ≥107 run — membership + floor)
- **E07-C06** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; `testRecommendedBlockParsesAndConforms` + both amended stanza tests + every previously accepted suite, ≥108 run — the E07 exit-checkpoint leg 1; see `plan/04-epics/E07-behavioral-kind/chunks.md` §checkpoint)

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

**E06: ACCEPTED 2026-07-25.** All seven chunks accepted; exit checkpoint filled in
(`plan/04-epics/E06-coding-kit-lint/chunks.md`, three legs green on head `0c4fb7b`:
22-test named kit suite within a 74/74 sweep incl. the three owed properties · B-03
probe leg = D-71 + Q-32 · CI run 30155928234). E06's interface digest — the block
schema, registration naming/order, `PCKKit`, `PCKLintRuleCheck rule:packages:`, the
two catalog registrations, the D-41 enforcement point (tabled in that file) — is
hereby frozen; amendments need a decision-sheet entry. The entry checks of E07 and
E08 can pass. One review round-trip this epic (C13 fix 1, rationale string); Q-32
(trait-lint escape) remains open for the owner.

**E03: ACCEPTED 2026-07-25.** All eight chunks accepted (C19 is a documented numbering
gap, never a chunk); exit checkpoint filled in
(`plan/04-epics/E03-configuration-scope-law/chunks.md`, three legs green on head
`e26fc9c`: 42-test named suite within an 88/88 sweep with all five named properties ·
precheck green at every pick · CI run 30156668709). E03's interface digest — the caller
surface (`fromString:`/`fromFile:`), the version-2 artifact schema, and the eight
specified-but-internal readers E04 consumes (tabled in that file) — is hereby frozen;
amendments need a decision-sheet entry. E04's entry check can pass. No fix round-trips
this epic; B-14 (Symbol/String asymmetry) reached C23 unruled and remains open in the
backlog for E04; B-15 filed at close (fromFile: encoding-error escape candidate).

**E04: ACCEPTED 2026-07-25.** All five chunks accepted; exit checkpoint filled in
(`plan/04-epics/E04-registry-kit-handoff-conformance/chunks.md`, three legs green
on head `9127e31`: 26-test named suite within a 114/114 sweep discharging
P-CONFORMANCE (both), P-LOADING-INERT, P-REG-FRESH (registry + reflective arms;
gate clause → E05), P-ERR-IS-RED (registration arm), P-GATE-MISSING (core-half
machinery), P-CFG-STRICT (duplicate-name arm) · precheck green at every pick with
D-73-qualified commits · CI run 30169997450). Per the frozen roadmap: **no new
frozen exports** — the engine is internal; the SDK contract it validates is
E02's. The specified-but-internal surface E05 consumes (tabled in that file:
`PGRRegistry fromConfiguration:`/`registrations`/`size`,
`PGRRegistration fromSpec:`/`name`/`kind`/`isResolved`/`run` with stamped total
verdicts, kit-raised `PGRConfigurationError` propagating unhandled) is changeable
only via decision-sheet entry while E05 is in flight. E05's entry check can pass —
**E05's cut is the next Prompt-4 run (owner)**. One review round-trip this epic
(E04-C05 fix 1, inert mutation arm); the Gate-4 addendum's ADVISORY (kit-raised
error propagation untested — obedient scratch kit) stands recorded for the E05
cut. E04's B-17 (fuel-snapshot dirt) was filed at C01 acceptance.

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

**E08 rows (E08-C01–E08-C05) added by the fifth Prompt-4 run (2026-07-25; Gate 4
pending).** First epic-qualified cut (D-73): the counter is local to E08, so the
concurrent same-day cuts (E04, E07 — papers on disk) cannot collide by
construction. E08 `accepted` when all five rows are `accepted` and the exit
checkpoint in `plan/04-epics/E08-fix-command/chunks.md` is filled in (named
suites — `PCKFixCommandTest` 9 · `PCKLintRuleCheckTest` 8 ·
`PCKNoIsNilIfTrueRuleTest` 3 — green within a ≥102 sweep incl. P-FIX-PREVIEW and
P-CAT-AUTOFIX · CI leg, on one head commit) — at which point E08's interface
digest (the `PCKFixCommand` fix-invocation implementation, the capability pair
on `PCKLintRuleCheck`, the D-72 environment law — tabled in that file) freezes,
and E09's entry check can count E08 satisfied. E08-C01 is the owner-scheduled
D-72 amendment chunk (ruled ground beyond the roadmap row; placement annotated
in `chunks.md` per D-61.a) — it amends E06's frozen surface through the
decision-sheet path, never a silent edit. [P] eligibility (disjoint manifests):
E08-C01 E08-C02; orchestrator runs them serialized — the COMMIT preconditions
(clean tree at spawn) and the shared `.build/work` verify image make shared-tree
concurrency unsound; disjointness stands as the reviewer's cross-check. E08
itself runs `[P]` beside E05/E07 per the frozen roadmap (ground:
`Phi-Coding-Kit-Rules`/`-Tests-Rules`; `PCKKitTest` is E07's file — no E08
manifest touches it).

**E04 rows (E04-C01–E04-C05) added by the fifth Prompt-4 run (2026-07-25; Gate 4
pending; first cut under D-73 epic-qualified IDs).** E04 `accepted` when all five
rows are `accepted` and the exit checkpoint in
`plan/04-epics/E04-registry-kit-handoff-conformance/chunks.md` is filled in (the
26-test named suite — 7 `PGRScratchCheckFixturesTest` + 6 `PGRRegistrationTest` +
13 `PGRRegistryTest` — green with every previously accepted suite, ≥114 run,
membership + floor · D-67 precheck discipline with `E04-C##:`-prefixed commits ·
CI leg, on one head commit) — at which point E04 closes with **no new frozen
exports** (the frozen roadmap's ruling: the engine is internal; the SDK contract
it validates is E02's) and the specified-but-internal `PGRRegistry`/
`PGRRegistration` surface E05 consumes is tabled in that file (changeable only
via decision-sheet entry while E05 is in flight), so E05's entry check can pass.
Properties: P-CONFORMANCE and P-LOADING-INERT discharged in full; P-REG-FRESH's
named test lands here with its gate/report clause completing at E05; the
P-ERR-IS-RED registration arm, P-GATE-MISSING core-half machinery, and
P-CFG-STRICT's duplicate-name arm (E03's recorded handoff) are discharged and
recorded as cross-epic statements in the chunk index. No `[P]` in this epic:
C02 consumes C01's fixtures and C03–C05 share the `PGRRegistry`/`PGRRegistryTest`
file pair — strictly serial picks; every manifest is disjoint from the kit-track
cuts (E07/E08) running `[P]` beside this one.

**E07 rows (E07-C01–E07-C06) added by the fifth Prompt-4 run (2026-07-25; Gate 4
pending; epic-qualified IDs per D-73 — the concurrent same-day cuts E04/E08 own
their local counters, so no collision is possible by construction).** E07
`accepted` when all six rows are `accepted` and the exit checkpoint in
`plan/04-epics/E07-behavioral-kind/chunks.md` is filled in (the 20 new E07 tests
— `PCKBehavioralFixturesTest` 5 · `PCKSuiteRunCacheTest` 3 ·
`PCKTestSuiteCheckTest` 4 · `PCKNoSkippedTestsMetaRuleTest` 3 · `PCKKitTest` +5
— green with every previously accepted suite, ≥108 run, membership + floor ·
D-67 precheck discipline with `E07-C##:`-prefixed commits · CI leg, on one head
commit) — at which point E07's interface digest (behavioral registration naming
incl. the `behavioral/tests-role` sentinel, the completed four-stage order law,
the cache's one-message protocol, the kit-side wiring spellings, the complete
three-key `recommendedBlock` — tabled in that file) freezes, and E09's entry
check can count E07 satisfied. Properties owed and discharged here: P-GATE-SKIP,
P-SUITES-BEFORE-META, P-GATE-MISSING (suite half; the gate half is E05's),
P-STANZA-VALID, plus the two R-37 behavioral fixture pairs. No `[P]` in this
epic: the chain is strictly linear (each chunk consumes its predecessor's
deliverables; E07-C05/C06 share the `PCKKit`/`PCKKitTest` file pair). E07 runs
`[P]` beside E04/E05/E08 per the frozen roadmap; its ground is
`-Behavioral`/`-Fixtures-Behavioral`/`-Tests-Behavioral` plus
`src/Phi-Coding-Kit/PCKKit.class.st` and the `-Tests-Rules` file
`PCKKitTest.class.st` (the frozen E06 ruling "E07 extends the class in place";
E08's papers reciprocally cede that file) — E07 alone touches `PCKKit` after
E06, and the eight C05-amended E06 tests are scheduled ground enumerated in the
work order, never silent edits.
