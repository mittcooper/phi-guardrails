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
| E08-C01 | E08 | accepted | — | implementer-E08-C01 (picked @ 056e932; accepted @ f5680d6, 115 run; strict packageNamed: ruled in-scope by review) |
| E08-C02 | E08 | accepted | — | implementer-E08-C02 (picked @ 9c5af29; accepted @ 44dee8a, 123 run; Q-33 filed; advisory to C03 review: changes snapshot-vs-live-view) |
| E08-C03 | E08 | accepted | E08-C01, E08-C02 | implementer-E08-C03 (picked @ 87366b1; accepted @ d531e2c, 129 run; watch point closed — changes answers a snapshot; advisories to C04: re-preview semantics, "pending/applied" comment) |
| E08-C04 | E08 | accepted | E08-C03 | implementer-E08-C04 (picked @ e0bfd4c; accepted @ aa71c6e, 135 run ×2 idempotent; C03 advisories closed; B-19 filed) |
| E08-C05 | E08 | accepted | E08-C01, E08-C04 (Q-33 ruled — D-74) | implementer-E08-C05b (re-picked @ f84e2cb; accepted @ 19beb68, 148 run — E08 checkpoint leg 1) |
| E07-C01 | E07 | accepted | — | implementer-E07-C01 (picked @ c962f6c; accepted @ 574d04f, 120 run, fixtures unswept) |
| E07-C02 | E07 | accepted | E07-C01 | implementer-E07-C02 (picked @ 6f9eea9; accepted @ b2bcca4, 126 run) |
| E07-C03 | E07 | accepted | E07-C02 | implementer-E07-C03 (picked @ 64b711f; accepted @ 4024f30, 132 run; stall post-commit, report recovered; advisory to C05: wiring test may also pin packages-reader truthfulness) |
| E07-C04 | E07 | accepted | E07-C03 | implementer-E07-C04 (picked @ 51c6af7; accepted @ d1528c6, 138 run) |
| E07-C05 | E07 | accepted | E07-C04 | implementer-E07-C05 (picked @ b8a0317; accepted @ 627cea1, 143 run; amendment table exact, 5 untouched byte-identical; nit to C06/backlog: suite-spec packages-reader truthfulness unpinned; B-17 corroborated by red-run fuel debris) |
| E07-C06 | E07 | accepted | E07-C05 | implementer-E07-C06 (picked @ f528a23; accepted @ f569549, 144 run — E07 checkpoint leg 1) |
| E05-C01 | E05 | accepted | — | implementer-E05-C01 (picked @ 085d23c; fix 1 accepted @ 95984e2, 151 run) |
| E05-C02 | E05 | accepted | — | implementer-E05-C02 (picked @ 95984e2; accepted @ 1b2aa9e, 158 run) |
| E05-C03 | E05 | accepted | E05-C02 | implementer-E05-C03 (picked @ 1b2aa9e; accepted @ 43b20aa, 162 run) |
| E05-C04 | E05 | accepted | E05-C03 | implementer-E05-C04 (picked @ 43b20aa; fix 1 accepted @ 68f6f4a, 166 run) |
| E05-C05 | E05 | accepted | E05-C04, E05-C01 | implementer-E05-C05 (picked @ 68f6f4a; accepted @ 5fad1d5, 170 run; B-21/B-22 filed) |
| E05-C06 | E05 | accepted | E05-C05 | implementer-E05-C06 (picked @ 5a51f01; accepted @ 9339b07, 174 run) |
| E05-C07 | E05 | accepted | E05-C05 (Q-34 ruled — D-75) | implementer-E05-C07 (picked @ 9339b07; committed @ 65bd022; Q-34 → D-75, arm 4 amended @ f250ad6; accepted post-re-run, arms 0/1/2/1-relayed) |
| E09-C01 | E09 | accepted | — | implementer-E09-C01 (picked @ 964787b; committed @ 0dc0e82; accepted @ 0dc0e82, 180 run — verify green, reviewer accept) |
| E09-C02 | E09 | accepted | — | implementer-E09-C02 (picked @ 0dc0e82; committed @ f401511; accepted @ f401511, 183 run — verify green, reviewer accept) |
| E09-C03 | E09 | accepted | — | implementer-E09-C03 (picked @ f401511; committed @ b3e384d; accepted @ b3e384d, 189 run + self-hosted gate exit 0 / 10 GREEN — both instruments verified, reviewer accept) |
| E09-C04 | E09 | accepted | — | implementer-E09-C04 (picked @ b3e384d; committed @ ff8e473; accepted @ ff8e473, 193 run + self-hosted gate exit 0 — both legs verified, reviewer accept; SmalltalkCI-selector question → backlog B-26) |
| E09-C05 | E09 | accepted | E09-C04 | implementer-E09-C05 (round 1 @ 8809f00 → Q-35/D-76 guide amend; round 2 @ e4ad139 → Q-36/D-77 fence reshape; round 3 re-pick @ a568bf8; committed @ 4b42d0e; accepted @ 4b42d0e, 194 run + self-hosted gate exit 0 — both instruments verified, reviewer accept) |
| E09-C06 | E09 | accepted | E09-C05 | implementer-E09-C06 (picked @ 4b42d0e; committed @ c50a064; accepted @ c50a064, 195 run + self-hosted gate exit 0, C05 methods byte-identical 92/0 — both instruments verified, reviewer accept) |
| E10-C01 | E10 | accepted | — | implementer-E10-C01 (picked @ 0a25d0d; committed @ 91cac09; accepted @ 91cac09, 205 run + self-hosted gate exit 0 / 10 M1 registrations unchanged — verify + gate verified, reviewer accept) |
| E10-C02 | E10 | accepted | E10-C01 | implementer-E10-C02 (picked @ 91cac09; committed @ 3bbdb9d; accepted @ 3bbdb9d, 212 run + self-hosted gate exit 0 / 10 M1 registrations unchanged, C01 methods byte-intact 157/0 — verify + gate verified, reviewer accept; B-27 filed) |
| E10-C03 | E10 | accepted | — | implementer-E10-C03 (picked @ 66b1c4e; committed @ a40cb6b; accepted @ a40cb6b, 216 run + self-hosted gate exit 0 / 10 M1 registrations unchanged, support class unswept — verify + gate verified, reviewer accept) |
| E10-C04 | E10 | accepted | E10-C01, E10-C02, E10-C03 | implementer-E10-C04 (two prior spawns died to environment — infra stall, then a false foreign-dirt halt on a stale snapshot; re-spawned @ a40cb6b; committed @ 2b9791c; accepted @ 2b9791c, 221 run + self-hosted gate exit 0 / 10 M1 registrations unchanged, instanceSide confirmed — verify + gate verified, reviewer accept; §4.2/PGRVerdict advisory Q → Q-37, conservative arm implemented, owner-pending) |
| E10-C05 | E10 | accepted | E10-C02, E10-C03, E10-C04 | implementer-E10-C05 (picked @ fe40b2f; committed @ afc582c; accepted @ afc582c, 225 run + self-hosted gate exit 0 / 10 M1 registrations unchanged, C04 methods byte-identical 73/0 — verify + gate verified, reviewer accept) |
| E10-C06 | E10 | accepted | E10-C02, E10-C04 | implementer-E10-C06 (picked @ afc582c; committed @ b994a3e; accepted @ b994a3e, 230 run + self-hosted gate exit 0 / 10 M1 registrations unchanged; amendment table held — one accepted test amended, generic arch path byte-identical — verify + gate verified, reviewer accept) |
| E11-C01 | E11 | accepted | — | implementer-E11-C01 (picked @ 0592afd; committed @ c73dbb4; fix 1 — asArray-identity aliasing → `Array withAll:` — @ 318f46c; accepted @ 318f46c, 236 run + self-hosted gate exit 0 / 10 M1 registrations unchanged — verify + gate verified, reviewer accept; name kept `PGRKitEnvironment`; respondsTo:-skeleton erratum → backlog B-29) |
| E11-C02 | E11 | accepted | E11-C01 | implementer-E11-C02 (picked @ 3b52335; committed @ be651ac; accepted @ be651ac, 244 run + self-hosted gate exit 0 / 10 M1 registrations unchanged (gate run exercises the fallback path live), accepted PGRRegistryTest methods byte-identical, pre-change red witness recorded — verify + gate verified, reviewer accept first pass) |
| E11-C03 | E11 | accepted | — | implementer-E11-C03 (picked @ 5e4f11a; committed @ 027f2d8; accepted @ 027f2d8, 241 run + self-hosted gate exit 0 / 10 M1 registrations unchanged — verify + gate verified, reviewer accept first pass; P5 record: allSubclasses + Symbol=String clause confirmed in-image; non-blocking reviewer notes — scratch-root staleness one-liner, tests-first witnessing skipped-and-disclosed — held for M2 mining) |
| E11-C04 | E11 | accepted | E11-C01, E11-C03 | implementer-E11-C04 (picked @ b439e27; committed @ 0cb957a; accepted @ 0cb957a, 250 run + self-hosted gate exit 0 / 10 M1 registrations unchanged (gate now flows through the environment form live — PCKKit answers the probe), accepted kit-test methods byte-identical (95/0, 19/0) — verify + gate verified, reviewer accept first pass; non-blocking reviewer note — D-25 concatenation content unasserted, candidate one-line hardening — held for M2 mining) |
| E11-C05 | E11 | accepted | E11-C02, E11-C04 | implementer-E11-C05 (picked @ 8f71cd5; committed @ 786bacf; accepted @ 786bacf — both instruments on one commit: verify 250 run 0F/0E + self-hosted gate exit 0 / **12 registrations** GATE: GREEN (10 → 12, the completed §7.5 artifact enforced live, no first-run violations — the budgeted risk did not materialize); amendment table held (pin-test file the only accepted test amended); tests-first red witnessed (2F against the M1 artifact) — verify + gate verified, reviewer accept first pass) |
| E12-C01 | E12 | accepted | — | implementer-E12-C01 (picked @ f330ad3; committed @ 7172155; accepted @ 7172155, 252 run 0F/0E + self-hosted gate exit 0 / 12 registrations unchanged GATE: GREEN, both new cases present by name, footprint exactly the 5-file manifest 163/0 — verify + gate verified, reviewer accept first pass; non-blocking reviewer note — baseline resolved via Smalltalk globals vs direct reference style in the sibling test — held for milestone mining) |
| E12-C02 | E12 | accepted | — | implementer-E12-C02 (picked @ 076c3f7; committed @ 2908da0; accepted @ 2908da0, sweep 252 run 0F/0E (no swept test added, D-57 by design) + unswept-pair eval arm 2 ran/2 passed/0F/0E + self-hosted gate exit 0 / 12 registrations unchanged GATE: GREEN, footprint exactly the 4-file manifest 105/0 — all three legs integrator-verified, reviewer accept first pass; non-blocking reviewer nit — provenance history note in the rule's class comment — held for milestone mining) |
| E12-C03 | E12 | accepted | E12-C01, E12-C02 | implementer-E12-C03 (picked @ ce40b97; committed @ b5dcb7f; fix 1 — reviewer revise: testToyRulePlantIsCaught's production-scope clause was prose, strengthened with `verdict findings size = 1` — amended to 749ef34; accepted @ 749ef34, sweep 257 run 0F/0E GREEN WITH THE SIX PLANTS COMMITTED (D-57 shape held) + self-hosted gate exit 0 / 12 registrations unchanged GATE: GREEN (D-26 exempt-role guard witnessed live), five witnesses by name, footprint exactly the 4-file manifest 169/0 — verify + gate integrator-verified on the revised head, reviewer accept on re-verdict; layers-sub-map-as-Dictionary deviation judged the faithful reading, no ruling needed) |
| E12-C04 | E12 | todo | E12-C01, E12-C02 | — |
| E12-C05 | E12 | todo | E12-C01 | — |

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
- **E05-C01** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 38 `PGRConfigurationTest` (35 accepted byte-identical + 3 new) + every previously accepted suite, ≥151 run — membership + floor, never an exact ceiling)
- **E05-C02** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 7 `PGRReportTest` + every previously accepted suite, ≥155 run — membership + floor)
- **E05-C03** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 4 `PGRGateTest` + 7 `PGRReportTest` + every previously accepted suite, ≥159 run — ≥162 once E05-C01's 3 tests are in per the listed serial pick order; membership + floor)
- **E05-C04** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 8 `PGRGateTest` + every previously accepted suite, ≥163 run — ≥166 once E05-C01 is in per the listed serial pick order; membership + floor)
- **E05-C05** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 12 `PGRGateTest` + every previously accepted suite, ≥170 run — membership + floor)
- **E05-C06** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 16 `PGRGateTest` + every previously accepted suite, ≥174 run — membership + floor; the three new fixture classes appear in no test-run line)
- **E05-C07** — the four shell arms of its work order's checkpoint section (clean→0 · red→1 · malformed→2 · unloadable image→3) plus `bash tools/verify.sh` still green (≥174) and `guardrails.sh` tracked executable; see `plan/04-epics/E05-gate-report-invocation/C07-reference-runner.md` §VERIFY
- **E09-C01** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 6 `PGRArchSelfTest` + every previously accepted suite, ≥180 run — membership + floor, never an exact ceiling)
- **E09-C02** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 3 `PGRSurfaceConformanceTest` + every previously accepted suite, ≥177 run — parallel-landed E09 chunks add to the count; membership + floor)
- **E09-C03** — two instruments, same commit: `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 3 `PGRToySweepExemptionTest` + 3 `PCKArtifactBlockM1FormTest` + every previously accepted suite, ≥180 run — membership + floor) **and** `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston` → exit 0, 10 green registrations
- **E09-C04** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 4 `PGRQuickstartSampleHarnessTest` + every previously accepted suite, ≥178 run — membership + floor)
- **E09-C05** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; `testWriteACheckSamples` + 4 `PGRQuickstartSampleHarnessTest` + every previously accepted suite, ≥179 run — ≥194 once E09-C01–C03 are in per the listed serial pick order; membership + floor)
- **E09-C06** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; both `PGRQuickstartSamplesTest` methods + every previously accepted suite, ≥195 run — membership + floor); then the E09 exit checkpoint = the M1 milestone boundary on the accepted head; see `plan/04-epics/E09-self-host-m1-freeze/chunks.md` §checkpoint

- **E10-C01** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 10 `PCKLayerMapTest` + every previously accepted suite, ≥205 run — membership + floor, never an exact ceiling)
- **E10-C02** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 17 `PCKLayerMapTest` incl. the three P-LAYERMAP-TOTAL config arms + every previously accepted suite, ≥212 run — membership + floor)
- **E10-C03** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 4 `PCKLayerMapFixtureTest` + every previously accepted suite, ≥199 run — membership + floor; `PCKLayerMapFixture` appears in no test-run line)
- **E10-C04** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 5 `PCKLayerMapCheckTest` incl. P-FINDING-PRECISE + P-CAT-FIXTURES(arch) + P-LAYERMAP-TOTAL advisory + every previously accepted suite, ≥221 run — membership + floor)
- **E10-C05** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 9 `PCKLayerMapCheckTest` incl. the four D-79/D-79.a semantics witnesses + every previously accepted suite, ≥225 run — membership + floor)
- **E10-C06** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; `PCKKitTest` with the amended `testLayerMapKeyProducesNoRegistrationsAndNoError` + 5 new dispatch tests, the generic-arch path green + every previously accepted suite, ≥226 run — membership + floor; C05's 4 independent of C06 — the E10 exit-checkpoint leg 1; see `plan/04-epics/E10-layer-map-check/chunks.md` §checkpoint) **and** `./guardrails.sh guardrails.ston` → exit 0, 10 M1 registrations unchanged (E10 adds none — regression leg)

- **E11-C01** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 6 `PGRKitEnvironmentTest` + every previously accepted suite, ≥236 run when picked first — membership + floor, never an exact ceiling; [P] sibling E11-C03 raises the floor by 5 if picked earlier)
- **E11-C02** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 3 new `PGRRegistryTest` + every accepted `PGRRegistryTest` byte-identical + every previously accepted suite, ≥239 run once E11-C01 is in per the listed serial pick order — membership + floor)
- **E11-C03** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 5 `PCKSrcInventoryCheckTest` + every previously accepted suite, ≥235 run when picked first — membership + floor; [P] sibling E11-C01 raises the floor by 6 if picked earlier)
- **E11-C04** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 5 new `PCKKitTest` + `PCKSrcInventoryCheckTest>>testMissingWithoutSrcKey` + every accepted kit-test method byte-identical + every previously accepted suite, ≥247 run once E11-C01/C03 are in per the listed serial pick order (230 + 6 + 5 + these 6) — membership + floor)
- **E11-C05** — two instruments, same commit: `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; the 3 amended `PCKArtifactBlockM1FormTest` pins + every previously accepted suite, ≥250 run — membership + floor) **and** `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston` → exit 0, **12 registrations**, `GATE: GREEN` (the completed §7.5 artifact enforced — the E11/M2 exit-checkpoint core; see `plan/04-epics/E11-src-inventory-full-artifact/chunks.md` §checkpoint)

