# E07-C05 · PCKKit: behavioral derivation and the run cache      [E07 · depends: E07-C04 · parallel: no]

GOAL      The kit's behavioral builder fills in: one derived suite registration per
          tests-role package (or the `behavioral/tests-role` missing sentinel when
          the expansion is empty), one run-scoped cache shared by every behavioral
          check of the call, the own-meta-rule special case, and the frozen
          four-stage order — with the eight accepted `PCKKitTest` methods amended
          to the scheduled post-insertion shapes.

TRACE     R-23, R-24 (empty-expansion half) · spec ch. 5 §5.1, §5.4 · ch. 1 §1.4
          (registration order; kit-custom construction), §1.5 (`#behavioral` rows) ·
          D-25 (suites derive from the tests role) · D-36 (one cache, per-package
          pull) · P-SUITES-BEFORE-META · P-GATE-MISSING (suite half) · roadmap §2
          preamble ("E07 alone touches `PCKKit` after E06").

## CONTEXT DIGEST

**What exists when this chunk starts:** E07-C01…C04 accepted (fixture family ·
`PCKSuiteRunCache` · `PCKTestSuiteCheck` · `PCKNoSkippedTestsMetaRule`). `PCKKit`
stands at its E06-frozen form: `validateBlock:` (five keys, strict),
`lintSpecFor:productionPackages:`, the generic
`promisedSpecFor:prefix:kind:packages:` path for `#architectureChecks`/`#metaRules`,
and `registrationsFrom:productionPackages:testsPackages:` answering lint →
architecture → meta. The E06 exit checkpoint froze the order law **already naming
this chunk's insertion**: "answered order lint → architecture → (behavioral suites,
E07) → meta-rules" — so amending the E06 tests below is scheduled ground, not a
frozen-surface amendment.

**§5.1 derivation, the whole law:** behavioral suites have **no block key**. One
registration per tests-role package (the `testsNames` argument, in handed order),
kind `#behavioral`, name `'behavioral/' , packageName`, check
`PCKTestSuiteCheck package: packageName cache: cache`. An **empty** tests-role
expansion yields instead **one missing registration named `behavioral/tests-role`**
(the literal name — ch. 1 §1.5), kind `#behavioral`, reason naming the empty
expansion (R-24: the stock runner exits 0 on nothing-to-run; silence is never a
pass). Derivation is unconditional — it does not depend on any block content.

**§5.4 cache wiring:** `registrationsFrom:productionPackages:testsPackages:` builds
**one `PCKSuiteRunCache new` per call**, closes every behavioral check of that call
over it, and lets it go with them — run-scoped sharing, not global state (R-35).
Two calls never share a cache.

**The own-meta-rule special case (§5.4):** the kit constructs its own behavioral
checks directly. In the `#metaRules` loop, resolve the name as today; when the
resolved class is **identical to `PCKNoSkippedTestsMetaRule`**, construct via
`PCKNoSkippedTestsMetaRule packages: testsNames cache: cache` (the run's one
cache); every other resolved class keeps the existing generic
`promisedSpecFor:prefix:kind:packages:` path unchanged — a client class named in
`#metaRules` reaches no cache. Unresolved names still answer missing specs. Spec
name and kind are unchanged either way (`'behavioral/' , name`, `#behavioral`).

**Order law (frozen, completed here):** all lint specs, then all architecture
specs, then all derived behavioral-suite specs (or the one sentinel), then all
`#metaRules` specs — in-key order preserved.

**Signatures this chunk builds on (verbatim):**

```smalltalk
"E06-frozen (current PCKKit, unchanged parts):"
PCKKit class >> registrationsFrom: aBlock productionPackages: productionNames testsPackages: testsNames
PCKKit class >> promisedSpecFor: aCheckName prefix: aPrefixString kind: aKindSymbol packages: roleNames
"E07-C02…C04:"
PCKSuiteRunCache class >> new            "empty; resultsForPackage: is the protocol"
PCKTestSuiteCheck class >> package: aPackageName cache: aSuiteRunCache
    "internal readers: package · cache"
PCKNoSkippedTestsMetaRule class >> packages: testsPackageNames cache: aSuiteRunCache
    "internal reader: cache; list via inherited packages"
"E02-frozen SDK:"
PGRRegistrationSpec class >> name: aNameString kind: aKindSymbol check: aCheck
PGRRegistrationSpec class >> missing: aNameString kind: aKindSymbol reason: aReasonString
"spec readers: name · kind · check (nil on missing) · missingReason (nil on resolved)"
```

