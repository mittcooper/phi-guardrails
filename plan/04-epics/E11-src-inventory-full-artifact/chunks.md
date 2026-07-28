# E11 · Src inventory and the full artifact — chunk index

Cut by the ninth committed Prompt-4 run (2026-07-27), re-cut fresh from the D-81
ruling (the superseded pre-D-81 option-(a) cut was retired uncommitted to
`.build/superseded/` per that entry — this cut was made without reading it, per the
owner's notice). Epic-qualified IDs per D-73. Accepted verify sweep at cut time:
**230 tests** — every count below is named-suite membership plus a floor, never an
exact ceiling. **E11's acceptance IS the M2 milestone boundary** (roadmap M2 exit:
both instruments green over the COMPLETED §7.5 artifact) — the exit checkpoint below
states that criterion; the epic ends at the owner's milestone gate.

Ruled ground in force: **D-81** (the kit environment view — read the entry before
implementing; the five-keyword extended message is VETOED, do not rebuild it) ·
**D-79/D-79.a** (layer-map semantics) · **D-80** (`#unlayered` advisory rides clean
reports only; no red-with-advisories anything) · **D-45** (`#src` semantics) ·
**D-25/D-25.a** (dead-code guard + verified spellings) · **D-51** (every check named
explicitly) · **D-53.5** (kits never receive the configuration object) · **D-78**
(M1 closed; M2 = E10→E11 confirmed frozen). E12's ground is not pre-built: the
committed `Toy-*` skeletons are E01 baseline ground, exempt-role by declaration —
untouched by every manifest here.

## Chunks

| ID | Title | Depends-on | [P] | LOC est. | Acceptance (one line) |
|---|---|---|---|---|---|
| E11-C01 | `PGRKitEnvironment` — the published kit environment view | — | yes | ~100 | `PGRKitEnvironmentTest` (6) green — the D-81 view: four named readers, fresh copies, nil srcPath legal, no generic lookup |
| E11-C02 | Engine probe — core builds the view, hands it, falls back | E11-C01 | no | ~120 | `PGRRegistryTest` (+3) green — the view carries resolved roles + exempt + srcPath across the boundary; three-argument kits served unchanged (every accepted registry test byte-identical) |
| E11-C03 | `PCKSrcInventoryCheck` — the dead-source read-only walk | — | yes | ~140 | `PCKSrcInventoryCheckTest` (5) green — red per stray directory / green on clean root (P-NO-DEAD-SRC fires+silent legs), baseline clause absorbs `BaselineOf*` dirs, nonexistent root loud, scratch roots only |
| E11-C04 | Kit environment form + `PCKSrcInventoryCheck` dispatch | E11-C01, E11-C03 | no | ~140 | `PCKKitTest` (+5) and `testMissingWithoutSrcKey` green — one pipeline, two doors (delegation witness); src-check constructed from the view or missing without `#src` (§1.5, P-NO-DEAD-SRC third leg); layer-map + generic paths intact; zero accepted methods amended |
| E11-C05 | The completed §7.5 artifact — self-hosted walls | E11-C02, E11-C04 | no | ~90 | the 3 amended pin tests green over the completed committed artifact AND `./guardrails.sh guardrails.ston` exit 0 with **12** registrations GREEN — the scheduled amendment lands per its scripted table |

Sum ≈ 590 LOC — the roadmap's "~4 chunks (small closing epic, knowingly)" cut as
five: the D-81 view and its engine seam are two separately reviewable concerns
(SDK value vs. engine dispatch), and folding them would put ~220 LOC and two
packages in one diff.

[P] eligibility (disjoint manifests): E11-C01 · E11-C03. The orchestrator runs them
serialized — the COMMIT preconditions (clean tree at spawn) and the shared
`.build/work` verify image make shared-tree concurrency unsound; disjointness stands
as the reviewer's cross-check. C02/C04/C05 are strictly serial (C02 needs the view;
C04 needs view + check; C05 needs both doors live).