- **E12-C01** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 2 `PGRToyBaselineTest` + every previously accepted suite, ≥252 run when picked first — membership + floor, never an exact ceiling) **and** `./guardrails.sh guardrails.ston` → exit 0, 12 registrations unchanged, `GATE: GREEN` (regression leg — E12 adds nothing to the framework's artifact)
- **E12-C02** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; no swept test added — ≥250 run, floor per pick order) **and** the unswept-pair eval arm (`ToyNoIsNilIfFalseRuleTest suite run` → 2 run, 2 passes, 0 failures, 0 errors) **and** the 12-registration gate regression leg (see its work order §VERIFY)
- **E12-C03** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 5 `PGRToyPlantWitnessTest` + every previously accepted suite, ≥257 run once E12-C01 is in per the listed serial pick order — membership + floor; the sweep stays green WITH the six plants committed) **and** the 12-registration gate regression leg (the D-26 exempt guard live)
- **E12-C04** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 2 `PGRToyArtifactTest` + every previously accepted suite, ≥254 run once E12-C01/C02 are in per the listed serial pick order, ≥259 once C03 is in — membership + floor) **and** the 12-registration gate regression leg
- **E12-C05** — `bash tools/build-image.sh && bash tools/verify.sh` (exit 0; 4 `PGRConfigurationDraftTest` + the amended `PGRSurfaceConformanceTest` green in its five-audience/46-triple form (one accepted method renamed by schedule, all others byte-identical) + every previously accepted suite, ≥256 run once E12-C01 is in per the listed serial pick order, ≥263 once C02–C04 are in — membership + floor) **and** the 12-registration gate regression leg

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