**The eight accepted `PCKKitTest` methods that change** (the derivation adds one
behavioral entry to every completing contract call; each amendment is exactly the
delta below — no other accepted test may change):

| Accepted test (current assertion) | Amended expectation |
|---|---|
| `testArchitectureCheckResolvedViaPackagesConstructor` (tests `#()`; 1 spec) | 2 specs: first the unchanged architecture spec (all existing first-spec assertions stand); last named `'behavioral/tests-role'`, kind `#behavioral`, `check` nil |
| `testLayerMapKeyProducesNoRegistrationsAndNoError` (tests `#()`; 1 spec) | 2 specs: first `'lint/PCKNoIsNilIfTrueRule'` (unchanged), last the `'behavioral/tests-role'` sentinel — the map still contributes nothing |
| `testLintRegistrationsFromBlock` (tests `#()`; 2 specs) | 3 specs: name array `#('lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule' 'behavioral/tests-role')`; the per-spec lint assertions (kind/class/packages/rule) now iterate only the first two |
| `testMetaRuleResolvedWithTestsRole` (tests `#('T-One')`; 1 spec) | 2 specs: first `'behavioral/T-One'` kind `#behavioral` check class `PCKTestSuiteCheck`; the existing meta-spec assertions move to `specs last` |
| `testRecommendedBlockRegistersCleanly` (tests `#()`; 2 specs, none missing) | hand `testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral')` instead: 3 specs — the two lint names then `'behavioral/Phi-Coding-Kit-Fixtures-Behavioral'` — all resolved, none missing (E07-C06 widens this to 4 when the stanza completes) |
| `testRegistrationOrderIsLintThenArchitectureThenMeta` (tests `#('T-One')`; 3 names) | name array `#('lint/PCKNoIsNilIfTrueRule' 'architecture/PCKArchStubCheck' 'behavioral/T-One' 'behavioral/PCKMetaStubCheck')` — the four-stage order law, complete; update the method comment (the method name stays — it is accepted history) |
| `testUnresolvedArchitectureAndMetaAnswerMissingSpecs` (tests `#('T-One')`; 2 specs) | 3 specs: first/last assertions stand (architecture missing · meta missing); the middle is `'behavioral/T-One'`, resolved — restrict the `check isNil`/`missingReason` loop to first and last |
| `testUnresolvedLintRuleAnswersMissingSpec` (tests `#()`; 1 spec) | 2 specs: first the unchanged lint missing spec (all existing first-spec assertions stand); last the `'behavioral/tests-role'` sentinel, kind `#behavioral`, `check` nil |

(`testClassAnsweringNeitherPathSignals`, `testNonRuleClassSignals`,
`testRuleWithoutOwnSeveritySignals`, `testUnknownBlockKeySignals`, and
`testRecommendedBlockParsesAsKitBlock` are untouched — the first four raise before
derivation; the last never calls the contract. 8 amended + 5 untouched = the 13
accepted methods, accounted in full.)

