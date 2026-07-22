# Spec ch. 7 — The gate, headless and in CI

*Satisfies: R-06, R-07, R-09, R-29 (as amended by D-45), R-30, R-42, R-45, R-47 · D-03,
D-13, D-15, D-21, D-39, D-40, D-45. D-10's adapter mechanism and D-23's no-self-sweep
rule are **superseded by D-45** (D-10's plain-object half stands). Package
`Phi-Guardrails-Gate` (gate + report).*

## 7.1 The failure condition, verbatim (Gate-2 required statement)

> The gate exits nonzero **iff** the artifact fails to parse or validate (a
> configuration error, D-16 — nonzero before any report exists), **or** at least one
> registration's verdict is **missing ∨ skipped ∨ red** — where a lint registration is
> red **iff** its rule's severity is `#error` and the rule reported ≥1 violation (each a
> finding; violations of sub-`#error` rules are advisories and never block, D-03), and
> architecture and behavioral registrations are red on **any** finding.

Equivalently: exit 0 **iff** the artifact parsed cleanly and every registration is green.
Advisories never affect the exit code.

**A check that breaks is red, and the run continues** (D-21, restated here because this
chapter owns the failure condition): a resolved check whose `run` signals an unhandled
exception yields a red verdict carrying the error description — never a crash of the gate,
never a pass — and the remaining registrations still run. Errors *outside* a
registration's `run` are the top-level handler's business (§7.3).

## 7.2 The gate object (D-10's surviving half, D-45: a plain object any caller invokes)

`PGRGate`, package `Phi-Guardrails-Gate`. Protocol (frozen at M1):

```smalltalk
gate := PGRGate forConfiguration: aPGRConfiguration.
gate onVerdict: [ :verdict | ... ].      "optional; replaces the default sink"
report := gate run.                       "→ PGRReport"
```

- `forConfiguration:` — named constructor; builds the registry (§1.4) eagerly, so
  configuration errors surface before anything runs.
- `run` — runs every registration in registry order, passes each verdict to the sink as
  it completes, answers the report. Same object, same verdicts, whether called from a
  script, an agent loop, or a Playground (R-30): invocation mode changes only who reads
  the report.
- **Streaming (R-45):** the default sink writes one line per verdict to the Transcript;
  `runHeadless:` (§7.3) replaces it with a stdout writer. A run is never a black box — an
  agent watching the stream can react to the first red verdict before the run ends.

**The three run modes (D-25; the source's primary-vs-enforcement split made normative).**
The same gate serves three moments, and only one mode produces the **verdict of record**:

| Run mode | When | Covers | Verdict |
|---|---|---|---|
| edit | as the agent writes | touched methods (badge / engine over the code just written) | informative only |
| chunk | between edits and at work-order handoff | the chunk's tests + regression guard; the gate over any configuration, including narrowed scratch configurations | informative — gates the handoff, not the build |
| CI | every commit; milestone boundaries re-run everything accumulated | the full registry, from the committed artifact, over the baseline-derived packages | **the verdict of record — the only one** |

Narrowing what a run covers is lawful only where a check's verdict is local (a
lint or layer verdict per method depends on that method alone) and only in the
informative modes; behavioral verdicts are global (a change can break a distant test)
and are never diff-narrowed. P6 is carried entirely by the CI mode: its input is the
committed artifact and baseline in git — nobody in the loop, human or agent, can narrow
*that* run (R-08).

`PGRReport`: `verdicts` (ordered) · `isClean` (all green) · `exitCode` (0 / 1) ·
`blockingVerdicts` · `advisories` · `printOn:` rendering the format below. Verdict line
format — one line per verdict, details indented beneath: each finding's target and
message, plus a `rationale:` line where the check carries one (every lint rule and the
meta-rule do, R-13/§2.3/§5.3; the layer-map check's findings are self-explanatory and
carry none, ch. 4). The verdict states shown are illustrative of the format only — they
are not the committed toy's actual state (which is all-red, §8.2):

```
PGR gate · Phi-Guardrails-Toy · 6 registrations
[ GREEN ] lint/PGRNoIsNilIfTrueRule (34ms)
[ RED   ] architecture/PGRLayerMapCheck (12ms)
          PGRToyWidget>>#render references PGRToyDatabase — layer 'ui' → 'persistence' is not allowed
[MISSING] behavioral/Phi-Guardrails-Toy-Tests — tests-role package contains no tests
          … (3 further verdict lines elided from this example)
GATE: RED — 2 blocking of 6 · exit 1
```

## 7.3 The invocation contract (R-07, R-47, D-45; D-15: Clap is incomplete in the stock image, so `eval` it is)

