# E14-C01 · `ToyDemoTest` scaffold: the planted-state guard and the exact-six red arm  [depends: — · parallel: no]

GOAL      Create `ToyDemoTest` in the swept `Phi-Guardrails-Tests-Toy` with D-43's
`setUp` planted-state guard and the first of the three ruled tests:
`testGateIsRedOnPlantedViolations` — one gate run over the toy's own committed
artifact answers **exactly** six verdicts, in registry order, every one red, each
naming its planted target.

TRACE     R-32 (demonstration half — planted violations caught by the gate) ·
R-43 (demo half — the architecture registration red on the planted reach) ·
R-44 (the behavioral registrations red on the failing test and the skip) ·
spec ch. 8 §8.3 (the test class, its home, the exact-count law) · P-GATE-RED
(ch. 9 — discharged by this test plus the D-43 protections) · D-43 (the `setUp`
guard; the `ensure:` restoration half lands at E14-C02 with the first mutation) ·
D-46 (the home: `Phi-Guardrails-Tests-Toy`, an ordinary swept tests-role package;
the nesting/termination argument) · D-26/D-57 (the committed red state this test
reads).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**What this chunk builds.** E12 committed the toy client red: six planted
violations, each already witnessed live at check level. This chunk adds the
**gate-level** demonstration the roadmap reserved for E14: a fresh, in-image gate
run over the toy's own configuration artifact, asserted to answer exactly the six
red verdicts. No source mutation happens in this chunk — the mutation arms are
E14-C02/C03; this chunk lays down the class, the guard, and the red baseline.

**The frozen surfaces this chunk calls (verbatim; all re-probed at cut time —
probes.md P1/P2/P7):**

- `PGRConfiguration class>>fromString: aSTONString` → a configuration (E03; strict
  parse — the toy artifact is valid, accepted E12 ground).
- `PGRGate class>>forConfiguration: aPGRConfiguration` → a gate instance; instance
  `run` → a `PGRReport`. **One `forConfiguration:` per gate run, always fresh**:
  the registry (and the behavioral suite-run cache inside it) is built per
  construction — reusing a gate across runs would replay stale suite results
  (accepted E07 cache law: one cache per registry build).
- `PGRReport>>verdicts` (Array of `PGRVerdict`, registry order) · `isClean`
  (true iff every verdict green) · `exitCode` (0 clean, else 1) ·
  `blockingVerdicts` (every non-green verdict) — all fresh-copy readers (E05).
- `PGRVerdict>>registrationName` · `isGreen` · `findings` (Array of `PGRFinding`);
  `PGRFinding>>target` · `message` (E02).
- `BaselineOfToy class>>guardrailsSTON` — the committed toy artifact (E12, frozen);
  read it with `fromString:` (a `fromString:` config has no directory — by design,
  D-45/D-18).

**The frozen six-registration shape (E12 digest; probed in order, P1):**

```
'lint/PCKNoIsNilIfTrueRule'
'lint/ReCodeCruftLeftInMethodsRule'
'lint/ToyNoIsNilIfFalseRule'
'architecture/PCKLayerMapCheck'
'behavioral/Toy-Tests'
'behavioral/PCKNoSkippedTestsMetaRule'
```

**The frozen plant inventory and each plant's marker + expected finding target
(E12 digest; probed, P2/P3/P8):**

| # | Home (class>>selector) | Source marker (guard; body-distinguishing) | Expected finding target (probed) |
|---|---|---|---|
| 1 | `ToyOrder>>#totalOrZero` | `'items isNil ifTrue:'` | `'ToyOrder>>#totalOrZero'` |
| 2 | `ToyOrder>>#logTotal` | `'Transcript show: self total'` | `'ToyOrder>>#logTotal'` |
| 3 | `ToyOrder>>#itemCountOrZero` | `'items isNil ifFalse:'` | `'ToyOrder>>#itemCountOrZero'` |
| 4 | `ToyOrderView>>#storeSnapshot` | `'ToyOrderStore empty'` | `'ToyOrderView>>#storeSnapshot'` |
| 5 | `ToyOrderTest>>#testTotalIsFortyTwo` | `'equals: 42'` | `'ToyOrderTest>>#testTotalIsFortyTwo'` |
| 6 | `ToyOrderTest>>#testSkippedOnPurpose` | `'self skip:'` | `'ToyOrderTest>>#testSkippedOnPurpose'` |

