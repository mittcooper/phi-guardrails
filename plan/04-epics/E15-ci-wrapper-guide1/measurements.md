# E15-C03 — the D-13 measurement: raw record

*Deliverable of E15-C03 (R-09 measurement half · spec §7.6 · D-13 · roadmap M4).*
*Measured 2026-07-28. All dates absolute; nothing converted to relative form.*

**Head commit (epic head, all local + in-image numbers below):**
`99d2a737ace1c2760853728b9b3bf653b8d99adb` — "E15 bookkeeping: C02 accepted;
B-33 filed" (a plan-file-only commit over C02's src/tests; `git status` clean at
measure time; precheck `PRECHECK PASS @ 99d2a73`).

**Work image identity:** `.build/work/phi.image`, freshly built by
`bash tools/build-image.sh` at this head (group `CI` loaded from
`tonel:///Users/mitt/dev/projects/phi-guardrails/src`), file mtime
`2026-07-28 23:43`. Source image
`.build/pharo/Pharo13.0-SNAPSHOT-64bit-4f7563dfe5.image`; toolchain build
`4f7563dfe5` (D-63). `SystemVersion current` →
`Pharo-13.1.0+SNAPSHOT.build.745.sha.4f7563dfe5e465d0cb0a269e3ba58a351b1a8cde
(64 Bit)`, build 745. `pharo.version` → `130`.

**§7.6 non-binding working targets (the values D-13 rules on at M4):**
full gate in CI **< 60 s** · in-image incremental **< 10 s**.

**Ground note:** the CI numbers are read from the two most-recent green two-step
runs, which stand on the pushed heads d8851e2 (C01) and 8ca0549 (C02). The epic
head 99d2a73 is a plan-file-only commit over 8ca0549, so the src/infra the CI
gate ran is byte-identical to the ground the local + in-image numbers measure
(probes.md P6: `git diff 2f4cccb..HEAD -- src/ … guardrails.sh` empty across the
E15 cycle; 99d2a73 adds no src/infra over 8ca0549).

---

## Family 1 — CI, per step, from the two most-recent green two-step runs

Command (per run):
`gh run view <run-id> --json jobs --jq '.jobs[] | {name, startedAt, completedAt,
steps: [.steps[] | {name, startedAt, completedAt, conclusion}]}'`
Durations = `completedAt − startedAt` per step (whole seconds; GitHub reports
second-granularity ISO timestamps).

### Run 30421725514 — C01 (`E15-C01: CI to the two-step contract + wrapper-guard self-test`), head `d8851e2`

Raw step timestamps (job `validation`, all `conclusion: success`):

```
Set up job                              04:14:15 → 04:14:17
Run actions/checkout@v4                 04:14:17 → 04:14:18
Run hpi-swa/setup-smalltalkCI@v1        04:14:18 → 04:14:20
step 1 · validation — smalltalkCI       04:14:20 → 04:14:39    = 19 s
assemble the gate image (§7.3 recipe)   04:14:39 → 04:14:56    = 17 s
step 2 · enforcement — gate headless    04:14:56 → 04:14:58    =  2 s
wrapper-guard self-test (P-WRAPPER-GUARD)04:14:58 → 04:14:58   =  0 s
Post Run actions/checkout@v4            04:14:58 → 04:14:58
Complete job                            04:14:58 → 04:14:58
job wall-clock (startedAt→completedAt)  04:14:14 → 04:15:01    = 47 s
```

### Run 30422826304 — C02 (`E15-C02: arm-8 fix — comment + parse hoist per review`), head `8ca0549`

Raw step timestamps (job `validation`, all `conclusion: success`):

```
Set up job                              04:38:37 → 04:38:39
Run actions/checkout@v4                 04:38:39 → 04:38:39
Run hpi-swa/setup-smalltalkCI@v1        04:38:39 → 04:38:41
step 1 · validation — smalltalkCI       04:38:41 → 04:38:57    = 16 s
assemble the gate image (§7.3 recipe)   04:38:57 → 04:39:10    = 13 s
step 2 · enforcement — gate headless    04:39:10 → 04:39:12    =  2 s
wrapper-guard self-test (P-WRAPPER-GUARD)04:39:12 → 04:39:12   =  0 s
Post Run actions/checkout@v4            04:39:12 → 04:39:12
Complete job                            04:39:12 → 04:39:12
job wall-clock (startedAt→completedAt)  04:38:37 → 04:39:14    = 37 s
```

### CI summary

| number | C01 (30421725514) | C02 (30422826304) |
|---|---|---|
| **§7.6 "full gate in CI" = step-2 enforcement** | **2 s** | **2 s** |
| bootstrap: step-1 smalltalkCI (beside, not folded in) | 19 s | 16 s |
| bootstrap: gate-image assembly (beside, not folded in) | 17 s | 13 s |
| wrapper-guard self-test | 0 s | 0 s |
| total job wall-clock | 47 s | 37 s |

The §7.6 CI budget number is the **step-2 enforcement duration = 2 s** (the gate
running headless on the framework's own artifact). Bootstrap (smalltalkCI +
image assembly) is reported beside it, labeled, per the work order — not folded
into the gate number.

---

