# E07-C01 · The behavioral fixtures family      [E07 · depends: — · parallel: no]

GOAL      `Phi-Coding-Kit-Fixtures-Behavioral` gains `BaselineOfPCKFixture` and the
          four fixture test classes every later E07 chunk runs suites over, with a
          swept pinning suite that proves the baseline facts and the unswept-package
          guarantee.

TRACE     R-37 (behavioral fixture raw material) · spec ch. 5 §5.5 · ch. 9 §9.3 ·
          D-22 · D-25.a (empty-group and introspection facts) · D-57 (the sweep
          regex the package must not match).

## CONTEXT DIGEST

**What exists when this chunk starts:** the package directories
`src/Phi-Coding-Kit-Fixtures-Behavioral/` and `src/Phi-Coding-Kit-Tests-Behavioral/`
exist as stubs (`package.st` only), both already members of the frozen E01 baseline:
`Phi-Coding-Kit-Fixtures-Behavioral` is the sole member of the exempt-role `fixtures`
group, `Phi-Coding-Kit-Tests-Behavioral` a member of the `tests` group, and both load
via the composite `Tests` group — so `bash tools/build-image.sh` loads everything this
chunk adds. **No baseline (`BaselineOfPhiGuardrails`) or `package.st` edit is needed
or allowed** — the frozen E01 naming tree already provides both packages.

