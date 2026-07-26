# E09-C01 · `PGRArchSelfTest` — the reflective walls    [E09 · depends: — · parallel: yes]

GOAL      Machine-enforce the architecture walls before the layer-map check
          exists: one reflective test class sweeping the production packages
          for engine leakage, client references, kit over-reach, the
          gate→kit wall, `Transcript`, and network/stray-file references.

TRACE     R-04 (machine half) · R-05 (machine enforcement) · ch. 9 §9.1/§9.2
          (P-CORE-NEUTRAL · P-SDK-EDGE · P-NO-TRANSCRIPT · P-DETERMINISTIC ·
          P-FIX-GATE-WALL, reflective form) · ch. 0 §0.1 (the one-way
          arrows) · D-53, D-55, D-45 (§7.6's two ruled file accesses) ·
          B-15 (the Zn reconciliation below) · roadmap E09 goal line.

## CONTEXT DIGEST

**The seven production packages** (baseline group `production`, frozen at
E01): `Phi-Guardrails-SDK` · `Phi-Guardrails-Core` · `Phi-Guardrails-Gate` ·
`Phi-Coding-Kit` · `Phi-Coding-Kit-Rules` · `Phi-Coding-Kit-Architecture`
(currently classless — scanning it must not error) ·
`Phi-Coding-Kit-Behavioral`.

**The ch. 9 letters this chunk implements, condensed:**

- **P-CORE-NEUTRAL** (`testCoreReferencesNoEngineClass` +
  `testProductionReferencesNoClientClass`): no method in
  `Phi-Guardrails-SDK` or `-Core` references SUnit, Renraku, or RB classes;
  no method in any of the seven production packages references a class
  defined in a `Toy-*` package.
- **P-SDK-EDGE** (`testKitPackagesReferenceOnlySDK`): no method in **any**
  package whose name begins `Phi-Coding-Kit` (tests and fixtures included —
  the E07-recorded reading) references a class defined in
  `Phi-Guardrails-Core` or `Phi-Guardrails-Gate`.
- **P-FIX-GATE-WALL, reflective form** (`testGateReferencesNoKitClass`):
  no method in `Phi-Guardrails-Gate` references a class defined in any
  `Phi-Coding-Kit*` package (subsumes the §9.2 letter's
  `Phi-Coding-Kit-Rules`/`PCKFixCommand` clause). The property's layer-map
  form is M2's; this reflective form is the roadmap's "walls
  machine-enforced *before* the layer-map check exists".
- **P-NO-TRANSCRIPT** (`testNoProductionMethodReferencesTranscript`): no
  method in the seven production packages references the `Transcript`
  global, and none carries the literal `#Transcript` (the named `at:put:`
  evasion — a literals scan catches both the binding and the symbol).
- **P-DETERMINISTIC** (`testNoNetworkOrStrayFileReferences`): no method in
  the seven production packages has a `referencedClasses` entry defined in
  a `Zinc-*`, `Network-*`, or `Zodiac-*` package; `FileReference` /
  `FileSystem` / `FileLocator` are referenced only from the ruled sites.
  **The M1 allowlist is exactly three methods:**
  `PGRConfiguration class>>#fromFile:` · `PGRGate class>>#runHeadless:` ·
  `PGRGate class>>#runHeadless:on:` (`PCKSrcInventoryCheck` joins the
  allowlist at M2 by that epic's scheduled edit — do not pre-add it).
  Note: against today's committed source the two `PGRGate` entries are
  slack — only `fromFile:` actually touches the triad — carried because
  they are the ch. 9 letter's ruled sites, not because a use exists;
  only the `fromFile:` entry gets a liveness pin (the B-15 assertion
  below).

**The B-15 reconciliation (agent call, recorded veto-open in `chunks.md`):**
the accepted `PGRConfiguration class>>fromFile:` (E05-C01, owner-scheduled
B-15) reads file contents under
`on: FileException, ZnCharacterEncodingError do:` — it therefore
**references a Zinc-defined class**. The ch. 9 Zinc-arm letter predates
B-15's landing; reddening accepted, owner-scheduled ground is not this
test's job. Resolution: **the Zinc/Network/Zodiac arm carries the same
three-method allowlist as the file-triad arm** — the encoding-error catch
is inside the ruled artifact-read site. The test *pins* the reconciliation:
it asserts `fromFile:` **does** reference a Zinc-defined class (so a silent
future removal of the B-15 wrap is visible) and that no method outside the
allowlist references any.

**Sweep design.** All sweeps share helpers on the test class:

- `productionPackageNames` — the seven names above, verbatim.
- `methodsInPackageNamed:` — the package's `definedClasses`, instance and
  class side (`cls methods` + `cls class methods`); extension methods a
  package defines on classes elsewhere are outside the contract (the
  E08-addendum/B-05 reading; `src/` currently carries none). A classless
  package contributes zero methods, not an error.
- `definingPackageNameOf:` — a referenced class's own package name
  (`cls package name`).
- one generic sweep: collect every (method, referenced class) pair whose
  referenced class satisfies a ban predicate and whose method is not
  allowlisted; assert the collection is empty **with the offenders in the
  failure description** (Class>>#selector · referenced class).

**Every sweep must prove itself live** — a wrong ban predicate must be a
red test, never a silent vacuous pass (the scanned-nonzero rule, applied
twice):

1. each test asserts its sweep visited a nonzero method count (floors
   below);
2. each ban predicate is asserted true against a known-banned witness:
   `TestCase` and `ReAbstractRule` (engine arm — via their live defining
   packages), the string `'Toy-Core'` (client arm — string-level: the toy
   packages are classless at M1, so no class witness exists),
   `PGRRegistry` (kit-edge arm), `PCKFixCommand` (gate-wall arm),
   `ZnCharacterEncodingError` (network arm), `FileReference` (file-triad
   arm), and the test class's own `transcriptLivenessPlant` method
   (Transcript arm — see TESTS FIRST).

**Ban lists by defining-package name prefix** (engine arm): start from
`#('SUnit' 'Renraku' 'AST-Core' 'Refactoring')` and adjust to whatever the
live image answers for the defining packages of `TestCase`,
`ReAbstractRule`, `RBParser`, and `RBParseTreeRewriter` — the witness
assertions in (2) force the list right; record the final list in the
completion report (P5). Network arm prefixes: `#('Zinc' 'Network'
'Zodiac')`.

**⟨verify-in-image⟩ items delegated to you, record-in-report duty (P5, the
E04/E06 precedent):** the `referencedClasses` spelling on `CompiledMethod`
(or the equivalent per-method reflective source — whatever the live image
provides; the letter, not the spelling, is frozen) · the literals scan
spelling for the Transcript arm (`allLiterals` / `hasLiteral:` family —
must see both the global binding and a plain `#Transcript` symbol) · the
witness classes' actual defining package names.

**Constitution rules that bite here:** no global state (helpers are
instance/class-side methods, no caches) · test methods assert behavior — a
test that cannot fail is a defect (hence the liveness witnesses) · comments
state constraints the code cannot show (the liveness plant's comment is
exactly that) · no `skip`/`expectedFailures`.

**Glossary rows that bite:** gate-runnable things are *checks*; this class
is a plain SUnit *test* (it never registers) — nothing here touches the
registry.

## DELIVERABLES

- `src/Phi-Guardrails-Tests-Core/PGRArchSelfTest.class.st` — new; class
  `PGRArchSelfTest` (subclass of `TestCase`, package
  `Phi-Guardrails-Tests-Core`): the six test methods, the sweep helpers,
  and the `transcriptLivenessPlant` witness method. Nothing else — no other
  file, no package.st edits (Tonel needs none for an added class).
- LOC budget: target 155 / ceiling 300.

## TESTS FIRST

All six are the chunk's product (no non-test product code). Skeletons:

- `testCoreReferencesNoEngineClass` — given every method defined in
  `Phi-Guardrails-SDK` and `Phi-Guardrails-Core` (≥ 40 methods scanned,
  asserted); when referenced classes are collected; then none is defined in
  an engine package (prefix list above), and the ban predicate holds for
  `TestCase`'s and `ReAbstractRule`'s live defining packages.
- `testProductionReferencesNoClientClass` — given every method in the seven
  production packages (≥ 100 scanned, asserted); then no referenced class
  is defined in a package whose name begins `'Toy-'`, and the predicate
  holds for the string `'Toy-Core'`.
- `testKitPackagesReferenceOnlySDK` — given every method in every loaded
  package whose name begins `'Phi-Coding-Kit'` (≥ 60 scanned, asserted);
  then no referenced class is defined in `Phi-Guardrails-Core` or
  `Phi-Guardrails-Gate`, and the predicate holds for `PGRRegistry`.
- `testGateReferencesNoKitClass` — given every method in
  `Phi-Guardrails-Gate` (≥ 10 scanned, asserted); then no referenced class
  is defined in a `Phi-Coding-Kit*` package, and the predicate holds for
  `PCKFixCommand`.
- `testNoProductionMethodReferencesTranscript` — given every method in the
  seven production packages (≥ 100 scanned, asserted); then none carries
  the `Transcript` global binding or the `#Transcript` symbol among its
  literals; and the detector
  answers true for this class's own `transcriptLivenessPlant` (a helper
  whose body is `^ Transcript` — the deliberate witness, commented as such;
  it lives in a tests-role package, which no lint registration sweeps,
  D-33).
- `testNoNetworkOrStrayFileReferences` — given every method in the seven
  production packages (≥ 100 scanned, asserted); then (arm 1) no referenced class is defined in a
  `Zinc-*`/`Network-*`/`Zodiac-*` package except from the three allowlisted
  methods, and `PGRConfiguration class>>#fromFile:` **does** reference a
  Zinc-defined class (the B-15 pin); (arm 2) no method outside the same
  allowlist references `FileReference`, `FileSystem`, or `FileLocator`.

Fixtures: none — the subject is the committed production code itself.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 6 `PGRArchSelfTest`
          methods **plus every previously accepted suite** — membership
          plus a floor (≥ 180 run = 174 + 6; parallel-landed E09 chunks
          add to the count), never an exact ceiling.

OUT OF SCOPE
- `PCKSrcInventoryCheck` or any allowlist entry for it (M2/E11).
- Any layer-map machinery (E10) — these walls are reflective stand-ins.
- Any product-code change anywhere: if a sweep finds a genuine violation in
  accepted production code, **stop and report** (decision sheet) — fixing
  accepted files is outside this manifest.
- Sweeping extension methods (B-05 — deferred ground).
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest file, one commit
          `E09-C01: PGRArchSelfTest reflective walls` (D-73) before
          reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  the recorded ⟨verify⟩ spellings (referencedClasses form, literals scan,
  witness package names, final engine-prefix list) ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
