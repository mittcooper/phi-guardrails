# E09 · Self-host and the M1 freeze — chunk index (M1, the join epic)

*Produced by Prompt 4 (seventh run, 2026-07-26). Entry check: roadmap approved
and frozen (D-62); all three dependencies `accepted` in `plan/ledger.md` with
frozen interface digests — **E05** (2026-07-26, head `70410b3`: the gate-caller
SDK `runHeadless:`/`runHeadless:on:`/`forConfiguration:`/`onVerdict:`/`run`,
`PGRReport`'s five readers, the 0/1/2 exit contract, the runner's
relay-else-3 mapping; digest in
`plan/04-epics/E05-gate-report-invocation/chunks.md`) · **E07** (head
`f569549`: behavioral naming incl. the `behavioral/tests-role` sentinel, the
completed four-stage order law, the cache's one-message protocol, the complete
three-key `recommendedBlock`) · **E08** (head `19beb68`: `PCKFixCommand`'s
fix-invocation implementation, the capability pair, the D-72 environment law).
Owner notes honored: the M1 artifact is §7.5 **minus** the two architecture
entries and `#layerMap`/`#src` (the artifact grows as checks land,
constitution §3 — no M2 anticipation); D-75 is citable ground (irrelevant to
this epic's green path); P-DETERMINISTIC's reflective sweep is this epic's,
with the two ruled access sites `PGRConfiguration class>>fromFile:` and
`runHeadless:`'s `Stdio stdout` delegation; quickstart anchors are guides 2–3
(P-GUIDE-EXEC ⅔ — guide 1 is M4's); **E09's acceptance is the M1 milestone
boundary** (roadmap §1 checkpoint closes with it; formal M1 mining runs at
that close); D-66/D-67 — every COMMIT section cites `bash tools/precheck.sh`;
D-73 — IDs are epic-qualified `E09-C##`; every count assertion is named-suite
membership plus a floor, never an exact ceiling (accepted sweep = **174** at
cut time).*

| ID | Title | Depends | [P] | LOC est. | Acceptance (one line) |
|---|---|---|---|---|---|
| E09-C01 | `PGRArchSelfTest` — the reflective walls | — | yes | ~155 | the six wall sweeps green over the committed production packages, each proven live by banned-witness assertions — **P-CORE-NEUTRAL · P-SDK-EDGE · P-NO-TRANSCRIPT · P-DETERMINISTIC · P-FIX-GATE-WALL (reflective form)**; `PGRArchSelfTest` (6) green |
| E09-C02 | `PGRSurfaceConformanceTest` — the machine-witnessed freeze | — | yes | ~120 | the ch. 0 §0.3 M1 roster (41 triples + 4 error classes) mirrored as a class-side manifest and asserted resolvable — **P-SURFACE-CONFORMS**; `PGRSurfaceConformanceTest` (3) green |
| E09-C03 | `guardrails.ston` — M1 artifact, self-hosted green | — | yes | ~110 | the M1-form artifact committed at repo root; `./guardrails.sh guardrails.ston` exits **0** with 10 green registrations — **P-SELF-HOSTED (M1 form)**; the two tests-role pin classes land (`PGRToySweepExemptionTest` 3 · `PCKArtifactBlockM1FormTest` 3) |
| E09-C04 | The quickstart sample harness | — | yes | ~160 | fence extraction pinned against both committed guides (5 + 2 samples), class-sample compilation (fluid defs, `class >>`, one-liners, the `install:slots:` storage-input variant) and teardown round-trip proven; `PGRQuickstartSampleHarnessTest` (4) green |
| E09-C05 | `testWriteACheckSamples` — guide 2 verbatim | E09-C04 | no | ~150 | all five guide-2 samples executed through the harness and behaving as stated (plain-class conformance with the elided-storage input, skeleton + fix capability, fixture pair 2/2, registration name in the report) — **P-GUIDE-EXEC leg 1**; `PGRQuickstartSamplesTest` (1) green |
| E09-C06 | `testBuildAKitSamples` — guide 3 verbatim | E09-C05 | no | ~115 | both guide-3 samples executed and behaving as stated (two-message contract, stanza parse, unknown-key signal, missing + resolved spec arms, composed two-kit run in block order) — **P-GUIDE-EXEC leg 2**; closes the epic → the M1 checkpoint below |

Total ~810 LOC across 6 chunks. The frozen roadmap row estimates ~5; the +1
is the sample-harness split the row's own risk line anticipated ("the
verbatim-sample execution harness … is undesigned — a work-order design point
for the chunk stage"): the harness (C04) is separated from the two guide
tests (C05/C06) so no chunk carries both the machinery and its consumers.

**[P] eligibility (disjoint manifests):** E09-C01 (`PGRArchSelfTest`, new
file, `-Tests-Core`) · E09-C02 (`PGRSurfaceConformanceTest`, new file,
`-Tests-SDK`) · E09-C03 (`guardrails.ston` + two new test files in the two
stub packages) · E09-C04 (harness pair, new files, `-Tests-Gate`) — all four
pairwise disjoint. The orchestrator runs them serialized — the COMMIT
preconditions (clean tree at spawn) and the shared `.build/work` verify image
make shared-tree concurrency unsound; disjointness stands as the reviewer's
cross-check. C05→C06 are strictly serial (both extend
`PGRQuickstartSamplesTest.class.st`; C05 additionally consumes C04's
harness). E09 is the join epic — nothing runs `[P]` beside it (roadmap).

**Amended accepted surface: none.** Every deliverable in this cut is a new
file (`guardrails.ston` and five new class files) or a scheduled extension of
this epic's own C05 file by C06; **zero accepted test methods are amended**
and no accepted file appears in any manifest (the validator asserts this by
script). C06's reviewer diffs C05's methods for byte-identity.

## Property placements, stated (the E03/E04/E05 precedent)

- **Discharged in full here:** P-SURFACE-CONFORMS (E09-C02,
  `testEverySurfaceSelectorExistsWithRightArity`) · P-CORE-NEUTRAL (E09-C01,
  `testCoreReferencesNoEngineClass` + `testProductionReferencesNoClientClass`)
  · P-SDK-EDGE (`testKitPackagesReferenceOnlySDK`) · P-NO-TRANSCRIPT
  (`testNoProductionMethodReferencesTranscript`) · P-DETERMINISTIC
  (`testNoNetworkOrStrayFileReferences`).
- **P-FIX-GATE-WALL — reflective form here** (E09-C01,
  `testGateReferencesNoKitClass`); the property's layer-map form lands with
  the §4.4 map at M2 (E10/E11) — the roadmap's "walls machine-enforced
  *before* the layer-map check exists".
- **P-SELF-HOSTED — M1 form here** (E09-C03: the committed artifact + the
  local runner leg `./guardrails.sh guardrails.ston` → 0, re-run at the exit
  checkpoint); the property's CI form (the committed workflow's step 2) is
  **E15's** per the frozen roadmap — the E05-C07 aside "step 2 arrives at
  E09" is read as the *artifact's* arrival; adding the CI step here would
  exceed the frozen E09 row (divergence note, recorded).
- **P-GUIDE-EXEC — ⅔ here** (E09-C05/C06, the two M1-anchored guide legs);
  guide 1's leg is M4's (E15), its samples keep the ⟨verify⟩ header until
  then (ch. 9 letter).
- **Explicitly not owed here:** P-WRAPPER-GUARD (E15) · P-GATE-RED (E14) ·
  P-LAYERMAP-TOTAL / P-FINDING-PRECISE / P-NO-DEAD-SRC (M2).

## Agent calls recorded (veto-open, D-16 precedent; closing at acceptance unless vetoed)

- **The two tests-role pin classes (C03) — the one forced move of this cut:**
  `Phi-Guardrails-Tests-Toy` and `Phi-Coding-Kit-Tests-Architecture` are
  classless stubs, and the frozen E07 semantics make a zero-test-class
  tests-role package a `#missing` verdict — so R-38's "gate must pass from
  M1" is unsatisfiable without one real test class in each. The *move* is
  forced by ruled ground (R-38 × E07 freeze × §7.5 roles); the *contents*
  are this cut's calls: `PGRToySweepExemptionTest` pins the D-26/D-57
  committed-red guard (toy outside both sweep patterns, exempt-pattern
  totality, the frozen toy-group inventory) and `PCKArtifactBlockM1FormTest`
  pins the artifact's M1 form at the kit boundary (no architecture entries,
  every named check resolves). Both are permanent, decidable facts — E10/
  E11/E12/E14 extend those packages additively (E11 amends the M1-form pin
  by schedule when the artifact grows).
