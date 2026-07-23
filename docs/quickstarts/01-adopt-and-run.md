# Quickstart 1 — Adopt phi-guardrails and run the gate on your project

*Audience: a Pharo developer adopting the gate for an existing project (config author),
and anyone invoking it (gate caller). Derived from spec ch. 1 §1.1, ch. 7 §7.1–§7.5,
ch. 8 §8.1. Samples are unexecutable until milestone **M4** and are marked ⟨verify⟩;
at that milestone a test executes each sample verbatim (spec ch. 9, P-GUIDE-EXEC).*

phi-guardrails is a standalone checking tool for Pharo 13. You point it at a
configuration file; it reads your loaded code, runs exactly the checks the file names,
and answers a report and an exit code. **Adopting it changes nothing in your project**
— no dependency, no baseline edit, no test changes. Your project is the *subject* of
the gate, never its operator: any caller — you in a Playground, a CI job, a script —
may run it.

## 1 · Write `guardrails.ston`

One file declares everything. It can live anywhere (you always pass its path
explicitly); the root of your repo is the recommended spot for a project that owns its
config. It is pure-data STON — no comments, no class tags. ⟨verify⟩

```ston
{
    #schemaVersion : 2,
    #project : 'Acme',
    #baseline : 'BaselineOfAcme',
    #roles : {
        #production : [ 'Acme-(Core|Server)' ],
        #tests      : [ 'Acme-Tests' ] },
    #kits : [ {
        #kit : 'PCKKit',
        #lintRules : [ 'PCKNoIsNilIfTrueRule',
                       'ReCodeCruftLeftInMethodsRule' ],
        #metaRules : [ 'PCKNoSkippedTestsMetaRule' ] } ]
}
```

Reading it:

- `#baseline` names your loaded `BaselineOf` subclass — it is the only package
  inventory. The `#roles` matchers (a baseline group name, a package name, or a
  full-match regex) assign **every** package the baseline defines to exactly one role:
  `#production` (targeted by lint and architecture checks), `#tests` (run as
  behavioral suites, every red test fails the gate), or `#exempt` (never targeted).
  A package left in no role is a configuration error, not a silent escape.
- The `#kits` block is the coding kit's **entire** configuration. Nothing runs by
  default: the three entries above are the kit's *recommended block* — a documented
  starter template — and deleting a line is the only (fully diffable) way to not run
  a check. The two lint rules ship an `isNil ifTrue: → ifNil:` autofix rule and
  Pharo's own debug-cruft rule; the meta-rule fails the gate on any skipped or
  expected-failure test.
- When your project has layers to declare, add `#architectureChecks :
  [ 'PCKLayerMapCheck' ]` and a `#layerMap` to the kit block (spec ch. 4 §4.1); add
  a top-level `#src` if you register the dead-source check (spec ch. 7 §7.5).

You don't have to write this by hand: with your baseline loaded,
`PGRConfigurationDraft draftFor: 'BaselineOfAcme'` answers a draft of this file for
your review. The draft may guess; the running gate never does. ⟨verify⟩

## 2 · Run the gate headless

The reference runner is `guardrails.sh`, and the recipe from zero to a runnable gate
is three steps (spec ch. 7 §7.3 — the framework's own CI workflow is the executable,
tested copy of the same steps): ⟨verify⟩

1. Fetch a Pharo 13 headless VM and image.
2. Load the framework, then your project the way it normally loads: ⟨verify⟩

   ```smalltalk
   Metacello new
       baseline: 'PhiGuardrails';
       repository: 'github://<org>/phi-guardrails:main/src';
       load.
   ```

3. Point the runner at the pieces and the config:

```bash
export PHARO_VM=/path/to/pharo IMAGE=/path/to/acme.image
./guardrails.sh /path/to/acme/guardrails.ston
```

Exit codes — the machine contract:

| Code | Meaning |
|---|---|
| 0 | every registered check ran and is green |
| 1 | at least one verdict is not green (red, missing, or skipped) |
| 2 | the run produced no verdict: configuration error, or an escaped exception |
| 3 | (wrapper only) the gate did not run at all — image or VM failure |

The report streams to stdout, one line per registration. The printed text is for
humans — script against the exit code, never the wording. Illustrative shape ⟨verify⟩:

```
PGR gate · Acme · 4 registrations
[ GREEN ] lint/PCKNoIsNilIfTrueRule (34ms)
[ RED   ] lint/ReCodeCruftLeftInMethodsRule (21ms)
          AcmeServer>>#start — Breakpoints, logging statements, etc. should not be
          left in production code.
[ GREEN ] behavioral/Acme-Tests (2103ms)
[ GREEN ] behavioral/PCKNoSkippedTestsMetaRule (2ms)
GATE: RED — 1 blocking of 4 · exit 1
```

## 3 · Run it in-image

The same gate, the same verdicts, from a Playground or an agent loop. There is no
default output — the gate writes only to what you give it: ⟨verify⟩

```smalltalk
| config gate report |
config := PGRConfiguration fromFile: '/path/to/acme/guardrails.ston'.
gate := PGRGate forConfiguration: config.
gate onVerdict: [ :v | Transcript crShow: v printString ].   "optional live stream"
report := gate run.
report isClean.            "true iff everything green"
report exitCode.           "0 or 1 — same number the headless run answers"
report blockingVerdicts.   "the non-green verdicts, for programmatic reading"
```

Each verdict answers `status`, `isGreen`, `registrationName`, `kind`,
`durationMillis`, `findings`, and `advisories`; each finding answers `target`,
`message`, and `rationale` — the rationale is written to tell you (or your agent) what
to do instead.

A defective configuration signals before anything runs: ⟨verify⟩

```smalltalk
[ PGRConfiguration fromFile: path ]
    on: PGRConfigurationError
    do: [ :err | "one line naming the offending key, package, or class" ]
```

## 4 · What "missing" means — silence never passes

A registration that cannot resolve — a check name matching no loaded class, a
tests-role package containing no tests, an empty tests-role expansion — is a
**missing** verdict, and missing fails the gate exactly like red (spec ch. 1 §1.5).
The tool's standing rule: nothing registered may quietly not run.

## 5 · The two most likely first-run failures

Error wording is human-facing and not frozen — the texts below are representative,
not contractual. ⟨verify⟩

1. **A package in no role** (exit 2). You added `Acme-Benchmarks` to the baseline and
   no `#roles` matcher covers it:
   `PGRConfigurationError: package 'Acme-Benchmarks' is assigned to no role` —
   fix: widen a matcher or add the package to `#exempt`, visibly.
2. **A check name that resolves to nothing** (exit 1, missing) — a typo like
   `'PCKNoIsNilIfTrue'` yields
   `[MISSING] lint/PCKNoIsNilIfTrue — name resolves to no loaded class`;
   a loaded class that does *not* satisfy the check contract is instead a
   configuration error (exit 2) naming the class and the missing selector.

---
*Spec citations: ch. 1 §1.1–§1.2, §1.5 (schema, one-scope rule, missing semantics) ·
ch. 7 §7.1–§7.3 (failure condition, gate object, invocation contract, exit codes, and
the image-assembly recipe) · ch. 7 §7.5, ch. 4 §4.1 (dead-source check, layer map) ·
ch. 8 §8.1 (adoption steps, init draft). Ruling trail (log numbers, for maintainers):
D-45, D-47, D-49, D-51, D-53, D-55, D-59, D-60.*
