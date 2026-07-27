# E10-C06 · Kit-side `#layerMap` dispatch — give the parameter key its consumer  [depends: E10-C02, E10-C04 · parallel: no]

GOAL      Give `PCKKit` its `#layerMap` consumer: when the block presents `#layerMap`, parse+validate it against the production role (completeness law); when `#architectureChecks` names `PCKLayerMapCheck`, construct it with that map (absent map → missing; unloaded layer package → missing), while every other architecture-check entry keeps the generic `packages:` path unchanged.

TRACE     R-19 (client-supplied map through the generic engine) · R-21 (one more constraint = one more registration; the generic client-arch path stays) · R-43 · spec ch. 4 §4.1 (present ⇒ validated) · §4.2 (registration name `architecture/PCKLayerMapCheck`) · §4.3 (kit instantiates its own check richer than `packages:`; generic client checks via `packages:`) · §1.5 (required parameter key absent / unloaded → missing) · D-35/D-79/D-79.a (the map's semantics, delivered by C01–C04) · E06 frozen digest (the block schema + `#layerMap` "carried unread until E10 gives it its consumer").

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**This is the scheduled `#layerMap` consumer.** E06 froze `PCKKit`'s block schema and
recorded that `#layerMap` is "a parameter key: a present map is carried, unread, until E10
gives it its consumer" — and the accepted test's own comment says "carried … until E10
gives it its consumer **and its shape validation**." So this chunk realizing the consumer is
**scheduled ground**, not a silent frozen-surface amendment; it amends exactly one accepted
test (the amendment table below is scripted, not remembered).

**The accepted `PCKKit` surface you extend (verbatim — the E06-frozen method).**
`PCKKit class >> registrationsFrom: aBlock productionPackages: productionNames
testsPackages: testsNames` answers ordered `PGRRegistrationSpec`s in the canonical order
lint → architecture → behavioral → meta. Its current body (relevant excerpt):

```smalltalk
self validateBlock: aBlock.
specs := OrderedCollection new.
cache := PCKSuiteRunCache new.
(aBlock at: #lintRules ifAbsent: [ #() ]) do: [ :each |
    specs add: (self lintSpecFor: each productionPackages: productionNames) ].
(aBlock at: #architectureChecks ifAbsent: [ #() ]) do: [ :each |
    specs add: (self
        promisedSpecFor: each
        prefix: 'architecture/'
        kind: #architecture
        packages: productionNames) ].
specs addAll: (self behavioralSpecsFor: testsNames cache: cache).
(aBlock at: #metaRules ifAbsent: [ #() ]) do: [ :each |
    specs add: (self metaRuleSpecFor: each packages: testsNames cache: cache) ].
^ specs
```

- `promisedSpecFor: aName prefix: p kind: k packages: roleNames` (the generic path):
  unresolved name → `PGRRegistrationSpec missing: p,aName kind: k reason: ...`; resolved and
  answering class-side `packages:` → `PGRRegistrationSpec name: p,aName kind: k check:
  (cls packages: roleNames)`; resolved but no `packages:` constructor → `PGRConfigurationError`.
  **This path is unchanged for every arch check other than `PCKLayerMapCheck`** (that is how
  §4.3's "a genuinely new client arch check via `packages:`" and R-21 keep working).
- `validateBlock: aBlock` — strict envelope; its comment already says "#layerMap is only
  recognized here — its shape is E10's to validate." It currently validates only the three
  list keys (`#lintRules`/`#architectureChecks`/`#metaRules`) as String lists.
- `PGRRegistrationSpec` (frozen E02) — class-side `name:kind:check:` and
  `missing:kind:reason:`.

**What this chunk adds (§4.1/§4.2/§4.3/§1.5):**
1. **Parse+validate `#layerMap` whenever present** (spec §4.1: "when `#layerMap` is present,
   the layers and `#unlayered` must jointly cover every production-role package"). In
   `registrationsFrom:`, before/at the architecture pass, compute once:
   `layerMap := aBlock at: #layerMap ifPresent: [ :sub | PCKLayerMap fromLayerMap: sub
   productionPackages: productionNames ] ifAbsent: [ nil ]`. A malformed or non-covering map
   therefore raises `PGRConfigurationError` at block-open (family 7; strict), regardless of
   whether the check is registered — the config author's error is loud and single-sourced.
2. **Special-case `PCKLayerMapCheck` in the `#architectureChecks` pass** (identity, exactly
   as `metaRuleSpecFor:` special-cases the kit's own `PCKNoSkippedTestsMetaRule` — not
   kinship, `== PCKLayerMapCheck`). When the resolved class **is** `PCKLayerMapCheck`:
   - `#layerMap` absent (`layerMap` is nil) → `PGRRegistrationSpec missing:
     'architecture/PCKLayerMapCheck' kind: #architecture reason: <required #layerMap absent>`
     (§1.5 required-parameter-key-absent → missing).
   - some declared layer package not loaded (resolve each via `PackageOrganizer default
     packageNamed: name ifAbsent: [ nil ]`, any nil) → `PGRRegistrationSpec missing:
     'architecture/PCKLayerMapCheck' kind: #architecture reason: <names the unloaded package>`
     (§1.5 unloaded → missing).
   - otherwise → `PGRRegistrationSpec name: 'architecture/PCKLayerMapCheck' kind:
     #architecture check: (PCKLayerMapCheck layerMap: layerMap)`.
   Every **other** arch entry stays on `promisedSpecFor:` (the `packages:` generic path).
   Registration name is `architecture/PCKLayerMapCheck` (§4.2).
3. **Extend `validateBlock:`** only enough to reject a `#layerMap` value that is not a map
   (envelope shape), keeping the deep structural/coverage validation in `PCKLayerMap`
   (C01/C02) — do not duplicate `PCKLayerMap`'s checks in the kit.

Refactor freedom: you may add a private `architectureSpecFor: aName layerMap: aLayerMapOrNil
packages: productionNames` helper and call it from the `#architectureChecks` loop; keep
`promisedSpecFor:` intact for the non-layer-map path.

**Builds on (accepted):** `PCKLayerMap` (C01/C02) — `fromLayerMap:productionPackages:`;
`PCKLayerMapCheck` (C04) — class-side `layerMap:`, `kind` `#architecture`.

**Constitution rules that bite:** strict parsing (present map ⇒ validated, never silent
default); no global state (the parsed map is a local, discarded with the specs — never
cached class-side); dispatch by identity/lookup, not `isKindOf:`; the four-stage answer
order is unchanged; glossary terms exact. Touching any file outside the manifest below is a
review rejection.

**Verified spellings (P5):** `aDictionary at: k ifPresent: [:v|...] ifAbsent: [...]` ·
`PackageOrganizer default packageNamed: name ifAbsent: [...]` · `Smalltalk globals at:
name asSymbol ifAbsent: [nil]` (the accepted class-lookup spelling PCKKit already uses) ·
`==` identity compare against `PCKLayerMapCheck` (the accepted own-meta-rule pattern).

DELIVERABLES

Files (Tonel):
- **modify** `src/Phi-Coding-Kit/PCKKit.class.st` (extend `registrationsFrom:…`,
  `validateBlock:`; add the private arch-dispatch helper).
- **modify** `src/Phi-Coding-Kit-Tests-Rules/PCKKitTest.class.st` (amend the one accepted
  test per the table; add the new tests below).

LOC budget: target ~130 · ceiling 300.

── AMENDED-SURFACE TABLE (scripted over committed sources; the ONLY accepted test E10 changes) ──

Amended surface: `PCKKit class>>registrationsFrom:productionPackages:testsPackages:` — the
`#architectureChecks` dispatch and the newly-read `#layerMap` key. Enumeration script (run
against `src/`, output recorded in this cut's report):
- accepted tests that **present** a `#layerMap` key: **1** —
  `PCKKitTest>>testLayerMapKeyProducesNoRegistrationsAndNoError` (line 64).
- accepted tests/artifacts that **register `PCKLayerMapCheck` through a kit block**
  (`#architectureChecks` naming it): **0** (the other `#architectureChecks` entries name
  `PCKArchStubCheck` / `PGRFinding` / `PCKNoSuchCheck` — all stay on the generic path,
  unaffected).
- live references to `PCKLayerMapCheck` elsewhere: `PGRReportTest` lines 74/86 use the
  **string** `'architecture/PCKLayerMapCheck'` as a rendering fixture (no kit call) —
  unaffected. `PCKArtifactBlockM1FormTest` line 52-53 asserts the M1 artifact does **not**
  include `#architectureChecks`/`#layerMap` — unaffected (E11, not E10, completes the
  artifact).

| Accepted consumer | Current behavior | New behavior (this chunk) | Amendment |
|---|---|---|---|
| `PCKKitTest>>testLayerMapKeyProducesNoRegistrationsAndNoError` (line 64) | presents `#layerMap` = `{ #layers → Dictionary new }` (empty layers) with production `#('P-One')`, expects it **carried unread** → 2 specs (lint + behavioral sentinel), no error | `#layerMap` present ⇒ validated; empty layers do not cover `P-One` ⇒ **`PGRConfigurationError`** (completeness law) | **amend**: replace the empty/uncovering map with a **valid covering** map (e.g. `#layers → { 'p' → #('P-One') }`, no `#architectureChecks`) so the test still proves "present, valid, unconsumed ⇒ no registration, no error" (2 specs). The uncovering case moves to the new `testPresentButUncoveringLayerMapSignals` below. |

No other accepted test's behavior changes. (Every non-`PCKLayerMapCheck` `#architectureChecks`
test exercises the untouched `promisedSpecFor:` path — assert this stays green as the
regression guard.)

── CLASSES/METHODS ──
- `PCKKit class >> registrationsFrom:productionPackages:testsPackages:` — add the
  parse-when-present of `#layerMap` and route the `#architectureChecks` loop through the new
  helper.
- `PCKKit class >> architectureSpecFor: aName layerMap: aLayerMapOrNil packages: productionNames`
  (private) — the `== PCKLayerMapCheck` special case (absent-map/unloaded → missing;
  else `layerMap:` construction) falling back to `promisedSpecFor:` for every other name.
- `PCKKit class >> validateBlock:` — reject a non-map `#layerMap` value.

TESTS FIRST  (`PCKKitTest`; build blocks as `Dictionary`s exactly as accepted tests do)

- `testLayerMapKeyProducesNoRegistrationsAndNoError` *(amended per table)* — present, valid,
  covering `#layerMap`, **no** `PCKLayerMapCheck` entry; then specs are exactly the lint +
  behavioral-sentinel pair, no error (the map is validated but contributes no registration).
- `testPresentButUncoveringLayerMapSignals` *(new)* — present `#layerMap` whose layers do
  **not** cover the production role, no `#architectureChecks`; then
  `registrationsFrom:…productionPackages: #('P-One')…` signals `PGRConfigurationError`
  naming `'P-One'` (present ⇒ validated, §4.1).
- `testLayerMapCheckConstructedWithMapWhenRegistered` *(new)* — block with
  `#architectureChecks` = `#('PCKLayerMapCheck')` and a valid `#layerMap` covering the
  production role; then a spec named `'architecture/PCKLayerMapCheck'`, kind `#architecture`,
  whose `check` is a `PCKLayerMapCheck` (`check kind` = `#architecture`).
- `testLayerMapCheckMissingWhenNoMap` *(new)* — `#architectureChecks` = `#('PCKLayerMapCheck')`
  and **no** `#layerMap`; then the spec named `'architecture/PCKLayerMapCheck'` is a missing
  spec (`check` is nil, kind `#architecture`) whose reason names the absent `#layerMap`
  (§1.5).
- `testLayerMapCheckMissingWhenLayerPackageUnloaded` *(new)* — `#architectureChecks` =
  `#('PCKLayerMapCheck')` and a `#layerMap` whose layer names a package **not loaded** but
  listed in the handed production role (so completeness passes on names); then the spec is
  missing, reason naming the unloaded package.
- `testGenericArchitectureCheckStillUsesPackagesConstructor` *(regression, R-21/§4.3)* —
  `#architectureChecks` = `#('PCKArchStubCheck')` (the accepted stub, a non-owned arch
  check); then it still resolves via `packages:` to a spec `'architecture/PCKArchStubCheck'`
  with `check packages` = the production list — the special case did not disturb the generic
  path.

Fixtures: reuse the accepted `PCKArchStubCheck` (already in `Phi-Coding-Kit-Tests-Rules`,
inert). Maps are inline `Dictionary`s; the "unloaded" test uses a name absent from the image
but present in the handed production list.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors; `PCKKitTest` carries the amended test plus
          the five new ones (all named), and **every other accepted `PCKKitTest` case and
          every non-layer-map `#architectureChecks` test stays green** (the regression guard
          on the untouched `promisedSpecFor:` path); every previously accepted suite green.
          Assert named-suite membership plus a floor of **≥226 run** (195 + C01–C04's 26
          tests + this chunk's 5 net-new; C05's 4 are independent of C06 and not assumed;
          the amended test is not additive), never an exact ceiling.

OUT OF SCOPE
- Adding `#layerMap` / `#architectureChecks` to the framework's own `guardrails.ston`, or
  completing the §7.5 artifact — **E11** (the M1 artifact form froze at E09; E10 does not
  self-host the layer map).
- `PCKKit recommendedBlock` — the layer-map check is client-specific (needs a client map),
  never in the recommended block; leave it byte-identical.
- Changing `promisedSpecFor:`, `lintSpecFor:`, `behavioralSpecsFor:`, `metaRuleSpecFor:`, or
  the four-stage order.
- Any change to `PCKLayerMap` / `PCKLayerMapCheck` (C01–C05 froze them for this epic).

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition: one
commit `E10-C06: kit-side #layerMap dispatch`, nothing uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  confirmation the amendment table held (only the one accepted test changed; the generic
  arch path stayed green) · deviations (each one-line justified) ·
  new questions for the decision sheet.
