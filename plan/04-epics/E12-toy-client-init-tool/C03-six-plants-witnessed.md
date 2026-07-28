# E12-C03 · The six plants, committed red, with check-level witnesses  [depends: E12-C01, E12-C02 · parallel: no]

GOAL      Commit the toy's six planted violations as real, current code (three lint
plants in `Toy-Core`, one forbidden UI→Persistence reference in `Toy-UI`, one failing
test and one `skip:` test in `Toy-Tests`) and machine-witness each plant live at
**check level** in the swept `Phi-Guardrails-Tests-Toy` — so committed-red is a
machine fact from this chunk on, without pre-building E14's gate-level demo.

TRACE     R-32 (planted violations to be caught) · R-44 (the behavioral plants:
failing + skip) · R-43 (check half — the architecture plant the layer-map check
catches) · spec ch. 8 §8.2 (the plant table, verbatim source of all six) · D-26 (toy
committed red; plants are real current code; exempt-role in the framework's artifact
is the guard) · D-57 (the sweep-exemption shape that keeps verify green) · R-37/P1
(a plant nothing checks is a hope — hence the witnesses) · ch. 2 §2.3 (lint reads
production-role packages only — witness targeting).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**The plant table (spec ch. 8 §8.2, condensed — the complete set, six):**

| Home | Plant | Caught by (registration in the toy's artifact, E12-C04) |
|---|---|---|
| `Toy-Core` | one `isNil ifTrue:` | `lint/PCKNoIsNilIfTrueRule` |
| `Toy-Core` | one `Transcript show:` | `lint/ReCodeCruftLeftInMethodsRule` |
| `Toy-Core` | one `isNil ifFalse:` | `lint/ToyNoIsNilIfFalseRule` |
| `Toy-UI` | one direct reference to a `Toy-Persistence` class | `architecture/PCKLayerMapCheck` |
| `Toy-Tests` | one failing test | `behavioral/Toy-Tests` |
| `Toy-Tests` | one `skip:` test | `behavioral/PCKNoSkippedTestsMetaRule` |

**D-26 (the committed-red law, condensed):** the plants are **real, current code** —
what a real adopter's first gate run looks like, readable in place. The framework's own
gate never sweeps them: the toy is exempt-role by declaration in the framework's
committed artifact (`#exempt : [ 'fixtures', 'toy' ]` + `#exemptNamePatterns` `'Toy-.*'`
— accepted E09 ground, untouched by this epic). The verify sweep never sees them:
`Toy-Tests` matches neither tests-family pattern (D-57, pinned by the accepted
`PGRToySweepExemptionTest`). Plant methods carry a short comment naming the plant
(constitution: bad fixtures and planted violations are the sanctioned exception —
they exist to be caught, R-37/D-26 — and the comment states exactly that constraint;
the accepted `PCKCruftBadFixture` precedent).

**Where the plants go — exact host classes (E12-C01's committed contract):**
- `ToyOrder` (package `Toy-Core`; instVar `items`, an `OrderedCollection` of Numbers;
  existing selectors `empty`(class), `addItemPriced:`, `itemCount`, `total`). Add
  **three** methods, one plant each, in the cut-time-probed caught shapes
  (probes.md P2/P13 and the accepted `PCKLintBadFixture`/`PCKCruftBadFixture` forms):
  - `totalOrZero` — body shape: `items isNil ifTrue: [ ^ 0 ]. ^ self total`
    (the `isNil ifTrue:` plant).
  - `logTotal` — body shape: `Transcript show: self total printString. ^ self total`
    (the `Transcript show:` plant).
  - `itemCountOrZero` — body shape: `items isNil ifFalse: [ ^ items size ]. ^ 0`
    (the `isNil ifFalse:` plant).
- `ToyOrderView` (package `Toy-UI`; instVar `order`; existing selectors `on:`(class),
  `render`). Add **one** method:
  - `storeSnapshot` — body shape: `^ ToyOrderStore empty` (the direct
    `Toy-Persistence` reference; ui→persistence is not among the toy map's allowed
    pairs `ui→domain`, `domain→persistence`, so the walk reds it).
- **create** `ToyOrderTest` (package `Toy-Tests`, superclass `TestCase`) — the toy's
  own suite plants, exactly two methods (the accepted `PCKFailingFixtureTest`/
  `PCKSkippingFixtureTest` shapes):
  - `testTotalIsFortyTwo` — a plainly failing assertion (e.g.
    `self assert: ToyOrder empty total equals: 42` — an empty order totals 0), the
    planted failing test.
  - `testSkippedOnPurpose` — `self skip: 'planted skip'`.

**The witnesses — why and at what level (P1 applied to the epic's headline
deliverable):** "all six plants committed red" must be a machine-checked fact, not
prose. The witnesses live in the **swept** `Phi-Guardrails-Tests-Toy` and assert at
**check/checker level** — never by running a gate over the toy's configuration:
gate-level red→fixed→green over the toy artifact is E14's `ToyDemoTest` (frozen
roadmap), and this cut must not pre-build it. Levels used:

1. **Lint witnesses** — construct the frozen kit check directly:
   `PCKLintRuleCheck rule: <RuleClass> packages: #('Toy-Core')` (frozen E06 surface,
   re-probed P18), send `run` → a `PGRVerdict` (read via the frozen caller surface:
   `isGreen`, `findings`; each finding answers `target` — the critiqued entity printed
   precisely as `'Class>>#selector'` — and `message`; accepted §2.3 mapping). Lint
   targets **production-role packages only** (the accepted D-33 trade), so handing
   `#('Toy-Core')` mirrors the toy artifact's production role exactly.
2. **Architecture witness** — go through the **frozen kit contract** (never the
   internal `layerMap:` constructor):
   `PCKKit registrationsFrom: <block> productionPackages: #('Toy-Core' 'Toy-Persistence' 'Toy-Rules' 'Toy-UI') testsPackages: #('Toy-Tests')`
   where `<block>` is a `Dictionary` with `#kit → 'PCKKit'`,
   `#architectureChecks → #('PCKLayerMapCheck')`, and `#layerMap →` the toy's map
   (sub-map form, frozen E10 config-author surface):
   `#layers → { 'ui' → #('Toy-UI'). 'domain' → #('Toy-Core'). 'persistence' → #('Toy-Persistence') }`,
   `#allowed → #( #('ui' 'domain') #('domain' 'persistence') )`,
   `#unlayered → #('Toy-Rules')`.
   The answered specs (`PGRRegistrationSpec`, frozen E02 vocabulary: readers `name`,
   `kind`, `check`, `missingReason`) contain one named
   `'architecture/PCKLayerMapCheck'`; its `check`'s `run` answers the red verdict.
   Finding shape (accepted E10 ground): target = the referencing method
   (`'ToyOrderView>>#storeSnapshot'`), message names the referenced class and both
   layer names.
3. **Behavioral witnesses** — run the planted suite directly with SUnit and read the
   probed result protocol (probes.md P3): `ToyOrderTest suite run` →
   `failureCount` = 1, `skippedCount` = 1, `errorCount` = 0. (The suite check reds on
   a failing run and the no-skips meta-rule on a skip by the accepted E07 machinery;
   the counts are those checks' raw material — witnessing the counts witnesses the
   plants without re-testing accepted machinery.)

The kit block built in witness 2 also derives `behavioral/` specs (the accepted
four-stage order: lint → architecture → behavioral suites → meta) — the witness
filters by name and never runs those; running `behavioral/Toy-Tests`'s check here
would just re-run the suite witness 3 already runs.

**Termination note (accepted ch. 8 §8.3 argument, applied):** these witnesses are
themselves run by the framework's own gate (behavioral suite over
`Phi-Guardrails-Tests-Toy`) and nested-run the toy's failing suite — nesting
terminates because nothing in `Toy-Tests` drives a gate (the accepted E07
suite-check tests set the nested-red-run precedent).