- **The P-DETERMINISTIC Zinc-arm reconciliation (C01):** accepted B-15
  ground (`fromFile:` catching `ZnCharacterEncodingError`) references a
  Zinc-defined class; the ch. 9 Zinc-arm letter predates it. The sweep
  carries the same three-method allowlist in the Zinc arm as in the
  file-triad arm, and *pins* the reconciliation (asserts `fromFile:` does
  reference a Zinc class). A one-line ch. 9 erratum note is the owner's to
  ride a future spec pass (the B-19 pattern).
- **Test-class homes:** `PGRArchSelfTest` → `Phi-Guardrails-Tests-Core`
  (beside the E04 reflective-sweep precedent);
  `PGRSurfaceConformanceTest` → `Phi-Guardrails-Tests-SDK` (the surface is
  the SDK boundary); `PGRQuickstartSamplesTest` + harness →
  `Phi-Guardrails-Tests-Gate` (closes D-59's veto-open home: the sample
  tests drive gates on scratch configurations — nests and terminates,
  D-46).
- **The M1 surface manifest (C02)** excludes `PGRConfigurationDraft`
  (E12's; the config-author audience has no code member at M1 — pinned by
  `testManifestSpansTheFourCodeSurfacesAtM1`, amended by schedule at E12),
  `PGRVerdict class>>skipped` (D-21/D-32), and all internals; arity is read
  as intrinsic-to-the-selector (lookup success = the assertion).
