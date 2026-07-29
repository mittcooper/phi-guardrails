# E14 · The demonstration test — chunk index

Cut by the eleventh committed Prompt-4 run (2026-07-28). Epic-qualified IDs per
D-73. Entry check: roadmap approved and frozen (D-62); **M2 closed (D-82), E12
owner-accepted (2026-07-28)**; E14's three roadmap dependencies are all `accepted`
with frozen digests — **E12** @ `2d5d661` (the committed toy artifact
`BaselineOfToy class>>guardrailsSTON`, the six-registration shape in order, the
six-plant inventory) · **E11** @ `786bacf` (the full 12-registration gate over the
completed §7.5 artifact) · **E08** @ `19beb68` (the `PCKFixCommand` fix-invocation
surface). Accepted verify sweep at cut time: **263 tests**, self-hosted gate **12
registrations GREEN** — every count below is named-suite membership plus a floor,
never an exact ceiling, **except the demo's own six-verdict accounting, which is
exact by ruled design** (ch. 8 §8.3's exact-count law: "the exact count is
asserted deliberately … not slip in unnoticed behind a `>=` assertion"). **The D-82/Q-39 cut-time probe obligation is discharged in `probes.md`**
(this directory): every skeleton-named reflective predicate and frozen-surface
spelling probed live against the work image at HEAD `1f7c80f` (src byte-identical
to E12's src head `3333062`) or checked against its frozen digest — including full
round-trip probes of the fix arm and the source-mutation/restoration idioms (the
roadmap risk row, probed before papers were cut). The file is part of this epic's
validation record.

Ruled ground in force: **D-43** (both protections: `ensure:` restoration on every
path + the `setUp` planted-state guard) · **D-46** (the demo's home is the swept
`Phi-Guardrails-Tests-Toy`; the nesting/termination argument — exercised in
earnest for the first time under this epic's self-hosted leg) · **D-26/D-57** (the
toy stays committed red; nothing committed changes in any chunk) · **§8.1 residual
caveat** (the demo runs the gate over the TOY's configuration only, never the
framework's own `guardrails.ston` from inside a swept test) · **D-82
carry-forward corrections**, standing: (1) the committed
`.github/workflows/ci.yml` runs **CI step 1 only** (smalltalkci) — the two-step
upgrade is E15's scheduled edit; no work order claims a CI gate step; (2)
deliberate-absence guards use `includesSelector:`, never `respondsTo:` (none
needed in this cut); (3) the frozen `PGRVerdict` has no red-with-advisories
constructor — the `#unlayered` advisory rides CLEAN reports only (D-80, probed
live in the all-fixed arm, P5).

## Chunks

| ID | Title | Depends-on | [P] | LOC est. | Acceptance (one line) |
|---|---|---|---|---|---|
| E14-C01 | `ToyDemoTest` scaffold: planted-state guard + the exact-six red arm | — | no | ~120 | `testGateIsRedOnPlantedViolations` green in a ≥264 sweep — one toy-gate run, exactly 6 verdicts in frozen order, all red, each naming its plant; gate leg still 12 GREEN (now nesting the demo) |
| E14-C02 | `ensure:` restoration machinery + the autofix arm | E14-C01 | no | ~80 | `testLintAutofixThenGreen` green in a ≥265 sweep — preview(1)→apply(1), fixed registration alone green (5 blocking), restoration byte-identical; gate leg 12 GREEN |
| E14-C03 | The all-fixed-then-clean arm | E14-C02 | no | ~110 | `testAllFixedThenClean` green in a ≥266 sweep — six fixed sources → `isClean`/exit 0 with the one D-80 advisory, then all six restored byte-identical; gate leg 12 GREEN |

Sum ≈ 310 LOC — the roadmap's "~3 chunks" cut as three: the red baseline with the
guard, the fix arm with the restoration machinery, and the widest mutation arm are
three separately reviewable concerns sharing one test class. No `[P]`: all three
chunks modify the single file
`src/Phi-Guardrails-Tests-Toy/ToyDemoTest.class.st` — strictly serial picks
C01 → C02 → C03 (the verify floors are stated against that order).

## Scheduled ground riding this cut

**None. Amended accepted surface: none** — every chunk's manifest is exactly the
one NEW file `src/Phi-Guardrails-Tests-Toy/ToyDemoTest.class.st` (created at C01,
extended in place at C02/C03); zero accepted test files or accepted behavior
change anywhere in this cut (assertable by script over the three manifests: no
accepted file appears). R-32's demonstration half, R-43's demo half, R-44, and
P-GATE-RED land here per the frozen roadmap row; E14 adds nothing to the
framework's own artifact (the 12-registration gate leg is a pure regression
guard).

## Agent-judged calls at cut time (veto-open, D-16 precedent)

1. **The class name is `ToyDemoTest`** — §8.3's and the frozen roadmap row's
   spelling (the E14 goal line). D-43's older rendering `PGRToyDemoTest` predates
   the D-45/D-46 reshape of ch. 8; the current ruled artifacts agree, so this is
   recorded as superseded prose, not a live question. (A veto renames by its own
   chunk.)
2. **The `setUp` guard asserts planted state at source level, with
   body-distinguishing markers** — each of the six planted methods' current
   `sourceCode` contains its plant's body marker, failure message naming the
   method. Trace: D-43 item 2's "fails loudly at its cause" — source
   recompilation is the demo's only mutation vector, and the markers are probed
   (P8) to track the plant *body* on every path: present in the committed body,
   absent from the plant comments (which name their plant and survive the fix
   command — the naive-marker collision the first validation round caught),
   absent from every C03 fixed source. The all-red gate-level fact is test 1's
   own assertion, re-run continuously by the sweep.
3. **The fix arm runs nested under the self-hosted gate** — §3.3/D-42's caution
   ("do not run a fix from inside a gate run"; hazard: recompiling currently
   executing code) composes with D-46's ruled nesting: the fix targets exempt-role
   `Toy-Core` (no code the outer gate checks, no code executing in either gate),
   the in-image run is single-threaded (D-42's own argument), and D-46 accepted
   "every local verify runs the red → fixed → green cycle" as a cost of the swept
   home while §8.3 prescribes the fix arm as part of that cycle. Judged
   compatible; recorded here for the owner's eye.
4. **Restoration is asserted at source level (byte-identical snapshots), not by a
   third in-test gate run** — the probes pin the gate-level post-restore fact
   (P5: 6 blocking again), and the neighboring toy tests plus every `setUp` guard
   re-prove committed red continuously; a third gate run per test would re-test
   pinned ground at real cost.

## Cross-epic notes

- **The self-hosted gate leg changes character at E14-C01** without changing its
  assertion: still `./guardrails.sh guardrails.ston` → exit 0, **12 registrations
  unchanged**, `GATE: GREEN` — but `behavioral/Phi-Guardrails-Tests-Toy` (probed
  present, P6) now runs `ToyDemoTest`, nesting a toy-gate run (three by C03, one
  with the fix arm) inside the framework's own run. Termination is D-46's
  argument: the toy config's tests role is only `Toy-Tests`, which drives no
  gate. A hang or non-zero here is a stop-and-report, never a retry-and-hope.
- **CI stays step 1** (smalltalkci) — `ToyDemoTest` rides the existing sweep;
  the two-step upgrade, the wrapper guard, guide 1's discharge, and the D-13
  timing measurements are all E15's scheduled ground (do not pre-build).
- **E15 sequencing:** E14's acceptance is E15's entry check (frozen roadmap:
  E12 → E14 → E15, sequential; E15 closes M4).
- **`.gitignore` `*.fuel` (B-17)** stays with the next infra chunk — no E14 chunk
  is an infra chunk; the M1-mining recommendation stands unconsumed here.

## Exit checkpoint (proves the epic; freezes E14's interface)

E14 is provable by, on one head commit:

1. **Named suite (the verify command):** `bash tools/build-image.sh &&
   bash tools/verify.sh` exit 0, 0 failures / 0 errors — the three `ToyDemoTest`
   cases (`testGateIsRedOnPlantedViolations` · `testLintAutofixThenGreen` ·
   `testAllFixedThenClean`) listed by name with **every previously accepted suite
   still green**, ≥266 run (263 accepted at cut + 3 net new); membership + floor
   — discharging **P-GATE-RED** (the exact-six red arm plus both D-43
   protections) and completing **R-32 (demonstration half) · R-43 (demo half) ·
   R-44**. The sweep passing at all proves the D-43 machinery: three
   source-mutating tests ran and left the toy committed-red for every neighboring
   toy test.
2. **Self-hosted gate leg (regression, no new registration):**
   `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
   → exit 0, **12 registrations unchanged**, `GATE: GREEN` — E14 adds nothing to
   the framework's artifact, and the leg now proves the **D-46 nested-gate
   termination in earnest**: the outer framework gate sweeps `ToyDemoTest`,
   which drives inner toy-gates (including the fix arm), and the run terminates
   green.
3. **Infra leg:** `bash tools/precheck.sh` green at every pick; D-73 `E14-C##:`
   commit prefixes throughout (D-66/D-67).
4. **CI leg:** `.github/workflows/ci.yml` green on an actual CI run of the same
   head — **step 1 only (smalltalkCI)**, sweeping `ToyDemoTest` with the rest;
   the committed workflow runs no gate step — the two-step upgrade is E15's
   scheduled edit (D-82 carry-forward 1).

**Frozen at acceptance (E14's interface digest):** per the frozen roadmap — **no
new frozen exports**. E14 delivers the machine witness (the demonstration) over
surfaces frozen at E02/E03/E05/E08/E12: what freezes is the **demo contract
itself** — `ToyDemoTest`'s three named tests in the swept
`Phi-Guardrails-Tests-Toy`, the exact-six-verdict assertion (which is *designed*
to break when the recommended block grows — §8.3's exact-count law, now
red-test-enforced), and the D-43 protection pair as standing behavior. Amendments
(e.g. when M5 grows the toy's registry) need a decision-sheet entry.
Internal/unfrozen: the helper spellings (`plantedShapes`, `runToyGate`,
`expectedRegistrationNames`, `restoringSourcesOf:during:`, `fixedPlantSources`)
and the six fixed-source texts.

Checkpoint result (filled at epic close, 2026-07-28): **GREEN on head `2f4cccb`**
(src-defining chunk head `e09cd6b`; the two commits differ only in `plan/ledger.md`
bookkeeping) — leg 1: verify 266/266, 0 failures / 0 errors, all three `ToyDemoTest`
cases by name with every previously accepted suite green (263 at cut + 3 net new;
P-GATE-RED discharged — the exact-six red arm, the fix arm, and the
all-fixed-then-clean arm all ran live in the sweep, and the sweep's neighboring toy
tests re-proved the committed red state after each mutation — both D-43 protections
standing); leg 2: `./guardrails.sh guardrails.ston` exit 0, **12 registrations
unchanged**, `GATE: GREEN 0 blocking of 12` — the D-46 nested-gate termination proven
in earnest (behavioral/Phi-Guardrails-Tests-Toy 0ms pre-E14 → ~200ms at close,
driving inner toy-gates including the fix arm, terminating green on every pick);
leg 3: precheck green at every pick, `E14-C##:` prefixes throughout (C01's spawn
died once to a transient API connection error and was resumed in place — no fix
round-trips consumed anywhere in the epic); leg 4: CI run 30418311955 success on the
same head `2f4cccb` (step 1 only — smalltalkCI; the two-step upgrade stays E15's
scheduled edit, D-82 carry-forward 1). Interface digest above **frozen** (the demo
contract: the three named tests, the exact-six law red-test-enforced, the D-43 pair
as standing behavior; no new frozen exports). E14 closed — **NOT a milestone
boundary** (M4 closes at E15); reported to the owner for epic acceptance.
