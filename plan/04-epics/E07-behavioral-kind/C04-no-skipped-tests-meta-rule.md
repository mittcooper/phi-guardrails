# E07-C04 · PCKNoSkippedTestsMetaRule      [E07 · depends: E07-C03 · parallel: no]

GOAL      The no-skips meta-rule lands: it reads the same result objects the suite
          registrations use — pulled from the cache per package, never by run
          order — and reddens on every skipped test and expected failure, with the
          ruled rationale carried on the check and emitted with each finding.

TRACE     R-25 · R-24 (behavioral half — the disabled-check hole) · spec ch. 5
          §5.3, §5.5 (the meta-rule's pair and isolation test) · D-08 (result-object
          reading, no static heuristics) · D-36 (per-package pull; cannot fail
          open) · P-GATE-SKIP (both named tests land here).

## CONTEXT DIGEST

**What exists when this chunk starts:** E07-C01…C03 accepted — the fixture family,
`PCKSuiteRunCache` (public protocol exactly `resultsForPackage:`, class-side
`testClassesIn:`), and `PCKTestSuiteCheck class>>package:cache:` (kind
`#behavioral`; red/green/missing behavior proven). `PCKKit` does **not** yet
construct this class — C05 wires it.

**§5.3, the whole law:** `PCKNoSkippedTestsMetaRule` (kind `#behavioral`) reads
**the same result objects** the suite registrations use — through the run cache,
**pulled per package, never by run order** (D-36); no second run, no static
heuristics (D-08):

- For every tests-role package name handed at construction (the same derived list
  §5.1 builds suite registrations from — the kit hands it, C05), ask the cache
  `resultsForPackage:`. The lazy cache runs any suite not yet run, so the meta-rule
  sees every package's results even when it runs first or alone — a narrowed
  advisory-tier run cannot fail open — while in a full run every result is already
  cached and nothing runs twice.
- For each `TestResult`: one finding per test in `skipped` (message `'skipped'`)
  and per test in `expectedDefects` (message `'expected failure'`), target
  `'Class>>#selector'` (same target form as C03; element-selector spelling was
  verified and recorded by C03 — reuse it, do not re-derive).
- Verdict: red iff any finding, else green. An **empty** handed list is green here
  — vacuity is covered one level up: the kit already emits the
  `behavioral/tests-role` missing registration for an empty expansion (§5.1, C05),
  and the meta-rule iterates exactly that same derived list.

**Rationale (ruled wording, §5.3 — carried class-side and emitted with findings):**
"a skipped or expected-failure test is a disabled check — P6 makes disabling a
build failure; re-enable the test or delete it via a reviewed diff."

**What this rule deliberately is not (D-08):** the suspicious-shapes sweep (empty
test methods, never-run test classes) is a separate widened meta-rule at M5 — this
rule's zero-false-positive precision stays intact. Failures and errors are the
suite check's findings, never this rule's.

**Class design (agent calls recorded in `chunks.md`, veto-open):**

- `PCKNoSkippedTestsMetaRule` in `Phi-Coding-Kit-Behavioral`, subclass of
  `PGRCheck`. Instance variable `cache` (internal reader `cache` — C05's wiring
  test reads it); the tests-role list lives in the inherited skeleton storage
  (filled via the skeleton's private `setPackages:`; read back through the generic
  `packages` reader).
- Class-side constructor **`packages: testsPackageNames cache: aSuiteRunCache`** —
  the kit-custom wiring §5.4 licenses for the kit's own classes. The promised
  one-argument `packages:` stays inherited and untouched: a *client* class named in
  `#metaRules` takes that generic path and reaches no cache (§5.4); this class,
  kit-constructed, always gets the cache (C05 special-cases it).
- Class-side `rationale` answering the ruled wording; findings use the
  three-argument constructor with it.

**The scratch shape (§5.5, realized without `-Core`):** the tests-role list is
derived from `BaselineOfPCKFixture` by introspection —

```smalltalk
(BaselineOfPCKFixture project version packagesForSpecNamed: 'tests')
    collect: [ :spec | spec name ]     "→ #('Phi-Coding-Kit-Fixtures-Behavioral')"
```

