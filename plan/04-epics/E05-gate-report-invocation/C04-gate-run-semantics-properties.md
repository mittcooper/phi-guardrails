# E05-C04 · Gate run-semantics property tests    [E05 · depends: E05-C03 · parallel: no]

GOAL      Complete the cross-epic run-semantics properties at gate level —
          P-ERR-IS-RED's gate arm, P-GATE-MISSING's gate half, P-GATE-PURE,
          and P-REG-FRESH's gate clause — with no product code.

TRACE     R-12 (gate half — checking never mutates) · R-06 · ch. 7 §7.1
          (error→red, run continues; D-21) · ch. 0 §0.4 ("runs share
          nothing") · ch. 9 (P-ERR-IS-RED:
          `PGRGateTest>>#testRunContinuesAfterErroringCheck`;
          P-GATE-MISSING: `>>#testMissingRegistrationFailsGate`;
          P-GATE-PURE: `>>#testRunMutatesNoSource`; P-REG-FRESH gate clause
          — the E04-recorded split) · R-35.

## CONTEXT DIGEST

**What exists.** `PGRGate` (`forConfiguration:` eager, `onVerdict:`, `run` —
E05-C03) and `PGRReport` (`verdicts` · `isClean` · `exitCode` ·
`blockingVerdicts` — E05-C02) in `Phi-Guardrails-Gate`; `PGRGateTest`
(`Phi-Guardrails-Tests-Gate`) with helpers `artifactWithKitsFragment:`
(canonical scratch envelope over `'BaselineOfPGRScratchGrouped'`, project
`'Scratch'`, roles `scratch-prod`/`scratch-tst`/`scratch-ghost`) and
`gateFromKitsFragment:`, plus 4 green tests. `PGRVerdict` readers: `status`
(`#green`/`#red`/`#missing`/`#skipped`) · `isGreen` · `registrationName` ·
`findings`; `PGRFinding` readers: `target` · `message`.

**Scratch cast (accepted E04-C01 ground, `Phi-Guardrails-Tests-Core`):**
`PGRScratchSpecKit` (one spec per `#specs` entry, in order; arms `#check` /
`#missing` as in the C03 digest) driving `PGRScratchGreenCheck` (green),
`PGRScratchRedCheck` (one finding, target `'PGRScratchRedCheck'`),
`PGRScratchErroringCheck` (`run` raises `Error 'scratch check exploded'`;
the E04-accepted `PGRRegistrationTest>>#testErroringCheckYieldsRed` already
pins the registration-level conversion: one red verdict, one finding whose
target is the check's class name and whose message is the error
description).

**The second artifact for the freshness arm** (the E04-C05 shape, plain
baseline — author as one private helper on `PGRGateTest`):

```smalltalk
PGRGateTest >> plainBaselineArtifactString
    ^ '{
    #schemaVersion : 2,
    #project : ''ScratchPlain'',
    #baseline : ''BaselineOfPGRScratchPlain'',
    #roles : {
        #production : [ ''Phi-Guardrails-SDK'', ''Phi-Guardrails-Core'' ],
        #tests : [ ''Phi-Guardrails-Tests-SDK'' ] },
    #kits : [ { #kit : ''PGRScratchSpecKit'', #specs : [
        { #name : ''scratch/P1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' } ] } ]
}'
```

(`BaselineOfPGRScratchPlain` declares the three real packages and no groups,
so roles are assigned by exact package-name matchers; it declares no ghost
package, so no exempt role is needed. Note the resolved `#check` spec — this
arm wants a *runnable* second gate.)

**The four property statements, restated decidably:**