This section is not a fallback — it is **the** way the gate runs (D-45). Anyone or
anything may invoke it on any repo: a developer in a Playground, a CI job, a shell
script, an agent or harness, another tool. No caller is privileged and none is required;
the gate starts nothing, reads the configuration at the **explicit path the caller
passes** (no repo-root convention, no working-directory default — ruling D-45.1) and the
loaded code, and answers a verdict and an exit code. The caller provides everything: what
the gate needs is in `guardrails.ston` or in the loaded image — no environment sniffing,
no run-time inference (ruling D-45.4).

```smalltalk
PGRGate class >> runHeadless: aPathString
    "Parse the artifact at the path, run, print the report to stdout (verdicts stream
     as they complete), answer the exit code. Configuration errors print one line and
     answer 2. Equivalent to runHeadless: aPathString on: Stdio stdout."

PGRGate class >> runHeadless: aPathString on: aWriteStream
    "Same, onto an explicit stream — the testable seam (property P-GATE-HEADLESS)."
```

The contract script — part of the **reference runner** (D-45 ruling 4): a convenience
that must not re-privilege any caller; every line of it is reproducible by any other
caller:

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

The wrapper treats **any exit code that is not exactly 0, 1, or 2 as failure** (D-45):
the image failing to load, the `PGRGate` class being absent, or the VM dying must never
read as success. **This rule is machine-checked, not a waiver (D-49):** CI runs a
three-line shell self-test — invoke `guardrails.sh` with a deliberately unloadable
image and assert exit 3 — so the mapping itself cannot silently rot (property
P-WRAPPER-GUARD, ch. 9).

Exit codes: `0` clean · `1` ≥1 non-green verdict · `2` configuration error **or any
escaped exception** (D-39 — "no verdict produced"). (`Smalltalk exit:` verified, D-15.)

**The gate never ends without deciding a number** (D-39). Per-registration errors are
already red verdicts (§7.1, D-21), but an error escaping *anywhere else* — registry
construction, report rendering, the verdict sink, or a non-`Error` exception the
per-registration arm does not catch — would leave `runHeadless:` without an answer, so
`Smalltalk exit:` would never evaluate and the process exit code would be whatever the
headless image happens to produce. A crashed gate that CI reads as success is the worst
outcome this framework can have. Therefore **both `runHeadless:` forms wrap the entire run
in a top-level handler**: anything escaping is caught, one error line naming the exception
is written to the stream, and the method answers **2** — the same code as a configuration
error, both meaning *the run produced no verdict*. No path through either form ends
without answering 0, 1, or 2.

**Flush before exit.** `Smalltalk exit:` ends the process immediately, so both
`runHeadless:` forms **flush the stream before answering** — otherwise the tail of a long
red report is lost exactly when it matters most. Asserted in the headless test: the full
report text, including its last line, reached the stream before the exit code was
answered.

## 7.4 CI is just a caller (R-29 as amended by D-45)

Any CI system is one more caller of §7.3's contract — nothing in the framework knows or
privileges it. There is **no adapter test, no `Phi-Guardrails-CI-Tests` package, no
`ci-tests` role group**: all of that machinery existed only because the project had been
made the operator of its own gate, and D-45 retired it with the model. The framework's
own CI runs **two visible steps**:

1. **Validation** — smalltalkCI runs the test packages: the fixture-pair suites that
   prove the checks *work*. This step never goes through the gate.
2. **Enforcement** — a separate step invokes the gate headless on the framework's own
   config: `./guardrails.sh guardrails.ston` (§7.3). In this step the framework is the
   *subject* of the gate exactly as any client repo would be (R-47) — same contract,
   same exit codes, no special path.

The framework's own `.smalltalk.ston` (step 1 only):

```ston
SmalltalkCISpec {
    #loading : [ SCIMetacelloLoadSpec {
        #baseline : 'PhiGuardrails', #directory : 'src', #load : [ 'CI' ] } ],
    #testing : { #packages : [ 'Phi-Guardrails-Tests-.*' ],
                 #failOnZeroTests : true }
}
```

**Why two steps — D-40, restated structurally (D-45).** The tests-role suites execute in
both steps: step 1 runs them directly, step 2's gate runs them again as behavioral
registrations. That duplication is the independence D-40 demands — **a defect in the gate
cannot suppress the tests that detect it** — and it is now *visible architecture* rather
than a warning against an optimization: the test runner and the gate are two separate CI
steps by construction, not one run wrapped inside the other. The bootstrap problem it
answers is unchanged: CI loads the committed source, so a change to the gate is judged by
the *changed* gate; given a gate defect that greens regardless, step 1 still fails on the
fixture tests. Neither step may be deleted in favor of the other. Accepted cost as ruled:
every tests-role suite executes twice per CI run — seconds at v1 size. The companion
check is the "can the judge convict" test (property P-JUDGE-CONVICTS, ch. 9): given a
deliberately red registration, the report is red and the exit code is 1.

