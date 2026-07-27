# E10-C02 · `PCKLayerMap` — the completeness law (D-35) over the production role  [depends: E10-C01 · parallel: no]

GOAL      Extend `PCKLayerMap` construction so that, given the production-role package list, the layers and `#unlayered` jointly cover it exactly once — every disjointness / coverage / production-role / overlap fault a loud `PGRConfigurationError` — closing the silence-as-success hole at the layer level (D-79 ruling 3, scoped internal-only by D-79.a).

TRACE     R-18 · R-43 · spec ch. 4 §4.1 (completeness law) · D-35 (layers + `#unlayered` jointly total over the production role) · D-25 (scope-law spirit: disjoint + total; an unassigned package is loud) · D-79 ruling 3 (unmapped-ignored OVERRULED — every internal dependency declared) · D-79.a (the map judges **internal** client→client only, **total over client ground**; external references are B-02's separate ground, out of this epic's scope) · P-LAYERMAP-TOTAL (ch. 9, config-error arms).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**Builds directly on C01 (accepted).** C01 delivered `PCKLayerMap` with:
- class-side `fromLayerMap: aLayerMapSubMap` — parses `#layers` / `#allowed` / `#unlayered`,
  storing `layers` (`Dictionary` String→Array), `allowed` (Array of two-`String` Arrays),
  `unlayered` (Array of Strings). It already raises `PGRConfigurationError` for **shape**
  faults (non-map value, missing/empty `#layers`, non-String lists, `#allowed` naming an
  undeclared layer, malformed pairs).
- instance readers `layers` / `allowed` / `unlayered`; lookups
  `layerOfPackageNamed:` (declaring layer or nil) and
  `allowsFrom:to:` (self-reference always true; else literal directed membership).

C01 knows nothing of the production role. This chunk adds that dimension.

**The completeness law (spec §4.1 / D-35 — the rules this chunk enforces).** When
`#layerMap` is present, the layers and `#unlayered` must **jointly cover every
production-role package, each in exactly one place**. Configuration errors (each a loud
`PGRConfigurationError`, never a silent default):
1. a production-role package in **no** layer and **not** in `#unlayered` (uncovered — the
   D-79 ruling-3 hole: an undeclared internal package is loud, never invisibly ignored);
2. a package in **two** layers (layers must be pairwise disjoint);
3. a package in a layer **and** in `#unlayered` (overlap);
4. a layer naming a package **outside the production role** (D-25 — layers are
   production-role packages of the baseline);
5. an `#unlayered` entry naming a package **outside the production role** (or unknown to
   the production list).

**Why this is internal-only, and where "external" went (D-79.a — cite, do not
re-derive).** The layer map judges internal dependencies — client class → client class —
**total over client ground**, where "client ground" is exactly the production-role package
list handed here. Kernel/framework (external) references are a *separate* concern, the
ground of a declared-allowance check carried by backlog **B-02** (trigger: widening /
phi-llm milestone 0); the seam is declared, never silent. So this chunk makes the map total
over the **production role** (client ground); it says nothing about external packages, by
ruling. Do not add any kernel/framework handling.

