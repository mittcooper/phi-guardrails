# E04-C01 · Scratch checks and the spec-answering kit    [E04 · depends: — · parallel: no]

GOAL      Land the duck-typed scratch check family and the data-driven
          `PGRScratchSpecKit` that every E04 registry test drives, with a fixture
          suite pinning their behavior.

TRACE     ch. 1 §1.4 (kit contract: specs answered, checks instantiated) · ch. 9
          §9.3 (fixtures-without-red-tests residency) · R-40 (contract — the
          in-repo rehearsal of the external-kit shape, roadmap E04 risk row /
          B-08 partial) · D-53 (conformance, not ancestry) · D-54 (kits answer
          `PGRRegistrationSpec` values) · D-60 (the `packages:` instantiation
          contract).

## CONTEXT DIGEST

**Why these fixtures exist.** E04 builds `PGRRegistration` and `PGRRegistry` —
the engine side of the kit handoff. The roadmap rules that E04's tests exercise
the contract with **scratch duck-typed kits/checks** (never the coding kit — its
packages are another epic's ground, and duck-typing is itself the D-53 witness).
This chunk supplies that entire cast; C02–C05 only consume it.

**Frozen E02 SDK ground this chunk builds on (verbatim, from the E02 digest):**

- `PGRRegistrationSpec class>>name: aNameString kind: aKindSymbol check: aCheck` ·
  `class>>missing: aNameString kind: aKindSymbol reason: aReasonString`;
  instance readers `name` · `kind` · `check` · `missingReason`. A dumb value —
  no validation; a missing spec carries kind explicitly (no check exists to ask,
  D-60).
- `PGRVerdict class>>green` · `class>>redFindings: aCollection`; instance
  `status` · `isGreen` · `findings`.
- `PGRFinding class>>target: aString message: aString`; instance `target` ·
  `message`.
- The **check protocol** (conformance, not ancestry — `PGRCheck` optional):
  class-side `packages:` (constructor: the kit that names a check instantiates
  it, handing target package *names*; `run` stays argument-less — everything a
  check knows, it was given); instance `run` → verdict · `kind` → Symbol ·
  `canFix` (false unless overridden) · `fixCommandOn:` (required only when
  `canFix`) · reader `packages`.
- The **kit protocol** (class-side, exactly two messages):
  `registrationsFrom: aBlock productionPackages: productionNames testsPackages:
  testsNames` (the verbatim block Dictionary + the resolved role name lists —
  never the configuration object, D-53) answering an ordered collection of
  `PGRRegistrationSpec` values · `recommendedBlock` (STON text String).

**Existing precedent fixture (E03/C20, do not modify):** `PGRScratchKit` in
`Phi-Guardrails-Tests-Core` — a plain `Object` subclass, class-side only:
`registrationsFrom:productionPackages:testsPackages:` answers
`OrderedCollection new` (no registrations, whatever the block);
`recommendedBlock` answers `'{ #kit : ''PGRScratchKit'' }'`. It stays the
"kit that answers nothing" of C03's tests.

**The fixture contract this chunk pins (later chunks cite it verbatim):**

All classes live in `Phi-Guardrails-Tests-Core`, beside their tests (ch. 9
§9.3: fixtures without red tests sit in the mirroring tests-role package, where
they are inert — none is a `TestCase`). All are **plain `Object` subclasses** —
never `PGRCheck`/`PGRKit` subclasses; duck-typed conformance is the point.

1. `PGRScratchGreenCheck` — the full conforming check: instVar `packages`;
   class-side `packages: aCollection` → instance with `packages` copied to an
   `Array` (the E02 R-35 convention); instance `run` → `PGRVerdict green` ·
   `kind` → `#scratch` · `canFix` → `false` · reader `packages`.
2. `PGRScratchRedCheck` — subclass of `PGRScratchGreenCheck`; overrides `run` →
   `PGRVerdict redFindings: { PGRFinding target: 'PGRScratchRedCheck' message:
   'planted scratch violation' }`.
3. `PGRScratchErroringCheck` — subclass of `PGRScratchGreenCheck`; overrides
   `run` → `Error new signal: 'scratch check exploded'` (never answers).
4. `PGRScratchClaimsFixCheck` — subclass of `PGRScratchGreenCheck`; overrides
   `canFix` → `true` and implements **no** `fixCommandOn:` (the C04 defect
   witness).
5. `PGRScratchNonconformingCheck` — its own plain `Object` subclass: class-side
   `packages:` (so a kit can instantiate it), instance `kind` → `#scratch` ·
   `canFix` → `false` — and **no `run`**: the missing selector is exactly
   `#run` (the C04 conformance-error witness).
6. `PGRScratchSpecKit` — the data-driven kit, class-side only, stateless (no
   class-side variables — constitution: no global state). `recommendedBlock` →
   `'{ #kit : ''PGRScratchSpecKit'' }'`.
   `registrationsFrom: aBlock productionPackages: productionNames
   testsPackages: testsNames` reads `aBlock at: #specs ifAbsent: [ #() ]` and
   answers one spec per entry, **in entry order** (an `OrderedCollection`).
   Each entry is a map; dispatch on its keys:
   - has `#check` → resolve `Smalltalk classNamed: (entry at: #check)` (fixture
     assumption: always loaded — tests only name this chunk's classes),
     instantiate it via `packages: productionNames`, answer
     `PGRRegistrationSpec name: (entry at: #name) kind: (entry at: #kind)
     asSymbol check: theInstance`.
   - has `#missing` → `PGRRegistrationSpec missing: (entry at: #name) kind:
     (entry at: #kind) asSymbol reason: (entry at: #missing)`.
   - has `#echoRoles` → a missing spec (kind from the entry's `#kind`, as the
     other arms — the constructor requires one) whose reason **is** the
     received role lists, exactly: `'production: ' , (', ' join:
     productionNames) , ' | tests: ' , (', ' join: testsNames)` — the C03
     handoff witness.
   The kit performs **no block validation** — deliberately: it models an
   obedient kit; strictness inside blocks is kit-side ground (E06/E07), and
   block opacity to the core is what the registry tests witness (D-51).

**The kind `#scratch` (agent call, veto-open — recorded in chunks.md):** the
core treats `kind` as an opaque Symbol everywhere except the D-60 kind-agreement
law, so a non-catalog kind is the cleanest witness that the engine interprets
"only kinds and verdicts" (R-42) without a kind whitelist. Registration names
follow `<kind>/<discriminator>` (§1.3): `scratch/G1`, `scratch/M1`, …

**Constitution rules that bite here:** class-side named constructors over
`new`+setters (each check's `packages:`) · no global state (the spec kit is
stateless; `echoRoles` exists precisely to avoid argument-capturing state) ·
no `skip`/`expectedFailures` · glossary exactly: gate-runnable things are
*checks*; a *kit block* is the map inside `#kits`; a *registration spec* is the
kit's answered value.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export
to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present,
D-15); hand-writing class files is not allowed — the committed form must be what
the tooling emits. After export, a fresh `tools/build-image.sh` load from the
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Guardrails-Tests-Core/PGRScratchGreenCheck.class.st` — create.
- `src/Phi-Guardrails-Tests-Core/PGRScratchRedCheck.class.st` — create.
- `src/Phi-Guardrails-Tests-Core/PGRScratchErroringCheck.class.st` — create.
- `src/Phi-Guardrails-Tests-Core/PGRScratchClaimsFixCheck.class.st` — create.
- `src/Phi-Guardrails-Tests-Core/PGRScratchNonconformingCheck.class.st` — create.
- `src/Phi-Guardrails-Tests-Core/PGRScratchSpecKit.class.st` — create.
- `src/Phi-Guardrails-Tests-Core/PGRScratchCheckFixturesTest.class.st` — create
  (the seven tests below).
- Every class carries a class comment stating its fixture role (the C20
  precedent). No `package.st`, baseline, or `PGRConfiguration`/`PGRScratchKit`
  edits — touching anything outside this manifest is a review-rejection.
- LOC budget: target 150 / ceiling 260 (a seven-file fixture-family chunk — the
  E03/C20 shape; class-definition overhead, not logic, carries the count).

## TESTS FIRST

Test methods on `PGRScratchCheckFixturesTest` (subclass of `TestCase`):

- `testGreenCheckRunsGreen` — given `PGRScratchGreenCheck packages: #('P1')` /
  when `run` / then the verdict `isGreen`; `kind` = `#scratch`; `packages` =
  `#('P1')`.
- `testRedCheckFiresNamingPlant` — given the red check on any packages / when
  `run` / then `status` = `#red` and exactly one finding with message
  `'planted scratch violation'`.
- `testErroringCheckRaises` — given the erroring check / when `run` / then an
  `Error` is signalled whose description includes `'scratch check exploded'`
  (the check itself never converts — conversion is the registration's, C02).
- `testNonconformingCheckLacksRunOnly` — given an instance via `packages:` /
  then `respondsTo: #run` is false while `respondsTo: #kind` and
  `respondsTo: #canFix` are true (the defect is exactly the one selector).
- `testClaimsFixCheckLacksFixCommand` — given an instance / then `canFix` is
  true and `respondsTo: #fixCommandOn:` is false.
- `testSpecKitAnswersSpecsFromBlock` — given a block Dictionary with `#specs` =
  ⟨green entry `scratch/G1` naming `'PGRScratchGreenCheck'`, missing entry
  `scratch/M1` reason `'engine absent'`⟩ / when `registrationsFrom:` it
  `productionPackages: #('PA' 'PB') testsPackages: #('TA')` / then two specs in
  entry order: first `name` = `'scratch/G1'`, `kind` = `#scratch`, `check` a
  `PGRScratchGreenCheck` whose `packages` = `#('PA' 'PB')`, `missingReason`
  nil; second `check` nil, `missingReason` = `'engine absent'`, `kind` =
  `#scratch`.
- `testSpecKitEchoesRoleLists` — given a block with one `#echoRoles` entry /
  when handed `#('PA' 'PB')` / `#('TA')` / then one missing spec whose reason =
  `'production: PA, PB | tests: TA'` exactly.

Fixtures: this chunk's own classes; no configuration, no STON parsing — the kit
is driven with hand-built Dictionaries here (the registry drives it through
real artifacts from C03 on).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 7 new
          `PGRScratchCheckFixturesTest` methods **plus every previously
          accepted suite** (the 88-test accepted sweep at cut time) —
          named-suite membership plus a floor (≥ 95 run), never an exact
          ceiling: other epics run `[P]` beside this cut (D-73-era standing
          rule).

OUT OF SCOPE
- `PGRRegistration` / `PGRRegistry` — C02/C03.
- Any strict validation inside the spec kit (fixture models obedience; engine
  strictness is C04, kit strictness is E06/E07 ground).
- Touching `PGRScratchKit`, the scratch baselines, `PGRConfiguration`, or any
  frozen E02/E03 surface.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `E04-C01: scratch checks and the spec-answering kit` (D-73 qualified
          ID) before reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