- **The artifact's `#project` value (C03):** `'PhiGuardrails'` — feeds only
  the human-facing report header.
- **Sweep ban-lists by defining-package prefix (C01):** engine =
  `SUnit`/`Renraku`/`AST-Core`/`Refactoring` (adjusted to the live image's
  answers, witness-forced, final list recorded in the report); network =
  `Zinc`/`Network`/`Zodiac`; every sweep proves itself live (nonzero scan
  floors + known-banned witnesses).
- **Harness design (C04):** fences by ```` ``` ````-line pairs; `smalltalk`/
  `ston` info tags are samples, untagged fences are prose; class samples
  split at `Name( class)? >> selector` listing headers, method source =
  header remainder + following lines (one-liners and comment-only bodies
  compile verbatim); fluid pre-header segment evaluated + installed;
  instance-registered teardown, `ensure:`-guarded; repo-root locator =
  upward scan from `workingDirectory`, then a `SmalltalkCI`-provided
  project path when that global exists, then from `imageDirectory` — all
  three failing is a loud error, never a skip.
- **Sample-execution semantics (C05/C06):** the guide's code is executed
  verbatim; classes/packages a sample *references but does not define*
  (the Acme fixture classes, `DKClassCommentCheck`, the scratch artifact
  envelope around block fragments) are harness-supplied **inputs** — and
  so is the **author's-own plumbing guide-2 §2 deliberately elides**: that
  sample sends `self new setPackages: names` and reads `self packages`
  without defining setter, reader, or slot (D-60 recorded the setter as
  "illustrative, the author's own class"), so the test supplies the slot
  (via the harness's `install:slots:` variant) and the setter/reader pair
  as input before the sample's methods stand verbatim on top — without
  this the sample's constructor is a `MessageNotUnderstood` before any
  validation runs (validation round-1 finding, F-1). Guide-2 §2 runs in an
  isolated pass (it redefines §1's class name; its `run` body is the
  verbatim comment placeholder, so only conformance/registration facts are
  asserted there — the guide's own claim). Assertions are the guides'
  stated facts only: names, classes, counts, order — never report or error
  wording, never unstated exit codes.
- **CI stays step-1-only at E09** — the two-step upgrade and
  P-WRAPPER-GUARD are E15's frozen row (see the P-SELF-HOSTED placement
  note above).
- **⟨verify-in-image⟩ items delegated to implementers with
  record-in-report duty (P5, the E04/E06 precedent):** the
  `referencedClasses` and literals-scan spellings and witness package
  names (C01) · the `matchesRegex:` full-match form and STON file read
  (C03) · the fluid-builder install form, class/package removal spellings,
  and the smalltalkCI project-directory probe (C04) · scratch
  class-comment behavior and creation/removal forms (C05/C06).

## Exit checkpoint (closes E09 — and with it milestone M1)

E09 is provable by, on one head commit:

1. **Named suite:** the 21 new E09 tests — `PGRArchSelfTest` (6) ·
   `PGRSurfaceConformanceTest` (3) · `PGRToySweepExemptionTest` (3) ·
   `PCKArtifactBlockM1FormTest` (3) · `PGRQuickstartSampleHarnessTest` (4)
   · `PGRQuickstartSamplesTest` (2) — green under
   `bash tools/build-image.sh && bash tools/verify.sh`, with **every
   previously accepted suite still green** (174 accepted at cut time →
   floor ≥ 195 run, 0 failures, 0 errors — membership plus floor, never an
   exact ceiling). Named properties discharged by their ch.-9-named tests:
   **P-SURFACE-CONFORMS · P-CORE-NEUTRAL · P-SDK-EDGE · P-NO-TRANSCRIPT ·
   P-DETERMINISTIC · P-GUIDE-EXEC (write-a-check + build-a-kit legs)** —
   plus the recorded forms: P-FIX-GATE-WALL (reflective) and P-SELF-HOSTED
   (M1).
2. **Self-hosted leg (the roadmap §1 M1 clause):**
   `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo
   IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston` on the same
   commit → exit **0**; the streamed report shows `PhiGuardrails`, 10
   registrations, `GATE: GREEN`.
3. **Infra leg:** `bash tools/precheck.sh` green at every chunk pick (D-67
   standing discipline); commits carry D-73 qualified IDs
   (`E09-C##: <title>`).
