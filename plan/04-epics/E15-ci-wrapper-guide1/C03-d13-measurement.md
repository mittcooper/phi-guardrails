# E15-C03 · The D-13 measurement: timings recorded, the budget question filed  [depends: E15-C01, E15-C02 · parallel: no]

GOAL      Measure the full-gate and in-image gate timings on the epic's real
ground (the two-step CI runs and the work image) and file them as the
decision-sheet entry D-13 requires — the REQUIRED question this cut files by
design, so the budget becomes a ruled entry at the M4 gate.

TRACE     R-09 (measurement half) · spec ch. 7 §7.6 (non-binding working
targets: full gate in CI < 60 s, in-image incremental < 10 s; "At M4, with the
full gate running in CI, timings are measured and the budget becomes a ruled
decision-log entry") · D-13 (measure at M4, then rule — evidence-first, never
invented precision) · roadmap M4 exit criterion ("D-13 timings measured and
filed as a decision-sheet entry").

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**What exists when this chunk is picked:** E15-C01's two-step
`.github/workflows/ci.yml` is committed with green runs (step 1 smalltalkCI ·
gate-image assembly · step 2 `./guardrails.sh guardrails.ston` · the
wrapper-guard self-test); E15-C02's `testAdoptAndRunSamples` rides the sweep
(≥267). The framework's own artifact registers 12 checks; the gate's
behavioral registrations sweep the tests families, so a full framework-gate
run transitively drives `ToyDemoTest`'s nested toy-gates (framework + toy in
one number — §7.6's "full gate (framework + toy)" is this run).

**Measurement spellings (probed at cut, probes.md P7):**
`Time millisecondsToRun: [ … ]` answers a SmallInteger of wall-clock ms;
in-image full gate on the work image at cut time ≈ 876 ms (cold ≈ warm) — the
chunk re-measures on the epic head, never reuses this preview number.
`gh run view <run-id> --json jobs` carries per-step `startedAt`/`completedAt`
for the CI step durations. Local wall-clock: `time` (the shell builtin) around
`./guardrails.sh guardrails.ston`.

**What to measure (all on the epic-head commit, each recorded with its exact
command and raw output):**

1. **CI, per step, from the two most recent green runs** (C01's and C02's, or
   fresh re-runs): step-1 smalltalkCI duration · gate-image assembly duration
   · step-2 enforcement duration (the §7.6 "full gate in CI" number is the
   step-2 duration — bootstrap assembly is reported beside it, labeled, not
   folded in) · total job wall-clock.
2. **Local full gate ×3:**
   `time PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
   — three consecutive runs on a freshly built work image, all three reported,
   median named.
3. **In-image ×2 (cold, then warm, one session):**
   `Time millisecondsToRun: [ (PGRGate forConfiguration: (PGRConfiguration fromFile: 'guardrails.ston')) run ]`
   — a fresh gate per run (the E14 rule: never reuse a gate across runs); the
   warm number is §7.6's "in-image incremental" proxy and is labeled as a
   proxy (v1 has no incremental mode — the honest sentence belongs in the
   entry).

**The decision-sheet entry (Q-41 — the next free number after Q-40, which this
cut filed):** titled for the D-13 budget ruling; body = the measurement table
(raw numbers, commands, run ids, head commit), the §7.6 working targets beside
the measured values, and a **recommendation, never a ruling** — e.g. whether
the targets should harden as binding at their current values, at
measured-value-×-headroom, or stay advisory until the catalogs widen (M5).
Status line: awaiting the owner's M4 milestone gate (D-13 names that gate as
the ruling point).

**Constitution rules that bite here:** decisions are recommended by agents and
ruled by humans (the entry recommends); nothing is "done" by inspection — every
number in the entry carries the command and raw output that produced it; no
product code changes (a measurement chunk mutates nothing under `src/`).

DELIVERABLES

Files:
- **create** `plan/04-epics/E15-ci-wrapper-guide1/measurements.md` — the raw
  record: every command, every raw output/duration, run ids, head commit, work
  image identity, dated.
- **modify** `plan/04-decision-sheet.md` — append the Q-41 entry (append-only;
  touch nothing above it).

No `src/`, `docs/`, or infra file. LOC budget: n/a (papers, not code) —
target ≈ 120 lines of records · ceiling: keep the Q entry one screen.

TESTS FIRST

No SUnit test — the deliverable is evidence, and its "test" is completeness
(the E05-C07/E15-C01 infra-arm precedent):

- **Arm 1:** measurements.md contains all three measurement families (CI
  steps · local ×3 · in-image ×2) with raw outputs and the head commit named.
- **Arm 2:** `grep -c '^## Q-41' plan/04-decision-sheet.md` → 1, and the entry
  cites D-13, §7.6, the measured numbers, and a recommendation.
- **Arm 3 (regression, nothing disturbed):** `bash tools/build-image.sh &&
  bash tools/verify.sh` exit 0, ≥267 run; the self-hosted gate leg
  `PHARO_VM=… IMAGE=… ./guardrails.sh guardrails.ston` → exit 0, 12
  registrations, `GATE: GREEN`; `gh run list --workflow=ci.yml --limit 1` →
  `completed success` (the two-step contract standing on this head).

VERIFY    Arms 1–3 above on one head commit; `bash tools/precheck.sh` exit 0.

OUT OF SCOPE
- Ruling the budget (the owner's, at the M4 gate — D-13's own text).
- Any optimization prompted by the numbers (file observations in the entry).
- Any src/docs/infra edit; pre-building M5 ground (coverage floors, wider
  catalogs).

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67).
Postcondition: one commit `E15-C03: D-13 timings measured, Q-41 filed`,
nothing uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · the measured table (inline copy) · run ids · deviations
  (each one-line justified) · new questions for the decision sheet beyond
  Q-41.
