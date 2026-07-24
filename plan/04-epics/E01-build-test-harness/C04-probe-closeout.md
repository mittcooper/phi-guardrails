# C04 · Hosted-load probe, D-63 close-out, M0 checkpoint     [E01 · depends: C03 · parallel: no]

GOAL      Probe the §7.3 image-assembly load expression in its real (hosted) form,
          complete decision-log entry D-63, and run the full M0 exit checkpoint that
          closes E01.

TRACE     D-60/D-60.a (load expression; landing condition for E15 recorded, not
          discharged) · D-57 (regex confirmation on the real families) · R-39 ·
          roadmap M0 checkpoint row.

## CONTEXT DIGEST

**What exists:** the repo is published (C03) with a green step-1 CI run; D-63 holds
the C01 probe table plus C02's local-load row and C03's CI row.

**Constitution rules that bite here:**
- *Probe discipline (P5/R-39):* record the spelling as executed; a probe that cannot
  run to a conclusion is recorded as blocked with its cause and fallback — never
  silently skipped.
- *Append-or-frozen:* D-63 is completed by appending; no earlier entry, spec
  chapter, or roadmap line is edited. The spec's `<org>` placeholder (§7.3) stays a
  placeholder — D-63 records the real coordinates; E15 discharges the
  workflow-equivalence landing condition (D-60.a).

**The hosted-load probe (D-60.a's surviving species).** In a **fresh** pristine
image (never the work image), run the §7.3 recipe step 2 with D-64's ruled
coordinates as pushed by C03:

```smalltalk
Metacello new
    baseline: 'PhiGuardrails';
    repository: 'github://mittcooper/phi-guardrails:main/src';
    load: 'CI'.
```

then assert in the same session that `#BaselineOfPhiGuardrails` and the 20 packages
are present (reuse the smoke suite: run `PGRBaselineSmokeTest buildSuite run` and
assert `hasPassed`, or run the verify command against a saved copy). Record in
D-63: the exact URL form that worked and the `load: 'CI'` form. The repo is public
(D-64), so no credential machinery is expected; if the load nonetheless fails, record
the probe as **blocked** with its cause — the local `tonel://` row already proves the
load path, and the hosted form then rides E15's landing condition — and file a
decision-sheet question rather than working around it.

**The D-57 confirmation row:** C01 proved the alternation dialect on scratch
packages; C02/C03 ran the same regex over the real families (5 smoke tests, both
families' packages present, `XPhi…`-style false matches impossible). Append the row
stating the regex is confirmed **on the real tree**, citing verify.sh and the CI run
as evidence.

**D-63 completion.** The finished entry must answer every roadmap probe bullet:
D-57 regex (dialect + real tree) · D-58 collisions (`PCK`, `Toy`, `BaselineOfToy`)
· D-60/D-60.a load expression (local `tonel://` + hosted `github://` or its recorded
blocker) · D-61.b stream flush (four arms, the sentence E05 builds on). Close the
entry with the "complete at E01 acceptance" line resolved to the actual state and
the E15 landing-condition pointer (workflow load ≡ §7.3 real form, checked when
step 2 lands).

**The M0 exit checkpoint (roadmap §1, run all three legs):**
1. `bash tools/build-image.sh && bash tools/verify.sh` → exit 0,
   5 smoke tests run (the verify command on the smoke suite).
2. Latest `ci.yml` run on the head commit: green (step 1 on a real CI run).
3. D-63 answers all four probe bullets (read it back; a missing row fails the
   checkpoint).

## DELIVERABLES

- `plan/probes/m0-hosted-load.st` — new; the hosted-load probe source.
- `plan/decision-log.md` — append the two rows + the completion close-out to D-63.
- `plan/04-epics/E01-build-test-harness/chunks.md` — fill in the exit-checkpoint
  result line (date + the three legs' outcomes).
- LOC budget: target 30 / ceiling 300 (probe script + records; no product code).

## TESTS FIRST

No new SUnit tests. Decidable assertions:

- `probe_hosted_load_resolves` — given a fresh pristine image / when loading group
  `CI` via the real `github://` coordinates / then the load completes and the smoke
  suite passes in that image — **or** the probe is recorded blocked with its cause
  and a sheet question filed (exactly one of the two outcomes).
- `d63_answers_all_probe_bullets` — given the completed D-63 / then each of the four
  roadmap probe bullets has a row with spelling-as-executed and outcome.
- `m0_checkpoint_all_legs` — the three checkpoint legs above all pass on the head
  commit.

VERIFY    All three checkpoint legs green on one commit; regression guard:
          `tools/probe-m0.sh`, `tools/verify.sh`, and the CI run all green.

OUT OF SCOPE
- Discharging the D-60.a *workflow* landing condition (E15's, at step 2's landing).
- Editing §7.3's placeholder URL or any frozen artifact.
- Any code under `src/`.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · assertion names + outputs/URLs ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
