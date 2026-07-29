# E15 cut-time probes (D-82/Q-39 obligation) — part of the epic's validation record

Probed 2026-07-28 at HEAD `181709f` (clean tree; `git diff 2f4cccb..HEAD` over
`src/ docs/ .github/ guardrails.ston .smalltalk.ston guardrails.sh` is empty —
src and infra byte-identical to the E14 checkpoint head, so the 266-sweep and
all frozen digests are current ground). Work image `.build/work/phi.image`,
toolchain build `4f7563dfe5` (D-63). Shell-arm probes ran the actual committed
scripts (D-65 infra, expressly sanctioned by the owner's cut notice). Every
transcript below is as-executed output, unedited.

## P1 · Wrapper ∉{0,1,2} arms (`./guardrails.sh guardrails.ston`, committed wrapper, unmodified)

| arm | invocation | observed |
|---|---|---|
| A | `PHARO_VM=/nonexistent/vm IMAGE=/nonexistent/img` | `./guardrails.sh: line 3: /nonexistent/vm: No such file or directory` · `guardrails: gate did not run to a verdict (exit 127)` · **exit 3** |
| B | real VM, `IMAGE=/nonexistent/img.image` | VM logs `Image file not found` twice, then **exit 0** — the wrapper relays **success** |
| C | real VM, empty (0-byte) image file | VM logs `Invalid image format: detected version 0, expected version 68021`, **exit 1** — relays 1 (the D-75 ruled limitation, reconfirmed) |

Consequences consumed by the cut: the P-WRAPPER-GUARD CI self-test uses **arm
A** (deterministic, cross-platform: bash exec failure 127 → 3); arm B is a
**false-green hole** outside D-75's ruling — filed as **Q-40** (decision
sheet), no chunk touches the wrapper unless ruled; arm C reconfirms D-75. The
ch. 9 P-WRAPPER-GUARD row's "unloadable image exits 3" wording is queued as a
MINOR erratum (decision log wins: D-75 + this probe).

## P2 · Linux CI toolchain (files.pharo.org/get-files/130, fetched 2026-07-28)

Directory listing carries `pharoImage-x86_64.zip` and
`pharo-vm-Linux-x86_64-stable.zip` (no `pharoImage.zip`/`pharo64.zip` — 404).
Fetched both; SHA-256 as computed:

```
897668dd548864f74730065de3fa2b1f4b5d3636d4c7d14f91945f0a5ce22590  pharoImage-x86_64.zip
b4b344a8236f43f08eedad205ca6a292f85bbcbe107f5d68aed04595c43e83ed  pharo-vm-Linux-x86_64-stable.zip
```

