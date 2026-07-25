# C23 · Kit and baseline resolution    [E03 · depends: C22 · parallel: no]

GOAL      Resolve every block's `#kit` to a loaded, class-side-conforming kit
          class and `#baseline` to a loaded `BaselineOf` subclass, exposing
          `kitClasses` and `baselineClass`.

TRACE     spec ch. 1 §1.1 (strict list: `#kit` / `#baseline` resolution arms) ·
          §1.4 step 1 (resolve the block's kit class; failure → configuration
          error) · D-53 (conformance, not ancestry) · D-25.a (`inheritsFrom:
          BaselineOf`) · R-24 (validation half) · P-CFG-STRICT (unknown-kit arm).

## CONTEXT DIGEST

**What exists:** `PGRConfiguration class>>fromString:` runs pipeline stages 1–3
(strict parse · envelope shape · schema-version {2}); readers `project`,
`kitBlocks`. Test class `PGRConfigurationTest` carries `validArtifactString`
(baseline `'BaselineOfPGRScratchGrouped'`, one block `{ #kit : 'PGRScratchKit' }`,
roles production `['scratch-prod']` / tests `['scratch-tst']` / exempt
`['scratch-ghost']`, schemaVersion 2) plus a mutation helper. C20's fixtures:
`BaselineOfPGRScratchGrouped` and `BaselineOfPGRScratchPlain` (both `BaselineOf`
subclasses, loaded), and `PGRScratchKit` — a **plain `Object` subclass**,
class-side `registrationsFrom:productionPackages:testsPackages:` +
`recommendedBlock` (the duck-type witness). `PGRConfigurationError`: frozen E02
`-SDK` export, direct `Error` subclass; class is API, wording is not. Frozen E02
kit protocol (digest): exactly the two class-side selectors
`#registrationsFrom:productionPackages:testsPackages:` and `#recommendedBlock`.

**This chunk appends pipeline stage 4**, after the version law:

- **Kit resolution, per block, in order:** `Smalltalk classNamed: kitName`
  (verified 2026-07-25: answers the class, or nil for an unknown name — record:
  E03 chunks.md §probes). nil → `PGRConfigurationError` naming the kit name.
  A resolved class must **conform class-side** to the kit protocol: it
  `respondsTo:` both frozen selectors above (class-side `respondsTo:` verified
  same probe). Nonconformance → `PGRConfigurationError` naming the class **and
  the missing selector** (the D-53 error style).
- **The conformance-not-ancestry reading (agent call, veto-open — recorded in
  chunks.md §agent-calls):** §1.1's strict list says "a loaded `PGRKit`
  subclass"; the ruling ground says conformance — D-53 ("conformance, not
  ancestry, is what registration requires"), `PGRKit`'s frozen class comment ("a
  duck-typed plain class implementing the pair registers fine"), and the frozen
  roadmap's E04 row (its conformance tests use *duck-typed scratch kits*, which
  an ancestry check here would reject at parse). The decision log wins over older
  prose (constitution preamble), so this chunk checks **class-side conformance**,
  never `inheritsFrom: PGRKit`. `PGRScratchKit` is the witness.
- **Baseline resolution:** `Smalltalk classNamed: baselineName` — nil →
  `PGRConfigurationError` naming it; a resolved class must satisfy
  `inheritsFrom: BaselineOf` (D-25.a verified spelling) → else
  `PGRConfigurationError` naming the class.
- **Readers (specified-but-internal, E04/C24 consume):** `kitClasses` — the
  resolved classes, ordered as the `#kits` array, parallel to `kitBlocks`;
  `baselineClass` — the resolved class.

**Constitution rules that bite here:** no `isKindOf:`/`class ==` type predicates —
`respondsTo:` and `inheritsFrom:` here are the *specified contract checks* (the
ruled conformance/baseline tests, not type-dispatch workarounds; say so in a
comment only if the code cannot show it); strict parsing (family 7); glossary
exactly (*kit* — the class; *kit block* — the map); R-04 (no SUnit/Renraku/RB in
`-Core`).

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `tools/build-image.sh` load from the
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it
and asserts run count plus the 5 smoke tests.

## DELIVERABLES

- `src/Phi-Guardrails-Core/PGRConfiguration.class.st` — modify: stage 4 +
  `kitClasses`/`baselineClass` readers.
- `src/Phi-Guardrails-Tests-Core/PGRConfigurationTest.class.st` — modify: the
  five tests below.
- LOC budget: target 100 / ceiling 180.

## TESTS FIRST

Test methods on `PGRConfigurationTest`:

- `testResolvedKitAndBaselineReaders` — given the valid artifact / then
  `kitClasses` = an ordered collection of exactly `PGRScratchKit` (the class, not
  the name — and a duck-typed one: the conformance path, D-53) and
  `baselineClass` = `BaselineOfPGRScratchGrouped`.
- `testUnknownKitClassSignals` — **P-CFG-STRICT unknown-kit arm** — given the
  block `{ #kit : 'PGRNoSuchKit' }` / then `PGRConfigurationError` naming
  `'PGRNoSuchKit'`.
- `testNonKitClassSignals` — given `{ #kit : 'PGRFinding' }` (loaded, answers
  neither kit selector) / then `PGRConfigurationError` whose message contains
  `'PGRFinding'` and the missing selector's spelling.
- `testUnknownBaselineSignals` — given `#baseline : 'BaselineOfPGRNoSuch'` /
  then `PGRConfigurationError` naming it.
- `testNonBaselineClassSignals` — given `#baseline : 'PGRFinding'` (loaded, not a
  `BaselineOf` descendant) / then `PGRConfigurationError` naming it.

Fixtures: C20's; `PGRFinding` (frozen E02 SDK value class) doubles as the loaded
non-kit, non-baseline class — nothing new.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 5 new tests, the 10 prior
          `PGRConfigurationTest` methods, the 7 `PGRScratchFixturesTest` methods,
          the 19 accepted E02 SDK tests, and the 5 `PGRBaselineSmokeTest`
          methods (regression guard).

OUT OF SCOPE
- Sending either kit-protocol message — resolution stops at conformance; the
  handoff (`registrationsFrom:…`) is `PGRRegistry`'s, E04.
- Instance-side check conformance / kind agreement — E04 (on specs, D-60).
- Matcher expansion (C24) and everything after it.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `C23: kit and baseline resolution` before reporting for review;
          nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
