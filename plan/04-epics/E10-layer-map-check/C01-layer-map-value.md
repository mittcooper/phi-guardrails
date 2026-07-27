# E10-C01 · `PCKLayerMap` — the layer-map value (parse well-formed + readers + lookups)  [depends: — · parallel: no]

GOAL      A `PCKLayerMap` value that parses a well-formed `#layerMap` sub-map into layers / allowed-pairs / unlayered and answers the two lookups the check's walk needs, with the directed one-way self-referencing dependency rule (D-79) baked into `allowsFrom:to:`.

TRACE     R-18 · R-19 · R-43 (check-support half) · spec ch. 4 §4.1 (the `#layerMap` block key, structure only — completeness law is C02) · D-79 (rulings 1 & 2: self-reference always allowed; allowed pairs directed, one-way, non-transitive) · D-79.a (internal client→client scope) · glossary "layer map" / "layer".

CONTEXT DIGEST

*Everything below is self-contained; do not read other documents to implement this chunk.*

**What this chunk is.** The coding kit's layer-map check (E10) consumes a `#layerMap`
parameter key that, until now, `PCKKit` carries **unread** (frozen E06 comment: "#layerMap
is a parameter key: a present map is carried, unread, until E10 gives it its consumer").
This chunk builds the *value object* that reads it. It does **not** touch `PCKKit`
(that is C06), does **not** validate completeness (that is C02), and does **not** walk any
code (that is C04). Scope here: turn a well-formed sub-map into a usable value and answer
lookups.

**The `#layerMap` sub-map shape (config-author surface — freezes at E10 acceptance).**
STON parses the artifact into in-memory maps before any kit sees them; block keys are
`Symbol`s, layer names are `String`s (client vocabulary). The value handed to
`PCKLayerMap` is the map stored under `#layerMap`, e.g. (STON on the left, parsed shape on
the right):

```
#layerMap : {                                  aDictionary (Symbol keys)
  #layers : {                                    at: #layers -> aDictionary (String keys)
     'ui'          : [ 'Acme-UI' ],                'ui'  -> #('Acme-UI')
     'domain'      : [ 'Acme-Domain' ],            'domain' -> #('Acme-Domain')
     'persistence' : [ 'Acme-Persistence' ] },     'persistence' -> #('Acme-Persistence')
  #allowed : [ [ 'ui', 'domain' ],               at: #allowed -> #( #('ui' 'domain')
               [ 'domain', 'persistence' ] ],                       #('domain' 'persistence') )
  #unlayered : [ 'Acme-Glue' ] }                 at: #unlayered -> #('Acme-Glue')
```

- `#layers` — **mandatory**, a map: layer name (`String`) → list of package-name `String`s.
- `#allowed` — **mandatory**, a list of two-element lists `[ from, to ]`, each element a
  declared-layer name `String`. Semantics: code in layer *from* may reference classes in
  layer *to*. **Directed and one-way** — `['ui','domain']` grants `ui→domain` only, never
  `domain→ui` (D-79 ruling 2). **Not transitive** — `ui→domain` + `domain→persistence`
  does **not** grant `ui→persistence` (D-79 ruling 2). Membership is checked literally,
  never closed over.
- `#unlayered` — **optional**, a list of package-name `String`s deliberately outside every
  layer. Read and stored here; its meaning (unwalked/unjudged) is the check's (C04) and its
  completeness constraints are C02's.

**D-79 ruling 1 (baked into `allowsFrom:to:`):** a layer may always reference itself —
`allowsFrom: 'ui' to: 'ui'` is `true` with no declaration. Intra-layer references need no
`#allowed` entry.

**Frozen SDK vocabulary you may lean on (E02 digest — do not redefine):**
`PGRConfigurationError` is a direct `Error` subclass, catchable by class, signalled with
`PGRConfigurationError signal: aString`. (C01 raises it only for the shape faults listed
under DELIVERABLES; the coverage/production-role faults are C02.)

**Constitution rules that bite here (inline):**
- No global state — no class-side variables, no singletons. `PCKLayerMap` is an ordinary
  instance value; construct, read, discard.
- Pharo idiom — class-side named constructor over `new`+setters; `ifNil:`/`ifNotNil:` over
  `isNil ifTrue:`; no `isKindOf:`/`class ==` type-predicate dispatch; no `self halt` /
  `Transcript show:` / `self flag:`; comments state only what code cannot show.
- Strict parsing (family 7): a **shape** fault (see below) raises `PGRConfigurationError`,
  never a silent default. (Coverage/role faults are C02 — do not pre-implement them.)
- Names use glossary terms exactly: **layer**, **layer map**.

**Verified Pharo 13 spellings (P5 — already used in accepted repo code; cite, don't
re-probe):** `aDictionary at: aKey ifAbsent: [...]`, `aDictionary keysAndValuesDo:
[:k :v | ...]`, `anObject isDictionary`, `anObject isString`, `aCollection isCollection`,
`aCollection allSatisfy: [...]`. STON parses `#layers`' inner map to a `Dictionary` with
`String` keys (same family `PGRConfiguration` reads `#roles` by — reflective precedent, not
a new dependency).

DELIVERABLES

Files (Tonel, exact paths):
- **create** `src/Phi-Coding-Kit-Architecture/PCKLayerMap.class.st`
- **create** `src/Phi-Coding-Kit-Tests-Architecture/PCKLayerMapTest.class.st`

`PCKLayerMap` (package `Phi-Coding-Kit-Architecture`, prefix `PCK`, superclass `Object`,
instVars `layers allowed unlayered`):

- class-side `fromLayerMap: aLayerMapSubMap` — the named constructor. Reads `#layers`
  (mandatory), `#allowed` (mandatory), `#unlayered` (optional, absent → empty). Stores
  copies (`Array withAll:` for lists) so a caller mutating its input cannot reach in.
  Raises `PGRConfigurationError` **only** for the C01 shape faults:
  - `#layerMap` value is not a map (not `isDictionary`) → error naming `#layerMap`.
  - `#layers` absent, or its value is not a map, or empty → error naming `#layers`.
  - a `#layers` value that is not a list of `String`s → error naming the layer.
  - `#allowed` absent, or not a list, or an entry that is not a two-element list of
    `String`s → error naming `#allowed`.
  - `#allowed` names a layer not declared in `#layers` (either element) → error naming the
    undeclared layer.
  - `#unlayered` present but not a list of `String`s → error naming `#unlayered`.
  - (Coverage of the production role, disjointness across layers, layer∩unlayered overlap,
    production-role membership, unknown/unloaded packages — **all C02/C06; not here.**)
- instance readers: `layers` (the stored `Dictionary`), `allowed` (the stored `Array` of
  two-element `Array`s), `unlayered` (the stored `Array`).
- `layerOfPackageNamed: aPackageName` → the layer-name `String` whose package list includes
  `aPackageName`, or `nil` when no declared layer contains it (unlayered or unknown →
  `nil`; distinguishing those is C02/the check's concern, not this lookup's).
- `allowsFrom: aFromLayerName to: aToLayerName` → `Boolean`. `true` iff
  `aFromLayerName = aToLayerName` (self, D-79 ruling 1) **or** the two-element `Array`
  `{ aFromLayerName. aToLayerName }` is among `allowed` (literal directed membership, no
  transitive closure, no reverse — D-79 ruling 2).

LOC budget: target ~110 · ceiling 300 (fixture data exempt — there is none here).

TESTS FIRST  (in `PCKLayerMapTest`, superclass `TestCase`, package
`Phi-Coding-Kit-Tests-Architecture`; build sub-maps as in-image `Dictionary`s exactly as
STON would yield — `Symbol` block keys, `String` layer names)

- `testParsesLayersAllowedAndUnlayered` — given a well-formed sub-map with two layers, one
  allowed pair, one unlayered package; when `fromLayerMap:`; then `layers` has both layer
  keys with their package lists, `allowed` has the one pair, `unlayered` names the one
  package.
- `testUnlayeredDefaultsToEmptyWhenAbsent` — given a sub-map with no `#unlayered`; when
  parsed; then `unlayered` is empty (not nil).
- `testLayerOfPackageNamedFindsDeclaringLayer` — given `'ui'→#('Acme-UI')`; when
  `layerOfPackageNamed: 'Acme-UI'`; then answers `'ui'`.
- `testLayerOfPackageNamedAnswersNilForUnmapped` — given the same map; when
  `layerOfPackageNamed: 'Acme-Nowhere'`; then answers `nil`.
- `testAllowsSelfReferenceWithoutDeclaration` — given a map with layer `'ui'` and no
  `#allowed` self entry; when `allowsFrom: 'ui' to: 'ui'`; then `true` (D-79 ruling 1).
- `testAllowsDeclaredDirectedPair` — given `allowed` contains `['ui','domain']`; when
  `allowsFrom: 'ui' to: 'domain'`; then `true`.
- `testDoesNotAllowReverseOfDeclaredPair` — same map; when `allowsFrom: 'domain' to: 'ui'`;
  then `false` (D-79 ruling 2 — one-way).
- `testDoesNotAllowTransitivePair` — given `allowed` = `['ui','domain']`,
  `['domain','persistence']`; when `allowsFrom: 'ui' to: 'persistence'`; then `false`
  (D-79 ruling 2 — non-transitive).
- `testMissingLayersKeySignals` — given a sub-map without `#layers`; when `fromLayerMap:`;
  then signals `PGRConfigurationError` whose `messageText` includes `'layers'`.
- `testAllowedNamingUndeclaredLayerSignals` — given `allowed` = `['ui','ghost']` with no
  `'ghost'` layer; when `fromLayerMap:`; then signals `PGRConfigurationError` whose message
  names `'ghost'`.

Fixtures: none — all inputs are inline `Dictionary`s. (The three-package *code* fixture is
C03; it is not needed to unit-test the value.)

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors; the new `PCKLayerMapTest` (10 tests) run
          by name, plus **every previously accepted suite still green** — assert
          named-suite membership plus a floor of **≥205 run** (195 accepted at cut time +
          10), never an exact ceiling (sibling E10 chunks landing in parallel raise the
          count). Regression guard: the accepted `PCKKitTest` and `PCKArtifactBlockM1FormTest`
          suites stay green untouched.

OUT OF SCOPE
- The completeness law (coverage over the production role, disjointness, production-role
  membership, unknown/unloaded packages) — **C02**. Do not add coverage checks here.
- Any read of, or edit to, `PCKKit` — **C06**.
- Any reflective walk of code / `referencedClasses` — **C04**.
- Editing `guardrails.ston` or any baseline package — forbidden (E11 owns the self-hosted
  map; the baseline froze at E01).
- Adding a `redFindings:advisories:` or any constructor to `PGRVerdict` — frozen E02
  surface; not touched by this chunk (see C04's filed question).

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
`plan/ledger.md`; D-66/D-67). Postcondition: exactly one commit
`E10-C01: PCKLayerMap value + parse + lookups`, nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
