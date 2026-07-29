# E14-C02 · The `ensure:` restoration machinery and the autofix arm  [depends: E14-C01 · parallel: no]

GOAL      Add to `ToyDemoTest` the exception-safe source-restoration helper (D-43
item 1) and the second ruled test: `testLintAutofixThenGreen` — E08's preview-first
fix command drives the one fixable plant red → fixed, a fresh gate run shows **that
registration alone** turned green (five still blocking), and restoration returns
the committed red state byte-identically.

TRACE     R-32 (demonstration half — gate red → green via the shipped autofix) ·
spec ch. 8 §8.3 (`testLintAutofixThenGreen`: "apply `PCKFixCommand` (preview, then
apply) for `PCKNoIsNilIfTrueRule` to `Toy-Core`; re-run the gate; assert that
registration alone turned green (D-06 exercised end-to-end)") · D-43 item 1 (every
mutation restores via `ensure:`, on every path) · D-06 (preview-first fix) ·
D-42/§3.3 (the fix/gate composition note below) · P-GATE-RED (the D-43 protections
are part of its guarantee).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**What E14-C01 committed (this chunk's ground; all in
`src/Phi-Guardrails-Tests-Toy/ToyDemoTest.class.st`):** class `ToyDemoTest`
(superclass `TestCase`) with `setUp` asserting the six-row planted-state guard;
helper `plantedShapes` (six `{class. selector. marker}` triples); helper
`runToyGate` (a fresh
`(PGRGate forConfiguration: (PGRConfiguration fromString: BaselineOfToy guardrailsSTON)) run`
per send — never reuse a gate across runs, the suite cache is per registry build);
helper `expectedRegistrationNames` (the six names in order:
`'lint/PCKNoIsNilIfTrueRule'` · `'lint/ReCodeCruftLeftInMethodsRule'` ·
`'lint/ToyNoIsNilIfFalseRule'` · `'architecture/PCKLayerMapCheck'` ·
`'behavioral/Toy-Tests'` · `'behavioral/PCKNoSkippedTestsMetaRule'`); and
`testGateIsRedOnPlantedViolations`.

**The frozen fix-invocation surface (E08 digest, verbatim; re-probed live over the
toy plant at cut time — probes.md P4):**

- `PCKFixCommand class>>rule: aRuleClass packages: aCollectionOfPackageNames` —
  named constructor; signals `PGRNotAutofixable` unless the rule is a rewrite rule
  (`PCKNoIsNilIfTrueRule` is — the catalog autofix rule).
- instance `previewOn: aWriteStream` — mandatory first step; emits the diff on the
  stream and **answers the pending-change count** (probed: 1 for `Toy-Core` — the
  single `isNil ifTrue:` plant).
