# E05 · Gate, report, invocation contract — chunk index (M1)

*Produced by Prompt 4 (sixth run, 2026-07-25). Entry check: roadmap approved
and frozen (D-62); E05's dependency E04 is `accepted` in `plan/ledger.md`
(2026-07-25, head `9127e31`) with its specified-but-internal surface tabled in
`plan/04-epics/E04-registry-kit-handoff-conformance/chunks.md` §checkpoint
(`PGRRegistry fromConfiguration:`/`registrations`/`size`; `PGRRegistration
fromSpec:`/`name`/`kind`/`isResolved`/`run` with stamped total verdicts;
kit-raised `PGRConfigurationError` propagating unhandled — changeable only via
decision-sheet entry while E05 is in flight). Transitive ground: E02 frozen at
`5f2fc60`, E03 at `e26fc9c`; E06/E07/E08 all accepted — kit surfaces citable
fact. Owner notes honored: every COMMIT section cites `bash tools/precheck.sh`
(D-66/D-67); IDs are epic-qualified `E05-C##` (D-73); every count assertion is
named-suite membership plus a floor, never an exact ceiling (accepted sweep =
**148** at cut time); the D-63 flush record is consumed, not re-derived
(D-61.b); D-74 is citable ground. **Owner-scheduled ground riding this cut,
placements annotated per D-61.a:** B-15 hardening → E05-C01 (the backlog row's
recorded landing); the E04 validation ADVISORY (kit-raised-error propagation
untested) → E05-C06 (both arms). The roadmap row estimates ~6 chunks; this cut
is 7 — the B-15 rider is the +1.*

| ID | Title | Depends | [P] | LOC est. | Acceptance (one line) |
|---|---|---|---|---|---|
| E05-C01 | B-15 hardening: `fromFile:` encoding wrap + empty exempt-patterns pin | — | yes | ~60 | an undecodable config file signals `PGRConfigurationError`; the `#exemptNamePatterns : [ ]` edge pinned both ways; `PGRConfigurationTest` 38 green, accepted 35 byte-identical |
| E05-C02 | `PGRReport`: the value and its rendering | — | yes | ~150 | frozen readers (`verdicts`/`isClean`/`exitCode`/`blockingVerdicts`/`advisories`) + single-sourced §7.2 rendering seam; `PGRReportTest` (7) green |
| E05-C03 | `PGRGate`: `forConfiguration:`, `onVerdict:`, `run` | E05-C02 | no | ~130 | eager registry, one verdict per registration in order, caller-supplied sink only; `PGRGateTest` (4) green — **P-GATE-COMPLETE · P-STREAM (both) · P-JUDGE-CONVICTS** |
| E05-C04 | Gate run-semantics property tests | E05-C03 | no | ~110 | **P-ERR-IS-RED completes · P-GATE-MISSING gate half · P-GATE-PURE · P-REG-FRESH gate clause**; `PGRGateTest` +4 green, no product code |
| E05-C05 | `runHeadless:`/`runHeadless:on:` — the invocation contract | E05-C04, E05-C01 | no | ~155 | exit codes 0/1/2, top-level handler, streamed report, flush, no default path; `PGRGateTest` +4 green — **P-GATE-HEADLESS · P-EXIT-CODES · P-NO-DEFAULT-PATH · P-SAME-VERDICT** |
| E05-C06 | Escape arms: throwing kit, throwing stream, kit-raised config error | E05-C05 | no | ~115 | **P-NEVER-UNDECIDED** (both arms) + the E04 ADVISORY tested (headless + direct); three `-Tests-Gate` fixtures; `PGRGateTest` +4 green, no product code |
| E05-C07 | `guardrails.sh` — the reference runner | E05-C05 | yes | ~40 | the §7.3 script committed executable at repo root; four shell arms exit exactly 0/1/2/3; verify sweep unchanged |

Total ~760 LOC across 7 chunks (= the sum of the work-order targets; the
frozen roadmap row estimates ~6 chunks — the owner-scheduled B-15 rider adds
E05-C01, annotated above).

**[P] eligibility (disjoint manifests):** E05-C01 (`-Core` +
`PGRConfigurationTest`) · E05-C02 (`PGRReport` + `PGRReportTest`) · E05-C07
(`guardrails.sh` alone, once E05-C05 is accepted). The orchestrator runs them
serialized — the COMMIT preconditions (clean tree at spawn) and the shared
`.build/work` verify image make shared-tree concurrency unsound; disjointness
stands as the reviewer's cross-check. C03–C06 are strictly serial: C03/C04/C05/
C06 share the `PGRGate.class.st`/`PGRGateTest.class.st` file pair (the E03/E04
shape). E05 itself was scheduled `[P]` beside E06/E07/E08 per the frozen
roadmap; all three are already accepted, so this cut runs alone — every E05
manifest is disjoint from every accepted kit-track file.

**Property placements, stated (cross-epic splits recorded so they are
statements, not drift — the E03/E04 precedent):**