## Family 2 — local full gate ×3 (freshly built work image, head 99d2a73)

Command (each of three consecutive runs):
`time PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo
IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`

Raw `time` output (zsh builtin; `total` = wall-clock) and gate verdict:

```
run 1:  0.95s user 0.05s system 99% cpu 1.002 total   exit 0   GATE: GREEN 0 blocking of 12
run 2:  0.95s user 0.03s system 99% cpu 0.986 total   exit 0   GATE: GREEN 0 blocking of 12
run 3:  0.93s user 0.03s system 99% cpu 0.965 total   exit 0   GATE: GREEN 0 blocking of 12
```

Wall-clock: 1.002 s · 0.986 s · 0.965 s → **median 0.986 s**. All three exit 0,
12 registrations, `GATE: GREEN`.

Full gate report (run 1, the 12 registrations — framework + toy in one number,
§7.6's "full gate (framework + toy)"; per-check ms are the gate's own report):

```
PGR gate · PhiGuardrails · 12 registrations
[ GREEN ] lint/PCKNoIsNilIfTrueRule (42ms)
[ GREEN ] lint/ReCodeCruftLeftInMethodsRule (84ms)
[ GREEN ] architecture/PCKLayerMapCheck (0ms)
[ GREEN ] architecture/PCKSrcInventoryCheck (0ms)
[ GREEN ] behavioral/Phi-Guardrails-Tests-SDK (2ms)
[ GREEN ] behavioral/Phi-Guardrails-Tests-Core (22ms)
[ GREEN ] behavioral/Phi-Guardrails-Tests-Gate (160ms)
[ GREEN ] behavioral/Phi-Guardrails-Tests-Toy (206ms)
[ GREEN ] behavioral/Phi-Coding-Kit-Tests-Rules (344ms)
[ GREEN ] behavioral/Phi-Coding-Kit-Tests-Architecture (52ms)
[ GREEN ] behavioral/Phi-Coding-Kit-Tests-Behavioral (3ms)
[ GREEN ] behavioral/PCKNoSkippedTestsMetaRule (0ms)
GATE: GREEN           0 blocking of 12 · exit 0
```

(`behavioral/Phi-Guardrails-Tests-Toy` is the nested toy-gate leg — a full
framework-gate run transitively drives `ToyDemoTest`'s toy-gates, so this single
number is §7.6's "full gate (framework + toy)".)

---

## Family 3 — in-image ×2 (cold, then warm; one eval session, head 99d2a73)

Command (one `--headless … eval`, both measurements in sequence, a fresh
`PGRGate` per run per the E14 rule — never reuse a gate across runs):

```
.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo --headless .build/work/phi.image \
  eval "| cold warm | \
    cold := Time millisecondsToRun: [ (PGRGate forConfiguration: (PGRConfiguration fromFile: 'guardrails.ston')) run ]. \
    warm := Time millisecondsToRun: [ (PGRGate forConfiguration: (PGRConfiguration fromFile: 'guardrails.ston')) run ]. \
    String cr, '<<MEASURE cold=', cold printString, 'ms warm=', warm printString, 'ms MEASURE>>'"
```

Raw answer (the eval prints the last expression; gate stdout filtered):

```
<<MEASURE cold=906ms warm=911ms MEASURE>>
```

**cold = 906 ms · warm = 911 ms** (both `Time millisecondsToRun:` →
SmallInteger, wall-clock ms). Cold ≈ warm: v1 has **no incremental gate mode**
(every `run` builds the full registry and runs every check), so the second run
is not faster. The **warm number (911 ms) is §7.6's "in-image incremental"
proxy** and is labeled a proxy here — there is no true incremental measurement
to make in v1; the honest sentence rides into the Q-41 entry.

---

## Measured vs §7.6 working targets (summary the ruling reads)

| §7.6 target | measured | headroom |
|---|---|---|
| full gate in CI **< 60 s** (= step-2 enforcement) | 2 s (both runs) | ~30× under |
| in-image incremental **< 10 s** (proxy = warm in-image) | 0.911 s | ~11× under |

Beside those (not the budget numbers, reported for M5 context): total CI job
wall-clock 37–47 s (also < 60 s, thinner margin — the practical CI-minutes cost
dominated by bootstrap: smalltalkCI 16–19 s + image assembly 13–17 s, not by the
gate); local full-gate wall-clock median 0.986 s (VM boot + gate).

---

## Regression arm (nothing disturbed — Arm 3 of the work order, head 99d2a73)

```
bash tools/build-image.sh          → work image built (group 'CI' from tonel://…/src)
bash tools/verify.sh               → "VERIFY PASS: exit 0, 267 run, all 5 smoke tests present"  (exit 0)
  (runner tail: "267 run, 267 passes, 0 failures, 0 errors.")
PHARO_VM=… IMAGE=… ./guardrails.sh guardrails.ston
                                   → "GATE: GREEN  0 blocking of 12"  exit 0  (12 registrations)
gh run list --workflow=ci.yml --limit 1
                                   → "completed  success  E15-C02: arm-8 fix …  30422826304"
```

All green: 267-test sweep (≥267), self-hosted gate 12 registrations GREEN, the
two-step contract standing green on this head's lineage.