`pharoImage-x86_64.zip` is **byte-identical to the D-66-pinned image zip**
(same checksum as `tools/install.sh`'s `IMAGE_SHA256`); contents:
`Pharo13.0-SNAPSHOT-64bit-4f7563dfe5.image` + `.changes` +
`Pharo13.1-64bit-4f7563d.sources` + `pharo.version` — exactly the D-63
verified build, so CI step 2 runs the same image build as every local leg. VM
zip entry point: `bin/pharo` (+ `lib/*.so`). Both pins go verbatim into
E15-C01's workflow (D-66: drift fails loudly).

## P3 · Guide-1 fence inputs, end-to-end against the committed harness + gate (work image)

Script: scratch Acme world installed via `PGRQuickstartSampleHarness`
(`BaselineOfAcme` with `<baseline>` pragma naming `Acme-Core`/`Acme-Server`/
`Acme-Tests`; one clean class each; a passing `AcmeSmokeTest`), then guide 1's
fence texts verbatim. Output as executed:

```
3a INSTALLED: baseline+3 packages
3b names: #('lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule' 'behavioral/Acme-Tests' 'behavioral/PCKNoSkippedTestsMetaRule')
3b isClean: true exitCode: 0
3c draft parses, project: 'Acme'
3d wrapped fence value class: Array size: 0
3e handler saw: PGRConfigurationError text: Malformed STON: STONReaderError: At character 28: ': expected'
3f PGRConfigurationError: Packages assigned to no role: Acme-Benchmarks
3g missing verdict: #missing exitCode: 1
3h metacello fence parses: true
3h bad source: true
3i NO ERROR at fromString:
3i PGRConfigurationError: OrderedCollection is loaded but is not a Renraku rule class
```

Readings: 3b = fence 1 verbatim yields the guide's four registration names in
order, clean/0 on a clean adopter (D-60.a's "guide 1's four registrations
reconcile", now live). 3c = `PGRConfigurationDraft draftFor:` works on a
runtime-installed baseline. 3d = the block-wrap idiom
(`OpalCompiler new evaluate: '[:path | ' , fence , ' ]'` then `value:`)
executes §3's fence verbatim against a scratch config file; the fence's last
expression (`blockingVerdicts`) answers an empty Array on the clean world.
3e = the §3 defective-config handler shape catches `PGRConfigurationError`; `messageText`
names the offense. 3f = §5 failure 1 signals `PGRConfigurationError` at
`fromString:` (before anything runs). 3g = §5 failure 2 yields `#missing`
named `lint/PCKNoIsNilIfTrue`, exit 1. 3i = the loaded-but-nonconforming
variant signals `PGRConfigurationError`. (3h's two `true`s exposed the
non-discriminating parse spelling → P4.)

## P4 · Syntax-check spelling (the Metacello-fence compile-boundary arm)

`OpalCompiler new source: …; parse` method-parses and answers
`isFaulty = true` for BOTH the clean Metacello expression and broken source —
**not discriminating; rejected.** Probed replacement:

```
OCParser exists: true
good parseExpression isFaulty: false
bad parseExpression isFaulty: ERR OCCodeError
```

**`OCParser parseExpression:`** — clean expression (with trailing period) →
node, `isFaulty` false; broken source → signals `OCCodeError`. C02's arm 5
asserts `isFaulty` false (a signal also reds the arm).

## P5 · The committed harness over the committed guide 1 + the workflow locator

```
guide-1 sample count: 3
1: #ston first-line: {
2: #smalltalk first-line: | config gate report |
3: #smalltalk first-line: [ PGRConfiguration fromFile: path ]
ci.yml located: true
ci.yml has smalltalkci line: true
```

The §2 Metacello fence is **invisible** (indented inside list item 2 — the
harness's column-0 fence rule): the committed guide yields 3 samples, not 4.
This drives C02's de-indent reshape and the 4-sample inventory pin (the
tests-first red: arm 1 fails on the unamended guide). The E09 "harness must
not choke on guide 1" advisory is answered: it does not choke — it parses 3
samples cleanly. `locateUpwardFrom:for:` reaches the committed
`.github/workflows/ci.yml` from the work image (C02 arm 5's reader).

## P6 · Ground identity

`git diff 2f4cccb..HEAD -- src/ docs/ guardrails.ston .smalltalk.ston
.github/ guardrails.sh` → empty. The cut's 266-sweep figure, the frozen E14
digest, and every file this cut references are the accepted checkpoint ground.

## P7 · Timing spellings (E15-C03)

```
millisecondsToRun answers: SmallInteger value: 0
in-image full gate (cold, work image): 876 ms
in-image full gate (2nd run, warm): 875 ms
```

`Time millisecondsToRun:` confirmed; the in-image full framework gate (12
registrations, nesting the toy demo) runs in under a second on the cut-day
work image — preview only; C03 re-measures on the epic head. `gh` CLI present
for the CI-step duration reads.

## P8 · Workflow-shape reference sweep (scripted; C01's amendment table)

Scope: `git ls-files 'src/**/*.st' 'docs/**/*.md' 'tools/*' 'guardrails.sh'
'.github/workflows/*' '.smalltalk.ston' 'README*'` → **136 files scanned**
(nonzero asserted). Patterns: `ci\.yml` · `smalltalkci`/`smalltalkCI`/
`SmalltalkCI` · `workflow` · `step 1` · `step 2` · `two-step`. Hits, each
accounted: `.github/workflows/ci.yml` (the amended file) · `.smalltalk.ston`
(step-1 config, final form) · `docs/quickstarts/01-adopt-and-run.md:65` (the
executable-copy sentence — true once C01 lands; guide amended in C02) ·
`PGRQuickstartSampleHarness` (runtime `SmalltalkCI` global locator, not a
shape pin) · seven `src/` "step 1"/"step 2" hits across six files
(`PCKSuiteRunCache` carries two), all spec-paragraph *stage* comments (§1.4 ·
§5.2 · §7.5 · §8.1 · Tonel test mirrors). **No committed
file pins step-1-only as permanent; zero committed tests read the workflow.**

## P9 · Decision-sheet counter

Last filed question: Q-39 (ruled, D-82). This cut files **Q-40** (the P1 arm-B
false-green hole); E15-C03 files **Q-41** (the D-13 timings).