## Scheduled ground riding this cut (placements per D-61.a)

- **The D-81 landing** (C01/C02/C04): the environment view + additive
  `registrationsFrom:environment:` beside the frozen three-argument form. Zero
  accepted consumers change (scripted enumeration in C02/C04's notes: every
  committed `registrationsFrom:`/`fromConfiguration:` caller dispositioned —
  fallback or behavior-preserving delegation, witnessed by accepted suites staying
  byte-identical and green). The E02 digest already carries the D-81 erratum line.
- **The pin-test amendment** (C05): the ONLY accepted test file E11 amends —
  `PCKArtifactBlockM1FormTest`, whose own class comment schedules it ("E11 amends
  the M1-form assertions by schedule when the artifact grows"). Amendment table
  scripted over `git ls-files 'src/**/*.st' 'docs/**/*.md' 'tools/*'
  'guardrails.sh' '.github/workflows/*' '.smalltalk.ston'` (116 files scanned;
  independently re-confirmed by the validator's full-tree 237-file sweep): all
  other `guardrails.ston` references are scratch/decoy fixtures, comments, or
  client-sample guides; zero committed files assert the 10-registration count.
  Table inlined in C05.

## Cross-epic notes / advisories

- **`PGRKit` skeleton stays untouched** (all chunks): the engine probe folds
  inheritance, so skeleton support for the environment form would falsely claim it
  for every subclass — carried as B-28 (4), post-v1.
- **`PGRSurfaceConformanceTest` / ch. 0 §0.3 roster**: the view's readers join the
  kit-author roster at the owner's next doc pass (the D-81-consequences pattern —
  spec and manifest mirror move together); until then the view's freeze is
  red-test-enforced by `PGRKitEnvironmentTest`. Advisory to the owner, not
  normative ground.
- **Behavioral-suite derivation is untouched**: under the environment form the
  suites still derive from the view's tests-role list — same law, new source.
- **`PGRArchSelfTest>>ruledFileAccessSelectors` comment (validator MINOR-3, owner's
  doc pass)**: the accepted comment says "PCKSrcInventoryCheck joins at M2 by that
  epic's scheduled edit" — the E11 walk as cut compiles no file-triad class literal
  (String-extension sends only, C03's constraint line), so the allowlist needs no
  entry and the arm stays green unamended; the comment's promised edit turned out
  unnecessary and its wording (plus the allowlist's non-naming of §7.6's second
  ruled file access) rides the owner's next doc pass beside the §0.3 roster note.
  If a C03 implementation ever genuinely needs a triad literal, that is a
  stop-and-report, not a silent allowlist edit.
- **Q-38 → D-81 closed on the sheet at this cut**; no open question rides the epic
  at cut time.

## Exit checkpoint (freezes E11's interface — AND is the M2 milestone boundary)

E11 is provable by, on one head commit — and its acceptance closes M2 (roadmap M2
exit criterion, stated here per the owner's gate notice): **both instruments green
over the COMPLETED §7.5 artifact** —

1. **Named suite (instrument 1, the verify command):**
   `bash tools/build-image.sh && bash tools/verify.sh` exit 0, 0 failures / 0
   errors — the E11 suites `PGRKitEnvironmentTest` (6) · `PGRRegistryTest` (+3) ·
   `PCKSrcInventoryCheckTest` (6 incl. the C04-added missing leg) · `PCKKitTest`
   (+5) · the 3 amended `PCKArtifactBlockM1FormTest` pins, with **every previously
   accepted suite still green** — ≥250 run (230 accepted at cut + 20 net new);
   membership + floor, never an exact ceiling. Properties discharged here:
   **P-NO-DEAD-SRC** (all three ch.-9-named legs: fires · silent · missing) and the
   pin-test half of the completed-form witness.
2. **Self-hosted gate leg (instrument 2, the enforcement step) — NEW REGISTRATIONS:**
   `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
   → exit 0, `PhiGuardrails`, **12 registrations** (10 M1 + `architecture/
   PCKLayerMapCheck` + `architecture/PCKSrcInventoryCheck`), `GATE: GREEN` —
   **P-SELF-HOSTED in its full form**: the gate now machine-enforces the §4.4 walls
   and the dead-source law on our own repo (constitution §3's enforcement map goes
   live for the architecture row). A genuine violation surfaced by this leg is
   fixed or filed, never mapped away (the roadmap-budgeted risk).
3. **Infra leg:** `bash tools/precheck.sh` green at every pick; D-73 `E11-C##:`
   commit prefixes throughout.
4. **CI leg:** `.github/workflows/ci.yml` green on an actual CI run of the same
   head — **step 1 only (smalltalkCI)**, sweeping the new suites; the committed
   workflow runs no gate step — the two-step upgrade (the gate as CI step 2) is
   E15's scheduled edit (M4, frozen roadmap). Until E15, the M2 criterion's
   12-registration enforcement witness is leg 2's local gate run (the E09/E10
   checkpoint precedent; corrected at Gate 4 — the advisor's finding).

**Frozen at acceptance (E11's interface digest — amendments need a decision-sheet
entry):**
- **`PGRKitEnvironment`** (SDK): constructor
  `productionPackages:testsPackages:exemptPackages:srcPath:`; readers
  `productionPackages` · `testsPackages` · `exemptPackages` · `srcPath` (nil when
  the envelope declares no `#src`). Growth path per D-81 ruling 4: a future
  published fact = ONE NEW READER via decision-sheet amendment — never a new
  kit-protocol selector, never a probe arm.
- **The optional kit-protocol message** `registrationsFrom:environment:` (block +
  view), engine-probed per kit with fallback to the frozen three-argument form —
  the E02 digest's D-81 erratum made permanent surface.
- **Registration `architecture/PCKSrcInventoryCheck`** — kind `#architecture`;
  missing when the configuration declares no `#src` (§1.5); red with one finding
  per dead directory under the declared root (baseline clause included).
- **The completed artifact form** (config-author surface, the repo's own): §7.5
  verbatim — `#src : 'src'`, both architecture entries, the §4.4 four-layer/
  four-edge map with no `#unlayered`; grows only by scheduled epic edits, witnessed
  by the amended pin test.

Internal / unfrozen: `PCKSrcInventoryCheck class>>srcPath:packages:` (kit-side, the
engine validates only `PGRCheck`'s contract), the walk's spellings,
`PGRScratchEnvKit`, the engine's delegation/probe implementation shape, the pin
test's helpers.

Checkpoint result (filled at acceptance, 2026-07-28): **GREEN on head `786bacf`**
— leg 1: verify 250/250, 0 failures / 0 errors (`PGRKitEnvironmentTest` 6 ·
`PGRRegistryTest` +3 · `PCKSrcInventoryCheckTest` 6 incl. the C04-added missing
leg · `PCKKitTest` +5 · the 3 amended `PCKArtifactBlockM1FormTest` pins; 230 at
cut + 20 net new; P-NO-DEAD-SRC discharged on all three ch.-9-named legs);
leg 2: `./guardrails.sh guardrails.ston` exit 0, `PhiGuardrails`, **12
registrations** (10 M1 + both architecture entries), `GATE: GREEN 0 blocking
of 12` — P-SELF-HOSTED full form, no first-run violation (the budgeted risk
did not materialize; nothing weakened); leg 3: precheck green at every pick,
`E11-C##:` prefixes throughout (C01 carried one reviewer fix round-trip,
commit `318f46c`); leg 4: CI run 30326283281 success on the same head (step 1
only — smalltalkCI; the gate-as-step-2 is E15's scheduled edit). Interface
digest above **frozen**. E11 accepted — **M2 closes at this boundary** (the
mining pass and milestone report follow at the owner's gate).