**E07: ACCEPTED 2026-07-25.** All six chunks accepted; exit checkpoint filled in
(`plan/04-epics/E07-behavioral-kind/chunks.md`, three legs green on head `f569549`:
the 20 new E07 tests within a 144/144 sweep discharging P-GATE-SKIP (both),
P-SUITES-BEFORE-META, P-GATE-MISSING (suite half; gate half → E05),
P-STANZA-VALID, and P-CAT-FIXTURES (behavioral) · precheck green at every pick
with D-73-qualified commits · CI run 30181950983). E07's interface digest —
behavioral registration naming incl. the `behavioral/tests-role` sentinel, the
completed four-stage order law, `PCKSuiteRunCache`'s one-message protocol (one
cache per `registrationsFrom:` call), the kit-side wiring spellings
(`PCKTestSuiteCheck package:cache:` · `PCKNoSkippedTestsMetaRule packages:cache:`),
and the complete three-key `recommendedBlock` (tabled in that file) — is hereby
frozen; amendments need a decision-sheet entry. E09's entry check can count E07
satisfied (E09 still needs E05 and E08). No fix round-trips this epic; one
implementer-session stall (E07-C03, post-commit, report recovered); the C05
amendment table applied exactly (five untouched methods byte-identical —
deterministic check). B-20 filed at close (suite-spec `packages`-reader
truthfulness unpinned — the C03→C05 carried nit, outside C06's manifest);
B-17's fuel-debris hazard was corroborated live at C05's red run.

**E08: ACCEPTED 2026-07-25.** All five chunks accepted; exit checkpoint filled in
(`plan/04-epics/E08-fix-command/chunks.md`, both legs green on head `19beb68`: the
three named suites — `PCKFixCommandTest` 9 · `PCKLintRuleCheckTest` 8 ·
`PCKNoIsNilIfTrueRuleTest` 3 — within a 148/148 sweep discharging P-FIX-PREVIEW
(all three legs) and P-CAT-AUTOFIX, with the D-72 amendment's witness · CI run
30183734274). E08's interface digest — the `PCKFixCommand` fix-invocation
implementation (one instance, one invocation; staleness = re-read vs the
preview-time snapshot, the B-19-corrected reading), the capability pair on
`PCKLintRuleCheck` (`canFix` = the mechanical rewrite-recipe fact, D-74), and the
D-72 environment law (tabled in that file) — is hereby frozen; amendments need a
decision-sheet entry. E09's entry check can now count **E07 and E08 both
satisfied — only E05 remains** (its cut is the owner's next Prompt-4 run).
Epic history: Q-33 filed from C02's report and ruled D-74 mid-epic (the
work-order amendment landed in two owner commits; C05's first implementer session
used the intermediate text and was terminated under the owner's stop-and-report
notice — standing rule adopted: foreign uncommitted tree state at pick time is a
stop-and-report, never adopt-and-commit); one API-error implementer restart
(no state lost); no fix round-trips. B-18/B-19 filed from this epic's reviews.

**E05 rows (E05-C01–E05-C07) added by the sixth Prompt-4 run (2026-07-25; Gate 4
pending; epic-qualified IDs per D-73 — the counter is local to E05, so no
collision with any concurrent cut is possible by construction).** E05
`accepted` when all seven rows are `accepted` and the exit checkpoint in
`plan/04-epics/E05-gate-report-invocation/chunks.md` is filled in (the 26 new
E05 tests — `PGRReportTest` 7 · `PGRGateTest` 16 · `PGRConfigurationTest` +3 —
green with every previously accepted suite, ≥174 run, membership + floor · the
E05-C07 runner leg's four shell arms exiting exactly 0/1/2/3 · D-67 precheck
discipline with `E05-C##:`-prefixed commits · CI leg, on one head commit) — at
which point E05's interface digest (the gate-caller SDK — `runHeadless:` /
`runHeadless:on:` / `forConfiguration:` / `onVerdict:` / `run` /
`PGRReport`'s five readers — the exit-code contract 0/1/2, and the reference
runner's ∉{0,1,2}→3 mapping, tabled in that file) freezes, and **E09's entry
check can pass on all three prerequisites (E05 · E07 · E08)**. Owner-scheduled
ground riding this cut, placements annotated per D-61.a: B-15 → E05-C01 (the
one chunk touching accepted files: `fromFile:` wrap widening with its scripted
consumer table; accepted tests amended: zero, additive only); the E04
validation ADVISORY → E05-C06 (kit-raised `PGRConfigurationError`, headless +
direct arms). Cross-epic completions recorded in the chunk index: P-ERR-IS-RED,
P-GATE-MISSING, and P-REG-FRESH all complete at E05-C04; P-CFG-STRICT gains
two additive arms at E05-C01. [P] eligibility (disjoint manifests): E05-C01
E05-C02 E05-C07; orchestrator runs them serialized — the COMMIT preconditions
(clean tree at spawn) and the shared `.build/work` verify image make
shared-tree concurrency unsound; disjointness stands as the reviewer's
cross-check. C03–C06 are strictly serial (shared
`PGRGate.class.st`/`PGRGateTest.class.st` file pair).

**E05: ACCEPTED 2026-07-26.** All seven chunks accepted; exit checkpoint
filled in (`plan/04-epics/E05-gate-report-invocation/chunks.md`, four legs
green on head `70410b3`: the 26 new E05 tests — `PGRConfigurationTest` +3 ·
`PGRReportTest` 7 · `PGRGateTest` 16 — within a 174/174 sweep discharging
P-GATE-COMPLETE, P-STREAM (both), P-JUDGE-CONVICTS, P-GATE-PURE,
P-GATE-HEADLESS, P-EXIT-CODES, P-NO-DEFAULT-PATH, P-SAME-VERDICT,
P-NEVER-UNDECIDED (both arms), plus the recorded completions P-ERR-IS-RED /
P-GATE-MISSING / P-REG-FRESH and P-CFG-STRICT's two B-15 arms · runner leg
0/1/2/1-relayed per the D-75-amended arm 4 · precheck green at every pick
with D-73-qualified commits · CI run 30192903522). E05's interface digest —
the gate-caller SDK (`PGRGate class>>runHeadless:` / `runHeadless:on:` /
`forConfiguration:`; instance `onVerdict:` / `run` → `PGRReport`;
`PGRReport>>verdicts` / `isClean` / `exitCode` / `blockingVerdicts` /
`advisories`), the exit-code contract (0 clean · 1 non-green · 2 config
error or escape, D-39), and the reference runner's mapping (`guardrails.sh`
relays 0/1/2, else 3 with one stderr line; tabled in that file) — is hereby
frozen; amendments need a decision-sheet entry. The report's printed text is
explicitly not an API; `PGRReport project:verdicts:`, the rendering seam,
and `PGRGate`'s instVars stay internal. **The core track (E01→E05) is
complete; E09's entry check can now count all three prerequisites (E05, E07,
E08) satisfied — the M1 join epic is the owner's next Prompt-4 cut.** Epic
history: two fix round-trips in seven chunks (E05-C01 fixture-matcher
fidelity + report accounting; E05-C04 purity-witness deletion hole — both
reviewer-caught, one pass each); Q-34 filed from C07's stop-and-report
trigger and ruled D-75 option (a) mid-epic (the §7.3 mapping stands; the
unloadable-image collision is a known v1 limitation, hardening carried as
B-23); B-21/B-22 (C05 review: double registry build seam; append-splice
authoring convention unruled) and B-25 (C07 review: wrapper quote-injection
edge, folds into B-23) filed by the orchestrator; B-23/B-24 owner-filed.
Seat-agent note: the `.claude/agents/` seats were not registered in this
session's agent registry (predates f5d2af4's pickup); seats were reproduced
faithfully — implementer one tier down per the seat's model line, reviewer
inherited — prompts verbatim.

