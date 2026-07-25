# C21 · Envelope parse and shape       [E03 · depends: C20 · parallel: no]

GOAL      Land `PGRConfiguration class>>fromString:` stage 1 — strict STON parse
          plus the full envelope shape law: top-level map with Symbol keys, the
          five required core keys, no unknown top-level key, every core key
          well-shaped — with `project` and `kitBlocks` readers.

TRACE     spec ch. 1 §1.1 (core-owned keys table; strict-validation list, envelope
          arms) · §1.2 (one scope: the file) · D-16 (pure-data STON, strict) ·
          D-51 (core owns the whole envelope; blocks opaque, `#kit` the only
          common field) · R-02, R-24 (validation half), R-47 (the schema) ·
          property P-CFG-STRICT (its named test lands here).

## CONTEXT DIGEST

**What exists:** C20's fixtures in `Phi-Guardrails-Tests-Core`
(`BaselineOfPGRScratchGrouped` with groups `scratch-prod` = Phi-Guardrails-SDK +
Phi-Guardrails-Core · `scratch-tst` = Phi-Guardrails-Tests-SDK · `scratch-ghost` =
PGR-Scratch-Ghost (unloaded) · `scratch-overlap` · `scratch-empty` ·
`scratch-both`; `BaselineOfPGRScratchPlain`, no groups; duck-typed `PGRScratchKit`).
`Phi-Guardrails-Core` is an empty package stub (E01, frozen inventory);
`PGRConfigurationError` is a frozen E02 export: a direct `Error` subclass in
`Phi-Guardrails-SDK`, signalled with a one-line human-facing reason
(`PGRConfigurationError new signal: '...'` or `PGRConfigurationError signal:`) —
its message *text* is not an API, its *class* is.

**The class.** `PGRConfiguration` in `Phi-Guardrails-Core` — the parsed, validated
artifact (a «Core/engine» class, ch. 0 inventory). Public caller surface (freezes
at E03 acceptance): class-side `fromString:` (+ `fromFile:`, C27). Instance
readers are *specified but internal* (E04 consumes them; changeable without a
compatibility promise): this chunk lands `project` and `kitBlocks` (ordered,
verbatim). State via instance variables + private setters in a private-marked
protocol; class-side named constructor, never `new`+setters at call sites.

**The validation pipeline** (fromString:'s stages, built up across C21–C27 in
this fixed order — each later chunk appends a stage; this chunk lands 1–2):

1. **Parse** — `STON fromString: aString`.
2. **Envelope shape** (this chunk).
3. Schema-version law (C22). 4. Kit/baseline resolution (C23). 5. Role-matcher
expansion (C24). 6. Scope law + loadedness (C25). 7. Exempt-name patterns (C26).
8. `#src` anchor rules (C27).

**The envelope, verbatim from ch. 1 §1.1:** one map with Symbol keys. Core-owned
keys — `#schemaVersion` (Integer) · `#project` (String) · `#kits` (ordered array
of kit blocks, ≥1; each block a map whose **only common field** is `#kit`, a
String naming the kit class — everything else in a block is kit-custom and
**opaque to the core**: never validated, never interpreted here, handed verbatim)
· `#baseline` (String) · `#roles` (map: role → list of matcher Strings; exactly
the keys `#production`, `#tests`, optionally `#exempt`; `#production` and
`#tests` mandatory) — all five required. Optional: `#src` (String) ·
`#exemptNamePatterns` (list of Strings). **There are no other top-level keys**
(D-51): an unknown top-level key is a configuration error. Signal
`PGRConfigurationError` with the offending key/name in the message for every arm
(P-CFG-STRICT).

**Verified spellings (probed 2026-07-25, D-31.a work image — record: E03
chunks.md §probes; P5):**

- `STON fromString: '{ #a : 1, #b : [ ''x'' ] }'` → a `Dictionary` with Symbol
  keys (`ByteSymbol`); STON lists → `Array`.
- Malformed input (`'{ #a : '`) signals `STONReaderError`, an `Error` subclass —
  wrap the parse and re-signal as `PGRConfigurationError` (a caller catches by
  class, D-49; `STONReaderError` must never escape `fromString:`).
- **Class-tagged STON parses silently** (`'OrderedCollection [ 1 ]'` answers an
  `OrderedCollection`, no error): "pure-data STON" is enforced by *our* shape
  checks, not by the reader — the top-level Dictionary test refuses a class-tagged
  top level, and the per-key shape checks refuse class-tagged core-key values.
  (Class-tagged values *inside* a kit block are the block's owner's problem —
  blocks are opaque, D-51.)
- `isSymbol` / `isString` / `isInteger` / `isArray` / `isDictionary` are the shape
  predicates (`Symbol` is a `String` — test symbol-ness *before* string-ness where
  it matters; STON map keys arrive as Symbols, values written `'x'` as Strings).

