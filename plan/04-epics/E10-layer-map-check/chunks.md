# E10 · Layer-map check — chunk index (M2)

*Produced by Prompt 4 (eighth run, 2026-07-26). Entry check: **M1 closed (D-78)**;
the roadmap is approved and frozen (D-62); E10's roadmap dependencies **E06** (kit
dispatch + block schema, frozen at head `0c4fb7b`) and **E02** (SDK vocabulary,
frozen at head `5f2fc60`) are both `accepted` in `plan/ledger.md` with frozen
interface digests. Accepted verify sweep at cut time: **195 tests** — every count
assertion below is named-suite membership plus a floor, never an exact ceiling
(sibling-suite contingency, the E06 punch-list rule). IDs are epic-qualified
`E10-C##` (D-73); the counter is local to E10. Every COMMIT section cites
`bash tools/precheck.sh` as its precondition (D-66/D-67), commits `E10-C##:`-prefixed.*

***Ruled ground this cut builds against (read D-79 + D-79.a before cutting into any
chunk):*** ch. 4 §4.1's original "Implicit rules, fixed" prose was the M1-gate audit's
one fabricated-intent finding; it is **superseded** by **D-79** (ruling 1 — a layer may
reference itself; ruling 2 — allowed pairs are directed, one-way, non-transitive; ruling
3 — "unmapped references are ignored" **OVERRULED**) as scoped by **D-79.a** (the layer
map judges **internal** client→client dependencies only, **total over client ground** via
the D-35 completeness law; **external** kernel/framework references are the separate
declared-allowance check's ground — backlog **B-02**, out of this epic by ruling). Every
chunk cites D-79/D-79.a, never §4.1's original text. **Self-hosting the layer map into the
framework's own `guardrails.ston` is E11's, not E10's** — the M1 artifact form froze at
E09; E10 delivers the mechanism and proves it on a scratch mini-fixture.

| ID | Title | Depends | [P] | LOC est. | Acceptance (one line) |
|---|---|---|---|---|---|
| E10-C01 | `PCKLayerMap`: value, parse, readers, lookups | — | no | ~110 | `PCKLayerMapTest` (10) green — a well-formed `#layerMap` parses; `allowsFrom:to:` bakes in D-79's self-reference + directed one-way non-transitive membership |
| E10-C02 | `PCKLayerMap`: completeness law (D-35) | E10-C01 | no | ~120 | `PCKLayerMapTest` (+7 = 17) green — layers + `#unlayered` jointly total over the production role, every gap/overlap/non-production a `PGRConfigurationError` (P-LAYERMAP-TOTAL config arms) |
| E10-C03 | Architecture scratch mini-fixture (builder + self-test) | — | yes | ~110 | `PCKLayerMapFixtureTest` (4) green — three scratch packages with the planted forbidden reference install and tear down cleanly; the plant is provably present |
| E10-C04 | `PCKLayerMapCheck`: §4.2 walk + verdict + `#unlayered` advisory | E10-C01, E10-C02, E10-C03 | no | ~150 | `PCKLayerMapCheckTest` (5) green — fires precisely on the forbidden reference (P-FINDING-PRECISE, P-CAT-FIXTURES arch), silent on the conforming map, advisory names the unlayered packages (P-LAYERMAP-TOTAL advisory arm) |
| E10-C05 | D-79 / D-79.a semantics witnesses | E10-C02, E10-C03, E10-C04 | no | ~100 | `PCKLayerMapCheckTest` (+4 = 9) green — self-reference-needs-no-declaration, one-way, non-transitive, and external-out-of-scope each a red-if-broken test (test-only) |
| E10-C06 | Kit-side `#layerMap` dispatch | E10-C02, E10-C04 | no | ~130 | `PCKKitTest` (1 amended + 5 new) green — a present `#layerMap` is validated (§4.1); `PCKLayerMapCheck` is constructed with the map (absent/unloaded → missing); the generic arch path is undisturbed (R-21) |

Total ~720 product-adjacent LOC across 6 chunks (E10-C05 is test-only; the fixture's
planted-method source strings in E10-C03 are fixture data, outside the budget); roadmap
estimate ~6 chunks — holds.

**`[P]` semantics.** E10-C03 (fixture builder, package `Phi-Coding-Kit-Tests-Architecture`)
has a manifest disjoint from E10-C01/C02 (`PCKLayerMap` in `Phi-Coding-Kit-Architecture` +
`PCKLayerMapTest`), so it is structurally parallel-safe. Under the D-67 discipline picks are
sequential with a clean tree between them; `[P]` records structural independence
(worktree-parallel is safe), not a scheduling requirement. Every other pair is serial: C02
extends C01's file; C04 consumes C01 + C02 + C03; C05 extends C04's test file (and uses
C02's `fromLayerMap:productionPackages:`); C06 consumes C02 + C04. **Manifest disjointness
cross-check** (the reviewer's [P] guard): C01/C02 touch
`Phi-Coding-Kit-Architecture/PCKLayerMap.class.st` +
`Phi-Coding-Kit-Tests-Architecture/PCKLayerMapTest.class.st`; C03 touches
`Phi-Coding-Kit-Tests-Architecture/PCKLayerMapFixture{,Test}.class.st`; C04 touches
`Phi-Coding-Kit-Architecture/PCKLayerMapCheck.class.st` +
`Phi-Coding-Kit-Tests-Architecture/PCKLayerMapCheckTest.class.st`; C05 touches only
`PCKLayerMapCheckTest.class.st`; C06 touches `Phi-Coding-Kit/PCKKit.class.st` +
`Phi-Coding-Kit-Tests-Rules/PCKKitTest.class.st`. No two `[P]`-eligible chunks share a file.

## Amended accepted surface (scripted, not remembered)

**Exactly one** accepted test changes across the epic, in **E10-C06** (scheduled ground:
the `#layerMap` consumer E06 explicitly deferred to E10, and the accepted test's own comment
says "carried … until E10 gives it its consumer **and its shape validation**"):
`PCKKitTest>>testLayerMapKeyProducesNoRegistrationsAndNoError`. The enumeration was built by
script over the committed `src/` (recorded in E10-C06's AMENDED-SURFACE TABLE and this cut's
validation report):
- accepted tests presenting a `#layerMap` key: **1** (that test).
- accepted tests registering `PCKLayerMapCheck` through a kit block: **0** (all other
  `#architectureChecks` tests name `PCKArchStubCheck`/`PGRFinding`/`PCKNoSuchCheck` — the
  untouched generic `packages:` path).
- `PCKLayerMapCheck` elsewhere: `PGRReportTest` uses it only as a rendering-fixture **string**
  (no kit call); `PCKArtifactBlockM1FormTest` asserts the M1 artifact **omits** `#layerMap`/
  `#architectureChecks` (E11's ground, not E10's) — both unaffected.

No chunk touches `guardrails.ston`, the baseline, or `PCKKit recommendedBlock`.

## Reconciliations recorded (owner-directed; no question filed — no conflict)

- **P-LAYERMAP-TOTAL letter vs D-79/D-79.a** (E10-C02): the ch. 9 letter (config errors for
  uncovered / layered-and-unlayered / unlayered-non-production, plus the run-time advisory)
  is the D-35 completeness law and is fully consistent with D-79.a's internal-only,
  total-over-client-ground scope. No conflict → **no question filed** (recorded per the
  owner's reconcile-or-file instruction).

## Question filed this cut (decision sheet — recommend, never rule)

- **Q (E10-C04): §4.2 step 4 vs the frozen `PGRVerdict`.** §4.2 says the verdict carries the
  `#unlayered` advisory in *every* report (green **and** red), but the E02-frozen
  `PGRVerdict` has no `redFindings:advisories:` constructor — the advisory can attach only to
  a green verdict. E10-C04 implements the supported arm (advisory on green; red carries
  findings only) and files the choice: **(a)** advisory-on-green-only [no surface change,
  implemented] or **(b)** amend the frozen E02 `PGRVerdict` [decision-sheet amendment]. Owner
  to rule; no frozen surface is amended by this epic.

## Agent calls recorded (veto-open, closing on the D-16 precedent at acceptance)

- **`#layerMap` sub-map format** (frozen export): `#layers` (map layerName-String →
  package-name-String list, mandatory) · `#allowed` (list of two-element `[from, to]`
  declared-layer-name lists, mandatory, directed one-way non-transitive) · `#unlayered`
  (package-name-String list, optional). The config-author surface E10 freezes.
- **`PCKLayerMap` constructor pair** — `fromLayerMap:` (shape-only, C01) and
  `fromLayerMap:productionPackages:` (completeness-aware, C02, the one C06 uses). Two
  constructors keep C01's unit tests independent of the production role.
- **`PCKLayerMapCheck class>>layerMap:`** — the kit-owned constructor, richer than the
  promised `packages:` because the kit owns this check (§4.3, mirroring
  `PCKLintRuleCheck rule:packages:`). Internal (kit-side), not a frozen public surface.
- **Kit special-case by identity** `== PCKLayerMapCheck` in the `#architectureChecks` pass —
  mirrors the accepted own-meta-rule special case (`== PCKNoSkippedTestsMetaRule`), not a
  banned type predicate.
- **Scratch mini-fixture over three runtime packages** (`PCKScratchArch-Ui/-Domain/-Persistence`)
  built and torn down in the test — the frozen baseline (E01) admits no new packages; the
  E08/E09 `Super << #Name package:'…'; install` + `removeFromSystem` precedent.
- **`referenced instanceSide`** normalization in the walk — ⟨verify-in-image⟩ delegated to
  the C04 implementer with record-in-report duty (P5).
- **Advisory-on-green-only** for the `#unlayered` line pending the filed question (C04).

## Exit checkpoint (freezes E10's interface)

E10 is provable by, on one head commit:

1. **Named suite:** the four `Phi-Coding-Kit-Tests-Architecture`/`-Tests-Rules` test classes
   this epic adds or amends —
   `PCKLayerMapTest` (17) · `PCKLayerMapFixtureTest` (4) · `PCKLayerMapCheckTest` (9) ·
   `PCKKitTest` (+5 new, 1 amended) — green under
   `bash tools/build-image.sh && bash tools/verify.sh`, with **every previously accepted
   suite still green** (≥230 run — 195 accepted at cut + 35 net new [10+7+4+5+4+5];
   named-suite membership plus that floor, never an exact ceiling). Properties discharged here:
   **P-LAYERMAP-TOTAL** (config arms in `PCKLayerMapTest`, advisory arm in
   `PCKLayerMapCheckTest>>#testUnlayeredReportedAsAdvisory`), **P-FINDING-PRECISE**
   (`PCKLayerMapCheckTest>>#testFiresOnForbiddenReference`), **P-CAT-FIXTURES (arch)** (the
   fires/silent fixture pair), and the **D-79/D-79.a** semantics (the four
   `PCKLayerMapCheckTest` witnesses, E10-C05).
2. **Self-hosted gate leg (regression, no new registration):**
   `./guardrails.sh guardrails.ston` still exits 0 with its 10 M1 registrations — E10 adds
   **no** entry to the framework's own artifact (that is E11); this leg proves E10 did not
   disturb the self-hosted M1 form. (Run with the repo's own VM/image per the accepted E09
   invocation.)
3. **CI leg:** the committed `.github/workflows/ci.yml` (step 1) green on an actual CI run of
   the same commit — the new architecture-kit tests ride the existing smalltalkCI sweep.

**Frozen at acceptance (E10's interface digest — later epics build on these; amendments need
a decision-sheet entry):**
- **The `#layerMap` key format** (config-author surface): the three-key sub-map above —
  `#layers` / `#allowed` / `#unlayered` — with D-79/D-79.a semantics (self-reference implicit,
  allowed pairs directed one-way non-transitive, internal client→client only, layers +
  `#unlayered` total over the production role). **E11 consumes this to self-host the map.**
- **Registration:** `architecture/PCKLayerMapCheck` — the kit's one shipped architecture
  check, resolved from an `#architectureChecks` entry naming `PCKLayerMapCheck` with a present
  `#layerMap`; absent map or unloaded layer package → the missing sentinel of that name.

Internal / unfrozen: `PCKLayerMap`'s selectors and `PCKLayerMapCheck class>>layerMap:` (the
generic contract the engine validates is `PGRCheck`'s, E02's); the walk's reflective
spellings; `PCKLayerMapFixture`.

Checkpoint result (filled at acceptance): _pending._
