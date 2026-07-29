# E15-C01 · CI to the two-step contract + the wrapper-guard self-test  [depends: — · parallel: no]

GOAL      Upgrade the committed `.github/workflows/ci.yml` to §7.4's two-step
contract — step 1 smalltalkCI unchanged, step 2 the gate headless on the repo's
own artifact via a §7.3-recipe gate image — plus the P-WRAPPER-GUARD shell
self-test, discharging the D-60.a landing condition; `.smalltalk.ston` is
confirmed already in its final form.

TRACE     R-29 (as amended by D-45) · spec ch. 7 §7.3 (recipe + wrapper rule) ·
§7.4 (the two steps) · ch. 9 P-WRAPPER-GUARD, P-SELF-HOSTED (CI form) · D-40
(two-step independence) · D-45 · D-49 (self-test, not waiver) · D-60/D-60.a
(load-expression landing condition) · D-63 (M0 probe record: hosted-load row) ·
D-64 (real coordinates) · D-65 (infra locations) · D-66 (checksum pins) · D-75
(∉{0,1,2} erratum) · D-82 carry-forward 1 (this chunk IS the scheduled two-step
upgrade).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**The two-step contract (§7.4, condensed).** The framework's own CI runs two
visible steps: (1) validation — smalltalkCI runs the test packages, never
through the gate; (2) enforcement — a separate step invokes
`./guardrails.sh guardrails.ston`, the framework as gate *subject* like any
client (R-47). Both steps deliberately run every tests-role suite twice per CI
run (D-40 independence: a defect in the gate cannot suppress the tests that
detect it); neither step may be deleted in favor of the other. One workflow
file invokes both: `.github/workflows/ci.yml`.

**The wrapper rule (§7.3/D-45) and its self-test (D-49/P-WRAPPER-GUARD).**
`guardrails.sh` (committed, accepted at E05 — DO NOT MODIFY) relays exit 0/1/2
and maps any other code to 3 with one stderr line. D-49: this mapping is
machine-checked by a ~three-line CI shell step — a deliberate non-gate failure
must exit exactly 3. **Probed arm spellings (cut-time, probes.md P1, darwin VM
build 4f7563dfe5):**

- nonexistent `$PHARO_VM` → bash exec failure 127 → wrapper exits **3** with
  `guardrails: gate did not run to a verdict (exit 127)` — **this is the
  self-test arm**;
- real VM + empty/corrupt image → VM exits 1 → relays 1 (the D-75 ruled known
  v1 limitation — the ch. 9 P-WRAPPER-GUARD row's "unloadable image exits 3"
  wording predates D-75; the decision log wins — cite D-75, use the missing-VM
  arm);
- real VM + **nonexistent image file** → this VM exits **0** → relays 0 — a
  false-green hole, newly probed at this cut and filed as **Q-40**
  (decision sheet). **Out of scope here unless the owner rules otherwise**
  (owner scope line: B-23/B-25-class collision hardening stays M5).

**The image-assembly recipe (§7.3/D-60) and the D-60.a landing condition.** The
workflow's step-2 gate image is assembled by the recipe — fetch a Pharo 13
headless VM+image, Metacello-load the code, set `$PHARO_VM`/`$IMAGE`, invoke
the wrapper — and the workflow is the recipe's *executable copy*: its load
expression must be the real form of §7.3's, judged against the M0 probe
record's hosted-load row (D-63, executed green at E01/C04):

```smalltalk
Metacello new
    baseline: 'PhiGuardrails';
    repository: 'github://mittcooper/phi-guardrails:main/src';
    load: 'CI'.
```

(D-64 real coordinates; the framework's own CI loads the baseline's `CI` group
— §7.3 step 2's own note. The repo is public; no token machinery. D-64's
main-only push model means the hosted load of `main` is the commit under
judgment on every push run; recorded as a cross-epic note in `chunks.md`.)