4. **CI leg:** the committed `.github/workflows/ci.yml` (step 1) green on
   an actual CI run of the same commit — the 21 new tests ride the
   existing smalltalkCI sweep (the quickstart locator's CI behavior is
   proven here, not assumed).

**At acceptance (E09's interface digest — and the M1 milestone close):**

- **No new frozen exports** — E09 is the join: what it delivers is the
  **machine witness** over surfaces already frozen at E02/E03/E05/E06/E07/
  E08 (`PGRSurfaceConformanceTest`'s manifest is the frozen roster's
  mirror; from here the freeze is red-test-enforced, roadmap §2) and the
  reflective wall enforcement (`PGRArchSelfTest`).
- **The committed M1 artifact form freezes as ruled ground:**
  `guardrails.ston` = §7.5 minus the two architecture entries and
  `#layerMap`/`#src`; it grows only by scheduled epic edits (E11 completes
  it; E12's toy artifact is separate), witnessed by
  `PCKArtifactBlockM1FormTest`.
- Internal and unfrozen: the harness's parsing/locator machinery, the pin
  tests' helper spellings, the sweep helpers.
- **M1 closes:** the roadmap §1 M1 checkpoint (verify sweep + runner leg +
  both sample tests, one head) is exactly legs 1–2 plus the named
  `PGRQuickstartSamplesTest` methods; the orchestrator runs the **formal
  M1 mining pass** over E02–E09's reports/reviews at this close (the E01
  precedent), and E10's entry check (M2) can then pass.

Checkpoint result (filled at acceptance): —

## Addendum — validation record and post-PASS punch list (2026-07-26)

Two validation rounds (fresh validator each round, per the exit criteria):

1. **Round 1: REJECT** (1 BLOCKING + 1 MINOR + 2 ADVISORY) — F-1: C05's
   plain-class pass ordered `AcmeClassCommentCheck packages:` and a
   registry build against guide-2 §2, whose sample deliberately elides
   `setPackages:`/storage (D-60's recorded "illustrative, the author's own
   class") — a `MessageNotUnderstood` dead end before any validation runs.
   Remediated in-session: the harness-supplied-inputs reading extended to
   cover the elided author-side storage (C04 gains the `install:slots:`
   variant with a pin-test arm; C05 step 1 supplies slot + setter/reader
   as input; the semantics call above records it); the round's MINOR (the
   fluid-idiom probe-file pointer in C04's digest) swept in the same batch
   (the cascade idiom now inlined). LOC 795 → 810, count sites updated.
2. **Round 2: PASS** (0 BLOCKING · 2 MINOR · 2 ADVISORY) — report on file:
   `plan/validation/04-E09-report.md` (the gate's artifact). Punch list
   applied the same day, one batch, no re-validation per the validation
   rules: explicit ≥ 100 scan floors added to C01 skeletons 5–6; the
   dead-slack note added to C01's file-triad allowlist (the two `PGRGate`
   entries are the ch. 9 letter's ruled sites, unpinned because unused
   today). The advisories (guide-1 not-choking untested until M4; the
   ch. 9 Zinc-arm erratum riding the owner's next spec pass) stand as
   recorded — the agent-call list above is their veto surface.

## Milestone note

E09 joins the core track (E01→E05) with the kit track (E06→E07/E08): all
eight prior epics are accepted ground; this cut touches no accepted file.
Its acceptance is the **M1 milestone boundary** — the walking skeleton,
self-hosted.
