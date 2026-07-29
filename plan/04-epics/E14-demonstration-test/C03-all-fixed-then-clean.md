# E14-C03 · The all-fixed-then-clean arm  [depends: E14-C02 · parallel: no]

GOAL      Add to `ToyDemoTest` the third ruled test: `testAllFixedThenClean` —
with every plant fixed in-image (the six probed fixed sources compiled over the
plants), the same gate answers GREEN (`isClean`, exit code 0, the one D-80
advisory riding the clean report) — then restoration returns the committed red
state byte-identically, completing red → fixed → green inside one test class.

TRACE     R-32 (demonstration half — gate red → green complete) · R-43 (demo half
— the architecture registration green once the reach is removed) · R-44 (the
behavioral registrations green once the failing test and the skip are fixed) ·
spec ch. 8 §8.3 (`testAllFixedThenClean`: "fix every plant in-image (rewrite,
remove the reference, the failing assertion, the skip); re-run; assert
`report isClean` and exit code 0") · D-43 (both protections exercised on the
demo's widest mutation) · D-80 (the `#unlayered` advisory rides CLEAN reports
only) · P-GATE-RED (guarantee column: the toy's red state survives every run).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**What E14-C01/C02 committed (this chunk's ground; all in
`src/Phi-Guardrails-Tests-Toy/ToyDemoTest.class.st`):** class `ToyDemoTest`
(superclass `TestCase`) with: `setUp` asserting each planted method's source still
contains its **body-distinguishing** marker (probed absent from the plant
comments and from every fixed source below — P8); helper `plantedShapes` — the
six `{class. selector. marker}` triples `{ToyOrder. #totalOrZero. 'items isNil
ifTrue:'}` · `{ToyOrder. #logTotal. 'Transcript show: self total'}` ·
`{ToyOrder. #itemCountOrZero. 'items isNil ifFalse:'}` · `{ToyOrderView.
#storeSnapshot. 'ToyOrderStore empty'}` · `{ToyOrderTest. #testTotalIsFortyTwo.
'equals: 42'}` · `{ToyOrderTest. #testSkippedOnPurpose. 'self skip:'}`; helper
`runToyGate` — a fresh
`(PGRGate forConfiguration: (PGRConfiguration fromString: BaselineOfToy guardrailsSTON)) run`
per send (never reuse a gate across runs); helper `expectedRegistrationNames`;
helper `restoringSourcesOf: classSelectorPairs during: aBlock` — snapshots
`{class. selector. sourceCode. protocolName}` per pair, runs the block, and
`ensure:`-recompiles every snapshot via `compile:classified:` (D-43 item 1); and
the two earlier tests.