**The canonical green artifact** — the test-side helper `validArtifactString`
(instance method on the test class, C21's deliverable, reused by every later
chunk; written against C20's fixtures so it stays green as validation tightens
through C27):

```smalltalk
validArtifactString
    ^ '{
        #schemaVersion : 2,
        #project : ''Scratch'',
        #baseline : ''BaselineOfPGRScratchGrouped'',
        #roles : {
            #production : [ ''scratch-prod'' ],
            #tests : [ ''scratch-tst'' ],
            #exempt : [ ''scratch-ghost'' ] },
        #kits : [ { #kit : ''PGRScratchKit'' } ]
    }'
```

Plus one small mutation helper so defect arms stay one-liners (agent detail —
e.g. `artifactWithout: aKey` / `artifactWith: aKey value:` operating on the
parsed-and-re-written STON, or plain per-test literal strings; implementer's
choice, kept inside this test class).

**Constitution rules that bite here:** strict parsing — malformed or unknown
input raises a configuration error, never a silent default (family 7); glossary
exactly (*configuration artifact*, *kit block* — never "section"; *configuration
error*); `PGR` prefix; no global state; class-side named constructors; comments
state constraints code cannot show; R-04 — nothing in `-Core` references
SUnit/Renraku/RB classes (STON and the SDK are fine).

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `tools/build-image.sh` load from the
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it
and asserts run count plus the 5 smoke tests.

## DELIVERABLES

- `src/Phi-Guardrails-Core/PGRConfiguration.class.st` — the class, stages 1–2 of
  the pipeline, readers `project` and `kitBlocks`.
- `src/Phi-Guardrails-Tests-Core/PGRConfigurationTest.class.st` — the mirror test
  with `validArtifactString` (+ mutation helper) and the tests below.
- LOC budget: target 140 / ceiling 240.

## TESTS FIRST

Test methods on `PGRConfigurationTest`:

- `testValidArtifactParses` — given `validArtifactString` / when
  `PGRConfiguration fromString:` / then an instance is answered whose `project` =
  `'Scratch'` and whose `kitBlocks` has exactly one block whose `#kit` value is
  `'PGRScratchKit'` (handed verbatim).
- `testUnknownKeySignals` — **P-CFG-STRICT's named test** — given the valid
  artifact plus a top-level `#extra : 1` / then `fromString:` signals
  `PGRConfigurationError` whose message contains `'extra'` (the offending key is
  named).
- `testNonMapTopLevelSignals` — given `'[ 1 ]'` (parses fine, wrong shape) / then
  `PGRConfigurationError`; and given `'{ ''schemaVersion'' : 2 }'` (a map whose
  keys are Strings, not Symbols — constructible STON) / then
  `PGRConfigurationError` (the top level must be a map **with Symbol keys** —
  the §1.1 first arm, explicit, not merely caught by the missing-key arm).
- `testMalformedStonSignals` — given `'{ #a : '` / then `PGRConfigurationError`
  (never a naked `STONReaderError` — assert the class).
- `testMissingCoreKeySignals` — given the valid artifact with `#roles` removed /
  then `PGRConfigurationError` naming `roles`.
- `testKitsBlockShapeSignals` — given `#kits : [ ]` / then signals; and given
  `#kits : [ { #notKit : ''X'' } ]` (a block without `#kit`) / then signals
  (malformed-block arm of P-CFG-STRICT).
- `testRolesShapeSignals` — given `#roles` missing `#tests` / then signals; and
  given a `#roles` map with an extra key `#extraRole : [ ]` / then signals naming
  it (exactly `#production`/`#tests`/`#exempt` are legal).

Fixtures: C20's (referenced by name only in this chunk — resolution starts at
C23; the green artifact simply carries names that will keep resolving later).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 7 `PGRConfigurationTest` methods
          above, the 7 `PGRScratchFixturesTest` methods, the 19 accepted E02 SDK
          tests, and the 5 `PGRBaselineSmokeTest` methods (regression guard).

OUT OF SCOPE
- Any resolution or expansion: `#kit`/`#baseline` name lookup (C23), matchers
  (C24), scope law (C25), `#exemptNamePatterns` semantics (C26 — only its
  is-an-array-of-strings *shape* is checked here), `#src` semantics (C27 — only
  its is-a-String shape here), the schema-version *value* law (C22 — only
  Integer-ness here).
- Duplicate registration names — an E04 (registry) concern; names do not exist at
  parse time.
- Opening a kit block beyond reading `#kit` — blocks are opaque (D-51).
- Editing the baseline, any `package.st`, or anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `C21: envelope parse and shape` before reporting for review; nothing
          left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