**Constitution rules that bite here:** strict validation unchanged (family 7 — this
chunk adds no new block key and must not touch `validateBlock:`'s law); no global
state (the cache is per-call); comments state constraints the code cannot show
(the special-case comment cites §5.4 and D-36 — why the own class gets the cache
and clients do not); a test that cannot fail is a defect.

**Construction runs nothing:** building a `PCKTestSuiteCheck` never pulls the
cache — registry construction stays inert (R-41's spirit); the tests below that
name real packages therefore add no nested suite runs.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `bash tools/build-image.sh` load from committed
`src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it.

## DELIVERABLES

- `src/Phi-Coding-Kit/PCKKit.class.st` (modify — the behavioral builder and the
  meta-loop special case; `recommendedBlock` untouched, E07-C06's ground)
- `src/Phi-Coding-Kit-Tests-Rules/PCKKitTest.class.st` (modify — 4 methods added,
  the 8 enumerated amendments; the frozen E06 ruling "E07 extends the class in
  place" is this manifest line's warrant)
- `src/Phi-Coding-Kit-Tests-Behavioral/PCKTestSuiteCheckTest.class.st` (modify —
  1 method added)
- LOC budget: target 150 / ceiling 300.

## TESTS FIRST

New methods on `PCKKitTest` (4):

- `testDerivesOneSuiteRegistrationPerTestsRolePackage` — given an empty block and
  tests `#('Phi-Coding-Kit-Fixtures-Behavioral' 'Phi-Guardrails-Tests-SDK')` / then
  exactly 2 specs, names `'behavioral/Phi-Coding-Kit-Fixtures-Behavioral'` then
  `'behavioral/Phi-Guardrails-Tests-SDK'` (handed order), each kind `#behavioral`,
  each check a `PCKTestSuiteCheck` whose `package` is its name's suffix (§5.1
  derivation, whole and ordered).
- `testSuiteRegistrationsPrecedeMetaRules` — **P-SUITES-BEFORE-META** (ch. 9 name):
  given `#metaRules → #('PCKMetaStubCheck')` and the same two tests packages / then
  every derived suite spec's index in the answer is lower than every `#metaRules`
  spec's index.
- `testOwnMetaRuleRidesTheRunCache` — given `#metaRules →
  #('PCKNoSkippedTestsMetaRule')` and tests
  `#('Phi-Coding-Kit-Fixtures-Behavioral')` / then the last spec is
  `'behavioral/PCKNoSkippedTestsMetaRule'`, kind `#behavioral`, its check a
  `PCKNoSkippedTestsMetaRule` whose `packages` equals the tests list and whose
  `cache` is **identical to** the suite spec's check `cache` — one run-scoped cache
  per call (§5.4, D-36); the sibling `PCKMetaStubCheck` path is already pinned
  generic by the amended `testMetaRuleResolvedWithTestsRole`.
- `testTwoRegistrationRoundsShareNoCache` — given the same inputs handed to two
  separate `registrationsFrom:` calls / then the two suite checks' `cache`s are
  **not** identical — run-scoped, never shared across constructions (R-35).

New method on `PCKTestSuiteCheckTest` (1):

- `testMissingOnEmptyTestsRole` — **P-GATE-MISSING, suite half** (ch. 9 name; ch. 5
  §5.5 places it here): given an empty block and tests `#()` / then exactly one
  spec — name the literal `'behavioral/tests-role'`, kind `#behavioral`, `check`
  nil, `missingReason` present — an empty tests-role expansion is a loud missing
  registration, never a silent green (R-24).

Plus the eight enumerated amendments (table above).

Fixtures: E07-C01…C04 deliverables (accepted) · E06's `PCKMetaStubCheck` /
`PCKArchStubCheck` stubs · the two catalog rules.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0, 0 failures,
          0 errors; output lists the 4 new and 8 amended `PCKKitTest` methods and
          the 4 `PCKTestSuiteCheckTest` methods, plus every previously accepted
          suite — the 88 accepted E01/E02/E03/E06 tests (8 of them in amended
          form), the 14 accepted E07-C01…C04 tests, and any accepted
          parallel-track (E04/E05/E08) suites (membership + floor ≥107, never an
          exact ceiling).

OUT OF SCOPE
- `recommendedBlock` and its two stanza tests' further widening (E07-C06).
- Any change to `validateBlock:`'s five-key law, the lint pipeline, or the
  architecture path beyond the enumerated test amendments; any new block key.
- Engine-side validation — conformance, kind agreement, duplicate names
  (E04's ground).
- Touching `Phi-Coding-Kit-Rules`, any other `-Tests-Rules` file, `package.st`
  files, or the baseline.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files, one
          commit `E07-C05: PCKKit behavioral derivation and run cache`
          (epic-qualified ID, D-73) before reporting for review; nothing left
          uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · deviations
  from the work order (each with one-line justification) · new questions for the
  decision sheet.
