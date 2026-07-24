# E01 · Build/test harness, skeleton, probes — chunk index (M0)

*Produced by Prompt 4 (first run — ledger created alongside). Inputs frozen at D-62.
Entry check: Gate 3 closed (roadmap frozen at D-62); E01 `depends-on` is empty;
`plan/ledger.md` did not exist before this run.*

| ID | Title | Depends | [P] | LOC est. | Acceptance (one line) |
|---|---|---|---|---|---|
| C01 | Permanent toolchain + M0 environment probes | — | no | ~120 | `install.sh` idempotent + `probe-m0.sh` exits 0; D-63 created with the D-58 / D-61.b / D-57-dialect rows |
| C02 | Tonel skeleton, baseline group tree, smoke suite | C01 | no | ~180 | fresh image Metacello-loads group `CI` from committed `src/`; `verify.sh` green with the 5 smoke tests run; D-63 local-load row appended |
| C03 | CI step 1: `.smalltalk.ston` + workflow, green on a real run | C02 | no | ~40 | actual green `ci.yml` run executing the smoke suite; publishes per D-64 (Q-29 ruled: `mittcooper/phi-guardrails`, public, `main`) |
| C04 | Hosted-load probe, D-63 close-out, M0 checkpoint | C03 | no | ~30 | D-63 answers all four roadmap probe bullets; all three M0 checkpoint legs green on one commit |

Total ~370 LOC across 4 chunks (roadmap estimate: ~4 — holds).

Size notes (constitution §3 band, on record for Gate 4): C02 sits above the 150
target (never the ceiling) — its ~40 LOC of `package.st` stubs are manifest
boilerplate, and the chunk's one concern (the frozen naming tree) does not split;
C03 (~40) and C04 (~30) sit below the 50 floor, deliberately — CI-configuration
and probe/record-keeping chunks carry little code by nature.

## Agent calls recorded (veto-open at the Gate-4 spot-check)

- **Framework-tests split:** `-Tests-SDK` / `-Tests-Core` / `-Tests-Gate` /
  `-Tests-Toy` (mirror of the three production packages + D-46's demo home). Spec
  fixes only `-Tests-Core` and `-Tests-Toy`; the other two follow the mirror
  convention and ch. 9's class roster.
- **`tests` role group holds both families** (framework + kit tests): §8.1's row
  wording says only `Phi-Guardrails-Tests-*`, but §7.5 + D-57 + the scope law force
  the kit tests in — decision log wins over older prose.
- **Smoke-test name `PGRBaselineSmokeTest`:** follows the corpus's descriptive
  `PGR*Test` precedent (`PGRArchSelfTest`, `PGRSurfaceConformanceTest`) rather than
  strict `<Subject>Test`, keeping `PGR*` symmetry (B-09).
- **Toy stubs land in E01** (empty packages only): the roadmap's hazard design-out
  ("E01 pre-creates **all** package stubs and the full baseline group tree") governs;
  R-36's Toy-family *contents* remain E12's, per its placement annotation.
- **Toolchain location** — no longer an open call: ruled by D-65 (Q-30). Committed
  harness scripts in `tools/`; all uncommitted build state in the single git-ignored
  `.build/` (`pharo/` · `work/` · `scratch/`).

## Exit checkpoint (freezes E01's interfaces)

E01 is provable by, on one head commit:

1. **Named suite:** `PGRBaselineSmokeTest` (package `Phi-Guardrails-Tests-Core`,
   5 tests — all ten baseline groups asserted exactly) green under the pack's
   verify command run from
   `tools/verify.sh`, with C01's probe harness (`tools/probe-m0.sh`) also green on
   the same commit — this suite is the machine witness of the frozen
   export (the naming tree: 20 packages + baseline group tree, asserted exactly).
2. **CI leg:** the committed `.github/workflows/ci.yml` (step 1 only) green on an
   actual CI-service run of the same commit.
3. **Probe leg:** decision-log **D-63** complete — D-57 regex · D-58 collisions ·
   D-60/D-60.a load expression (local + hosted-or-recorded-blocker) · D-61.b stream
   flush — each row carrying the spelling as executed.

Checkpoint result (C04 fills in): **2026-07-23, all three legs green on head
`a92faf6`** · leg 1: `tools/build-image.sh && tools/verify.sh` exit 0 —
`5 run, 5 passes, 0 failures, 0 errors.`, all 5 `PGRBaselineSmokeTest` tests
named (`tools/probe-m0.sh` also ALL PASS on the same commit) · leg 2: `ci.yml`
run 30067111092 on `a92faf6` — success · leg 3: D-63 complete, all four probe
bullets answered with spellings as executed (hosted `github://` load ran green;
no blocker row needed).

**Frozen at acceptance:** the `src/` package inventory (21 directories) and the
baseline's ten group names with their exact memberships. Later epics fill stub
packages; adding, renaming, or re-grouping a package requires a decision-sheet
entry.