**Constitution rules that bite here:** plants and bad fixtures are the sanctioned
exception to the idiom bans (`isNil ifTrue:`, `Transcript show:`, skip) — **only** in
`Toy-*` homes, each marked by its comment; no `skip`/`expectedFailures` in
`Phi-Guardrails-Tests-Toy` (tests-role — the witnesses are all green, plain tests);
tests assert behavior; touching any file outside the manifest is a review rejection.

DELIVERABLES

Files (Tonel):
- **modify** `src/Toy-Core/ToyOrder.class.st` (add the three plant methods)
- **modify** `src/Toy-UI/ToyOrderView.class.st` (add `storeSnapshot`)
- **create** `src/Toy-Tests/ToyOrderTest.class.st` (the two suite plants)
- **create** `src/Phi-Guardrails-Tests-Toy/PGRToyPlantWitnessTest.class.st`

LOC budget: target ~140 · ceiling 300.

TESTS FIRST  (`PGRToyPlantWitnessTest`, package `Phi-Guardrails-Tests-Toy`; a helper
building the toy kit block of digest item 2 is shared by the architecture witness)

- `testIsNilIfTruePlantIsCaught` — given
  `PCKLintRuleCheck rule: PCKNoIsNilIfTrueRule packages: #('Toy-Core')`; when `run`;
  then the verdict is not green and exactly one finding's `target` equals
  `'ToyOrder>>#totalOrZero'`.