**Cut-time toolchain probe for ubuntu-latest (probes.md P2):**
`https://files.pharo.org/get-files/130/pharoImage-x86_64.zip` is
**byte-identical** to the D-66-pinned image zip (SHA-256
`897668dd548864f74730065de3fa2b1f4b5d3636d4c7d14f91945f0a5ce22590`; contains
`Pharo13.0-SNAPSHOT-64bit-4f7563dfe5.image` + `.changes` +
`Pharo13.1-64bit-4f7563d.sources` — exactly the D-63 verified build);
`pharo-vm-Linux-x86_64-stable.zip` SHA-256
`b4b344a8236f43f08eedad205ca6a292f85bbcbe107f5d68aed04595c43e83ed`, entry point
`bin/pharo`. Both pins go into the workflow (D-66: drift fails loudly).

**Constitution rules that bite here:** committed harness/infra lives outside
the product write boundary (D-65 — `ci.yml` and `.smalltalk.ston` are named
committed infra; uncommitted CI build state goes under `.build/`); no
weakening, skipping, or unregistering a check to make a build pass (P6); the
verify command and the self-hosted gate leg must stay green.

DELIVERABLES

Files:
- **modify** `.github/workflows/ci.yml` — to exactly the target below (the
  complete file, verbatim; iterate only if a CI red forces a disclosed
  deviation).
- **verify-only** `.smalltalk.ston` — confirm the committed file already
  equals the spec's final form, which is exactly (inlined here so nothing else
  need be read; cut-time diff says the committed file IS this, byte-for-byte):

  ```ston
  SmalltalkCISpec {
      #loading : [ SCIMetacelloLoadSpec {
          #baseline : 'PhiGuardrails', #directory : 'src', #load : [ 'CI' ] } ],
      #testing : { #packages : [ 'Phi-Guardrails-Tests-.*', 'Phi-Coding-Kit-Tests-.*' ],
                   #failOnZeroTests : true }
  }
  ```

  **No edit expected.** If a divergence is found, stop and report — do not
  improvise.

No other file. `guardrails.sh`, `tools/*`, `src/**` untouched.

Target `.github/workflows/ci.yml`:

```yaml
name: CI
on: [push, pull_request]
jobs:
  validation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hpi-swa/setup-smalltalkCI@v1
        with:
          smalltalk-image: Pharo64-13
      - name: "step 1 · validation — smalltalkCI (spec §7.4)"
        run: smalltalkci -s Pharo64-13
        shell: bash
        timeout-minutes: 30
      - name: "assemble the gate image (spec §7.3 recipe — the D-60.a executable copy)"
        run: |
          mkdir -p .build/gate && cd .build/gate
          curl -sSLo image.zip https://files.pharo.org/get-files/130/pharoImage-x86_64.zip
          curl -sSLo vm.zip https://files.pharo.org/get-files/130/pharo-vm-Linux-x86_64-stable.zip
          echo "897668dd548864f74730065de3fa2b1f4b5d3636d4c7d14f91945f0a5ce22590  image.zip" | sha256sum -c -
          echo "b4b344a8236f43f08eedad205ca6a292f85bbcbe107f5d68aed04595c43e83ed  vm.zip" | sha256sum -c -
          unzip -q image.zip && unzip -q vm.zip -d vm
          mv Pharo13.0-*.image gate.image
          mv Pharo13.0-*.changes gate.changes
          ./vm/bin/pharo --headless gate.image eval "Metacello new baseline: 'PhiGuardrails'; repository: 'github://mittcooper/phi-guardrails:main/src'; load: 'CI'. Smalltalk snapshot: true andQuit: true"
        shell: bash
        timeout-minutes: 20
      - name: "step 2 · enforcement — the gate headless on the framework's own artifact (spec §7.4)"
        run: PHARO_VM=.build/gate/vm/bin/pharo IMAGE=.build/gate/gate.image ./guardrails.sh guardrails.ston
        shell: bash
        timeout-minutes: 10
      - name: "wrapper-guard self-test (P-WRAPPER-GUARD, D-49)"
        run: |
          code=0
          PHARO_VM=/nonexistent-vm IMAGE=/nonexistent.image ./guardrails.sh guardrails.ston || code=$?
          test "$code" -eq 3
        shell: bash
        timeout-minutes: 5
```

(Notes that are part of the order: the self-test body is `-e`-safe by the
`|| code=$?` capture — GitHub's `shell: bash` runs `-e -o pipefail`, and a bare
`cmd && exit 1` list would abort the step with the wrapper's own code. If
`vm/bin/pharo` lacks its executable bit after `unzip` on ubuntu, add one
`chmod +x vm/bin/pharo` line as a disclosed deviation. The step-1 spelling
`smalltalkci -s Pharo64-13` is the D-63-recorded working form — `-s` takes the
platform; the config auto-detects at the repo root.)

