# C06 · Commit-hygiene precheck (D-67)      [E02 · depends: — · parallel: yes]

GOAL      Land `tools/precheck.sh` — the machine-enforced chunk-boundary
          precondition: a clean working tree modulo `plan/ledger.md` before an
          implementer spawns, nonzero with a listing otherwise.

TRACE     D-67 (B-12 ruled — the binding ruling this chunk implements) · D-65
          (`tools/` is the committed-harness home; build state in git-ignored
          `.build/`) · constitution §2 mutation discipline (repo build
          infrastructure sits outside the product write boundary — this chunk
          touches `tools/` only) · P1 applied to the pipeline.

## CONTEXT DIGEST

**The ruling (D-67, verbatim substance):** commit hygiene becomes machine-enforced
(P1 applied to the pipeline): a `tools/` precondition check requiring (a) a clean
working tree — modulo the ledger, the orchestrator's one mutable file — before an
implementer spawns, and (b) each accepted chunk committed before the next pick.
From E02 on, work orders state commit expectations explicitly (that half of the
ruling is carried by the epic's work-order format — every E02 order has a COMMIT
section — not by this chunk).

**Why:** uncommitted working-tree state leaked between chunk boundaries in all four
E01 chunks' reports — the one correction that repeated across the milestone mining
sweep (B-12).

**Reading recorded for (b), stated so the script stays one check:** at pick time,
(b) is subsumed by (a) — if the tree is clean modulo the ledger, everything the
previous chunk touched is committed. The script therefore makes one deterministic
check and prints the HEAD commit, so the orchestrator records each pick against a
sha. (If the orchestrator ever needs a stronger (b), that is a new backlog item,
not this script's scope.)

**Required behavior — `tools/precheck.sh`, new file:**

1. From any working directory, resolve the repo root (the `tools/install.sh`
   pattern: `ROOT="$(cd "$(dirname "$0")/.." && pwd)"`); run `git status
   --porcelain` there.
2. Filter out any line whose path field is exactly `plan/ledger.md` (whatever its
   two-character XY status — modified, staged, or both).
3. **Untracked files count as dirt** — that was E01's actual leak; `--porcelain`
   lists them as `?? path` and they must fail the check. (`.build/` is git-ignored
   and never appears; nothing to special-case.)
4. Remainder empty → print `PRECHECK PASS @ <head sha>` (short sha via
   `git rev-parse --short HEAD`) and exit 0.
5. Remainder non-empty → print `PRECHECK FAIL — uncommitted state:` followed by the
   offending porcelain lines verbatim, and exit 1.
6. `set -uo pipefail`, bash, no new dependencies (git only — already the repo's
   substrate).

## DELIVERABLES

- `tools/precheck.sh` — new, executable (`chmod +x`). **Nothing else.**
- LOC budget: target 30 / ceiling 60. Shell only — no SUnit tests; the VERIFY arms
  below are this chunk's test.

## TESTS FIRST

Shell arms, in order (the contract skeletons):

- **arm-clean-passes** — given a clean tree (commit or stash anything pending first)
  / when `bash tools/precheck.sh` runs / then exit 0 and the output is
  `PRECHECK PASS @ <sha>` matching `git rev-parse --short HEAD`.
- **arm-ledger-exempt** — given only `plan/ledger.md` modified (append a scratch
  blank line, revert after the arm) / when the script runs / then exit 0 — the
  orchestrator's one mutable file never blocks a pick.
- **arm-untracked-fails** — given one untracked scratch file at the repo root /
  when the script runs / then exit 1 and the listing names it.
- **arm-modified-fails** — given a tracked file modified (append to
  `tools/verify.sh`, revert after the arm) / then exit 1 and the listing names it.

## VERIFY

```
bash tools/precheck.sh                                    # arm 1: exit 0, PASS @ head
printf '\n' >> plan/ledger.md && bash tools/precheck.sh; RC=$?; git checkout -- plan/ledger.md
[ "$RC" -eq 0 ] || { echo "LEDGER ARM FAILED"; exit 1; }  # arm 2: ledger-only dirt passes
touch precheck-tamper.txt
if bash tools/precheck.sh; then echo "UNTRACKED ARM FAILED"; exit 1; fi
rm precheck-tamper.txt                                    # arm 3: untracked fails, named
printf '\n' >> tools/verify.sh
if bash tools/precheck.sh; then echo "MODIFIED ARM FAILED"; exit 1; fi
git checkout -- tools/verify.sh                           # arm 4: modified fails, named
bash tools/build-image.sh && bash tools/verify.sh         # regression guard stays green
```

Expected: arms 1–2 exit 0, arms 3–4 exit 1 with the offender listed, regression
sweep green.

OUT OF SCOPE
- Enforcing the COMMIT sections' wording, parsing `plan/ledger.md`, or any
  ledger-state validation (the one-check reading above is on record).
- Git hooks, CI wiring, or invoking this from any other script — the integrator's
  operating loop adopts it as a step once accepted (D-67's consequence, not code).
- Any `src/` or `plan/` change; any new tool or dependency.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` (check
          `git status --porcelain` by eye — this chunk is the tool being born).
          Postcondition: exactly `tools/precheck.sh`, committed as one commit
          `C06: commit-hygiene precheck (D-67)` before reporting for review;
          nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · arm outputs (1–4 + regression) ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
