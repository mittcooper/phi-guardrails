# E10-C04 · `PCKLayerMapCheck` — the §4.2 walk, verdict, and `#unlayered` advisory  [depends: E10-C01, E10-C02, E10-C03 · parallel: no]

GOAL      `PCKLayerMapCheck` — a `PGRCheck` of kind `#architecture` that walks the layered packages reflectively, emits one precise finding per forbidden inter-layer reference, returns red iff any finding (else green), and carries the `#unlayered` advisory on the clean path — proven by the fixture pair.

TRACE     R-18 (reflective queries, never file parsing) · R-19 (generic engine, client-supplied map) · R-20 (finding precision) · R-37 (fixture pair) · R-43 (v1's one shipped architecture test) · spec ch. 4 §4.2 (the walk) · §4.4 (fixture pair) · D-15 correction 3 (`CompiledMethod>>referencedClasses`, the literals/isBehavior sketch is wrong) · D-79 rulings 1–2 (self-reference; directed one-way non-transitive) · D-79.a (internal client→client only) · P-CAT-FIXTURES (arch) · P-FINDING-PRECISE · P-LAYERMAP-TOTAL (advisory arm).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**Builds on (accepted):**
- **C01/C02 `PCKLayerMap`** — instance readers `layers` (`Dictionary` layerName→package
  names), `allowed`, `unlayered` (Array of package-name Strings); lookups
  `layerOfPackageNamed: aString` (declaring layer name, or `nil` when in no layer —
  unlayered **or** external both answer nil) and `allowsFrom: fromLayer to: toLayer`
  (`true` for self-reference and for a literal declared directed pair; `false` otherwise).
  Constructor for tests: `PCKLayerMap fromLayerMap: subMap productionPackages: prodNames`.
- **C03 `PCKLayerMapFixture`** — class-side `install` / `remove` (guarded, `ensure:`-safe)
  and package-name accessors `uiPackageName` / `domainPackageName` /
  `persistencePackageName` / `packageNames`. Installs `PCKScratchUiView`
  (`usesDomain`→domain, `usesPersistence`→persistence, `usesSibling`→ui,
  `usesExternal`→`OrderedCollection`), `PCKScratchUiWidget`, `PCKScratchDomainModel`
  (`usesPersistence`→persistence, `usesUi`→ui), `PCKScratchPersistenceStore`.

**Frozen SDK you construct against (E02 digest — verbatim, do not redefine):**
- `PGRCheck` (optional skeleton, `-SDK`) — class-side `packages: aCollection`; instance
  `packages` reader; `run` / `kind` / `canFix` (default `false`) / `fixCommandOn:`. A check
  conforms by protocol, not ancestry; subclassing `PGRCheck` is the convenient path and
  gives you `packages`/`canFix false` for free.
- `PGRVerdict` — class-side constructors: `green` · `greenAdvisories: aCollection` ·
  `redFindings: aCollection` · `missingReason: aString` · `skipped` (engine-only). Instance
  readers: `status` · `findings` · `advisories` · `isGreen`. **There is no `red +
  advisories` constructor** — `redFindings:` sets advisories to `#()`. (This gap is the
  filed question below.)
- `PGRFinding` — class-side `target: aString message: aString` and
  `target:message:rationale:`; readers `target` · `message` · `rationale`. Used for both
  findings (in `redFindings:`) and advisories (in `greenAdvisories:`) — which it is depends
  on the verdict that carries it, never on the finding.

**The walk (spec §4.2 — implement exactly), for the layer map handed at construction:**
1. For every layer `L` and every declared package of `L`: resolve it via
   `PackageOrganizer default packageNamed: pkgName ifAbsent: [ nil ]`; a nil package
   contributes nothing to the walk (loaded-ness → *missing registration* is C06's dispatch
   concern, never a walk finding).
2. For every class defined in `L`'s packages (`package definedClasses`), every method of
   that class **including class-side** (`cls methods`, `cls class methods`): collect
   `method referencedClasses`; normalize each to its **instance side**
   (`referenced instanceSide` — ⟨verify-in-image, P5⟩: confirm `instanceSide` is the Pharo 13
   selector that maps a metaclass to its class and is a no-op on a class; record the
   confirmed spelling in the completion report).
3. For each referenced class, find its layer via
   `layerMap layerOfPackageNamed: referenced instanceSide package name`. Emit a finding iff
   that layer `M` is **non-nil** (the referenced class lives in a declared layer — an
   internal client→client edge, D-79.a) **and** `(layerMap allowsFrom: L to: M) not`.
   A `nil` `M` (external kernel/framework, or a deliberately unlayered client package) is
   **never** a finding — self-reference is already absorbed because
   `allowsFrom: L to: L` is `true` (D-79 ruling 1).
4. Verdict: **red iff ≥1 finding** (`PGRVerdict redFindings: findings`); **else green** —
   and on the green path, if `layerMap unlayered` is non-empty, carry **one advisory** line
   naming those packages (`PGRVerdict greenAdvisories: { theAdvisoryFinding }`); with no
   unlayered packages, plain `PGRVerdict green`.

**Finding precision (R-20 / P-FINDING-PRECISE — the exact contract):** the finding's
`target` string is **exactly** `Class>>#selector` of the offending method — build it as
`method methodClass name , '>>#' , method selector` (the accepted E09 `PGRArchSelfTest`
spelling). The `message` names both ends and the ruling: the referenced class name and both
layer names, e.g. `references PCKScratchPersistenceStore — layer 'ui' → 'persistence' is
not allowed`. One finding per (method, referenced class) pair; a method reaching two
forbidden classes yields two findings. No rationale string is required (a layer-map finding
carries no rule rationale — pass the two-arg `target:message:`).

**The advisory (§4.2 step 4 / P-LAYERMAP-TOTAL run-time arm):** on a green verdict with a
non-empty `#unlayered`, exactly one advisory `PGRFinding` naming the unlayered packages —
target a stable sentinel (e.g. `'architecture/PCKLayerMapCheck'` or `'#unlayered'`), message
lists the package names. Reported, never blocking (`isGreen` stays true).

**⚠ Filed question (do not resolve in code — implement the conservative arm below).** Spec
§4.2 step 4 reads that "the verdict does carry one advisory" restating `#unlayered` "in
**every** report", but the frozen `PGRVerdict` (E02) offers **no red+advisories
constructor** — a red verdict cannot carry the advisory. **This chunk implements the
supported arm: the advisory rides the green (clean) verdict; a red verdict carries findings
only.** Record on the decision sheet: *"§4.2 step 4 vs frozen PGRVerdict — the unlayered
advisory can attach only to green verdicts (no `redFindings:advisories:` constructor).
Recommend (a) advisory-on-green-only [no surface change, implemented] or (b) amend the
frozen E02 `PGRVerdict` with `redFindings:advisories:` [decision-sheet amendment]. Owner to
rule."* Amending `PGRVerdict` is **forbidden** in this chunk (frozen surface).

**Constitution rules that bite here (inline):** reflective queries of the checked image are
the check's *subject matter*, not state — no global state introduced; the gate only
**reports**, never mutates (the walk reads, never compiles); Pharo idiom (no
`isKindOf:`/`class ==` — the walk uses `layerOfPackageNamed:` lookups, not type predicates;
no `Transcript`/`self flag:`/`self halt`); glossary terms exact (**layer map**, **finding**,
**advisory**, **verdict**, **check**).

**Verified spellings (P5, accepted repo code):** `PackageOrganizer default packageNamed:
aName ifAbsent: [...]` · `package definedClasses` · `cls methods` / `cls class methods` ·
`method referencedClasses` · `method methodClass name` · `method selector` ·
`aClass package name`. ⟨verify⟩: `referenced instanceSide` (record confirmed spelling).

DELIVERABLES

Files (Tonel):
- **create** `src/Phi-Coding-Kit-Architecture/PCKLayerMapCheck.class.st`
- **create** `src/Phi-Coding-Kit-Tests-Architecture/PCKLayerMapCheckTest.class.st`

`PCKLayerMapCheck` (package `Phi-Coding-Kit-Architecture`, superclass `PGRCheck`, instVar
`layerMap`):
- class-side `layerMap: aPCKLayerMap` — the kit-owned constructor (this class carries its
  map, richer than the promised `packages:`, exactly as `PCKLintRuleCheck` carries its rule
  — §4.3). Stores the map; answers the instance.
- `kind` → `#architecture`.
- `run` → the §4.2 walk above, answering a `PGRVerdict`.
- private helpers as needed (`findingsOverLayers`, `advisoryVerdictFor:` etc.) to keep `run`
  legible.

LOC budget: target ~150 · ceiling 300 (if the walk + these tests cannot fit, that is a
split finding, not a budget exception — C05 already carries the D-79/D-79.a semantics
tests, so this chunk should hold).

TESTS FIRST  (`PCKLayerMapCheckTest`; each test wraps `PCKLayerMapFixture install` …
`[ ... ] ensure: [ PCKLayerMapFixture remove ]`; build the map with
`PCKLayerMap fromLayerMap: aSubMap productionPackages: PCKLayerMapFixture packageNames`)

- `testKindIsArchitecture` — a `PCKLayerMapCheck layerMap: anyValidMap`; `kind` = `#architecture`.
- `testFiresOnForbiddenReference` *(P-CAT-FIXTURES bad · P-FINDING-PRECISE)* — given the
  fixture and a map: layers ui/domain/persistence over the three fixture packages,
  `#allowed` = `ui→domain`, `domain→persistence` (so `ui→persistence` is a non-transitive
  forbidden edge); when `run`; then the verdict is not green, and among `findings` there is
  one whose `target` is **exactly** `'PCKScratchUiView>>#usesPersistence'` and whose
  `message` includes `'PCKScratchPersistenceStore'`, `'ui'`, and `'persistence'`.
- `testSilentOnConformingMap` *(P-CAT-FIXTURES good)* — same fixture and layers, but
  `#allowed` grants every edge the fixture actually uses (`ui→domain`, `ui→persistence`,
  `domain→persistence`, `domain→ui`); when `run`; then the verdict `isGreen` and `findings`
  is empty (self and external edges never needed a grant).
- `testUnlayeredReportedAsAdvisory` *(P-LAYERMAP-TOTAL advisory arm)* — given a map: layers
  ui/domain over the ui/domain fixture packages, `#unlayered` = the persistence fixture
  package, `#allowed` granting `ui→domain` and `domain→ui` (so no forbidden edge to a
  *layered* class remains; references into the unlayered persistence package are unjudged);
  when `run`; then the verdict `isGreen` **and** `advisories` is non-empty and some advisory
  `message` names the persistence package.
- `testGreenWithNoUnlayeredHasNoAdvisory` — given a fully-layered conforming map with empty
  `#unlayered`; when `run`; then `isGreen` and `advisories` is empty (the advisory appears
  only when there is something unjudged to declare).

Fixtures: `PCKLayerMapFixture` (C03). No committed fixture packages.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors; `PCKLayerMapCheckTest` (5 tests) run by
          name — `testFiresOnForbiddenReference` discharges **P-FINDING-PRECISE** and
          P-CAT-FIXTURES(arch) bad half, `testSilentOnConformingMap` the good half,
          `testUnlayeredReportedAsAdvisory` the P-LAYERMAP-TOTAL advisory arm; every
          previously accepted suite still green. Assert named-suite membership plus a floor
          of **≥221 run** (195 + C01/C02/C03's 21 tests + this chunk's 5), never an exact
          ceiling.

OUT OF SCOPE
- The D-79/D-79.a **semantics witnesses** (self-reference-needs-no-declaration, one-way,
  non-transitive, external-out-of-scope) — **C05** (they pin `run`'s ruled behavior with
  dedicated tests; `run` here must already behave correctly, C05 only witnesses it).
- Kit dispatch / `#layerMap` reading in `PCKKit` — **C06**.
- Unloaded-package → missing registration — **C06** (the walk just skips a nil package).
- Amending `PGRVerdict` (frozen) — forbidden; file the question instead.
- Editing the baseline or `guardrails.ston` (E11 self-hosts the map).

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition: one
commit `E10-C04: PCKLayerMapCheck walk + verdict + advisory`, nothing uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  the confirmed `instanceSide` spelling (P5) · deviations (each one-line justified) ·
  new questions for the decision sheet (the §4.2-vs-PGRVerdict advisory question is
  pre-filed above — restate it unless already recorded).