- **Discharged in full here:** P-GATE-COMPLETE, P-STREAM (both named tests),
  P-JUDGE-CONVICTS (E05-C03) · P-GATE-PURE (E05-C04) · P-GATE-HEADLESS,
  P-EXIT-CODES, P-NO-DEFAULT-PATH, P-SAME-VERDICT (E05-C05) ·
  P-NEVER-UNDECIDED (E05-C06).
- **P-ERR-IS-RED — completes here** (E05-C04
  `PGRGateTest>>#testRunContinuesAfterErroringCheck`; the registration arm was
  E04-C02's `PGRRegistrationTest>>#testErroringCheckYieldsRed`).
- **P-GATE-MISSING — completes here** (gate half, E05-C04
  `PGRGateTest>>#testMissingRegistrationFailsGate`; the suite half was E07's
  `PCKTestSuiteCheckTest>>#testMissingOnEmptyTestsRole`; the core-half
  machinery was E04-C02's).
- **P-REG-FRESH — completes here** (gate clause, E05-C04
  `PGRGateTest>>#testTwoGatesProduceIndependentReports`; registry +
  mutation-isolation + reflective arms accepted at E04-C05, whose reflective
  sweep over `-Core` **and** `-Gate` now covers the real gate classes on every
  run without amendment — exactly the "same reflective sweep" completion the
  E04 papers recorded).
- **P-CFG-STRICT — gains two additive arms** (E05-C01's encoding and
  empty-pattern tests; the property's named tests stay E03's, untouched).
- **Explicitly not owed here:** P-WRAPPER-GUARD (the CI shell self-test — E15;
  E05-C07's arm 4 verifies the same mapping locally and records the observed
  code) · P-DETERMINISTIC / P-NO-TRANSCRIPT (E09's reflective sweeps; the
  D-55 no-`Transcript` and §7.6 two-file-access constraints bind every E05
  work order now, sweep-tested at E09) · P-SELF-HOSTED and the repo's own
  `guardrails.ston` (E09).

**Amended accepted surface — one chunk, tabled (D-61.a):** E05-C01 modifies
`PGRConfiguration class>>fromFile:` (accepted E03 product; frozen caller
surface) under the owner-scheduled B-15 row. Its work order carries the
scripted consumer enumeration (`grep -rn 'fromFile:' src/` — two accepted
tests, both unaffected, no production caller) and amends **zero** accepted
test methods; every other E05 manifest touches no accepted file. (E05-C01 and
E05-C04/C05/C06 add methods to accepted/new test files additively; additive
extension of a test class is not an amendment — the reviewer diffs accepted
methods for byte-identity.)

## Agent calls recorded (veto-open, D-16 precedent; closing at acceptance unless vetoed)

- **`PGRReport advisories` = concatenation across verdicts (C02):** ch. 7
  §7.2 lists the reader without defining aggregation; the report-level answer
  is every verdict's advisories, verdict order, fresh `Array` per send.
- **Report internal constructor `project:verdicts:` (C02):** the report needs
  the project string for §7.2's header; construction stays engine-internal,
  no frozen surface grows.
- **Rendering split for streaming reuse (C02/C05):** class-side
  `printHeaderProject:count:on:` / `printVerdict:on:` + instance
  `printSummaryOn:` compose `printOn:`, and `runHeadless:on:` streams the same
  three — the §7.2 format keeps exactly one owner. Tests assert substrings,
  never byte-exact renderings (the format is not an API).
- **Green summary-line form (C02):** `GATE: GREEN — 0 blocking of N · exit 0`
  (the §7.2 example shows only the red form).
- **Top-level handler catch set (C05):** `on: Error, Halt do:` — D-39 names
  "a non-`Error` exception" among the escapes; `Halt` is the concrete
  non-`Error` catchable on this image. Resumable notifications are not
  caught: an unhandled `Notification` resumes with nil by default and so
  never "escapes" — the handler narrows to what would actually kill the run.
  Verified spelling recorded by the C05 implementer (P5).
- **Error-line wording (C05):** for `PGRConfigurationError`, the
  `messageText`; otherwise exception class name + `description`; exactly one
  line either way. Tests assert substrings and the line count only.
- **Guarded error-line write (C05/C06):** the handler's own write is wrapped
  `on: Error do:` swallowing — a broken stream still gets its number (the
  D-39 law outranks the line).
- **Fixture residency (C06):** gate-adversarial fixtures live in
  `Phi-Guardrails-Tests-Gate` beside their tests (the E04-C01 residency rule
  applied per package); the E04 scratch cast is reused across the package
  boundary by name inside artifact strings — no new dependency, the work
  image loads both.
- **`--headless` in the committed runner (C07):** one token inserted into
  §7.3's script text — `$PHARO_VM` is quoted as a single word, so the flag
  cannot ride inside the variable; every D-63 probe arm ran this VM with
  `--headless`. The frozen mapping is byte-identical to the spec.
- **⟨verify-in-image⟩ items delegated to implementers with record-in-report
  duty (P5, the E04/E06 precedent):** the Zn encoding-error class and
  binary-write spelling (C01) · the `methods`/`sourceCode` snapshot spellings
  (C04) · the `Error, Halt` ExceptionSet and `Stdio stdout` delegation (C05) ·
  the throwing stream's minimal write-message set (C06) · the observed
  unloadable-image VM exit code (C07).

## Exit checkpoint (closes E05; freezes the gate-caller surface — see below)

E05 is provable by, on one head commit:

1. **Named suite:** `PGRReportTest` (7) + `PGRGateTest` (16) +
   `PGRConfigurationTest` (38 = 35 accepted + 3) — the 26 new E05 tests —
   green under `bash tools/build-image.sh && bash tools/verify.sh`, with
   **every previously accepted suite still green** (148 accepted at cut time
   → floor ≥ 174 run, 0 failures, 0 errors — membership plus floor, never an
   exact ceiling). Named properties discharged by their ch.-9-named tests:
   **P-GATE-COMPLETE · P-STREAM (both) · P-JUDGE-CONVICTS · P-GATE-PURE ·
   P-GATE-HEADLESS · P-EXIT-CODES · P-NO-DEFAULT-PATH · P-SAME-VERDICT ·
   P-NEVER-UNDECIDED** — plus the recorded completions: P-ERR-IS-RED (gate
   arm), P-GATE-MISSING (gate half), P-REG-FRESH (gate clause), and
   P-CFG-STRICT's two additive B-15 arms.
2. **Runner leg:** the four E05-C07 shell arms on the same commit — exit
   exactly 0 / 1 / 2 / 3 — with `guardrails.sh` tracked executable at the
   repo root.
3. **Infra leg:** `bash tools/precheck.sh` green at every chunk pick (D-67
   standing discipline); commits carry D-73 qualified IDs
   (`E05-C##: <title>`).
4. **CI leg:** the committed `.github/workflows/ci.yml` (step 1) green on an
   actual CI run of the same commit — the new tests ride the existing
   smalltalkCI sweep.

**At acceptance (E05's interface digest — the frozen exports the roadmap
assigns this epic; amendments need a decision-sheet entry):**

- **The gate-caller SDK (ch. 0 §0.3, read-only by construction):**
  `PGRGate class>>runHeadless:` · `runHeadless:on:` · `forConfiguration:`;
  instance `onVerdict:` · `run` → `PGRReport`; `PGRReport>>verdicts` ·
  `isClean` · `exitCode` · `blockingVerdicts` · `advisories`. (The verdict/
  finding readers and `PGRConfiguration class>>fromFile:`/`fromString:` were
  frozen at E02/E03 and are unchanged; the report's printed text is
  human-facing and explicitly not an API.)
- **The exit-code contract:** `0` clean · `1` ≥ 1 non-green verdict · `2`
  configuration error or any escaped exception ("the run produced no
  verdict", D-39) — both `runHeadless:` forms answer one of exactly these
  three, always.
- **The reference runner's mapping:** `guardrails.sh <config-path>` exits
  with the image's answer when it is exactly 0, 1, or 2, and **3** otherwise
  (one stderr line naming the unexpected code).
- Internal and unfrozen: `PGRReport project:verdicts:` and the rendering
  seam; `PGRGate`'s instVars; the verdict-line format.

Checkpoint result (filled at acceptance): **GREEN on head `70410b3`
(2026-07-26)**. Leg 1 — `bash tools/build-image.sh && bash tools/verify.sh`:
174 run, 174 passes, 0 failures, 0 errors; named suites exact —
`PGRConfigurationTest` 38 (35 accepted byte-identical + 3) · `PGRReportTest`
7 · `PGRGateTest` 16 — the 26 new E05 tests within the ≥174 floor; all nine
fully-owed properties plus the four recorded completions and P-CFG-STRICT's
two B-15 arms discharged by their named tests. Leg 2 (runner) — the four
shell arms on the same head: 0 · 1 · 2 · **1** — arm 4 per its D-75-amended
expectation (this VM exits 1 on an unloadable image; the wrapper relays it
faithfully — known v1 limitation, hardening at B-23; a genuinely out-of-set
code still maps to 3); `guardrails.sh` tracked executable (100755, blob
`44a1123`). Leg 3 (infra) — `bash tools/precheck.sh` green at every one of
the seven picks; every commit `E05-C##:`-prefixed (D-73). Leg 4 (CI) — run
**30192903522** `completed success` on the same head. Epic history: two fix
round-trips (C01 exact-name matchers + report accounting; C04 purity-test
deletion hole); Q-34 filed from C07's stop-and-report and ruled D-75 option
(a) mid-epic (arm 4 amended @ `f250ad6`); B-21/B-22/B-25 filed from reviews,
B-23/B-24 owner-filed.

## Milestone note

E05's acceptance completes the core track (E01→E02→E03→E04→E05). With E06,
E07, and E08 already accepted, **E09's entry check can pass on all three
prerequisites** — the M1 join epic is the next cut.