- `testCodeCruftPlantIsCaught` — same with `ReCodeCruftLeftInMethodsRule`; then not
  green and some finding's `target` equals `'ToyOrder>>#logTotal'`.
- `testToyRulePlantIsCaught` — same with `ToyNoIsNilIfFalseRule`; then not green and
  exactly one finding's `target` equals `'ToyOrder>>#itemCountOrZero'` (the rule's
  own fixture pair lives in `Toy-Tests`, outside this production-scoped run — C02's
  bad fixture must NOT appear here).
- `testForbiddenUiReferenceIsCaught` — given the kit block of digest item 2 handed to
  `PCKKit registrationsFrom:productionPackages:testsPackages:`; when the spec named
  `'architecture/PCKLayerMapCheck'` is detected and its `check` `run`; then the
  verdict is not green and some finding has `target` =
  `'ToyOrderView>>#storeSnapshot'` and a `message` containing `'ToyOrderStore'`.
- `testFailingAndSkipPlantsAreLive` — given `ToyOrderTest suite run`; then
  `failureCount` = 1, `skippedCount` = 1, `errorCount` = 0 (the two behavioral plants
  are live and are exactly the declared two).

Fixtures: the plants this chunk commits (they ARE the fixtures — D-26); C01's classes;
C02's rule.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors — the committed-red discipline's
          proof rides this line: the sweep stays green **with the plants committed**;
          the five `PGRToyPlantWitnessTest` cases listed by name, every previously
          accepted suite green — ≥257 run once E12-C01 is in per the listed serial
          pick order (250 + C01's 2 + these 5); membership + floor, never an exact
          ceiling.
          **Plus the self-hosted regression leg:**
          `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
          → exit 0, **12 registrations unchanged**, `GATE: GREEN` — the framework's
          own gate does not redden on the toy's plants (D-26's exempt-role guard,
          witnessed live).

OUT OF SCOPE
- Running a gate (`PGRGate`/`PGRRegistry`) over any toy configuration, asserting the
  six-verdict report, any fix/green arm, `ensure:` restoration, or a planted-state
  `setUp` guard — all E14 `ToyDemoTest` ground (D-43/§8.3; do not pre-build).
- The toy's artifact text (E12-C04).
- Fixing, weakening, or gating any plant (P6; they exist to be caught).
- Touching `guardrails.ston`, `.smalltalk.ston`, the framework baseline, or any
  accepted test file.

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition:
one commit `E12-C03: the six plants committed red, check-level witnessed`, nothing
uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output (sweep + gate
  leg) · deviations (each one-line justified) · new questions for the decision sheet.
