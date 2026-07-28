# E11-C04 · Kit-side environment form + `PCKSrcInventoryCheck` dispatch  [depends: E11-C01, E11-C03 · parallel: no]

GOAL      Give `PCKKit` the D-81 environment form — `registrationsFrom:environment:` as the one pipeline, the frozen three-argument message delegating through a degenerate view — and give `PCKSrcInventoryCheck` its dispatch: named in `#architectureChecks`, it is constructed over the view's `srcPath` and full package inventory, or goes missing when the view declares no `#src` (§1.5), while the layer-map and generic architecture paths stay byte-equivalent.

TRACE     D-81 rulings 1–3 (the view crosses the boundary; additive landing; internal delegation shape is the cut's) · D-53.5 (never the configuration object) · spec ch. 7 §7.5 (registration `architecture/PCKSrcInventoryCheck`; missing without `#src`) · ch. 1 §1.5 (the `#architecture` missing row names `#src` for `PCKSrcInventoryCheck` — an envelope key) · ch. 9 P-NO-DEAD-SRC (the missing leg, `testMissingWithoutSrcKey`, lands here) · D-25 (the scope law that makes production+tests+exempt the full baseline inventory) · R-21/§4.3 (the generic `packages:` path stays).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**The accepted `PCKKit` surface you extend (verbatim, current bodies).**

`PCKKit class >> registrationsFrom: aBlock productionPackages: productionNames
testsPackages: testsNames` (the frozen E02 contract) currently:

```smalltalk
| specs cache layerMap |
self validateBlock: aBlock.
specs := OrderedCollection new.
cache := PCKSuiteRunCache new.
layerMap := aBlock
    at: #layerMap
    ifPresent: [ :sub | PCKLayerMap fromLayerMap: sub productionPackages: productionNames ]
    ifAbsent: [ nil ].
(aBlock at: #lintRules ifAbsent: [ #() ]) do: [ :each |
    specs add: (self lintSpecFor: each productionPackages: productionNames) ].
(aBlock at: #architectureChecks ifAbsent: [ #() ]) do: [ :each |
    specs add: (self architectureSpecFor: each layerMap: layerMap packages: productionNames) ].
specs addAll: (self behavioralSpecsFor: testsNames cache: cache).
(aBlock at: #metaRules ifAbsent: [ #() ]) do: [ :each |
    specs add: (self metaRuleSpecFor: each packages: testsNames cache: cache) ].
^ specs
```

`PCKKit class >> architectureSpecFor: aName layerMap: aLayerMapOrNil packages:
productionNames` (private, E10) — dispatch by class identity:

```smalltalk
(Smalltalk globals at: aName asSymbol ifAbsent: [ nil ]) == PCKLayerMapCheck ifFalse: [
    ^ self
        promisedSpecFor: aName
        prefix: 'architecture/'
        kind: #architecture
        packages: productionNames ].
aLayerMapOrNil ifNil: [
    ^ PGRRegistrationSpec
        missing: 'architecture/PCKLayerMapCheck'
        kind: #architecture
        reason: 'PCKLayerMapCheck requires the #layerMap parameter key, which is absent' ].
aLayerMapOrNil layers valuesDo: [ :packageNames |
    packageNames do: [ :packageName |
        (PackageOrganizer default packageNamed: packageName ifAbsent: [ nil ]) ifNil: [
            ^ PGRRegistrationSpec
                missing: 'architecture/PCKLayerMapCheck'
                kind: #architecture
                reason: 'layer-map package ' , packageName , ' is not loaded' ] ] ].
^ PGRRegistrationSpec
    name: 'architecture/PCKLayerMapCheck'
    kind: #architecture
    check: (PCKLayerMapCheck layerMap: aLayerMapOrNil)
```

Other accepted private helpers, signatures only (bodies untouched this chunk):
`lintSpecFor:productionPackages:` · `behavioralSpecsFor:cache:` ·
`metaRuleSpecFor:packages:cache:` · `promisedSpecFor:prefix:kind:packages:` ·
`validateBlock:` (strict five-key envelope: `#(kit lintRules architectureChecks
layerMap metaRules)`) · `recommendedBlock`.

**What lands (D-81's additive landing, kit side):**

1. **New class-side `registrationsFrom: aBlock environment: anEnvironment`** — the
   pipeline above moves here, with role lists read off the view
   (`anEnvironment productionPackages` / `testsPackages`) and the architecture
   dispatch now handed the environment (so it can reach `srcPath` and the full
   inventory). Canonical four-stage order, block-key validation, one
   `PCKSuiteRunCache` per call, block-open `#layerMap` validation — all exactly as
   today, just sourced from the view.
2. **The frozen three-argument message becomes a delegation** (D-81: "the
   three-argument contract remains complete for kits that consume no envelope fact;
   internal delegation shape is the cut's"):

   ```smalltalk
   ^ self
       registrationsFrom: aBlock
       environment: (PGRKitEnvironment
           productionPackages: productionNames
           testsPackages: testsNames
           exemptPackages: #()
           srcPath: nil)
   ```

   A three-argument caller therefore sees byte-equivalent behavior for every block
   the M1/E10 ground admits — and, when such a block names `PCKSrcInventoryCheck`,
   the honest §1.5 answer: missing (no `#src` fact exists on that path). `PCKKit`
   referencing `PGRKitEnvironment` is lawful: `kit → sdk` is an allowed edge (§4.4).
3. **The `PCKSrcInventoryCheck` arm in the architecture dispatch** — same identity
   pattern as the layer-map arm (`== PCKSrcInventoryCheck`, the accepted
   own-check special case, never `isKindOf:`). When `#architectureChecks` names it:
   - view `srcPath` nil → `PGRRegistrationSpec missing:
     'architecture/PCKSrcInventoryCheck' kind: #architecture reason:` a string
     naming the absent `#src` envelope key (§1.5: "`#src` for
     `PCKSrcInventoryCheck` — an envelope key").
   - else → `PGRRegistrationSpec name: 'architecture/PCKSrcInventoryCheck' kind:
     #architecture check: (PCKSrcInventoryCheck srcPath: anEnvironment srcPath
     packages: <production + tests + exempt, concatenated from the view>)`. The
     concatenation is the full baseline inventory by the D-25 scope law (roles
     disjoint + jointly total over the baseline's packages).
   Every other name: `PCKLayerMapCheck` keeps its E10 arm verbatim; anything else
   keeps `promisedSpecFor:` (R-21/§4.3 — the generic client path).

**The E11-C01 view surface (this epic's, frozen at acceptance):**
`PGRKitEnvironment class >> productionPackages:testsPackages:exemptPackages:srcPath:`;
readers `productionPackages` · `testsPackages` · `exemptPackages` (fresh copies) ·
`srcPath` (String or nil).

**The E11-C03 constructor (kit-internal):**
`PCKSrcInventoryCheck class >> srcPath: aPathString packages: packageNameCollection`;
instance `kind` = `#architecture`, `run` = the read-only walk.

**Engine note (context only — E11-C02, do not touch):** the engine probes
`respondsTo: #registrationsFrom:environment:` per kit and prefers it; after this
chunk `PCKKit` answers true and is engine-served through the view. The probe folds
inheritance — which is why `PGRKit` (the optional SDK skeleton) must NOT gain the
selector here or ever in v1 (B-28 (4) carries that question post-v1).

**Constitution rules that bite:** strict parsing (unknown key still loud; no new
block key exists — `#src` is an *envelope* key, it never appears in the kit block, so
`validateBlock:` and `blockKeys` are untouched); no global state (view and cache are
call-locals); dispatch by identity, not type predicates; the four-stage order is
frozen ground. Touching any file outside the manifest is a review rejection.

**Verified spellings (P5):** all sends above are accepted-code spellings
(`Smalltalk globals at:ifAbsent:` · `==` identity · `,` on Arrays/OrderedCollections
for concatenation — ⟨verify-in-image⟩ the exact concatenation you write and record
it, e.g. `anEnvironment productionPackages , anEnvironment testsPackages ,
anEnvironment exemptPackages`).

── AMENDED-SURFACE NOTE (scripted; behavior-preserving) ──

The reshaped accepted method is `PCKKit class >>
registrationsFrom:productionPackages:testsPackages:` (delegation; contract
unchanged). Committed callers enumerated by script
(`git ls-files 'src/**/*.st' | xargs grep -l "registrationsFrom:"`), kit-relevant
rows: `PCKKitTest` (drives the three-argument form throughout) ·
`PCKArtifactBlockM1FormTest` (its `m1Specs` helper, three-argument over the
committed M1 artifact — still layer-map-free until E11-C05) ·
`PCKTestSuiteCheckTest` (three-argument, behavioral) · scratch/SDK/core files
untouched by this chunk. **None is amended:** the delegation preserves the answered
specs for every accepted block (no accepted block names `PCKSrcInventoryCheck`;
scripted at the cut: zero hits outside this epic's new tests), witnessed by every
accepted `PCKKitTest` / `PCKTestSuiteCheckTest` / `PCKArtifactBlockM1FormTest`
method staying byte-identical and green. Zero accepted test methods change in this
chunk; `PCKSrcInventoryCheckTest` gains one **new** method (the file is E11-C03's,
accepted within this same epic — an in-epic addition, not an accepted-ground
amendment).

DELIVERABLES

Files (Tonel):
- **modify** `src/Phi-Coding-Kit/PCKKit.class.st` — add
  `registrationsFrom:environment:`; reshape the three-argument method into the
  delegation; extend the architecture dispatch with the `PCKSrcInventoryCheck` arm
  (rename/extend the private helper as needed — private surface is unfrozen); update
  the class comment (two entry points, D-81; the view; the `#src` consumer).
- **modify** `src/Phi-Coding-Kit-Tests-Rules/PCKKitTest.class.st` — add the five
  tests below; every accepted method stays byte-identical.
- **modify** `src/Phi-Coding-Kit-Tests-Architecture/PCKSrcInventoryCheckTest.class.st`
  — add `testMissingWithoutSrcKey` (the P-NO-DEAD-SRC third leg, ch.-9-named into
  this class).

LOC budget: target ~140 · ceiling 300.

TESTS FIRST

`PCKKitTest` additions (build blocks as `Dictionary`s exactly as accepted tests do;
views via `PGRKitEnvironment productionPackages:...testsPackages:...exemptPackages:...srcPath:...`):

- `testEnvironmentFormMatchesThreeArgumentForm` *(the delegation witness)* — given
  one block (the two catalog lint rules + the meta-rule, no architecture keys); when
  answered via the three-argument form and via the environment form over a
  degenerate view (same roles, exempt `#()`, srcPath nil); then the two spec lists
  have equal names, kinds, and missing-nesses pairwise (one pipeline, two doors).
- `testSrcInventoryCheckConstructedFromView` — given a view with srcPath an absolute
  scratch path and production/tests/exempt `#('P-One')`/`#('T-One')`/`#('X-One')`,
  and a block with `#architectureChecks : #('PCKSrcInventoryCheck')`; when the
  environment form runs; then a spec named `'architecture/PCKSrcInventoryCheck'`,
  kind `#architecture`, whose check is a `PCKSrcInventoryCheck` (`check kind` =
  `#architecture`, check notNil).
- `testSrcInventoryCheckMissingWithoutSrc` — same block, view with srcPath nil; then
  the spec of that name is missing (`check` nil) with a reason naming `#src` (§1.5).
- `testThreeArgumentFormAnswersSrcInventoryMissing` — the three-argument form with
  that block; then the same missing spec (the delegation's degenerate view carries
  no `#src` fact — the frozen form stays complete and honest, D-81).
- `testLayerMapPathIntactUnderEnvironmentForm` — given a view (srcPath nil) whose
  production is `#('P-One')` and a block with a covering `#layerMap`
  (`#layers → { 'p' → #('P-One') }`) and `#architectureChecks :
  #('PCKLayerMapCheck')`; when the environment form runs; then the
  `'architecture/PCKLayerMapCheck'` spec is **missing with a reason naming
  `'P-One'` as not loaded** — `P-One` is a scratch name, unloaded in the verify
  image, so this is the deterministic E10 arm (map covers the role at block-open;
  the loaded-ness gate then answers the missing sentinel, exactly the accepted
  `testLayerMapCheckMissingWhenLayerPackageUnloaded` behavior) reproduced
  byte-equivalently through the environment door — the E10 dispatch rides the
  view's production list unchanged.

`PCKSrcInventoryCheckTest` addition:

- `testMissingWithoutSrcKey` *(ch.-9-named, P-NO-DEAD-SRC missing leg)* — given a
  block registering `PCKSrcInventoryCheck` and a view whose `srcPath` is nil (a
  configuration that declares no `#src`); when `PCKKit registrationsFrom: block
  environment: view`; then the `'architecture/PCKSrcInventoryCheck'` spec is
  missing with a `#src`-naming reason (the registration is missing — §1.5 pattern —
  never green, never an error).

Fixtures: inline Dictionaries and views; no files touched on disk (the check is
constructed, never run, in these tests).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors; the six new tests listed by name;
          **every accepted `PCKKitTest`, `PCKTestSuiteCheckTest`, and
          `PCKArtifactBlockM1FormTest` method byte-identical and green** (the
          delegation regression witness); every previously accepted suite green —
          ≥247 run once E11-C01 and E11-C03 are in per the listed serial pick order
          (230 + 6 + 5 + these 6, C02's 3 not assumed); membership + floor, never an
          exact ceiling.

OUT OF SCOPE
- The framework's own artifact (E11-C05 completes it; the committed
  `guardrails.ston` stays byte-identical here).
- `PGRKit` / `PGRRegistry` / any `-Core`/`-Gate`/`-SDK` file (C01/C02 own those; the
  view is consumed, not defined, here).
- `recommendedBlock` — the src-inventory check needs a client `#src` and the
  layer-map check a client map; neither joins the recommended stanza (D-51
  composition; leave the method byte-identical).
- New block keys or `validateBlock:`/`blockKeys` changes (`#src` is an envelope key,
  never a block key).
- Amending any accepted test method.

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition:
one commit `E11-C04: kit environment form + PCKSrcInventoryCheck dispatch`, nothing
uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · confirmation
  every accepted kit-test method stayed byte-identical · which arm
  `testLayerMapPathIntactUnderEnvironmentForm` mirrored and why · deviations (each
  one-line justified) · new questions for the decision sheet.
