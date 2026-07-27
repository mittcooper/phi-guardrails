# E10-C05 · D-79 / D-79.a semantics — the machine witnesses  [depends: E10-C02, E10-C03, E10-C04 · parallel: no]

GOAL      Pin the four ruled layer-map semantics — self-reference needs no declaration, allowed pairs are one-way, allowed pairs are non-transitive, external references are out of scope — as dedicated red-if-broken tests on `PCKLayerMapCheck`, so the M1-gate audit's ruling (D-79/D-79.a) becomes machine-enforced rather than prose.

TRACE     spec ch. 4 §4.1 erratum + §4.2 · D-79 ruling 1 (a layer may always reference itself) · D-79 ruling 2 (allowed pairs directed, one-way, non-transitive — `ui→domain` infers neither `domain→ui` nor `ui→persistence`) · D-79 ruling 3 as scoped by D-79.a (the map judges **internal** client→client only; kernel/framework references are B-02's separate ground, out of this epic).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**Why a dedicated chunk.** D-79 and D-79.a are the ground this whole epic was gated on: the
M1-gate audit found ch. 4 §4.1's "Implicit rules, fixed" stated three semantics tracing to
no ruling, and the owner ruled them (two confirmed, one overruled-then-rescoped). The
producer builds against those rulings, not §4.1's original prose. C04 already implements the
correct `run` behavior; **this chunk adds the tests that would redden if any of the four
ruled semantics silently regressed** — the audit finding turned into a standing wall.
This is a **test-only** chunk: no product code changes.

**The four rulings, restated (the assertions below must each fail if the rule broke):**
1. **Self-reference (D-79 ruling 1):** intra-layer references need no `#allowed` entry — a
   ui class referencing another ui class is never a finding, even with no `ui→ui` pair.
2. **One-way (D-79 ruling 2):** `#allowed` = `['ui','domain']` grants `ui→domain` only; a
   `domain→ui` reference under that same map **is** a finding (the reverse is a separate
   declaration).
3. **Non-transitive (D-79 ruling 2):** `#allowed` = `['ui','domain']`, `['domain','persistence']`
   does **not** grant `ui→persistence`; a `ui→persistence` reference under that map **is** a
   finding.
4. **External out of scope (D-79 ruling 3 × D-79.a):** a reference from a layered class to a
   kernel/framework class (defined in no declared layer) is **never** a finding — external
   dependencies are the separate B-02 check's ground, declared-not-silent by ruling; the
   layer map judges internal client→client only.

**Builds on (accepted):**
- **C04 `PCKLayerMapCheck`** — class-side `layerMap: aPCKLayerMap`; `run` → `PGRVerdict`
  (`isGreen`, `findings`, each `PGRFinding` with `target` = `Class>>#selector` and
  `message` naming the referenced class + both layers).
- **C03 `PCKLayerMapFixture`** — `install`/`remove` (guarded, `ensure:`-safe),
  `uiPackageName`/`domainPackageName`/`persistencePackageName`/`packageNames`. The fixture's
  relevant plants: `PCKScratchUiView>>usesSibling`→`PCKScratchUiWidget` (ui→ui),
  `PCKScratchUiView>>usesExternal`→`OrderedCollection` (ui→external),
  `PCKScratchUiView>>usesDomain`→domain, `PCKScratchUiView>>usesPersistence`→persistence,
  `PCKScratchDomainModel>>usesUi`→ui (domain→ui),
  `PCKScratchDomainModel>>usesPersistence`→persistence.
- **C01/C02 `PCKLayerMap`** — `fromLayerMap: subMap productionPackages: prodNames`.

**Constitution rules that bite here:** every test asserts behavior that fails if the rule
broke — a test that cannot fail is a defect (ch. 9 / constitution §2); teardown via
`ensure:`; no `skip`/`expectedFailures`; glossary terms exact.

DELIVERABLES

Files (Tonel):
- **modify** `src/Phi-Coding-Kit-Tests-Architecture/PCKLayerMapCheckTest.class.st` (add the
  four tests below; the `PCKLayerMapCheckTest` class was created by C04).

No product-code files. (If implementing the tests reveals `run` does **not** already satisfy
a ruling, that is a C04 defect — **stop and report**, do not patch `run` from this chunk;
the ruling is the fixed point.)

LOC budget: target ~100 · ceiling 300 (test-only).

TESTS FIRST  (added to `PCKLayerMapCheckTest`; each wraps `PCKLayerMapFixture install` …
`[ ... ] ensure: [ PCKLayerMapFixture remove ]`; maps built over
`PCKLayerMapFixture packageNames`)

- `testSelfReferenceNeedsNoDeclaration` *(D-79 ruling 1)* — given layers ui/domain/persistence
  with `#allowed` granting every **declared** edge the fixture uses **except** any `ui→ui`
  self entry (there is none to grant); when `run`; then **no** finding's `target` is
  `'PCKScratchUiView>>#usesSibling'` — the ui→ui reference is silently fine. (Assert the
  absence specifically, so an over-broad map cannot make the test vacuous: use a map that is
  otherwise green.)
- `testAllowedPairIsOneWay` *(D-79 ruling 2, direction)* — given layers ui/domain and
  `#allowed` = `['ui','domain']` only (persistence declared `#unlayered` so the map is
  total and the only judged edges are ui↔domain); when `run`; then there **is** a finding
  whose `target` is `'PCKScratchDomainModel>>#usesUi'` (domain→ui, undeclared) and **no**
  finding whose `target` is `'PCKScratchUiView>>#usesDomain'` (ui→domain, granted).
- `testAllowedPairIsNotTransitive` *(D-79 ruling 2, transitivity)* — given layers
  ui/domain/persistence and `#allowed` = `['ui','domain']`, `['domain','persistence']`;
  when `run`; then there **is** a finding whose `target` is
  `'PCKScratchUiView>>#usesPersistence'` (ui→persistence is not granted by the two hops).
- `testExternalReferenceIsOutOfScope` *(D-79 ruling 3 × D-79.a)* — given any total map over
  the fixture packages (kernel classes are in no declared layer); when `run`; then **no**
  finding's `message` mentions `'OrderedCollection'` and no finding targets
  `'PCKScratchUiView>>#usesExternal'` — the external reference is unjudged here (it is
  B-02's ground). Prove the walk is non-vacuous in the same test (the map is one under which
  a *declared* forbidden edge would fire) so a walk that found nothing at all cannot pass.

Fixtures: `PCKLayerMapFixture` (C03).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors; `PCKLayerMapCheckTest` now 9 tests (5
          from C04 + 4) run by name, the four new ones witnessing D-79 rulings 1–3 and
          D-79.a; every previously accepted suite still green. Assert named-suite membership
          plus a floor of **≥225 run** (≥221 after C04 + 4), never an exact ceiling.

OUT OF SCOPE
- Any change to `PCKLayerMapCheck`, `PCKLayerMap`, or the fixture — this chunk only adds
  tests; a needed behavior change is a stop-and-report against C04, not a patch here.
- Kit dispatch (**C06**), the baseline, `guardrails.ston`.
- External/B-02 machinery — out of this epic by D-79.a; this chunk only witnesses that the
  layer map stays silent on external references, it builds no external check.

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition: one
commit `E10-C05: D-79/D-79.a semantics witnesses`, nothing uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations (each one-line justified) · new questions for the decision sheet.