**P-LAYERMAP-TOTAL reconciliation (owner-directed — recorded, no conflict).** Ch. 9's
P-LAYERMAP-TOTAL letter is: *a production package in no layer and not `#unlayered` / in a
layer and `#unlayered` / an `#unlayered` entry outside the production role each signal
`PGRConfigurationError`; a run's verdict carries the advisory line naming the `#unlayered`
packages.* The three config-error arms are **exactly** faults 1, 3, 5 above and are
consistent with D-79/D-79.a (the advisory arm is C04's). **No conflict — no question
filed.** (Recorded per the owner's instruction to reconcile the P-LAYERMAP-TOTAL letter
against D-79/D-79.a and file only on conflict.)

**Constitution rules that bite here (inline):** strict parsing — every fault above raises,
none defaults silently (family 7); no global state; Pharo idiom (`ifNil:`/`ifNotNil:`, no
type-predicate dispatch, no debugging leftovers); glossary terms exact (**layer map**,
**scope law**, **production role**). `PGRConfigurationError signal: aString` (frozen E02
surface, catchable by class).

**Verified spellings (P5):** as C01 — `keysAndValuesDo:`, `at:ifAbsent:`, `allSatisfy:`,
`isString`; plus `aCollection asBag` / duplicate detection by counting, or a plain
accumulate-and-check-membership loop (implementer's choice; no new dependency).

DELIVERABLES

Files (modify only — both created by C01):
- **modify** `src/Phi-Coding-Kit-Architecture/PCKLayerMap.class.st`
- **modify** `src/Phi-Coding-Kit-Tests-Architecture/PCKLayerMapTest.class.st`

`PCKLayerMap` additions:
- class-side `fromLayerMap: aLayerMapSubMap productionPackages: aCollectionOfProductionNames`
  — the completeness-aware constructor. It performs C01's shape parse (reuse
  `fromLayerMap:` internally, or a shared private builder) **and then** enforces faults 1–5
  above against `aCollectionOfProductionNames`, raising `PGRConfigurationError` naming the
  offending package (and, for faults 2/3, the conflict) on the first violation. On success
  answers a fully-valid `PCKLayerMap`.
- keep `fromLayerMap:` as the shape-only constructor (C01 callers/tests unchanged); the new
  selector is the one C06 uses in the integrated path. Factor the shared shape parse into a
  private helper if it avoids duplication (no behavior change to `fromLayerMap:`).
- (no new readers/lookups; `layers`/`allowed`/`unlayered`/`layerOfPackageNamed:`/
  `allowsFrom:to:` are unchanged.)

LOC budget: target ~120 · ceiling 300.

TESTS FIRST  (added to `PCKLayerMapTest`; production list is an inline `Array` of Strings;
map sub-maps inline as in C01)

- `testUnassignedProductionPackageSignals` *(P-LAYERMAP-TOTAL)* — given production
  `#('A-Ui' 'A-Domain' 'A-Orphan')`, layers covering only `A-Ui`/`A-Domain`, empty
  `#unlayered`; when `fromLayerMap:productionPackages:`; then signals
  `PGRConfigurationError` naming `'A-Orphan'`.
- `testLayeredAndUnlayeredOverlapSignals` *(P-LAYERMAP-TOTAL)* — given `A-Domain` in layer
  `'domain'` **and** in `#unlayered`; when constructed; then signals
  `PGRConfigurationError` naming `'A-Domain'`.
- `testUnlayeredNamesNonProductionSignals` *(P-LAYERMAP-TOTAL)* — given `#unlayered` names
  `'A-NotProduction'` absent from the production list; when constructed; then signals
  `PGRConfigurationError` naming `'A-NotProduction'`.
- `testPackageInTwoLayersSignals` — given `A-Ui` listed in both `'ui'` and `'domain'`;
  when constructed; then signals `PGRConfigurationError` naming `'A-Ui'`.
- `testLayerNamesNonProductionPackageSignals` — given layer `'ui'` names `'A-Foreign'`
  absent from the production list; when constructed; then signals `PGRConfigurationError`
  naming `'A-Foreign'`.
- `testFullyCoveringMapConstructsCleanly` — given production `#('A-Ui' 'A-Domain' 'A-Glue')`
  with layers covering `A-Ui`/`A-Domain` and `#unlayered` = `#('A-Glue')`; when
  constructed; then no error and `layerOfPackageNamed: 'A-Ui'` = `'ui'`,
  `unlayered` includes `'A-Glue'`.
- `testEmptyUnlayeredWithTotalLayersConstructsCleanly` — given production fully partitioned
  by layers, no `#unlayered`; when constructed; then no error and `unlayered` is empty.

Fixtures: none (inline data).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors; `PCKLayerMapTest` now 17 tests (10 from
          C01 + 7) run by name, all three P-LAYERMAP-TOTAL config-error arms among them;
          every previously accepted suite still green. Assert named-suite membership plus a
          floor of **≥212 run** (195 + 17), never an exact ceiling.

OUT OF SCOPE
- The `#unlayered` **advisory line** (P-LAYERMAP-TOTAL's fourth, run-time arm) — that is a
  verdict the *check* produces; **C04**.
- Unloaded-package → **missing registration** (§1.5): loaded-ness is resolved at kit
  dispatch (**C06**), not here — this chunk validates over the production **names** it is
  handed, which are the config's declared production role.
- Any external/kernel/framework handling — B-02's ground by D-79.a; explicitly not this
  epic's.
- Reading/editing `PCKKit` (**C06**) or walking code (**C04**).

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition: one
commit `E10-C02: PCKLayerMap completeness law (D-35)`, nothing uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations (each one-line justified) · new questions for the decision sheet.
