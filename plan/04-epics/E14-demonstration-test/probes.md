# E14 · Cut-time probe record (D-82/Q-39 obligation)

*Every skeleton assertion in this cut that names a reflective predicate or a
frozen-surface selector/constructor was executed against the work image — or checked
against the frozen digest — before the cut was committed. Work image:
`.build/work/phi.image`, built by `bash tools/build-image.sh` at the E12 close (src
head `3333062`); probed at HEAD `1f7c80f` after confirming
`git diff --stat 3333062 HEAD -- src/` is **empty** (the post-E12 commits are
plan/ledger bookkeeping only — the image is current for `src/`). Probes run headless
with the D-31.a VM (`.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo --headless
.build/work/phi.image eval …`); probe evals never save the image, so every mutation
probe below left the on-disk image untouched. The fix-arm and source-mutation
idioms are probed with full round trips (the roadmap E14 risk row: "in-image
source mutation/restoration is the framework's most delicate test"). Transcripts
verbatim; digest-checked rows cite their frozen table instead of a
transcript. This file is part of the epic's validation record (the validator
spot-checks ≥3 probes live).*

## Live probe transcripts

**P1/P2 — one gate run over the toy's committed artifact: exactly six verdicts, in
the frozen registry order, all red, each naming its planted target (E14-C01's whole
test-1 contract):**

```
P1 report class: PGRReport
P1 verdict count: 6
P1 names in order: #('lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule' 'lint/ToyNoIsNilIfFalseRule' 'architecture/PCKLayerMapCheck' 'behavioral/Toy-Tests' 'behavioral/PCKNoSkippedTestsMetaRule')
P1 all non-green: true
P1 isClean: false
P1 exitCode: 1
P1 blocking: 6
P2 lint/PCKNoIsNilIfTrueRule status: #red targets: #('ToyOrder>>#totalOrZero')
P2 lint/ReCodeCruftLeftInMethodsRule status: #red targets: #('ToyOrder>>#logTotal')
P2 lint/ToyNoIsNilIfFalseRule status: #red targets: #('ToyOrder>>#itemCountOrZero')
P2 architecture/PCKLayerMapCheck status: #red targets: #(#'ToyOrderView>>#storeSnapshot')
P2 behavioral/Toy-Tests status: #red targets: #(#'ToyOrderTest>>#testTotalIsFortyTwo')
P2 behavioral/PCKNoSkippedTestsMetaRule status: #red targets: #(#'ToyOrderTest>>#testSkippedOnPurpose')
```

(Note the mixed Symbol/String target rendering: `#'X' = 'X'` holds in-image — the
B-14 fact re-confirmed at E09 and relied on by the accepted `PGRToyPlantWitnessTest`
comparisons; the skeletons compare with `=`/`assert:equals:` against String literals,
the accepted precedent.)

