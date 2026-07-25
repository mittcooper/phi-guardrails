# E07-C03 · PCKTestSuiteCheck      [E07 · depends: E07-C02 · parallel: no]

GOAL      The behavioral suite check lands: one tests-role package name, kind
          `#behavioral`, verdicts red-on-failure-or-error with `Class>>#selector`
          findings, green on a clean package, and missing on a package with zero
          test classes.

TRACE     R-23, R-24 (the zero-test-classes half) · spec ch. 5 §5.2, §5.5 (the
          suite check's pair) · ch. 1 §1.5 (`#behavioral` suite missing row) ·
          D-21 (missing is a verdict, not an exception) · P-CAT-FIXTURES
          (behavioral, first pair).

## CONTEXT DIGEST

**What exists when this chunk starts:** E07-C01 (fixture family) and E07-C02
(`PCKSuiteRunCache`) accepted. The E02-frozen SDK (signatures below). `PCKKit` does
**not** yet construct this class — C05 wires it; here the class and its behavior
stand alone.

**§5.2, the whole law:** `PCKTestSuiteCheck` (kind `#behavioral`) holds one
tests-role package name. `run`:

1. Test classes = classes defined in the package that inherit from `TestCase` and
   answer `isAbstract` false — ask `PCKSuiteRunCache class>>testClassesIn:` (C02's
   shared query; never re-derive the filter). Zero test classes ⇒ the verdict is
   **missing** — reason text names the package and states it contains no tests
   (wording is human-facing, not an API; R-24: silence is never a pass). No cache
   pull happens in this arm.
2. Otherwise pull `resultsForPackage:` on the construction-handed cache — the check
   never runs suites itself and never builds a cache (everything it knows, it was
   given — D-60's construction law).
3. Findings: one per failure and one per error in the `TestResult` — target
   `'Class>>#selector'` (from the result's `failures` and `errors` collections),
   message `'failed'` / `'errored'` respectively. Passed, skipped, and
   expected-failure tests produce **no** findings here — skips are the meta-rule's
   subject (§5.3's precision split).
4. Verdict: red iff any finding, else green.

**Class design (agent calls recorded in `chunks.md`, veto-open):**

- `PCKTestSuiteCheck` in `Phi-Coding-Kit-Behavioral`, subclass of `PGRCheck`
  (conformance is what registration requires; subclassing is the convenience the
  skeleton exists for). Instance variables `package` and `cache`, with internal
  readers `package` and `cache` (kit-internal — C05's wiring test reads them).
- Class-side constructor **`package: aPackageName cache: aSuiteRunCache`** — the
  kit-custom wiring §5.4 licenses ("the kit constructs its own behavioral checks
  directly"). It also fills the inherited skeleton storage via the skeleton's
  private `setPackages:` with a one-element `Array`, so the generic `packages`
  reader stays truthful for any protocol-level reader.
- The elements of `failures`/`errors` are `TestCase` instances; the selector
  accessor spelling on them is **⟨verify-in-image⟩** (P5 — record the verified form
  in the completion report; D-15 verified the collections exist, not the element
  protocol). Target string form is fixed: class name, `'>>#'`, selector.
- Findings use the two-argument constructor (no rationale — §5.2 gives these
  findings none; the meta-rule's findings carry one, §5.3).

**Frozen signatures used (verbatim, E02 digest):**

```smalltalk
PGRCheck class >> packages: aCollectionOfPackageNames   "skeleton constructor"
PGRCheck >> packages        "reader"  ·  PGRCheck >> canFix   "default false"
PGRFinding class >> target: aTargetString message: aMessageString
"PGRFinding readers: target · message · rationale (nil here)"
PGRVerdict class >> green
PGRVerdict class >> redFindings: aCollection
PGRVerdict class >> missingReason: aString
"PGRVerdict readers: status (#green|#red|#missing) · findings · isGreen ·
 missingReason (internal reader)"
```

**Green-arm subject (agent call, veto-open — the §5.5 letter bent, on record):**
§5.5 says "green over the clean fixture class", but the check's unit is a
**package** and the one frozen fixtures package must contain the red and skipping
classes — a clean *package* result is unconstructible there, and adding a package
would edit the frozen E01 baseline (decision-sheet-only). The green arm therefore
targets **`'Phi-Guardrails-Tests-SDK'`** — a real, always-green, no-skips mirror
package (19 pure value-object tests; nested re-run is bounded and stateless). The
clean fixture class `PCKPassingFixtureTest` keeps its §5.5 role inside the red
package: the red arm asserts passes produce no findings.

**Constitution rules that bite here:** the check never mutates anything (the gate
only reports); no global state — cache handed at construction; glossary — this is a
**check** producing **findings**, "test" only ever names the SUnit methods it runs;
comments state constraints the code cannot show; a test that cannot fail is a
defect.

**Runtime note:** the red arm nests the fixture package's 5-method run; the green
arm nests `Phi-Guardrails-Tests-SDK`'s 19. Bounded, terminating (neither package
constructs checks or caches).

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `bash tools/build-image.sh` load from committed
`src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it.

## DELIVERABLES

- `src/Phi-Coding-Kit-Behavioral/PCKTestSuiteCheck.class.st`
- `src/Phi-Coding-Kit-Tests-Behavioral/PCKTestSuiteCheckTest.class.st`
- LOC budget: target 115 / ceiling 250.

## TESTS FIRST

Test methods on `PCKTestSuiteCheckTest` (`Phi-Coding-Kit-Tests-Behavioral`, 3 — a
fourth, `testMissingOnEmptyTestsRole`, is added to this class by E07-C05, whose
subject is the kit's derivation, not this class's behavior):

- `testRedOnFailingSuite` — given a check on
  `'Phi-Coding-Kit-Fixtures-Behavioral'` with a fresh cache / when `run` / then
  `kind` is `#behavioral`, `status` is `#red`, `isGreen` false, and the findings'
  (target → message) pairs are **exactly**
  `'PCKFailingFixtureTest>>#testAlwaysFails' → 'failed'` and
  `'PCKFailingFixtureTest>>#testAlwaysErrors' → 'errored'` (asserted as a set —
  result-collection order is not guaranteed): the passing and skipping classes
  produce no finding (precision — the §5.3 split), and the expected failure is not
  a failure (D-15 trap pinned at the check level).
- `testGreenOnPassingSuite` — given a check on `'Phi-Guardrails-Tests-SDK'` with a
  fresh cache / when `run` / then `isGreen` true and `findings` empty — the good
  half of the behavioral fixture pair (R-37).
- `testMissingOnPackageWithoutTestClasses` — given a check on `'Phi-Coding-Kit'`
  (loaded; defines only `PCKKit`, no `TestCase`) with a fresh cache / when `run` /
  then `status` is `#missing` and the internal `missingReason` names the package —
  R-24's zero-test-classes arm: a tests-role package with nothing to run is never
  silently green.

Fixtures: E07-C01's family; `PCKSuiteRunCache` (E07-C02); the loaded packages
`'Phi-Guardrails-Tests-SDK'` and `'Phi-Coding-Kit'` as green/missing subjects.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0, 0 failures,
          0 errors; output lists the 3 new `PCKTestSuiteCheckTest` methods plus
          every previously accepted suite — the 88 accepted E01/E02/E03/E06 tests,
          the 8 accepted E07-C01/C02 tests, and any accepted parallel-track
          (E04/E05/E08) suites (membership + floor ≥99, never an exact ceiling).

OUT OF SCOPE
- The kit's derivation of suite registrations, the `behavioral/tests-role` missing
  sentinel, and `testMissingOnEmptyTestsRole` (all E07-C05).
- The meta-rule (E07-C04); any `PCKKit` edit; engine-side wrapping, stamping, or
  conformance validation (E04's `PGRRegistration`).
- A fix capability (`canFix` stays inherited-false — behavioral verdicts have no
  rewrite).
- Touching the fixtures package, `package.st` files, the baseline, or anything in
  `Phi-Coding-Kit-Rules`/`-Tests-Rules`.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files, one
          commit `E07-C03: PCKTestSuiteCheck` (epic-qualified ID, D-73) before
          reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · the verified
  failure/error-element selector spelling (P5 record duty) · deviations from the
  work order (each with one-line justification) · new questions for the decision
  sheet.
