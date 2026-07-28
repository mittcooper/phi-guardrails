# E12 · Toy client and init tool — chunk index

Cut by the tenth committed Prompt-4 run (2026-07-28). Epic-qualified IDs per D-73.
Entry check: roadmap approved and frozen (D-62); **M2 closed (D-82)** on head
`786bacf`; E12's four roadmap dependencies are all `accepted` with frozen digests —
**E03** @ `e26fc9c` (configuration) · **E06** @ `0c4fb7b` (rule contract, kit block
schema) · **E07** @ `f569549` (stanza, behavioral machinery) · **E10** @ `b994a3e`
(the `#layerMap` format the toy's artifact uses). Accepted verify sweep at cut time:
**250 tests**, self-hosted gate **12 registrations GREEN** (both re-run at the cut,
probes.md P15) — every count below is named-suite membership plus a floor, never an
exact ceiling. **The D-82/Q-39 cut-time probe obligation is discharged in
`probes.md`** (this directory): every skeleton-named reflective predicate and
frozen-surface spelling was probed live against the work image at HEAD `bca7c9b` or
checked against its frozen digest; the file is part of this epic's validation record.

Ruled ground in force: **D-26** (toy committed red; exempt-role by declaration is the
guard) · **D-57** (`Toy-Tests` matches neither tests-family pattern — the verify
sweep stays green over the plants) · **D-49** (`draftFor:` is draft-only; generation
may guess, the gate never infers — D-45 ruling 4) · **D-51/D-53/D-54** (stanza
single-sourced on the kit class; composition over defaults) · **D-79/D-79.a/D-80**
(layer-map semantics the toy's map rides) · **D-82 carry-forward corrections**,
standing: (1) the committed `.github/workflows/ci.yml` runs **CI step 1 only**
(smalltalkci) — the two-step upgrade is E15's scheduled edit; no work order claims a
CI gate step; (2) deliberate-absence guards use `includesSelector:`, never
`respondsTo:`; (3) the frozen `PGRVerdict` has no red-with-advisories constructor
(re-probed, P14). **E14's ground is not pre-built:** the witnesses stay at check
level, no committed test runs a gate over toy configuration, and the exit
checkpoint's six-red arm is an orchestrator-run eval, not a committed test.

## Chunks

| ID | Title | Depends-on | [P] | LOC est. | Acceptance (one line) |
|---|---|---|---|---|---|
| E12-C01 | The toy mini app and its groupless baseline | — | yes | ~110 | `PGRToyBaselineTest` (2) green — five packages declared, zero groups (R-47), the three-layer app real and clean |
| E12-C02 | `ToyNoIsNilIfFalseRule` and its fixture pair | — | yes | ~100 | `testFiresOnBadFixture`/`testSilentOnGoodFixture` green by eval arm (unswept home) — the client-convention model, flag-only, `#error` |
| E12-C03 | The six plants, committed red, with check-level witnesses | E12-C01, E12-C02 | no | ~140 | `PGRToyPlantWitnessTest` (5) green in a green sweep — every plant live and caught by its check; gate leg still 12 GREEN (exempt guard held) |
| E12-C04 | The toy's committed artifact: `guardrailsSTON` | E12-C01, E12-C02 | yes | ~90 | `PGRToyArtifactTest` (2) green — §1.1's example (content-identical) parses, validates, yields the six resolved registrations in order, no `run` sent |
| E12-C05 | `PGRConfigurationDraft` + the scheduled §0.3 mirror amendment | E12-C01 | yes | ~170 | `PGRConfigurationDraftTest` (4) green + the amended conformance manifest green (five audiences, 46 triples) — draft parses/validates for the toy, stanza byte-derived |

Sum ≈ 610 LOC — the roadmap's "~7 chunks" cut as five: the toy app, its rule, its
plants, and its artifact are four separately reviewable concerns, and the init tool
plus its scheduled manifest amendment is one (the accepted test's own comment ties
the amendment to "E12's `draftFor:` cut"); folding plants into the app chunk would
bury D-26's one concern, and a separate amendment chunk would split one scheduled
edit across two diffs.

[P] eligibility (disjoint manifests): E12-C01 ∥ E12-C02; after both land,
E12-C03 ∥ E12-C04 ∥ E12-C05 (C03: `ToyOrder`/`ToyOrderView`/`ToyOrderTest`/witness ·
C04: `BaselineOfToy` + artifact pin · C05: `-Core`/`-Tests-Core`/`-Tests-SDK`). The
orchestrator runs all picks serialized — the COMMIT preconditions (clean tree at
spawn) and the shared `.build/work` verify image make shared-tree concurrency
unsound; disjointness stands as the reviewer's cross-check. Listed serial pick
order: C01 → C02 → C03 → C04 → C05 (the verify floors are stated against it).

## Scheduled ground riding this cut (placements per D-61.a)

- **The conformance-mirror amendment** (E12-C05): the ONLY accepted test file E12
  amends — `PGRSurfaceConformanceTest`, on two written schedules: its own accepted
  class/test comments ("the config-author audience has no code member at M1
  (`PGRConfigurationDraft` is E12)" / "E12's `draftFor:` cut amends this by
  schedule") and the D-82 doc pass's ch. 0 §0.3 erratum (the `PGRKitEnvironment`
  readers "join this roster's conformance-test mirror at the next test-touching
  chunk" — this cut is that chunk; spec and mirror move together). Amendment table
  scripted over `git ls-files 'src/**/*.st'` (110 files scanned, probes.md P29):
  the manifest's only consumer is the amended file itself; no other accepted file
  references the manifest, its audience methods, or `PGRConfigurationDraft`. The
  optional `registrationsFrom:environment:` kit message joins **no** roster (per-kit
  optional with engine probe; the `PGRKit` skeleton deliberately lacks it — accepted
  E11/B-28 ground).
- **R-32's fixture half** (C01–C04) and **R-31's draft half** (C05) land here per the
  frozen roadmap row; R-32's demonstration half is E14's, R-31's adoption half is
  code-free post-D-45 (documented ch. 8 §8.1, exercised by the toy's extension
  package at C02).

## Cross-epic notes / advisories

- **E14 boundary held:** no committed test sends `run` through a registry/gate built
  from toy configuration; C04's pin stops at construction (`isResolved`), C03's
  witnesses run single checks. The demo test with D-43's protections, the exact
  six-verdict report assertion, and the fix/green arms are E14's whole scope.
- **CI stays step 1** (smalltalkci) until E15's scheduled two-step upgrade; every CI
  reference in this cut says so (D-82 carry-forward 1). The new swept suites ride the
  existing step-1 sweep; `Toy-Tests` is outside both its patterns (D-57).
- **Guide 1 untouched:** `docs/quickstarts/01-adopt-and-run.md` quotes
  `PGRConfigurationDraft draftFor:` — its executable-sample witness
  (`testAdoptAndRunSamples`) is E15's scheduled deliverable; C05 makes the quoted
  message real without touching the doc.
- **`.gitignore` `*.fuel` (B-17)** stays with the next infra chunk — no E12 chunk is
  an infra chunk; the M1-mining recommendation stands unconsumed here.
- **Committed-red hygiene for implementer sessions:** C03 onward, the toy is red
  under its OWN (future) artifact by design; nothing in the sweep, the framework
  gate, or CI step 1 sees that red (D-57/D-26 — pinned by accepted
  `PGRToySweepExemptionTest` and re-proven by every chunk's two VERIFY legs).

## Exit checkpoint (freezes E12's interface)

E12 is provable by, on one head commit:

1. **Named suite (the verify command):** `bash tools/build-image.sh &&
   bash tools/verify.sh` exit 0, 0 failures / 0 errors — the E12 swept suites
   `PGRToyBaselineTest` (2) · `PGRToyPlantWitnessTest` (5) · `PGRToyArtifactTest` (2)
   · `PGRConfigurationDraftTest` (4) · the amended `PGRSurfaceConformanceTest`
   (3 tests, one renamed, 46-triple manifest) — with **every previously accepted
   suite still green**, ≥263 run (250 accepted at cut + 13 net new swept; the toy's
   own 4 `Toy-Tests` methods are outside the sweep by design); membership + floor,
   never an exact ceiling.
2. **Self-hosted gate leg (regression, no new registration):**
   `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
   → exit 0, **12 registrations unchanged**, `GATE: GREEN` — E12 adds nothing to the
   framework's own artifact; the exempt-role guard holds over the committed-red toy,
   and the framework's own walls hold over the grown `-Core`.
3. **Committed-red arm (orchestrator-run eval — the D-26 deliverable made
   executable; deliberately NOT a committed test, E14's ground):**
   `.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo --headless .build/work/phi.image eval "((PGRRegistry fromConfiguration: (PGRConfiguration fromString: BaselineOfToy guardrailsSTON)) registrations collect: [ :r | r name -> r run isGreen ]) printString"`
   → six associations, in registry order, **every value `false`** — all six plants
   committed red under the toy's own artifact (a read-only run: the gate never
   mutates, accepted P-GATE-PURE ground).
4. **Unswept-pair arm (orchestrator-run eval):**
   `… eval "(ToyNoIsNilIfFalseRuleTest suite run) printString"` → 2 run, 2 passes,
   0 failures, 0 errors — the client-convention pair green in its unswept home.
5. **Infra leg:** `bash tools/precheck.sh` green at every pick; D-73 `E12-C##:`
   commit prefixes throughout (D-66/D-67).
6. **CI leg:** `.github/workflows/ci.yml` green on an actual CI run of the same
   head — **step 1 only (smalltalkCI)**, sweeping the new suites (`Toy-Tests`
   excluded by its patterns); the committed workflow runs no gate step — the
   two-step upgrade is E15's scheduled edit (D-82 carry-forward 1).

**Frozen at acceptance (E12's interface digest — later epics build on these;
amendments need a decision-sheet entry):**
- **`BaselineOfToy class>>guardrailsSTON`** — the committed toy artifact, §1.1's
  example **content-identical** (reader annotations stripped; the pins assert
  structure, never bytes — ADVISORY-2 swept at Gate 4); **E14 consumes it** via
  `PGRConfiguration fromString:`. Registry shape pinned: the six registrations, in
  order — `lint/PCKNoIsNilIfTrueRule` · `lint/ReCodeCruftLeftInMethodsRule` ·
  `lint/ToyNoIsNilIfFalseRule` · `architecture/PCKLayerMapCheck` ·
  `behavioral/Toy-Tests` · `behavioral/PCKNoSkippedTestsMetaRule`.
- **The plant inventory at its six named homes** (E14's exact-six demonstration and
  its planted-state `setUp` guard build on these spellings):
  `ToyOrder>>#totalOrZero` (`isNil ifTrue:`) · `ToyOrder>>#logTotal`
  (`Transcript show:`) · `ToyOrder>>#itemCountOrZero` (`isNil ifFalse:`) ·
  `ToyOrderView>>#storeSnapshot` (→ `ToyOrderStore`) ·
  `ToyOrderTest>>#testTotalIsFortyTwo` (failing) ·
  `ToyOrderTest>>#testSkippedOnPurpose` (`skip:`).
- **`ToyNoIsNilIfFalseRule`** — the client-convention model: flag-only
  `ReNodeMatchRule`, class-side `severity` `#error`, registered only in the toy's own
  artifact.
- **`BaselineOfToy`'s groupless form** — five packages, zero groups (the R-47
  witness, pinned by `PGRToyBaselineTest`).
- **Config-author surface now code-bearing:**
  `PGRConfigurationDraft class>>draftFor:` (draft STON text; draft-only, D-49) —
  conformance-mirrored in the amended manifest (five audiences, 46 triples, incl. the
  D-82-scheduled `PGRKitEnvironment` reader triples).

Internal / unfrozen: the draft tool's guess heuristics (the `PGRKit`-subclass
discovery anchor, the `-Tests` suffix role guess, the `BaselineOf`-prefix project
guess — documented guesses per D-45 ruling 4, revisable without surface amendment),
the toy domain classes' behavior details, the witness/pin test helpers.

Checkpoint result (to be filled at acceptance): —