**Report/verdict readers (frozen E05/E02):** `PGRReport>>isClean` (true iff every
verdict green) · `exitCode` (0 iff clean, else 1) · `advisories` (concatenation of
every verdict's advisories — reported, never blocking) · `blockingVerdicts`;
`PGRFinding>>target`.

**The six fixed sources (prescribed verbatim — probed as a full round trip,
probes.md P5: compiled in-image they turn the gate GREEN, exit code 0; restoring
the snapshots returns 6 blocking).** Each is compiled with
`class compile: fixedSource classified: (class >> selector) protocolName`
(idiom probed, P3 — package and protocol preserved):

| Class | Selector | Fixed source (verbatim) |
|---|---|---|
| `ToyOrder` | `#totalOrZero` | `totalOrZero` ⏎ `	items ifNil: [ ^ 0 ].` ⏎ `	^ self total` |
| `ToyOrder` | `#logTotal` | `logTotal` ⏎ `	^ self total` |
| `ToyOrder` | `#itemCountOrZero` | `itemCountOrZero` ⏎ `	^ items ifNil: [ 0 ] ifNotNil: [ items size ]` |
| `ToyOrderView` | `#storeSnapshot` | `storeSnapshot` ⏎ `	^ nil` |
| `ToyOrderTest` | `#testTotalIsFortyTwo` | `testTotalIsFortyTwo` ⏎ `	self assert: ToyOrder empty total equals: 0` |
| `ToyOrderTest` | `#testSkippedOnPurpose` | `testSkippedOnPurpose` ⏎ `	self assert: ToyOrder empty itemCount equals: 0` |

(⏎ = newline + the shown tab; §8.3's four fix species are all here: the
`ifNil:` **rewrite** ×2, the cruft and the persistence-**reference removal**, the
**failing assertion** corrected — an empty order totals 0 — and the **skip**
replaced by a real assertion. Each fixed source stays clean under every registered
check — probed, P5.)

**The advisory on the clean report (D-80, probed P5):** the toy's map declares
`#unlayered : ['Toy-Rules']`, so the clean `architecture/PCKLayerMapCheck` verdict
carries exactly one advisory (target `'architecture/PCKLayerMapCheck'`) — the
advisory rides the CLEAN report and does not block (`exitCode` 0). The frozen
`PGRVerdict` has no red-with-advisories constructor (D-82 carry-forward 3); the
advisory exists only on this green path.

**Why restoration is asserted at source level:** the demo's mutation vector is
source recompilation, so byte-identical `sourceCode` against the pre-test
snapshots IS the committed red state restored (probed: a post-restore gate run
answers 6 blocking again, P5 — the sweep's other toy tests and every later
`setUp` guard keep re-proving red continuously; a third in-test gate run would
re-test what P5 and the neighboring tests already pin).

**Constitution rules that bite here:** the toy mutations are transient test-body
state restored in the same test (the D-43 machinery) — nothing committed changes;
the transient `testSkippedOnPurpose` replacement is a real assertion (a test that
cannot fail is a defect — the fixed body asserts the empty order's item count);
tests assert behavior; touching any file outside the manifest is a review
rejection.

DELIVERABLES

Files (Tonel):
- **modify** `src/Phi-Guardrails-Tests-Toy/ToyDemoTest.class.st` only.

Methods to add:
- `fixedPlantSources` (helper) — the six `{class. selector. fixedSource}` triples
  of the table above, verbatim.
- `testAllFixedThenClean` (the contract skeleton below).

E14-C01/C02's methods are **untouched, byte-identical** (the reviewer diffs this).

LOC budget: target ~110 · ceiling 300.

TESTS FIRST  (`ToyDemoTest`)

- `testAllFixedThenClean` — **given** the planted toy (`setUp` guard) and
  pre-test snapshots of all six planted sources
  (`snapshots := pairs collect: [:pair | (pair first >> pair last) sourceCode]`
  where `pairs` is the six `{class. selector}` pairs of `plantedShapes`);
  **when**, inside `restoringSourcesOf: pairs during: [...]`:
  1. every `fixedPlantSources` triple is compiled
     (`class compile: fixedSource classified: (class >> selector) protocolName`);
  2. a fresh gate run (`self runToyGate`) answers `report isClean` **true** —
     with every plant fixed, the same gate over the same artifact is GREEN;
  3. `report exitCode` = **0**;
  4. `report advisories size` = 1 and that advisory's `target` =
     `'architecture/PCKLayerMapCheck'` — the D-80 `#unlayered` advisory rides the
     clean report without blocking it;
  **then**, after the block returns (restoration has run):
  5. each of the six methods' `sourceCode` equals its pre-test snapshot
     (`pairs with: snapshots do: [...]` — `with:do:` probed P7) — the committed
     red state is back, byte-identical on every one.

Fixtures: the toy's committed plants; the frozen toy artifact; the fixed sources
this chunk prescribes. Nothing new outside the one file.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors — all three `ToyDemoTest` cases
          listed by name, every previously accepted suite green — ≥266 run
          (263 at cut + C01's 1 + C02's 1 + this 1); membership + floor. This run
          is the epic exit checkpoint's leg-1 core.
          **Plus the self-hosted regression leg:**
          `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
          → exit 0, **12 registrations unchanged**, `GATE: GREEN` — the full
          red → fixed → green cycle now nests inside the framework's own gate run
          and terminates (D-46 exercised in earnest; non-zero or a hang is a
          stop-and-report).

OUT OF SCOPE
- Committing any change to the toy's packages (the fixes are transient in-image
  state, restored before the test returns — D-26's committed red state is law).
- A third in-test gate run after restoration (rationale in the digest; the
  neighboring tests and `setUp` guards pin post-restore red continuously).
- CI two-step, wrapper guard, guide 1, D-13 timings (E15 — do not pre-build).
- Touching any file outside the one-file manifest; any accepted test file.

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67).
Postcondition: one commit `E14-C03: ToyDemoTest — the all-fixed-then-clean arm`,
nothing uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output (sweep + gate
  leg) · deviations (each one-line justified) · new questions for the decision
  sheet.