- instance `apply` — executes the previewed changes, answers the applied change
  objects (probed: size 1); staleness or re-apply signal (not exercised here —
  E08's own tested ground).
- One instance, one invocation.

**Probed behavior of the arm (probes.md P4/P8):** after
`(PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Toy-Core'))` preview+apply,
`ToyOrder>>#totalOrZero`'s body reads `items ifNil: [ ^ 0 ].` — the fix
**preserves the plant comment**, which itself contains the words "isNil ifTrue:"
(D-26's plant comments name their plant), so the post-fix source still contains
the naive string `'isNil ifTrue:'` while the **body-distinguishing marker
`'items isNil ifTrue:'` is gone** (probed both ways, P8). Every post-fix source
assertion in this class therefore uses the body-distinguishing marker, never the
naive one. A fresh toy-gate run then answers the `'lint/PCKNoIsNilIfTrueRule'`
verdict **green** and `blockingVerdicts size` **5**; recompiling the saved source
restores byte-identity.

**The restoration helper (D-43 item 1, this chunk's machinery; idiom probed —
probes.md P3).** Ruled text: "Each source mutation saves the original and is
wrapped so the recompile runs whether the body succeeded, failed, or errored
(`ensure:`) — not left to `tearDown` alone." Contract:

- `restoringSourcesOf: classSelectorPairs during: aBlock` — for each
  `{class. selector}` pair, snapshot
  `{class. selector. (class >> selector) sourceCode. (class >> selector) protocolName}`
  **before** running the block; then `aBlock ensure: [ ...each snapshot...
  class compile: source classified: protocolName ]`. Probed facts (P3): `sourceCode`
  answers a ByteString; `protocolName` a ByteSymbol (use it, NOT `protocol`, which
  answers a `Protocol` object); `ClassDescription>>compile:classified:` recompiles
  preserving package (`Toy-Core`) and protocol; the restored `sourceCode` is
  byte-identical; the `ensure:` block runs under a signaled error.

**Verdict accounting is exact here (ruled).** §8.3's test-2 sentence — "assert
that **registration alone** turned green" — is the demo's six-verdict assertion
applied after one fix: 6 verdicts, the fixed one green, the other 5 blocking.
§8.3's exact-count law ("the exact count is asserted deliberately … not slip in
unnoticed behind a `>=` assertion") covers the demo's own verdict accounting;
everything OUTSIDE the demo's report stays membership + floor.

**The fix-under-nesting note (D-42/§3.3, agent-judged at cut, veto-open in
`chunks.md`).** §3.3's caution reads "do not run a fix from inside a gate run" —
its stated hazard is recompiling a method that is currently executing ("a
half-rewritten gate is a bad place to be"). Under the self-hosted leg the
framework's gate runs this test (nested, D-46), and this test invokes the fix
command. The composition is judged inside the caution's own terms: the fix targets
`Toy-Core` — exempt-role in the framework's artifact, so no code the outer gate
checks, and no code executing in either gate — the in-image run is single-threaded
(D-42), so the nested fix runs to completion and is restored before the outer run
reads anything further. D-46 accepted "every local verify runs the
red → fixed → green cycle" as a cost — the cycle includes this arm by the ruled
§8.3 text.

**Constitution rules that bite here:** the framework never mutates client code
except through the explicit, preview-first fix command — this test IS that
explicit invoker, and its other mutations (none in this chunk) go through plain
recompilation of the toy's own source, restored on every path; tests assert
behavior; no `skip`; touching any file outside the manifest is a review rejection.

DELIVERABLES

Files (Tonel):
- **modify** `src/Phi-Guardrails-Tests-Toy/ToyDemoTest.class.st` only.

Methods to add:
- `restoringSourcesOf: classSelectorPairs during: aBlock` (helper — the D-43
  item 1 machinery, contract above).
- `testLintAutofixThenGreen` (the contract skeleton below).

E14-C01's methods are **untouched, byte-identical** (the reviewer diffs this).

LOC budget: target ~80 · ceiling 300.

TESTS FIRST  (`ToyDemoTest`)

- `testLintAutofixThenGreen` — **given** the planted toy (`setUp` guard) and a
  pre-test snapshot `before := (ToyOrder >> #totalOrZero) sourceCode`; **when**,
  inside `restoringSourcesOf: { {ToyOrder. #totalOrZero} } during: [...]`:
  1. `command := PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Toy-Core')`;
  2. `command previewOn: (WriteStream on: String new)` answers **1** (the one
     plant is the one pending change — preview-first, D-06);
  3. `command apply` answers exactly **1** applied change;
  4. the plant body is gone from the live source
     (`deny: ((ToyOrder >> #totalOrZero) sourceCode includesSubstring: 'items isNil ifTrue:')`
     — the body-distinguishing marker; the preserved plant comment keeps the
     naive `'isNil ifTrue:'` string alive, probed P8);
  5. a fresh gate run (`self runToyGate`) answers 6 verdicts of which the one
     named `'lint/PCKNoIsNilIfTrueRule'` `isGreen`, and `blockingVerdicts size`
     = **5** — that registration alone turned green;
  **then**, after the block returns (restoration has run):
  6. `(ToyOrder >> #totalOrZero) sourceCode` equals `before` — the committed red
     state is back, byte-identical.

Fixtures: the toy's committed plants; the frozen toy artifact. Nothing new.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors — both `ToyDemoTest` cases
          listed by name, every previously accepted suite green — ≥265 run
          (263 at cut + C01's 1 + this 1); membership + floor.
          **Plus the self-hosted regression leg:**
          `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
          → exit 0, **12 registrations unchanged**, `GATE: GREEN` (the nested
          demo now includes the fix arm — the D-42 composition note above holds;
          non-zero or a hang is a stop-and-report).

OUT OF SCOPE
- The all-fixed-then-clean arm and the six fixed sources (E14-C03).
- Exercising `PGRFixStale` / `PGRFixNotPreviewed` / `PGRNotAutofixable` (E08's
  accepted tested ground — re-testing it here is duplication).
- Hand-mutating any source except through the fix command in this test (the
  hand-recompile arm is C03's).
- Touching any file outside the one-file manifest; any accepted test file.

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67).
Postcondition: one commit `E14-C02: ToyDemoTest — ensure: restoration + the
autofix arm`, nothing uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output (sweep + gate
  leg) · deviations (each one-line justified) · new questions for the decision
  sheet.