(`Pharo64-13` is a supported smalltalkCI platform; there is **no** critics option for
Pharo — only the gate runs registered rules headless, D-05/D-15. `#failOnZeroTests : true` is the
CI-level echo of R-24.) One CI-service workflow file invokes **both steps** —
**`.github/workflows/ci.yml`**, running `smalltalkci -s .smalltalk.ston` then
`./guardrails.sh guardrails.ston` on `Pharo64-13`
— which, with `guardrails.sh` (the reference runner, §7.3), makes **two** committed
files the framework owns outside `src/`, `plan/`, and the root artifacts (constitution
§2's write boundary names both — owner amendment landing with D-45/D-46). The pack's verify command remains the local loop:
`<pharo-vm> <image> test --fail-on-failure "Phi-Guardrails-Tests-.*"` — verified exit
semantics: green 0, red 1 (D-15).

## 7.5 Self-hosting artifact (R-38, D-25)

The framework's own `guardrails.ston` (repo root — the recommended in-repo default,
§1.1) declares: `#schemaVersion` `2` · `#src` `'src'` (relative to the config file's
directory, D-45 ruling 2) ·
`#baseline` `'BaselineOfPhiGuardrails'` · `#roles` — `#production : [ 'production' ]`
(the seven production packages incl. `-SDK`, §4.4's four layers), `#tests : [ 'tests' ]` (the
mirroring `Phi-Guardrails-Tests-*` packages), `#exempt : [ 'fixtures', 'toy' ]`
(baseline group names used as matchers — the convenience form; D-45) ·
`#exemptNamePatterns` `[ 'Phi-Guardrails-Fixtures-.*', 'Phi-Guardrails-Toy-.*' ]`
(D-25 residual 1) · one coding-kit block **naming every check explicitly** (D-51 — we
eat the explicit-composition rule ourselves): `#lintRules`
`[ 'PGRNoIsNilIfTrueRule', 'ReCodeCruftLeftInMethodsRule' ]` ·
`#architectureChecks` `[ 'PGRLayerMapCheck', 'PGRSrcInventoryCheck' ]` with the §4.4
`#layerMap` · `#metaRules` `[ 'PGRNoSkippedTestsMetaRule' ]`. Nothing is automatic:
delete a line here and that check stops running, visibly. The enforcement step (§7.4
step 2) therefore runs the framework against
itself on every CI run; the scope law
(§1.1) makes any new package that joins the baseline without a role a loud configuration
error. Toy and fixture packages are exempt-role by declaration — never swept (§3.2's
principle, now machine-checked); the toy has its own artifact and baseline exercised by
the demo test (ch. 8).

**Dead-code guard (D-25 residual 2; a registered check since D-45):**
**`PGRSrcInventoryCheck`** — it was a test only because tests were the invocation path;
under the invocation model it registers like everything else (kind `#architecture`, in
the kit block's `#architectureChecks`; the framework's own artifact writes the entry —
one scope, the file, D-51). Registration name `architecture/PGRSrcInventoryCheck`;
**missing** when the config declares no `#src` (the §1.5 parameter pattern). Its `run` is a **read-only walk**
of the declared source root (R-12 holds — checks never mutate; this walk and the artifact
read are the gate's only two file accesses, §7.6): red, with one finding per offender,
when a directory under `#src` neither names a package the baseline defines **nor is the
package of a loaded `BaselineOf` subclass** (`directories`, `basename` vs
`version packages` and the loaded baselines' `package name` — spellings D-25.a). The
baseline clause is forced, not convenient: the root baseline must sit in its own `src/`
directory for Metacello to find it (§7.4's `#directory : 'src'`), and no baseline
declares its own package — without the clause the check reds itself on day one. Code is
therefore either in the baseline (and so in a role, and so guarded), a baseline package
itself, or flagged as dead; there is no fourth state. Its fixture pair
(`PGRSrcInventoryCheckTest`, in `Phi-Guardrails-Tests-Coding-Architecture`) hands the
check a **scratch root** built and deleted by the test — never planted directories in the
real working tree.

## 7.6 Non-functional line (R-09, D-13)

No binding wall-clock budget in v1. Working target, non-binding: full gate (framework +
toy) **< 60 s** in CI; in-image incremental run **< 10 s**. At M4, with the full gate
running in CI, timings are measured and the budget becomes a ruled decision-log entry.
Design consequence honored now: checks do no I/O beyond the image except the two ruled
file accesses — the artifact read and `PGRSrcInventoryCheck`'s read-only walk of the
declared `#src` root (D-45) — so cost scales with loaded code size only.