**The D-60.a landing-condition discharge (record in the completion report):**
state explicitly that the workflow's step-2 load expression carries baseline
`'PhiGuardrails'`, repository `'github://mittcooper/phi-guardrails:main/src'`,
and `load: 'CI'` — the same expression the M0 probe record's hosted-load row
(D-63) executed green, coordinates per D-64. The smalltalkCI spec is *not* the
judged form (D-60.a's wrinkle: equivalence is judged on the step-2 image
assembly).

**Amendment table — committed references to the workflow's shape (scripted at
cut over the 136-file committed code+docs+infra scope; re-run the sweep and
confirm before commit):**

| Committed reference | Verdict |
|---|---|
| `.github/workflows/ci.yml` | the amended file itself |
| `.smalltalk.ston` | step-1 config only (§7.4 says so); final form confirmed, unchanged |
| `docs/quickstarts/01-adopt-and-run.md` line 65 ("the framework's own CI workflow is the executable, tested copy of the same steps") | becomes fully true when this chunk lands; the guide's own amendment is E15-C02's |
| `PGRQuickstartSampleHarness` (`SmalltalkCI` global locator) | runtime CI-environment probe, not a workflow-shape pin — untouched |
| `src/**` "step 1"/"step 2" grep hits (7 hits across 6 files — `PCKSuiteRunCache` carries two) | all spec-paragraph *stage* comments (§1.4, §5.2, §7.5, §8.1), not CI steps — untouched |

No committed file pins step-1-only as permanent; checkpoint CI-leg wordings in
`plan/` cite runs, not steps (append-or-frozen papers, not consumers).

LOC budget: target ~35 changed YAML lines · ceiling 300.

TESTS FIRST

This is a D-65 infra chunk: the "tests" are executable arms, not SUnit
skeletons (the E05-C07 precedent).

- **Arm 1 (local, red-first optional):** `code=0; PHARO_VM=/nonexistent-vm
  IMAGE=/nonexistent.image ./guardrails.sh guardrails.ston || code=$?;
  test "$code" -eq 3` — passes against the committed wrapper (probed P1);
  proves the self-test line itself before CI runs it.
- **Arm 2 (the CI run — the chunk's real verifier):** push; the workflow run
  on the chunk's head commit completes `success` with **all six steps green**
  (checkout · setup · smalltalkCI · assembly · enforcement · self-test);
  the step-2 log contains `GATE: GREEN` and `12 registrations`; the self-test
  step log shows the wrapper's one stderr line and exits green.
- **Arm 3 (regression):** `bash tools/build-image.sh && bash tools/verify.sh`
  exit 0, ≥266 run (no src change — the accepted sweep unchanged), **and**
  `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
  → exit 0, 12 registrations, `GATE: GREEN`.

VERIFY    `gh run list --workflow=ci.yml --limit 1` → `completed success` on
          this chunk's head commit, six steps green, step-2 log shows
          `GATE: GREEN` / 12 registrations; plus Arm 1 (local exit 3) and Arm 3
          (sweep ≥266 + self-hosted gate leg) on the same head. Red CI
          iterations are permitted inside the chunk (the M0/C03 precedent);
          the final state is one green run on the head.

OUT OF SCOPE
- Any edit to `guardrails.sh` — including the Q-40 missing-image false-green
  hole (filed on the decision sheet at this cut; hardening is unruled and
  B-23/B-25-class work stays M5 per the owner's scope line).
- Any edit to `tools/install.sh`/`build-image.sh` (the local darwin toolchain
  is untouched; the Linux fetch lives only in the workflow).
- Caching, matrix builds, PR-head-vs-main load gymnastics, or any CI feature
  beyond the contract (the trigger line stays `on: [push, pull_request]`).
- Pre-building anything of E15-C02/C03 (guide edits, sample test, timings).

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67).
Postcondition: commit(s) prefixed `E15-C01:`; final state — one green CI run
on the head, nothing uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · the CI run id + per-step results ·
  the D-60.a discharge statement · `.smalltalk.ston` confirmation ·
  deviations (each one-line justified) · new questions for the decision sheet.