**P3 — the source-mutation/restoration idiom (E14-C02/C03's machinery), full round
trip incl. the `ensure:`-under-signal arm:**

```
P3 sourceCode class: ByteString
P3 marker present: true
P3 protocol: Protocol (accessing) - 5 selector(s) class: Protocol
P3 CompiledMethod canUnderstand protocolName: true
P3 ClassDescription canUnderstand compile:classified: true
P3 post-compile marker gone: true
P3 post-compile package: Toy-Core
P3 post-compile protocol: #accessing
P3 restored byte-identical: true
P3 restored protocol: #accessing
P3 ensure-restore under signal: true
```

(`CompiledMethod>>protocol` answers a `Protocol` object, so the skeletons use
`protocolName` — probed `ByteSymbol`, P4 line 1 — as `compile:classified:`'s
argument; recompilation preserves package (`Toy-Core`) and protocol, and restoring
the saved `sourceCode` is byte-identical. The `ensure:` arm proves restoration runs
when the body signals — D-43 item 1's mechanism, live.)

**P4 — the fix arm (E08's frozen fix-invocation surface) over the toy plant, full
round trip: preview → apply → gate answers 5 blocking with the fixed registration
green → restore byte-identical:**

```
P4 protocolName: #accessing class: ByteSymbol
P4 pending after preview: 1
P4 applied count: 1
P4 post-apply source: 'totalOrZero	"PLANTED VIOLATION (R-37/D-26, sanctioned Toy-* exception): the `isNil ifTrue:`	PCKNoIsNilIfTrueRule fires on - real, current, caught code."	items ifNil: [ ^ 0 ].	^ self total'
P4 fixed registration green: true
P4 blocking after fix: 5
P4 restored byte-identical: true
```

**P5 — the all-fixed-then-clean arm: the six fixed sources E14-C03 prescribes,
compiled in-image → the same gate answers GREEN (exit 0) with exactly the one D-80
unlayered advisory riding the clean report → restore all six byte-identical → a
fresh gate run answers 6 blocking again:**

```
P5 all-fixed isClean: true
P5 all-fixed exitCode: 0
P5 all-fixed advisories: #('architecture/PCKLayerMapCheck')
P5 restored byte-identical all six: true
P5 post-restore blocking: 6
```

**P6 — the framework's own registry (the regression-leg claim and the D-46 nesting
path `behavioral/Phi-Guardrails-Tests-Toy`):**

```
P6 framework registrations: #('lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule' 'architecture/PCKLayerMapCheck' 'architecture/PCKSrcInventoryCheck' 'behavioral/Phi-Guardrails-Tests-SDK' 'behavioral/Phi-Guardrails-Tests-Core' 'behavioral/Phi-Guardrails-Tests-Gate' 'behavioral/Phi-Guardrails-Tests-Toy' 'behavioral/Phi-Coding-Kit-Tests-Rules' 'behavioral/Phi-Coding-Kit-Tests-Architecture' 'behavioral/Phi-Coding-Kit-Tests-Behavioral' 'behavioral/PCKNoSkippedTestsMetaRule')
P6 count: 12
```

**P7 — remaining skeleton spellings:**

```
P7 TestCase canUnderstand assert:description: true
P7 Array canUnderstand with:do: true
P7 String canUnderstand includesSubstring: true
```

**P8 — the body-distinguishing guard markers (remediation probe, validation round
1's F1/F2): each of the six markers is present in its committed plant body,
absent from the plant's own comment (which names its plant and survives the fix
command), gone from the live source after the fix arm (while the naive
`'isNil ifTrue:'` string survives in the preserved comment), and absent from
every C03 fixed source — so the `setUp` guard and C02's post-fix deny track the
body on every mutation path:**

```
P8 ToyOrder>>#totalOrZero marker present: true
P8 ToyOrder>>#logTotal marker present: true
P8 ToyOrder>>#itemCountOrZero marker present: true
P8 ToyOrderView>>#storeSnapshot marker present: true
P8 ToyOrderTest>>#testTotalIsFortyTwo marker present: true
P8 ToyOrderTest>>#testSkippedOnPurpose marker present: true
P8 ToyOrder>>#totalOrZero marker absent from comment: true
P8 ToyOrder>>#logTotal marker absent from comment: true
P8 ToyOrder>>#itemCountOrZero marker absent from comment: true
P8 ToyOrderView>>#storeSnapshot marker absent from comment: true
P8 ToyOrderTest>>#testTotalIsFortyTwo marker absent from comment: true
P8 ToyOrderTest>>#testSkippedOnPurpose marker absent from comment: true
P8 post-fix body marker gone: true
P8 post-fix comment survives (plain marker still present): true
P8 restored byte-identical: true
P8 no fixed source contains its marker: true
```

(The markers probed: `'items isNil ifTrue:'` · `'Transcript show: self total'` ·
`'items isNil ifFalse:'` · `'ToyOrderStore empty'` · `'equals: 42'` ·
`'self skip:'` — the C01 table's spellings, incl. plant 5's `'equals: 42'`,
which round 1 noted as previously annotation-only (F3); all six now carry this
transcript.)

## Digest-checked rows (no transcript needed; frozen tables)

- `PGRConfiguration class>>fromString:` — E03 digest
  (`plan/04-epics/E03-configuration-scope-law/chunks.md`), re-exercised live in
  P1/P4/P5.
- `PGRGate class>>forConfiguration:` · `PGRGate>>run` · `PGRReport>>verdicts` /
  `isClean` / `exitCode` / `blockingVerdicts` / `advisories` — E05 digest
  (`plan/04-epics/E05-gate-report-invocation/chunks.md`), re-exercised live in
  P1/P4/P5.
- `PGRVerdict>>registrationName` / `isGreen` / `findings`; `PGRFinding>>target` /
  `message` — E02 digest (`plan/04-epics/E02-sdk-vocabulary/chunks.md`),
  re-exercised live in P1/P2/P4.
- `PCKFixCommand class>>rule:packages:` · `previewOn:` (answers the pending count;
  mandatory first step) · `apply` (answers applied changes; one instance, one
  invocation) — E08 digest (`plan/04-epics/E08-fix-command/chunks.md`),
  re-exercised live in P4.
- `BaselineOfToy class>>guardrailsSTON`, the six-registration registry shape IN
  ORDER, and the six-plant inventory at its named homes — E12 digest
  (`plan/04-epics/E12-toy-client-init-tool/chunks.md`), re-exercised live in
  P1/P2/P3/P4/P5.
- `anySatisfy:` / `detect:` / `WriteStream on: String new` — accepted committed
  usage (`PGRToyPlantWitnessTest`, `PCKFixCommandTest`), additionally exercised
  live inside the P1–P5 probe scripts themselves.