**Why the fixtures package exists (ch. 5 §5.5, D-22):** behavioral fixtures are the
one fixture family that must contain red, skipped, and expected-failure **tests** — so
they must live where no swept role and no verify sweep can reach them. The package
name does not full-match the tests-family regex
`(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*` (the verify command's pattern and
smalltalkCI's `#testing` list, D-57; `matchesRegex:` is full-match, D-15), so the
verify sweep never runs these classes. Committed-red code is sanctioned **only** here
(constitution §2: red/skipped fixture tests exist only in `-Fixtures-*`/`-Toy-*`
packages).

**`BaselineOfPCKFixture` (ch. 5 §5.5):** a tiny `BaselineOf` subclass in the fixtures
package (the `BaselineOf*` prefix exception is constitutional, D-11 as amended). It
declares an **empty `production` group** (§1.1 makes `#production` mandatory in any
configuration; an empty group is declared, listed, and expands to nothing — verified,
D-25.a addendum) and the fixture package under a `tests` group. Later chunks derive
the scratch tests-role list from it by introspection — baseline introspection needs no
load (D-25.a). Shape:

```smalltalk
BaselineOfPCKFixture >> baseline: spec
    <baseline>
    spec for: #common do: [
        spec package: 'Phi-Coding-Kit-Fixtures-Behavioral'.
        spec
            group: 'production' with: #();
            group: 'tests' with: #( 'Phi-Coding-Kit-Fixtures-Behavioral' ) ]
```

**The four fixture classes** (all in `Phi-Coding-Kit-Fixtures-Behavioral`; each class
comment states it is a planted fixture, its red state deliberate — R-37/D-26's
planted-violation exemption from the constitution's leftover bans):

- `PCKPassingFixtureTest` (`TestCase` subclass) — one method `testAlwaysPasses`
  (`self assert: true`). Role: the clean class inside the red package — later chunks
  assert that passes produce **no** findings (precision).
- `PCKFailingFixtureTest` (`TestCase` subclass) — `testAlwaysFails`
  (`self assert: false`) and `testAlwaysErrors` (`self error: 'planted error'`).
  Role: the suite check's bad fixture (one failure, one error — §5.2's two finding
  messages).
- `PCKSkippingFixtureTest` (`TestCase` subclass) — `testSkippedOnPurpose`
  (`self skip: 'planted skip'`), `testExpectedlyFailing` (`self assert: false`), and
  instance-side `expectedFailures` answering `#( testExpectedlyFailing )`. Role: the
  meta-rule's bad fixture — exactly one `skip:` call and one `expectedFailures` entry
  (§5.5; skip mechanics `TestCase>>skip:` / `expectedFailures` verified, D-15).
- `PCKAbstractFixtureTest` (`TestCase` subclass) — class-side `isAbstract` answering
  `true`, plus one instance method `testWouldFailIfRun` (`self assert: false`). Role:
  proves the §5.2 test-class filter excludes abstract classes — if a later chunk's
  filter breaks, this class's failing test pollutes the package counts and the pin
  tests go red.

**The resulting package-run facts** (later chunks assert these; SUnit semantics
verified live, D-15): running the three concrete classes' suites as one package gives
a `TestResult` with `failureCount` 1 · `errorCount` 1 · `skippedCount` 1 ·
`expectedDefectCount` 1 · `runCount` 4 — the two semantic traps: a skipped test is
**not** in `runCount`, and an expected failure counts as passed while appearing in
`expectedDefects` (so it is not in `failures`).

**The pinning suite** `PCKBehavioralFixturesTest` (`TestCase` subclass in
`Phi-Coding-Kit-Tests-Behavioral` — swept, green-only; the descriptive fixture-suite
name follows the E03 `PGRScratchFixturesTest` precedent). It runs **no fixture
suite** — it pins shapes and baseline facts only; running is C02's ground.

**Verified spellings this chunk relies on (D-15/D-25.a — cite, do not re-probe):**

```smalltalk
BaselineOfPCKFixture project version              "→ MetacelloVersion"
version groups                                    "specs; each answers name"
version packagesForSpecNamed: 'tests'             "transitive expansion; specs answer name"
"empty group: declared, listed in groups, expands to #()  (D-25.a addendum)"
'Pkg-Name' matchesRegex: '...'                    "full-match semantics"
PackageOrganizer default packageNamed: aName      "the package; >>definedClasses"
cls inheritsFrom: TestCase                        "strict descent test"
```

**Constitution rules that bite here:** red/skipped fixtures only in `-Fixtures-*`
(D-22); no `skip`/`expectedFailures` in any tests-role package — the fixture package
is the sanctioned exception, the pinning suite is not; a test that cannot fail is a
defect; comments state constraints the code cannot show; glossary — these are
*fixtures* for gate-runnable **checks**, and SUnit's "tests" are only ever the
fixture methods themselves.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the tooling
emits. After export, a fresh `bash tools/build-image.sh` load from committed `src/` is
the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it.

## DELIVERABLES

- `src/Phi-Coding-Kit-Fixtures-Behavioral/BaselineOfPCKFixture.class.st`
- `src/Phi-Coding-Kit-Fixtures-Behavioral/PCKPassingFixtureTest.class.st`
- `src/Phi-Coding-Kit-Fixtures-Behavioral/PCKFailingFixtureTest.class.st`
- `src/Phi-Coding-Kit-Fixtures-Behavioral/PCKSkippingFixtureTest.class.st`
- `src/Phi-Coding-Kit-Fixtures-Behavioral/PCKAbstractFixtureTest.class.st`
- `src/Phi-Coding-Kit-Tests-Behavioral/PCKBehavioralFixturesTest.class.st`
- LOC budget: target 125 / ceiling 250 (the planted fixture methods are one-liners;
  most of the budget is the pinning suite).

## TESTS FIRST

Test methods on `PCKBehavioralFixturesTest` (5):

- `testBaselineDeclaresEmptyProductionGroup` — given `BaselineOfPCKFixture project
  version` / when the groups are listed and `'production'` expanded / then the group
  names include `'production'` and `packagesForSpecNamed: 'production'` answers empty
  — the D-25.a addendum fact §1.1's mandatory `#production` rests on.
- `testTestsGroupExpandsToTheFixturePackage` — given the same version / when
  `packagesForSpecNamed: 'tests'` / then the spec names are exactly
  `#('Phi-Coding-Kit-Fixtures-Behavioral')` — the scratch tests-role list every later
  chunk derives.
- `testFixturesPackageIsUnswept` — given the package name and the D-57 regex
  `'(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*'` / when `matchesRegex:` / then false —
  the committed-red package can never enter the verify sweep (D-22 pinned by machine,
  not by prose).
- `testPlantedFixtureShapesAreExact` — given the two red fixture classes / then each
  is a loaded `TestCase` descendant defined in `Phi-Coding-Kit-Fixtures-Behavioral`;
  `PCKFailingFixtureTest` has exactly the selectors `#testAlwaysFails` and
  `#testAlwaysErrors` among its test methods; `PCKSkippingFixtureTest` has exactly
  `#testSkippedOnPurpose` and `#testExpectedlyFailing`, and a fresh instance's
  `expectedFailures` equals `#( testExpectedlyFailing )` — the shapes §5.5's finding
  assertions will name.
- `testAbstractAndNonTestResidentsAreExcludable` — given the package's
  `definedClasses` / then `PCKAbstractFixtureTest isAbstract` is true and
  `BaselineOfPCKFixture` does not inherit from `TestCase` — the two residents the
  §5.2 filter (C02) must exclude, declared so.

Fixtures: this chunk's own deliverables — nothing pre-existing beyond the frozen
package stubs.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0, 0 failures,
          0 errors; output lists the 5 new `PCKBehavioralFixturesTest` methods plus
          every previously accepted suite — the 88 accepted E01/E02/E03/E06 tests
          and any accepted parallel-track (E04/E05/E08) suites (regression guard;
          membership + floor ≥93, never an exact ceiling). The four fixture classes
          must appear in **no** test-run line: the sweep not matching the fixtures
          package is itself part of the acceptance.

OUT OF SCOPE
- Running any fixture suite (C02's cache owns running); constructing checks (C03/C04);
  touching `PCKKit` (C05/C06).
- Any edit to `BaselineOfPhiGuardrails`, any `package.st`, or anything in
  `Phi-Coding-Kit-Rules`/`Phi-Coding-Kit-Tests-Rules` (E08's ground this round).
- A scratch `PGRConfiguration` — E07's kit-side tests never reference `-Core` classes
  (P-SDK-EDGE's reflective law covers every `Phi-Coding-Kit*` package, tests
  included); the scratch shape is baseline introspection, nothing more.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files, one
          commit `E07-C01: behavioral fixtures family` (epic-qualified ID, D-73)
          before reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) · new
  questions for the decision sheet.