(D-25.a spellings, pinned by E07-C01's suite). Kit test code never references
`PGRConfiguration` or any `-Core` class — P-SDK-EDGE's reflective law covers every
`Phi-Coding-Kit*` package, tests included.

**Frozen signatures used (verbatim, E02 digest):**

```smalltalk
PGRFinding class >> target: aTargetString message: aMessageString rationale: aRationaleStringOrNil
"PGRFinding readers: target · message · rationale"
PGRVerdict class >> green   ·   PGRVerdict class >> redFindings: aCollection
"PGRVerdict readers: status · findings · isGreen"
PCKTestSuiteCheck class >> package: aPackageName cache: aSuiteRunCache   "E07-C03"
"PCKSuiteRunCache: new · resultsForPackage: aPackageName → TestResult   (E07-C02)"
"TestResult>>skipped · expectedDefects — collections of test-case instances (D-15);
 skippedCount · expectedDefectCount — D-08's exact predicate ground"
```

**Constitution rules that bite here:** every rule carries a rationale (this one's
doubles as agent guidance and is emitted per finding); no global state; glossary —
a skipped test is a **disabled check** in P6 terms, "warning" never appears; a test
that cannot fail is a defect; no `skip`/`expectedFailures` in the swept test class
(the fixture package is the sanctioned exception).

**Constitution §3 self-note (worth a comment in the swept test class):** this chunk
is the machine form of the repo's own no-skips law — once registered (E09,
`guardrails.ston`), it sweeps every framework tests-role package including the
class that tests it.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `bash tools/build-image.sh` load from committed
`src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it.

## DELIVERABLES

- `src/Phi-Coding-Kit-Behavioral/PCKNoSkippedTestsMetaRule.class.st`
- `src/Phi-Coding-Kit-Tests-Behavioral/PCKNoSkippedTestsMetaRuleTest.class.st`
- LOC budget: target 115 / ceiling 250.

## TESTS FIRST

Test methods on `PCKNoSkippedTestsMetaRuleTest` (`Phi-Coding-Kit-Tests-Behavioral`,
3 — the first and third are **P-GATE-SKIP**, ch. 9):

- `testFiresOnSkipAndExpectedFailure` — given the scratch shape (tests-role list
  derived from `BaselineOfPCKFixture` as above) and a cache **warmed the full-run
  way** (a `PCKTestSuiteCheck` on the fixture package runs first against the same
  cache — the §1.4 suites-then-meta shape) / when the meta-rule runs / then `kind`
  is `#behavioral`, the verdict is red, and the findings' (target → message) pairs
  are **exactly** `'PCKSkippingFixtureTest>>#testSkippedOnPurpose' → 'skipped'` and
  `'PCKSkippingFixtureTest>>#testExpectedlyFailing' → 'expected failure'` (asserted
  as a set); each finding's `rationale` equals `PCKNoSkippedTestsMetaRule
  rationale`; the failing class contributes **no** finding (failures are the suite
  check's business — precision, D-08).
- `testSilentOnCleanSuite` — given packages `#('Phi-Guardrails-Tests-SDK')` (the
  no-skips green subject, C03's recorded call) and a fresh cache / when run / then
  green, no findings — the good half of the meta-rule's fixture pair (R-37).
- `testFiresInIsolationWithoutPriorSuiteRuns` — given the same scratch shape but a
  **fresh cache and no suite check run at all** / when the meta-rule runs alone /
  then the same two findings — the lazy pull ran the suites itself; the meta-rule
  cannot fail open (D-36's named regression).

Fixtures: E07-C01's family (the skipping class is the subject) ·
`PCKSuiteRunCache` (E07-C02) · `PCKTestSuiteCheck` (E07-C03, warm-up only).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0, 0 failures,
          0 errors; output lists the 3 new `PCKNoSkippedTestsMetaRuleTest` methods
          plus every previously accepted suite — the 88 accepted E01/E02/E03/E06
          tests, the 11 accepted E07-C01…C03 tests, and any accepted
          parallel-track (E04/E05/E08) suites (membership + floor ≥102, never an
          exact ceiling).

OUT OF SCOPE
- Kit wiring: derivation, the shared-cache construction, and the own-class
  special-case (E07-C05); the stanza line (E07-C06).
- The M5 widened meta-rules (mirror packages, regression set, fixture-pair rule,
  suspicious shapes — recorded ground, not code).
- Any second cache message; any static source heuristic (D-08 bans both).
- Touching the fixtures package, `package.st` files, the baseline, or anything in
  `Phi-Coding-Kit-Rules`/`-Tests-Rules`.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files, one
          commit `E07-C04: no-skips meta-rule` (epic-qualified ID, D-73) before
          reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · deviations
  from the work order (each with one-line justification) · new questions for the
  decision sheet.