**E09: ACCEPTED 2026-07-26 — and with it MILESTONE M1 CLOSES.** All six
chunks accepted; the exit checkpoint (`plan/04-epics/E09-self-host-m1-freeze/chunks.md`
§checkpoint) is met on head `c50a064`, four legs: (1) **named suite** — the 21
new E09 tests (`PGRArchSelfTest` 6 · `PGRSurfaceConformanceTest` 3 ·
`PGRToySweepExemptionTest` 3 · `PCKArtifactBlockM1FormTest` 3 ·
`PGRQuickstartSampleHarnessTest` 4 · `PGRQuickstartSamplesTest` 2) within a
**195/195** sweep, 0 failures/0 errors, discharging **P-SURFACE-CONFORMS ·
P-CORE-NEUTRAL · P-SDK-EDGE · P-NO-TRANSCRIPT · P-DETERMINISTIC · P-GUIDE-EXEC
(both M1 legs)** plus the recorded forms P-FIX-GATE-WALL (reflective) and
P-SELF-HOSTED (M1); (2) **self-hosted leg** — `./guardrails.sh guardrails.ston`
→ exit 0, `PhiGuardrails`, 10 registrations, `GATE: GREEN`; (3) **infra leg** —
`bash tools/precheck.sh` green at every pick, D-73 `E09-C##` commits; (4) **CI
leg** — CI run **30209108452** `completed success` on `c50a064` (also proving
the quickstart locator's CI behavior, informing B-26). Each leg was re-run by
the orchestrator independently, never on report. **Interface digest — no new
frozen exports:** E09 is the join; what freezes is the *machine witness* over
surfaces already frozen at E02/E03/E05/E06/E07/E08 — `PGRSurfaceConformanceTest`'s
41-triple/4-error manifest mirrors the ch. 0 §0.3 roster (the freeze is
red-test-enforced from here, roadmap §2) and `PGRArchSelfTest`'s six reflective
walls enforce the one-way arrows before the layer map exists. **The committed
M1 artifact form freezes as ruled ground:** `guardrails.ston` = §7.5 minus the
two architecture entries and `#layerMap`/`#src`; it grows only by scheduled
epic edits (E11 completes it), witnessed by `PCKArtifactBlockM1FormTest`.
Internal/unfrozen: the harness parsing/locator machinery, the pin-test and
sweep helper spellings.

Epic history — three chunks landed first-try (C01/C02/C03/C04 all accepted on
first review); **E09-C05 took three rounds via two owner rulings**: the
executable-guide property (P-GUIDE-EXEC) caught two real defects in the
producer-owned guide 2 §5 — a caret-plus-comment syntax error (Q-35 → **D-76**,
owner-broadened: ALL quickstart guides must be genuinely executable, standing
Drydock law) and, after the D-76 rewrite, a two-class-definitions-per-fence
shape that outran the accepted C04 harness parser (Q-36 → **D-77** option (a),
fence reshaped so the class definition leads). Both stop-and-reports were
verified independently before escalation; the implementer never patched guide,
harness, or assertion. E09-C06 landed last with C05's methods byte-identical
(92/0 diff). B-26 filed (C04 review: quickstart-locator `SmalltalkCI` selector
unpinned — the CI leg's green now validates the image-directory fallback as the
real CI path, so the guarded form is the accepted permanent form). No fix
round-trips (both C05 halts were external-guide escalations, not implementer
failures).

**Formal M1 mining pass (over E02–E09 reports/reviews, per the E01 precedent
and operating rule 9):** the milestone's recurring corrections were swept for
repeats warranting a new machine-enforced rule. Finding — **no new *product*
lint rule or architecture test is warranted**: the recurring items are not
recurring code-defect patterns but (a) build-infra debris and (b) process
notes. (a) **Repo-root debris from errored/red headless runs** is the one
repeat with a concrete machine remedy: `PharoDebug.log` (B-13, recurred across
E02, ruled **D-69** — gitignored) and `*.fuel` (B-17, from red SUnit CLI runs
at E04) recurred again at **E09-C05** (an errored probe dropped a `.fuel` at
repo root). Recommendation carried to B-17: close it by the D-69 precedent —
add `*.fuel` to `.gitignore` (build-infra category, D-65), a next-infra-chunk
one-liner. (b) Process notes, no rule owed: LOC routinely exceeds the 150 soft
target (never the 300 ceiling) on constitution-mandated-comment-heavy and
manifest-shaped test classes (C01 226 · C02 166 · C04 288) — the ceiling is the
real bound, reviewer-checked; and P5 in-image spelling gotchas (e.g.
`assert:equals:description:` does not exist) are the verify-the-spellings
discipline working as designed, recorded per chunk. The P-GUIDE-EXEC guide
episode is already machine-enforced going forward (D-76 makes verbatim
execution mandatory; the sample tests are the standing verifier).

**Open backlog dispositioned into the M1 mining packet (B-14…B-26):** all
carried, none M1-blocking. Resolved/advanced by this milestone: **B-15**
(`fromFile:` encoding-error wrap landed at E05; E09-C01's Zinc-arm pins the
reconciliation live) · **B-16** method-half landed (phi `2552925`); its
product-side completeness-check arm stays an M5 catalog candidate · **B-26**
validated by the CI leg (guarded locator + image-dir fallback confirmed the CI
workhorse). Carried unchanged to their named milestones: B-14 (Symbol/String
asymmetry — E09 re-confirmed `#X = 'X'` holds in-image; M5) · B-17 (the debris
recurrence above; next infra chunk) · B-18/B-19 (owner spec-erratum pass) · B-20
(next `PCKKitTest`-touching chunk) · B-21 (double registry build; M5 or next
`PGRGate` chunk) · B-22 (append-splice authoring convention still precedent, not
law — used again at E09-C06; owner ruling pass) · B-23/B-25 (wrapper hardening,
M5) · B-24 (structured STON report, E15/M5). Owner-pending errata noted for the
next spec pass: the ch. 9 Zinc-arm note (E09-C01) and the two E09 chunks-index
advisories (guide-1 not-choking untested until M4; the harness's
one-pre-header-definition-per-fence constraint, now a documented limit after
D-77). **E10's entry check (M2) can pass; per the owner's standing notice,
work stops here for the owner's M1 milestone gate.**

**E10: ACCEPTED 2026-07-27 — M2's first epic (the layer-map check).** All six
chunks accepted; the exit checkpoint (`plan/04-epics/E10-layer-map-check/chunks.md`
§checkpoint) is met on head `b994a3e`, three legs: (1) **named suite** — the four
E10 suites `PCKLayerMapTest` (17) · `PCKLayerMapFixtureTest` (4) ·
`PCKLayerMapCheckTest` (9) · `PCKKitTest` (+5 new, 1 amended) within a **230/230**
sweep, 0 failures/0 errors, discharging **P-LAYERMAP-TOTAL** (config arms +
advisory arm), **P-FINDING-PRECISE**, **P-CAT-FIXTURES (arch)** (the fires/silent
fixture pair), and the **D-79/D-79.a** semantics (the four C05 witnesses); (2)
**self-hosted gate leg** — `./guardrails.sh guardrails.ston` → exit 0 with its
**10 M1 registrations unchanged** (E10 adds no entry to the framework's own
artifact — that is E11; this leg proves E10 did not disturb the self-hosted M1
form); (3) **CI leg** — CI run **30284092618** `completed success` on `b994a3e`.
Each leg re-run by the orchestrator independently, never on report.

**Interface digest — frozen at acceptance (amendments need a decision-sheet
entry):** the **`#layerMap` key format** (config-author surface) — the three-key
sub-map `#layers` / `#allowed` / `#unlayered` with D-79/D-79.a semantics
(self-reference implicit, allowed pairs directed one-way non-transitive, internal
client→client only, layers + `#unlayered` total over the production role via the
D-35 completeness law) — **E11 consumes this to self-host the map**; and the
registration **`architecture/PCKLayerMapCheck`** (the kit's one shipped
architecture check, resolved from an `#architectureChecks` entry naming
`PCKLayerMapCheck` with a present `#layerMap`; absent map or unloaded layer package
→ the missing sentinel of that name). Internal/unfrozen: `PCKLayerMap`'s selectors
and `PCKLayerMapCheck class>>layerMap:` (the engine validates only `PGRCheck`'s E02
contract); the walk's reflective spellings (`referencedClasses`, `instanceSide`
P5-confirmed); `PCKLayerMapFixture`. **Amended accepted surface:** exactly one
accepted test, in E10-C06 —
`PCKKitTest>>testLayerMapKeyProducesNoRegistrationsAndNoError` (scheduled ground:
the `#layerMap` consumer E06 deferred to E10); the enumeration was scripted over
committed `src/` and the generic `packages:` arch path stayed byte-identical,
reviewer-verified.