Row *i*'s expected target belongs to registration *i* of the six above — the
pairing the demo asserts. **The markers are body-distinguishing by construction
(probed, P8):** each plant method's comment names its own plant (D-26's committed
plant comments), so a naive marker like `'isNil ifTrue:'` would be satisfied by
the surviving comment even after the body is fixed — the fix command preserves
comments (P4/P8). Every marker above is probed present in the committed body and
**absent from the comment**, and absent from every C03 fixed source — so the
guard genuinely tracks the body, on every mutation path. (Some targets render as
Symbols in-image; `#'X' = 'X'` holds — the accepted `PGRToyPlantWitnessTest`
comparison precedent. Compare with `=`/`anySatisfy:` against String literals.)

**The `setUp` guard (D-43 item 2, this chunk's second deliverable).** Ruled text:
"Before each test, the toy is checked to be in its expected planted (all-red)
condition. A leak from any source — a failed restoration, an interrupted run, a
Playground session, a future test — then fails loudly at its cause instead of
surfacing as a confusing failure elsewhere." Implementation: the guard asserts, for
each of the six rows above, that the method's **current `sourceCode` contains its
body-distinguishing marker** (`(class >> selector) sourceCode includesSubstring:
marker` — probed P3/P7/P8) with an `assert:description:` naming the offending
`Class>>#selector` (probed P7) — source recompilation is the demo's only mutation
vector, and the markers are probed to track the plant *body* on every mutation
path (P8: present committed, absent from the surviving comment after the fix arm,
absent from every C03 fixed source), so a leak fails loudly naming the leaked
method directly ("at its cause").
The guard runs in `setUp` (after `super setUp`) and therefore protects all three
tests, including the two later chunks add to this class.

**The exact-count law (ch. 8 §8.3, verbatim rationale — the one place a count is
exact, per the ruled design):** "The exact count is asserted deliberately: when the
recommended block grows at M5 and the toy's artifact composes the new entries in,
this test breaks, and that is the intended behavior — a new shipped check must
arrive with a decision about how the toy demonstrates it, not slip in unnoticed
behind a `>=` assertion."

**Termination (D-46, why this class may live in a swept package):** recursion
needs the *target config's* tests role to contain the package holding the
gate-driving test. The demo runs the gate on the **toy's** config, whose tests
role is only `Toy-Tests` — `Phi-Guardrails-Tests-Toy` can never enter that set. A
framework self-hosted run *nests* (outer gate → behavioral check runs `Tests-Toy`
→ this test runs an inner gate on the toy config → the inner run's behavioral
check runs `Toy-Tests`, which drives no gate → terminates); it does not recurse.
From this chunk on, the self-hosted regression leg exercises that nesting live —
expected: still exit 0, still 12 registrations, merely slower.

**§8.1 residual caveat (law):** the demo runs the gate over the TOY's
configuration only — never over the framework's own `guardrails.ston` from inside
a swept test.

**Constitution rules that bite here:** tests assert behavior (every assertion
below would fail on a leaked or missing plant); no `skip`/`expectedFailures` in
this tests-role package; class-side named constructors are consumed, never
`new`+setters; comments state constraints the code cannot show; touching any file
outside the manifest is a review rejection. Glossary: gate-runnable things are
**checks**; non-blocking findings are **advisories**.

DELIVERABLES

Files (Tonel):
- **create** `src/Phi-Guardrails-Tests-Toy/ToyDemoTest.class.st` — class
  `ToyDemoTest`, superclass `TestCase`, package `Phi-Guardrails-Tests-Toy`.
  (The class name is §8.3's and the frozen roadmap row's spelling; D-43's older
  `PGRToyDemoTest` rendering predates the D-45/D-46 reshape of ch. 8 —
  superseded prose, not a live question; the call is recorded veto-open in the
  epic index.)

Methods:
- `setUp` — `super setUp`, then the six-row planted-state guard (D-43 item 2).
- `plantedShapes` (helper) — the six `{class. selector. marker}` triples of the
  table above, one literal-array-of-triples answer; the single source both the
  guard and later chunks' snapshot lists read.
- `runToyGate` (helper) —
  `^ (PGRGate forConfiguration: (PGRConfiguration fromString: BaselineOfToy guardrailsSTON)) run`
  — a fresh gate (fresh registry, fresh suite cache) per send.
- `expectedRegistrationNames` (helper) — the six-name Array, in order, verbatim.
- `testGateIsRedOnPlantedViolations` (the contract skeleton below).
- Class comment: the demo's role (§8.3), the D-43 protections, the D-46
  termination argument condensed, and the exact-count rationale.

LOC budget: target ~120 · ceiling 300.

TESTS FIRST  (`ToyDemoTest`, package `Phi-Guardrails-Tests-Toy`)

- `testGateIsRedOnPlantedViolations` — **given** the committed toy in its planted
  state (guaranteed by `setUp`) and its own frozen artifact; **when** one fresh
  gate runs over it (`self runToyGate`); **then**:
  1. the report is not clean (`deny: report isClean`) and `exitCode` = 1;
  2. `report verdicts size` = **6** — exact, never a floor (the §8.3 exact-count
     law; the one ruled exception to the floors-only rule);
  3. `(report verdicts collect: [:v | v registrationName]) asArray` equals the
     six names of `expectedRegistrationNames`, in order;
  4. `report blockingVerdicts size` = 6 — every registration red, none green,
     none missing-but-unnoticed;
  5. for each verdict *i*, its `findings` contain the expected target of row *i*
     (`anySatisfy: [:f | f target = <target>]`) — each red names its planted
     target precisely (§8.3).

Fixtures: the toy's committed plants (they ARE the fixture — D-26); the committed
`BaselineOfToy class>>guardrailsSTON`. Nothing new.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors —
          `ToyDemoTest>>#testGateIsRedOnPlantedViolations` listed by name, every
          previously accepted suite green — ≥264 run (263 accepted at cut + this
          1); membership + floor, never an exact ceiling (the exactness lives
          INSIDE the test, on the demo's six verdicts, per the ruled design).
          **Plus the self-hosted regression leg:**
          `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
          → exit 0, **12 registrations unchanged**, `GATE: GREEN` — E14 adds
          nothing to the framework's artifact. Note: from this chunk on that leg
          **nests** — `behavioral/Phi-Guardrails-Tests-Toy` (probed present, P6)
          now runs this class, which runs an inner gate over the toy config; it
          terminates by the D-46 argument above. Slower is expected; non-zero or
          a hang is a stop-and-report.

OUT OF SCOPE
- Any mutation of toy source, the `ensure:` restoration helper, the fix arm, the
  all-fixed arm (E14-C02/C03).
- Running the gate over the framework's own `guardrails.ston` from inside any
  swept test (the §8.1 residual caveat — law).
- Touching the toy's packages, the witness/pin tests, `guardrails.ston`,
  `.smalltalk.ston`, `ci.yml` (CI stays step 1 — E15's ground), or any accepted
  test file.
- Weakening the exact-six assertion to a floor (P6; the exactness is ruled).

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67).
Postcondition: one commit `E14-C01: ToyDemoTest — planted-state guard + the
exact-six red arm`, nothing uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output (sweep + gate
  leg) · deviations (each one-line justified) · new questions for the decision
  sheet.
