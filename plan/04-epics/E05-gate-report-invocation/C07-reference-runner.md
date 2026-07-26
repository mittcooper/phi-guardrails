# E05-C07 · `guardrails.sh` — the reference runner    [E05 · depends: E05-C05 · parallel: yes]

GOAL      Commit the reference runner: the shell contract script that maps
          the image's answer to the process exit code and treats anything
          ∉ {0, 1, 2} as failure (exit 3) — the mapping E05 freezes.

TRACE     R-07 · R-47 · ch. 7 §7.3 (the contract script, verbatim ground) ·
          D-45 ruling 4 (a convenience that must not re-privilege any
          caller) · D-15 (`Smalltalk exit:` verified) · D-63 (probe arms ran
          `eval` with `--headless` on this exact toolchain). P-WRAPPER-GUARD
          (the CI shell self-test) is **E15's** — explicitly not owed here;
          this chunk's unloadable-image arm is local verification of the
          same mapping.

## CONTEXT DIGEST

**What exists.** `PGRGate class>>runHeadless: aPathString` (E05-C05):
parses, runs, prints to `Stdio stdout`, **answers** 0/1/2 — always, by the
top-level handler (D-39). The committed CI workflow
(`.github/workflows/ci.yml`) currently runs step 1 only (smalltalkCI); step
2 (`./guardrails.sh guardrails.ston`) arrives with the repo's own artifact
at E09 — **this chunk does not touch CI**.

**The contract script (ch. 7 §7.3, the normative text):**

```bash
#!/usr/bin/env bash
# guardrails.sh <config-path> — the headless gate; exit 0 = every registered check ran green
"$PHARO_VM" "$IMAGE" eval "Smalltalk exit: (PGRGate runHeadless: '$1')"
code=$?
case "$code" in
  0|1|2) exit "$code" ;;
  *) echo "guardrails: gate did not run to a verdict (exit $code)" >&2; exit 3 ;;
esac
```

The caller provides everything: `$PHARO_VM`, `$IMAGE`, and the explicit
config path — no defaults, no environment sniffing beyond those two ruled
variables (D-45 ruling 4; every line reproducible by any other caller). The
wrapper treats **any exit code that is not exactly 0, 1, or 2 as failure**:
the image failing to load, the `PGRGate` class being absent, or the VM dying
must never read as success.

**One recorded accommodation (agent call, veto-open, in `chunks.md`):** the
committed script inserts `--headless` between `"$PHARO_VM"` and `"$IMAGE"` —
every D-63 probe arm and every `tools/` script invokes this toolchain's VM
with `--headless`, and `$PHARO_VM` is quoted as a single word so the flag
cannot ride inside the variable. The mapping — the frozen part — is
byte-identical to §7.3.

**Repo placement:** repo root (`guardrails.sh`), committed, executable
(`chmod +x`). The constitution's write boundary names it explicitly as one
of the sanctioned root artifacts.

**Local verification harness facts:** VM at
`.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo`; work image (with E05 code
loaded from committed `src/`) at `.build/work/phi.image` after
`bash tools/build-image.sh`. The E04-C01 scratch cast
(`PGRScratchSpecKit`, `PGRScratchGreenCheck`, `PGRScratchRedCheck`) is
loaded in that image, so scratch artifacts can name them. Scratch artifacts
for the arms live under the git-ignored `.build/` (e.g.
`.build/scratch/e05/`), never in the working tree. Artifact texts (the
canonical envelope over `'BaselineOfPGRScratchGrouped'`, project
`'Scratch'`, roles `scratch-prod`/`scratch-tst`/`scratch-ghost`):

- `clean.ston` — `#kits : [ { #kit : 'PGRScratchSpecKit', #specs : [
  { #name : 'scratch/G1', #kind : 'scratch', #check :
  'PGRScratchGreenCheck' } ] } ]` → expect 0.
- `red.ston` — same with `'PGRScratchRedCheck'` → expect 1.
- `malformed.ston` — the literal `not ston {` → expect 2.

**Constitution rules that bite here:** the gate is headless — every check
runs unattended from a script, exit nonzero on violation (P4); no dependency
additions; repo build infrastructure (`tools/`, `.build/`) sits outside the
product write boundary (Q-30 ruling) while `guardrails.sh` is product — a
named root artifact.

## DELIVERABLES

- `guardrails.sh` — new, repo root, executable: the §7.3 script with the one
  recorded `--headless` accommodation. Nothing else — no committed scratch
  artifacts, no CI change, no `tools/` change.
- LOC budget: target 15 / ceiling 40.

## TESTS FIRST

No SUnit tests — the deliverable is shell; its contract is proven by the
VERIFY arms below (the E01/E02 infra-chunk shape). The arms are the
chunk's test skeletons; run them in order and paste outputs into the
completion report:

1. **Clean → 0:** `bash tools/build-image.sh`, write the three scratch
   artifacts under `.build/scratch/e05/`, then
   `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo
   IMAGE=.build/work/phi.image ./guardrails.sh .build/scratch/e05/clean.ston`
   — exit code 0; stdout shows the streamed report (header, `[ GREEN ]`
   line, `GATE:` line).
2. **Red → 1:** same invocation over `red.ston` — exit 1; report shows
   `[ RED` and `exit 1`.
3. **Config error → 2:** over `malformed.ston` — exit 2; exactly one error
   line.
4. **Unloadable image → documented (amended under D-75; Q-34 ruled option a):**
   same invocation with `IMAGE=` an empty file created under
   `.build/scratch/e05/` — record the VM's observed exit code and the
   wrapper's resulting code verbatim in the completion report. On this
   toolchain the VM exits **1** on a corrupt/empty image (probed thrice,
   Q-34), which §7.3's pass-through set relays as 1 — a **known v1
   limitation, accepted by ruling**: an unloadable image reads as a red
   gate until the widening hardening lands (M5 scope, D-75; E15's
   P-WRAPPER-GUARD self-test runs against the mapping as written). The arm
   asserts the wrapper faithfully relays what the VM answered — the script
   stays byte-identical to §7.3 (modulo the recorded `--headless`
   accommodation); a genuinely out-of-set VM code still maps to 3 with the
   stderr line.

VERIFY    the four arms above, in order — exit codes exactly 0 / 1 / 2 for
          arms 1–3; arm 4 per its amended expectation (observed codes
          recorded, wrapper relays faithfully) —
          plus `bash tools/verify.sh` still green (≥ 174 run when stacked
          after E05-C01–C06; the script changes no image code), and
          `git ls-files` shows `guardrails.sh` tracked with the executable
          bit.

OUT OF SCOPE
- The CI enforcement step and the P-WRAPPER-GUARD self-test — E09/E15.
- The repo's own `guardrails.ston` — E09.
- Any change to `tools/`, the workflow file, or image code.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest file, one commit
          `E05-C07: guardrails.sh reference runner` (D-73) before reporting
          for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · the four arms' invocations + captured
  exit codes and outputs · deviations from the work order (each with
  one-line justification) · new questions for the decision sheet · the
  observed unloadable-image VM exit code (P5-style record duty).