Epic history: C01/C02/C03/C05/C06 landed on first review; **E10-C04's two prior
implementer spawns died to the environment** — an infra stream-watchdog stall,
then a false foreign-dirt stop-and-report on a stale session-start git snapshot
(the tree was clean; precheck passed) — neither a fix round-trip; C04 landed green
on the third spawn (the integrator now prefixes every implementer brief with an
authoritative live pick-time tree-state note). **Q-37 filed** (E10-C04): §4.2 step
4 vs the frozen `PGRVerdict` — the `#unlayered` advisory can attach only to green
verdicts (no `redFindings:advisories:` constructor); the conservative
advisory-on-green arm is implemented and green, owner-pending, non-blocking.
E10-C06 carried two sound deviations (reviewer-verified): the uncovering-map test
names `'P-Two'` not `'P-One'` (the frozen C02 fault-order makes the single-package
case unreachable), and a `spec check packages isNil` assertion de-vacuifies the
construction test (`PCKLayerMapCheck` inherits `packages:` from `PGRCheck`, so the
generic path would pass every other assertion vacuously). **Not a milestone
boundary** (E10 is M2's first epic) — no formal mining pass; **E11's entry check
can pass.** Per the owner's E10 release notice, work stops here to report for epic
acceptance.

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

**E09 rows (E09-C01–E09-C06) added by the seventh Prompt-4 run (2026-07-26;
Gate 4 pending; epic-qualified IDs per D-73 — the counter is local to E09).**
E09 is the M1 join epic: all three dependencies (E05 · E07 · E08) were
`accepted` with frozen digests at cut time, and nothing runs `[P]` beside it.
E09 `accepted` when all six rows are `accepted` and the exit checkpoint in
`plan/04-epics/E09-self-host-m1-freeze/chunks.md` is filled in (the 21 new
E09 tests — `PGRArchSelfTest` 6 · `PGRSurfaceConformanceTest` 3 ·
`PGRToySweepExemptionTest` 3 · `PCKArtifactBlockM1FormTest` 3 ·
`PGRQuickstartSampleHarnessTest` 4 · `PGRQuickstartSamplesTest` 2 — green
with every previously accepted suite, ≥195 run, membership + floor · the
self-hosted leg `./guardrails.sh guardrails.ston` exit 0 with 10 green
registrations · D-67 precheck discipline with `E09-C##:`-prefixed commits ·
CI leg, on one head commit) — at which point **milestone M1 closes** (the
roadmap §1 checkpoint is exactly that set), the formal M1 mining pass runs
over E02–E09, and E10's entry check (M2) can pass. Per the frozen roadmap:
**no new frozen exports** — E09 delivers the machine witness over the
already-frozen surfaces (P-SURFACE-CONFORMS, red-test-enforced from here)
plus the committed M1 artifact form (grows only by scheduled epic edits;
witnessed by `PCKArtifactBlockM1FormTest`). **Amended accepted surface:
none** — every deliverable is a new file (five class files +
`guardrails.ston`) or C06's scheduled extension of C05's own file; zero
accepted test methods change. One forced move rides this cut, recorded
veto-open in the chunk index: the two classless tests-role stub packages
(`Phi-Guardrails-Tests-Toy`, `Phi-Coding-Kit-Tests-Architecture`) each gain
one real pin-test class in E09-C03 — without them the frozen E07 missing
semantics make R-38's self-hosted exit 0 unsatisfiable. Also recorded
veto-open: the P-DETERMINISTIC Zinc-arm allowlist reconciliation with
accepted B-15 ground, the D-59 test-home closure (`-Tests-Gate`), and the
CI-stays-step-1 reading (the two-step upgrade is E15's frozen row). [P]
eligibility (disjoint manifests): E09-C01 E09-C02 E09-C03 E09-C04;
orchestrator runs them serialized — the COMMIT preconditions (clean tree at
spawn) and the shared `.build/work` verify image make shared-tree
concurrency unsound; disjointness stands as the reviewer's cross-check.
C05→C06 strictly serial (shared `PGRQuickstartSamplesTest.class.st`; C05
consumes C04's harness).

**E10 rows (E10-C01–E10-C06) added by the eighth Prompt-4 run (2026-07-26;
Gate 4 pending; epic-qualified IDs per D-73 — the counter is local to E10).**
First M2 epic; **M1 closed (D-78)**. Entry check: roadmap approved and frozen
(D-62); E10's roadmap dependencies **E06** (frozen @ `0c4fb7b`) and **E02**
(frozen @ `5f2fc60`) are both `accepted` with frozen digests. E10 builds against
**D-79 + D-79.a**, never ch. 4 §4.1's original prose (the M1-gate audit's
fabricated-intent finding): the layer map judges internal client→client
dependencies only (total over the production role via the D-35 completeness
law), self-references implicit, allowed pairs directed one-way non-transitive;
external references are B-02's separate ground, out of this epic by ruling.
**Self-hosting the layer map is E11's, not E10's** — the M1 artifact form froze
at E09; E10 delivers the mechanism and proves it on a scratch mini-fixture, and
its exit checkpoint's self-hosted leg asserts the 10 M1 registrations are
**unchanged** (E10 adds none). E10 `accepted` when all six rows are `accepted`
and the exit checkpoint in `plan/04-epics/E10-layer-map-check/chunks.md` is
filled in (the named suites — `PCKLayerMapTest` 17 · `PCKLayerMapFixtureTest` 4 ·
`PCKLayerMapCheckTest` 9 · `PCKKitTest` +5/1-amended — green with every
previously accepted suite, ≥230 run (195 + 35 net new), membership + floor · the
self-hosted gate regression leg exit 0 with 10 registrations · CI leg, on one
head commit) — at
which point E10's interface digest (the `#layerMap` key format + the
`architecture/PCKLayerMapCheck` registration, tabled in that file) freezes and
**E11's entry check can pass**. **Amended accepted surface: exactly one test**,
in E10-C06 (scheduled ground — the `#layerMap` consumer E06 deferred to E10):
`PCKKitTest>>testLayerMapKeyProducesNoRegistrationsAndNoError`, enumerated by
script (E10-C06's amendment table; no other consumer). **One question filed**
(E10-C04): §4.2's every-report advisory vs the frozen `PGRVerdict` having no
red+advisories constructor — implemented advisory-on-green-only, owner to rule;
no frozen surface amended. `[P]` eligibility (disjoint manifests): E10-C01/C02
(the `PCKLayerMap` file pair) run beside E10-C03 (the fixture file pair);
orchestrator runs picks serialized — the COMMIT preconditions (clean tree at
spawn) and the shared `.build/work` verify image make shared-tree concurrency
unsound; disjointness stands as the reviewer's cross-check. C04 consumes
C01+C02+C03; C05 extends C04's test file (and uses C02's
`fromLayerMap:productionPackages:`); C06 consumes C02+C04 — strictly serial.

**E12 rows (E12-C01–E12-C05) added by the tenth committed Prompt-4 run (2026-07-28;
Gate 4 pending; epic-qualified IDs per D-73 — the counter is local to E12).** Entry
check: roadmap approved and frozen (D-62); **M2 closed (D-82)** on head `786bacf`;
E12's four roadmap dependencies — **E03** (@ `e26fc9c`) · **E06** (@ `0c4fb7b`) ·
**E07** (@ `f569549`) · **E10** (@ `b994a3e`) — all `accepted` with frozen digests.
M4's opening epic (absorbs the former E13 init tool, D-61.d). The **D-82/Q-39
cut-time probe obligation is discharged**: every skeleton-named reflective predicate
and frozen-surface spelling probed live against the work image at `bca7c9b` or
digest-checked — transcripts in `plan/04-epics/E12-toy-client-init-tool/probes.md`
(part of the epic's validation record). E12 `accepted` when all five rows are
`accepted` and the exit checkpoint in
`plan/04-epics/E12-toy-client-init-tool/chunks.md` is filled in — six legs: the ≥263
named-suite sweep (250 at cut + 13 net new swept: `PGRToyBaselineTest` 2 ·
`PGRToyPlantWitnessTest` 5 · `PGRToyArtifactTest` 2 · `PGRConfigurationDraftTest` 4 ·
the amended `PGRSurfaceConformanceTest` net 0) · the self-hosted gate regression leg
exit 0 with **12 registrations unchanged** (E12 adds nothing to the framework's own
artifact; the exempt guard holds over the committed-red toy) · the committed-red eval
arm (the toy's own six registrations all non-green — orchestrator-run, deliberately
not a committed test: E14's ground is not pre-built) · the unswept-pair eval arm ·
D-67 precheck discipline with `E12-C##:` prefixes · CI leg **step 1 only**
(smalltalkci; the two-step upgrade is E15's scheduled edit — D-82 carry-forward 1) —
at which point E12's interface digest freezes (tabled in that file:
`BaselineOfToy class>>guardrailsSTON` + the six-registration shape, the six-plant
inventory at its named homes, `ToyNoIsNilIfFalseRule`, the groupless `BaselineOfToy`,
`PGRConfigurationDraft class>>draftFor:` on the now code-bearing config-author
surface) and **E14's entry check can pass** (E14 also needs E11 — accepted — and
E08 — accepted). **Amended accepted surface: exactly one test file**, in E12-C05
(scheduled ground, two written schedules: the accepted test's own class/method
comments naming E12's `draftFor:` cut, and the D-82 §0.3 erratum's
next-test-touching-chunk line): `PGRSurfaceConformanceTest` — enumerated by script
over `git ls-files 'src/**/*.st'` (110 files scanned; the manifest's only consumer is
the amended file itself; zero other accepted files reference the manifest or
`PGRConfigurationDraft` — probes.md P29). [P] eligibility (disjoint manifests):
E12-C01 ∥ E12-C02, then E12-C03 ∥ E12-C04 ∥ E12-C05; the orchestrator runs all picks
serialized — the COMMIT preconditions (clean tree at spawn) and the shared
`.build/work` verify image make shared-tree concurrency unsound; disjointness stands
as the reviewer's cross-check. Listed serial pick order C01→C02→C03→C04→C05 (verify
floors stated against it).

**E11 rows (E11-C01–E11-C05) added by the ninth committed Prompt-4 run
(2026-07-27; Gate 4 pending; epic-qualified IDs per D-73 — the counter is local
to E11).** Entry check: roadmap approved and frozen (D-62, M2 re-confirmed at
D-78); E11's one roadmap dependency **E10** is `accepted` with its digest frozen
(@ `b994a3e`: the `#layerMap` key format + `architecture/PCKLayerMapCheck`).
This is the **re-cut from D-81** — Q-38's five-keyword option-(a) cut was
owner-VETOED and retired uncommitted to `.build/superseded/`; the fresh cut
builds the ruled shape: the read-only SDK environment view (`PGRKitEnvironment`,
four named readers, built by the core, D-53.5 upheld) landing ADDITIVELY as
`registrationsFrom:environment:` beside the frozen three-argument kit contract
(engine `respondsTo:` probe with fallback; zero accepted consumers change; the
`PGRKit` skeleton stays untouched — B-28 (4)). E11 `accepted` when all five rows
are `accepted` and the exit checkpoint in
`plan/04-epics/E11-src-inventory-full-artifact/chunks.md` is filled in — and
**E11's acceptance IS the M2 milestone boundary** (roadmap M2 exit): both
instruments green over the COMPLETED §7.5 artifact — the ≥250 named-suite sweep
(230 at cut + 20 net new: `PGRKitEnvironmentTest` 6 · `PGRRegistryTest` +3 ·
`PCKSrcInventoryCheckTest` 6 · `PCKKitTest` +5 · the 3 amended pins net 0) **and**
the self-hosted gate at **12 registrations** `GATE: GREEN` · D-67 precheck
discipline with `E11-C##:`-prefixed commits · CI leg, on one head commit — at
which point E11's interface digest freezes (tabled in that file:
`PGRKitEnvironment` + its growth path, the optional probed kit-protocol message,
`architecture/PCKSrcInventoryCheck`, the completed artifact form) and the epic
ends at the owner's milestone gate (M2 mining pass at close per operating rule
9). Properties owed and discharged here: **P-NO-DEAD-SRC** (all three ch.-9-named
legs) and **P-SELF-HOSTED (full form)**. **Amended accepted surface: exactly one
test file**, in E11-C05 (scheduled ground — the pin test's own class comment
schedules it): `PCKArtifactBlockM1FormTest`, enumerated by script over the
committed code + product-doc + infra scope (`git ls-files 'src/**/*.st'
'docs/**/*.md' 'tools/*' 'guardrails.sh' '.github/workflows/*'
'.smalltalk.ston'`, 116 files scanned; validator re-confirmed over the full
237-file tree; every other `guardrails.ston` reference is a scratch/decoy
fixture, comment, or client-sample guide; zero committed files assert the
10-registration count — table inlined in C05). Roadmap-budgeted risk
carried in C05: a first-run genuine violation is fixed or filed, the map never
weakened. [P] eligibility (disjoint manifests): E11-C01 E11-C03; orchestrator
runs them serialized — the COMMIT preconditions (clean tree at spawn) and the
shared `.build/work` verify image make shared-tree concurrency unsound;
disjointness stands as the reviewer's cross-check. C02→C04→C05 strictly serial
(C02 consumes C01's view; C04 consumes C01+C03 and cedes no file; C05 consumes
both doors live and the artifact).
