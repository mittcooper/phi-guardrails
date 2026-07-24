# C03 · CI step 1: `.smalltalk.ston` + workflow, green on a real run   [E01 · depends: C02 · parallel: no]

GOAL      Commit the framework's `.smalltalk.ston` and the minimal
          `.github/workflows/ci.yml` (validation step only) and get an actual green
          run on the CI service.

TRACE     spec ch. 7 §7.4 (two-step contract; step 1 lands here, step 2 is E15's) ·
          D-40 (validation independent of the gate) · D-57 (`.smalltalk.ston` lists
          both tests families) · roadmap M0 checkpoint · D-64 (Q-29 ruled:
          coordinates, visibility, branch).

## ENTRY CHECK — resolved

This chunk publishes the repository. **Q-29 is ruled (D-64):** host
`mittcooper/phi-guardrails` on github.com · visibility **public** · rename
`master` → `main` **before first push**. At task-writing time the repo had no git
remote; `gh` is authenticated as `mittcooper`. The push uses exactly D-64's values —
any deviation is a stop-and-report, not a judgment call.

## CONTEXT DIGEST

**What exists:** C02's committed `src/` skeleton, loadable via group `CI`; the smoke
suite green locally under `tools/verify.sh`.

**Constitution rules that bite here:**
- *Write boundary:* `.smalltalk.ston` and `.github/workflows/ci.yml` are the two
  root artifacts this chunk may create (both named in constitution §2 / spec ch. 7).
- *P6 discipline:* never weaken a check to go green — if CI fails, fix the cause or
  file a decision-sheet question; `#failOnZeroTests : true` stays.

**`.smalltalk.ston` — spec §7.4 verbatim, step 1 only:**

```ston
SmalltalkCISpec {
    #loading : [ SCIMetacelloLoadSpec {
        #baseline : 'PhiGuardrails', #directory : 'src', #load : [ 'CI' ] } ],
    #testing : { #packages : [ 'Phi-Guardrails-Tests-.*', 'Phi-Coding-Kit-Tests-.*' ],
                 #failOnZeroTests : true }
}
```

(`Pharo64-13` is a supported smalltalkCI platform; there is no critics option for
Pharo — D-05/D-15. With only the smoke suite existing, total tests = 5 > 0, so
`#failOnZeroTests` passes.)

**`ci.yml` — minimal, one job, step 1 only.** Working shape (the GitHub-action
spelling is verified *by the green run itself* — iterate freely and record the final
form in the completion report):

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
      - run: smalltalkci -s .smalltalk.ston
        shell: bash
        timeout-minutes: 30
```

Note the two-step contract: this workflow gains the enforcement step
(`./guardrails.sh guardrails.ston`) and the P-WRAPPER-GUARD self-test only at E15
(M4). Do not add placeholders for them — an empty step that "will be filled in" is
exactly the kind of silent scaffold the corpus forbids.

**D-60.a wrinkle, named for you:** step 1 loads via `SCIMetacelloLoadSpec`
(`#directory : 'src'`, the local checkout) — this is *not* the §7.3 image-assembly
load expression; equivalence with the `github://` form is judged at step 2 (E15).
C04 records the hosted-load probe; nothing in this chunk claims it.

**Publishing procedure (D-64's ruled values):** rename the branch *first*
(`git branch -m master main`), then create the GitHub repo public
(`gh repo create mittcooper/phi-guardrails --public --source . --push` or
remote-add + push) — the remote never sees `master`, so the spec's placeholder load
expression (`…:main/src`) is the real form from the first push.

## DELIVERABLES

- `.smalltalk.ston` — new, verbatim above.
- `.github/workflows/ci.yml` — new, step 1 only.
- The published remote with the workflow's first green run (record the run URL in
  the completion report).
- `plan/decision-log.md` — append one D-63 row: CI service · platform `Pharo64-13`
  · green-run URL · the final action spellings that worked.
- LOC budget: target 40 / ceiling 300.

## TESTS FIRST

No new SUnit tests — this chunk's contract is the CI service executing the *existing*
smoke suite. The decidable assertions, in checkpoint order:

- `ci_run_green` — given the pushed workflow / when the run completes / then its
  conclusion is success **and** the smalltalkCI log shows the 5
  `PGRBaselineSmokeTest` tests executed, 0 failures, 0 errors (a green run that ran
  zero tests is a failure of this chunk — the D-15 silence hole, guarded here by
  `#failOnZeroTests` plus your own reading of the log).
- `local_verify_still_green` — `tools/verify.sh` exits 0 on the same commit
  (local and CI agree on the same tree).

VERIFY    `gh run list --workflow=ci.yml --limit 1` shows `completed success` for the
          head commit, log inspected as above; regression guard:
          `bash tools/verify.sh` and `bash tools/probe-m0.sh`
          both exit 0.

OUT OF SCOPE
- Step 2 (`guardrails.sh`, `guardrails.ston`) and the wrapper self-test — E05/E09/E15.
- Branch-protection rules, badges, release tooling, any second workflow.
- Editing `src/` (if CI reveals a skeleton defect, that is a C02 reopen via the
  orchestrator, not a drive-by fix here — report it).

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · assertion names + run URL + log excerpt ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