- **P-ERR-IS-RED (gate arm — completes the property; the registration arm is
  E04-C02's):** with the throwing check placed **mid-registry**, the erroring
  registration yields `#red` with the error text as its finding message, the
  gate run **continues**, and **every later registration still produced a
  verdict**; the report exits 1. Errors raised inside a check's `run` never
  escape `PGRRegistration>>run` (D-21) — `PGRGate>>run` needs no handler for
  this to hold; the test proves the composed behavior.
- **P-GATE-MISSING (gate half — the ch.-9-named `PGRGateTest` test; the
  suite half was discharged at E07):** a missing registration's verdict has
  `status` `#missing`, `isClean` is false, exit is 1 — silence never passes.
- **P-GATE-PURE (R-12):** snapshot `sourceCode` of every method of the
  scratch check classes the run touches; run a gate over a red
  configuration; every source is identical afterwards — the gate only
  reports. Candidate snapshot spelling: over
  `PGRScratchGreenCheck methods` / `PGRScratchRedCheck methods`, collect
  `sourceCode` keyed by `selector` on both sides (⟨verify-in-image⟩
  delegated with record-in-report duty, P5).
- **P-REG-FRESH (gate clause — completes ch. 9's "two gates built from two
  artifacts in one image produce independent registries/reports"; the
  registry, mutation-isolation, and reflective arms were accepted at
  E04-C05, and that accepted reflective sweep over `-Core` **and** `-Gate`
  now covers the real gate classes on every run, unamended):** two gates
  over the grouped and plain artifacts answer reports that share nothing —
  each report carries exactly its own artifact's registration names; the
  verdict objects of the two reports are pairwise non-identical; re-running
  a fresh gate over the first artifact leaves the second gate's
  already-answered report unchanged (its verdicts collection still equal to
  what it held before).

**Constitution rules that bite here:** the framework never mutates client
code except through the explicit fix command — the gate only reports (this
chunk's purity test is that rule's machine witness); tests assert behavior; a
test that cannot fail is a defect; no `skip`/`expectedFailures`.

**Authoring rule (E01 precedent, verbatim):** author in-image and export to
`src/` with the image's Tonel tooling; hand-writing class files is not
allowed. After export, a fresh `tools/build-image.sh` load from committed
`src/` proves the round trip.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Guardrails-Tests-Gate/PGRGateTest.class.st` — modify: add
  `plainBaselineArtifactString` and the four tests below. **No product
  code** — if any property cannot be discharged without touching `-Gate` or
  `-Core` product classes, stop and report (that is a finding, not a
  workaround).
- LOC budget: target 110 / ceiling 190.

## TESTS FIRST

Test methods on `PGRGateTest`:

- `testRunContinuesAfterErroringCheck` — **ch.-9-named, P-ERR-IS-RED (gate
  arm, completing the property)** — given a three-spec artifact (green
  `scratch/G1`, erroring `scratch/E1` via `PGRScratchErroringCheck`, green
  `scratch/G2`) / when `run` / then the report holds three verdicts in
  order; `scratch/E1`'s has status `#red` and one finding whose message
  includes `'scratch check exploded'`; `scratch/G2`'s verdict exists and is
  green (the run continued); `exitCode` = 1.
- `testMissingRegistrationFailsGate` — **ch.-9-named, P-GATE-MISSING (gate
  half)** — given an artifact with one green spec and one missing spec
  (reason `'engine absent'`) / when `run` / then the missing verdict's
  `status` is `#missing`, `isClean` is false, `exitCode` = 1.
- `testRunMutatesNoSource` — **ch.-9-named, P-GATE-PURE** — given the
  `sourceCode` of every method of `PGRScratchGreenCheck` and
  `PGRScratchRedCheck` snapshotted / when a gate over a red artifact
  (specs `scratch/G1`, `scratch/R1`) runs / then every snapshotted source is
  equal to the live `sourceCode` afterwards — the run mutated nothing.
- `testTwoGatesProduceIndependentReports` — **P-REG-FRESH gate clause (the
  E04-recorded split, completed)** — given one gate over the grouped
  artifact (specs `scratch/G1`, `scratch/M1`) and one over
  `plainBaselineArtifactString` / when both run / then each report's verdict
  names are exactly its own artifact's (`#('scratch/G1' 'scratch/M1')` vs
  `#('scratch/P1')`); no verdict object of one report is identical (`==`) to
  any of the other's; and after a fresh gate over the grouped artifact runs
  again, the plain report's verdict names are unchanged.

Fixtures: the E04-C01 cast and both E03 scratch baselines (all untouched);
the new plain-baseline helper.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 8 `PGRGateTest` methods
          (4 prior + 4 new) and the 7 `PGRReportTest` methods **plus every
          previously accepted suite** — membership plus a floor (≥ 166 run
          when stacked after E05-C01–C03), never an exact ceiling.

OUT OF SCOPE
- `runHeadless:` and everything headless — E05-C05/C06.
- Amending any accepted E04 test (`PGRRegistryTest>>#testTwoRunsShareNothing`
  stands untouched — this chunk *adds* the gate clause in `PGRGateTest`; the
  accepted reflective sweep needs no edit to cover `-Gate`'s new classes).
- Touching any `-Core`, `-SDK`, or kit file.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `E05-C04: gate run-semantics property tests` (D-73) before
          reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet · the verified `methods`/`sourceCode`
  snapshot spellings (P5 record duty).
