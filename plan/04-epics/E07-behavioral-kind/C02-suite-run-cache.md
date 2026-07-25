# E07-C02 · PCKSuiteRunCache      [E07 · depends: E07-C01 · parallel: no]

GOAL      The run-scoped result cache lands: one public message
          `resultsForPackage:` that lazily runs a package's test classes once and
          answers the cached `TestResult` thereafter, plus the shared class-side
          test-class query the suite check's missing decision reuses.

TRACE     R-23/R-25 (the shared substrate) · spec ch. 5 §5.2 step 1, §5.4 · D-36
          (per-package pull, single-run guarantee) · R-35 (run-scoped, no global
          state) · roadmap E07 frozen export ("the cache's one-message protocol —
          internal but load-bearing for M5 meta-rules").

## CONTEXT DIGEST

**What exists when this chunk starts:** E07-C01 accepted — the fixtures package
holds `BaselineOfPCKFixture` and the four fixture classes with the pinned
package-run facts: three concrete `TestCase` classes (`PCKPassingFixtureTest` ·
`PCKFailingFixtureTest` · `PCKSkippingFixtureTest`, five test methods), one abstract
(`PCKAbstractFixtureTest`, class-side `isAbstract` true, whose `testWouldFailIfRun`
must never run), and the non-test resident `BaselineOfPCKFixture`. Package
`Phi-Coding-Kit-Behavioral` is an empty stub.

**What the cache is (§5.4):** suites run **once per gate run** even though two
registration families read them. The cache is a plain object created per registry
construction (C05 wires that), closed over by the behavioral registrations of that
run, and discarded with them — run-scoped sharing, not global state (R-35: no
class-side variables, no lookup by name). **Public protocol: one message**,
`resultsForPackage:` — lazily runs §5.2 step 1 on first request per package and
answers the cached `TestResult` thereafter. Correctness of the whole behavioral kind
rests on this cache alone (D-36): suite registrations and the meta-rule both pull by
package name, so no reader depends on what another has already run.

**§5.2 step 1, verbatim ground:** "Test classes = classes defined in the package
that inherit from `TestCase` and answer `isAbstract` false; build each class's suite
(`buildSuite`) and run it once, collecting the package's `TestResult`."

**Design (agent calls recorded in `chunks.md`, veto-open):**

- Class `PCKSuiteRunCache` in `Phi-Coding-Kit-Behavioral`. One instance variable
  `results` (a `Dictionary`, package name → `TestResult`), initialized empty in
  `initialize`; plain `new` is the constructor (no setters exist, so the
  named-constructor rule has nothing to name).
- `resultsForPackage: aPackageName` — `results at: aPackageName ifAbsentPut: [ ... ]`
  running the package's classes into one `TestResult`. A private helper method is
  fine; the **one-message law binds the public protocol**, not the method count.
- Class-side `testClassesIn: aPackageName` — the §5.2 filter, shared so the suite
  check's zero-test-classes decision (C03) asks the same question the runner answers:
  the package's `definedClasses` selected by `(each inheritsFrom: TestCase) and:
  [ each isAbstract not ]`, answered as an `Array` **sorted by class name** (a
  deterministic order — `definedClasses` order is not guaranteed; P2's precision
  costs nothing here).
- **Suite composition spelling is ⟨verify-in-image⟩** (P5, the E06 delegation
  precedent — record the verified form in the completion report): the intended shape
  is one aggregate suite, e.g. `TestSuite new` filled from each class's
  `buildSuite`, run once → one `TestResult`; `TestCase class>>buildSuite`,
  `TestSuite>>run → TestResult`, and `isAbstract` are verified (D-15), but the exact
  aggregation message (`addTests:` / `tests` or an equivalent) must be confirmed
  live before use. Whatever the spelling, the observable contract below is fixed.

**Frozen/verified spellings used (verbatim):**

```smalltalk
PackageOrganizer default packageNamed: aName     "the package (D-15)"
"Package>>definedClasses · cls inheritsFrom: TestCase · TestCase class>>isAbstract"
"TestCase class>>buildSuite · TestSuite>>run → TestResult   (all D-15)"
"TestResult: failureCount errorCount skippedCount expectedDefectCount runCount
 failures errors skipped expectedDefects — skipped tests are NOT in runCount; an
 expected failure counts as passed and appears in expectedDefects (D-15)"
```

**The pinned package-run facts C01 promised** (this chunk's lazy run must reproduce
them for `'Phi-Coding-Kit-Fixtures-Behavioral'`): `failureCount` 1 · `errorCount` 1 ·
`skippedCount` 1 · `expectedDefectCount` 1 · `runCount` 4. If
`PCKAbstractFixtureTest` leaked past the filter, `failureCount` would read 2 — the
counts are the filter's witness.

**Constitution rules that bite here:** no global state — the cache is an ordinary
instance handed around explicitly (R-35); strict, deterministic behavior (P2); no
`skip`/`expectedFailures` in the swept test class; a test that cannot fail is a
defect; comments state constraints the code cannot show (say *why* the query is
class-side and the protocol one message).

**Runtime note (roadmap risk):** each lazy pull nests a real SUnit run — five fixture
methods here; bounded and terminating by construction (fixture classes contain no
gate or cache calls).

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the tooling
emits. After export, a fresh `bash tools/build-image.sh` load from committed `src/`
is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it.

## DELIVERABLES

- `src/Phi-Coding-Kit-Behavioral/PCKSuiteRunCache.class.st`
- `src/Phi-Coding-Kit-Tests-Behavioral/PCKSuiteRunCacheTest.class.st`
- LOC budget: target 105 / ceiling 250.

## TESTS FIRST

Test methods on `PCKSuiteRunCacheTest` (`Phi-Coding-Kit-Tests-Behavioral`, 3):

- `testTestClassInventoryIsConcreteTestCasesOnly` — given the fixtures package name /
  when `PCKSuiteRunCache testClassesIn:` / then exactly `PCKFailingFixtureTest`,
  `PCKPassingFixtureTest`, `PCKSkippingFixtureTest` in name order — the abstract
  class and `BaselineOfPCKFixture` are excluded (§5.2's filter, decided here once
  for both readers).
- `testLazyPullRunsTheWholePackageOnce` — given a fresh cache / when
  `resultsForPackage: 'Phi-Coding-Kit-Fixtures-Behavioral'` / then the answered
  `TestResult` reads `failureCount` 1 · `errorCount` 1 · `skippedCount` 1 ·
  `expectedDefectCount` 1 · `runCount` 4 — the suites really ran, and both D-15
  semantic traps (skip outside `runCount`; expected failure outside `failures`) are
  pinned on this image.
- `testSecondPullAnswersTheIdenticalResult` — given one cache pulled twice for the
  fixtures package / then both answers are the **same object** (identity — the
  single-run guarantee, D-36); and a second, fresh cache's pull answers a
  **different** object (run-scoped, never shared across constructions — R-35).

Fixtures: E07-C01's fixture family (accepted).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0, 0 failures,
          0 errors; output lists the 3 new `PCKSuiteRunCacheTest` methods plus every
          previously accepted suite — the 88 accepted E01/E02/E03/E06 tests, the 5
          accepted E07-C01 tests, and any accepted parallel-track (E04/E05/E08)
          suites (membership + floor ≥96, never an exact ceiling).

OUT OF SCOPE
- Verdict production and the zero-test-classes **decision** (C03 — the cache only
  answers results; `missing` is the check's word).
- Any `PCKKit` wiring (C05); the meta-rule (C04).
- A second public cache message (`allResults` was deliberately deleted by D-36 —
  reintroducing any bulk reader is a frozen-design violation, not a convenience).
- Touching the fixtures package, `package.st` files, the baseline, or anything in
  `Phi-Coding-Kit-Rules`/`-Tests-Rules`.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files, one
          commit `E07-C02: suite run cache` (epic-qualified ID, D-73) before
          reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · the verified
  suite-aggregation spelling (P5 record duty) · deviations from the work order
  (each with one-line justification) · new questions for the decision sheet.
