# E07 · Behavioral kind — chunk index (M1)

*Produced by Prompt 4 (fifth run, 2026-07-25). Entry check: roadmap approved and
frozen (D-62); both dependencies accepted in `plan/ledger.md` with digests frozen —
E06 (2026-07-25, head `0c4fb7b`: block schema, registration naming/order, `PCKKit`,
the D-41 enforcement point) and E03 (2026-07-25, head `e26fc9c`: caller surface,
version-2 schema, internal readers). Owner notes honored: D-66/D-67 — every COMMIT
section cites `bash tools/precheck.sh`; **D-73 — this cut uses epic-qualified IDs
`E07-C01`…`E07-C06`** (ledger rows, commit messages, cross-references; filenames stay
`C##-<slug>.md`); every count assertion is named-suite membership plus a floor, never
an exact ceiling (E04/E05/E08 run `[P]` beside this cut). **Package fence:** this
epic's ground is `Phi-Coding-Kit-Behavioral` · `Phi-Coding-Kit-Fixtures-Behavioral` ·
`Phi-Coding-Kit-Tests-Behavioral` plus the `PCKKit` stanza/dispatch touch
(`src/Phi-Coding-Kit/PCKKit.class.st`) and `PCKKitTest.class.st` in
`-Tests-Rules` — the latter by the frozen E06 ruling "E07 extends the class in
place". Nothing in this cut touches `Phi-Coding-Kit-Rules` or any other
`-Tests-Rules` file (E08's footprint this round, including the D-72 trait-lint
amendment chunk — owner-assigned there, explicitly not E07's).*

| ID | Title | Depends | [P] | LOC est. | Acceptance (one line) |
|---|---|---|---|---|---|
| E07-C01 | The behavioral fixtures family | — | no | ~125 | `BaselineOfPCKFixture` (empty `production` group, D-25.a) + four fixture classes land in the unswept fixtures package; `PCKBehavioralFixturesTest` (5) pins the baseline facts, the D-57 unswept guarantee, and the planted shapes |
| E07-C02 | `PCKSuiteRunCache` | E07-C01 | no | ~105 | one public message `resultsForPackage:` — lazy per-package run, identical result on re-pull, fresh per instance; shared class-side `testClassesIn:` filter; `PCKSuiteRunCacheTest` (3) green |
| E07-C03 | `PCKTestSuiteCheck` | E07-C02 | no | ~115 | `package:cache:`, kind `#behavioral`; red with exact `Class>>#selector` findings on the failing fixture package, green on a clean package, missing on a zero-test-class package; `PCKTestSuiteCheckTest` (3) green (behavioral fixture pair 1, R-37) |
| E07-C04 | `PCKNoSkippedTestsMetaRule` | E07-C03 | no | ~115 | `packages:cache:`, ruled rationale carried and emitted; fires on the skip and the expected failure (warm cache and in isolation — D-36), silent on a clean package; `PCKNoSkippedTestsMetaRuleTest` (3) green incl. **P-GATE-SKIP** (both named tests) |
| E07-C05 | `PCKKit`: behavioral derivation and the run cache | E07-C04 | no | ~150 | one suite registration per tests-role package or the `behavioral/tests-role` sentinel; one run-scoped cache per call; own-meta-rule special case; four-stage order — `PCKKitTest` +4 (incl. **P-SUITES-BEFORE-META**) and `PCKTestSuiteCheckTest` +1 (**P-GATE-MISSING**, suite half) green with the 8 enumerated E06-test amendments |
| E07-C06 | Stanza completion and P-STANZA-VALID | E07-C05 | no | ~70 | `recommendedBlock` gains the `#metaRules` line (complete M1 set); stanza parses, registers to exactly 4 resolved specs, every check conforms; `PCKKitTest` +1 (**P-STANZA-VALID**) with the 2 stanza pins amended |

Total ~680 LOC across 6 chunks (= the sum of the work-order targets); the frozen
roadmap row estimated ~6 — holds. **No `[P]` anywhere, deliberately:** the chain is
strictly linear — C02 runs C01's fixtures, C03 pulls C02's cache, C04's full-run test
warms the cache through C03's check, C05 wires C03/C04 into the kit, C06 completes
what C05 dispatches; and C05/C06 share the same two class files. Structural
disjointness, the `[P]` precondition, is absent (the E03 note's shape, not the
E02/E06 one).

## Agent calls recorded (veto-open, closing on the D-16 precedent at acceptance)

- **Constructor spellings** `PCKTestSuiteCheck class>>package:cache:` and
  `PCKNoSkippedTestsMetaRule class>>packages:cache:` — the kit-custom wiring §5.4
  leaves to a kit's own classes (D-60); both also fill the inherited skeleton
  storage (`setPackages:`) so the generic `packages` reader stays truthful. Internal
  readers `package` / `cache` witness C05's wiring tests.
- **`testClassesIn:` lives class-side on `PCKSuiteRunCache`** — the §5.2 filter
  decided once for both readers (runner and missing decision) while the cache's
  *instance* protocol stays the frozen one message (D-36/roadmap export). Answered
  sorted by class name (deterministic — `definedClasses` order is not guaranteed).
- **Green/silent-arm subject = `'Phi-Guardrails-Tests-SDK'`** — §5.5's "green over
  the clean fixture class" letter bent on record: the check's unit is a package, the
  one frozen fixtures package must contain the red and skipping classes, and adding
  a package would edit the frozen E01 baseline (decision-sheet-only).
  `PCKPassingFixtureTest` keeps the clean-class role inside the red package: the red
  arms assert passes contribute no findings (precision).
- **Fixture names** `PCKPassingFixtureTest` · `PCKFailingFixtureTest` ·
  `PCKSkippingFixtureTest` · `PCKAbstractFixtureTest`; `BaselineOfPCKFixture` group
  names `'production'` (empty) / `'tests'`. The abstract class carries a would-fail
  test method so a broken `isAbstract` filter is a red count, not a silent pass.
- **Scratch shape = baseline introspection, never `PGRConfiguration`:** kit test
  code must not reference `-Core` classes — P-SDK-EDGE's reflective law (ch. 9)
  covers every `Phi-Coding-Kit*` package, tests included; the tests-role list is
  derived via the D-25.a spellings from `BaselineOfPCKFixture`.
- **Own-meta-rule detection by class identity** (`resolved == 
  PCKNoSkippedTestsMetaRule`) in the `#metaRules` loop — the kit special-cases
  exactly the classes it owns (§5.4); clients keep the generic promised-constructor
  path and reach no cache.
- **The eight E06-test amendments are scheduled ground, enumerated per test in
  E07-C05** — the E06 exit checkpoint froze the order law already naming this
  insertion ("lint → architecture → (behavioral suites, E07) → meta-rules"), and
  C18 recorded the stanza completion as E07's; no other accepted test may change.
- **P-STANZA-VALID's conform arm asserted directly at the kit boundary** (E07-C06):
  E04's engine validation is not accepted ground this round; the property's ch. 9
  letter (resolves, registers, conforms) is satisfiable — and asserted — without it.
- **Missing-reason and sentinel wording:** the literal registration name
  `behavioral/tests-role` is normative (ch. 1 §1.5); reason texts name the package
  or the empty expansion but their wording is human-facing, not an API.
- **⟨verify-in-image⟩ items delegated to implementers** with record-in-report duty
  (P5): the suite-aggregation spelling (E07-C02), the failure/error element
  selector accessor (E07-C03).

## Exit checkpoint (freezes E07's interfaces)

E07 is provable by, on one head commit:

1. **Named suite:** the four `Phi-Coding-Kit-Tests-Behavioral` test classes —
   `PCKBehavioralFixturesTest` (5) · `PCKSuiteRunCacheTest` (3) ·
   `PCKTestSuiteCheckTest` (4) · `PCKNoSkippedTestsMetaRuleTest` (3) — plus
   `PCKKitTest` at 18 (13 accepted E06 methods — 9 of them ending in amended
   form: 8 by C05, with the stanza pair completed by C06 — + 5 E07 methods): **20 new E07 tests** green under `bash tools/build-image.sh &&
   bash tools/verify.sh`, with every previously accepted suite still green (≥108
   run, 0 failures, 0 errors — membership plus floor; accepted parallel-track
   E04/E05/E08 suites add to the count). Properties discharged by their
   ch.-9-named tests: **P-GATE-SKIP**
   (`PCKNoSkippedTestsMetaRuleTest>>#testFiresOnSkipAndExpectedFailure` +
   `>>#testFiresInIsolationWithoutPriorSuiteRuns`) · **P-SUITES-BEFORE-META**
   (`PCKKitTest>>#testSuiteRegistrationsPrecedeMetaRules`) · **P-GATE-MISSING,
   suite half** (`PCKTestSuiteCheckTest>>#testMissingOnEmptyTestsRole`; the gate
   half is E05's) · **P-STANZA-VALID**
   (`PCKKitTest>>#testRecommendedBlockParsesAndConforms`) · **P-CAT-FIXTURES
   (behavioral)** — the two R-37 pairs (suite check: red/green; meta-rule:
   fires/silent).
2. **Infra leg:** `bash tools/precheck.sh` green at every chunk pick (D-67
   standing discipline); commits carry epic-qualified IDs (D-73).
3. **CI leg:** the committed `.github/workflows/ci.yml` (step 1) green on an
   actual CI run of the same commit — the new tests ride the existing smalltalkCI
   sweep; the fixtures package stays outside it (witnessed by
   `testFixturesPackageIsUnswept`).

**Frozen at acceptance (E07's interface digest — later epics build on these;
amendments need a decision-sheet entry):**

- **Behavioral registration naming:** derived suites `behavioral/<package name>`
  (one per tests-role package, handed order); the empty-expansion sentinel
  `behavioral/tests-role` (missing, kind `#behavioral`); meta-rules
  `behavioral/<Class>` (E06's naming, now exercised). Derivation is unconditional —
  no block key exists or may be added without a schema ruling.
- **The completed order law:** lint → architecture → behavioral suites →
  meta-rules, in-key/handed order preserved (the E06 freeze, completed).
- **`PCKSuiteRunCache`'s one-message instance protocol** `resultsForPackage:` —
  internal but load-bearing for M5 meta-rules (D-36; `allResults` stays deleted);
  one cache per `registrationsFrom:` call, never shared across calls.
- **The kit-side wiring spellings:** `PCKTestSuiteCheck class>>package:cache:` ·
  `PCKNoSkippedTestsMetaRule class>>packages:cache:` (kit-internal; the promised
  one-argument `packages:` remains the client path and reaches no cache).
- **`PCKKit class>>recommendedBlock`, complete M1 form:** three keys — `#kit`,
  `#lintRules` (the two catalog rules), `#metaRules`
  (`'PCKNoSkippedTestsMetaRule'`).

Checkpoint result (filled at acceptance, 2026-07-25): **PASS — all three legs
green on head `f569549`.** Leg 1: orchestrator-run
`bash tools/build-image.sh && bash tools/verify.sh` → exit 0, **144 run, 144
passes, 0 failures, 0 errors** — the 20 new E07 tests
(`PCKBehavioralFixturesTest` 5 · `PCKSuiteRunCacheTest` 3 ·
`PCKTestSuiteCheckTest` 4 · `PCKNoSkippedTestsMetaRuleTest` 3 · `PCKKitTest`
+5, with the 9 scheduled amendments in final form) listed by name with every
previously accepted suite; the four fixture classes appear in no test-run line
(sweep exemption held). Properties discharged: P-GATE-SKIP (both named tests) ·
P-SUITES-BEFORE-META · P-GATE-MISSING suite half (gate half → E05) ·
P-STANZA-VALID · P-CAT-FIXTURES (behavioral — both R-37 pairs). Leg 2:
`tools/precheck.sh` green at every pick (`c962f6c` · `6f9eea9` · `64b711f` ·
`51c6af7` · `b8a0317` · `f528a23`); all six commits carry D-73 `E07-C##:` IDs.
Leg 3: CI run **30181950983** `completed success` on `f569549`. No fix
round-trips this epic; one implementer-session stall (E07-C03, post-commit —
artifact unaffected, report recovered). The C05 amendment-scope law held under
a deterministic check: the five untouched `PCKKitTest` methods byte-identical
across the epic.

## Addendum — validation record and post-PASS punch list (2026-07-25)

Two validation rounds (fresh validator each round, per the exit criteria):

1. **Round 1: REJECT** (1 BLOCKING + 2 MINOR + 1 ADVISORY) — the C05 amendment
   table enumerated 7 of the 8 accepted `PCKKitTest` methods the derivation
   reddens, omitting `testUnresolvedLintRuleAnswersMissingSpec` (empty
   tests-role call, "size 1" assertion) and wedging a conforming implementer.
   Remediated in-session: the eighth amendment row added (first-spec assertions
   stand; the `behavioral/tests-role` sentinel appended), the 8+5=13 accounting
   stated in C05, and every count site (C05, this index, the ledger) corrected;
   the round's MINORs (the five-not-six fixture-method arithmetic in C02/C03)
   swept in the same batch.
2. **Round 2: PASS** (0 BLOCKING · 2 MINOR · 2 ADVISORY) — report on file:
   `plan/validation/04-E07-report.md` (the gate's artifact). Punch list applied
   the same day, one batch, no re-validation per the validation rules: C05's
   VERIFY parenthetical "(7 of them in amended form)" → 8; the exit-checkpoint
   parenthetical restated precisely (9 accepted methods end amended: 8 by C05,
   the stanza pair completed by C06). The advisories (the closing chunk's
   checkpoint pointer; the two recorded §5.5 letter-bends) stand as recorded —
   the agent-call list above is their veto surface.
