# E04-C02 · PGRRegistration: wrapping and run semantics    [E04 · depends: E04-C01 · parallel: no]

GOAL      Land `PGRRegistration` — the fully internal engine wrapper around one
          spec — whose `run` answers a stamped verdict: delegated when resolved,
          red on an unhandled check exception (D-21), missing when unresolved.

TRACE     ch. 1 §1.3 (`PGRRegistration` row: `fromSpec:` · `name` · `kind` ·
          `isResolved` · `run` → `PGRVerdict`; fully internal, D-54) · §1.4 run
          flow (error→red conversion, stamping) · §1.5 (missing is a verdict,
          not an exception) · R-06 (missing half) · R-42 · D-21 · D-32 ·
          P-ERR-IS-RED (registration arm — its ch.-9-named test lands here) ·
          P-GATE-MISSING (core half — machinery only; the named property tests
          are E05's/E07's, recorded in chunks.md).

## CONTEXT DIGEST

**What exists.** From E04-C01 (in `Phi-Guardrails-Tests-Core`):
`PGRScratchGreenCheck packages:` (run → green verdict, kind `#scratch`, canFix
false), `PGRScratchRedCheck` (run → red with one finding, message `'planted
scratch violation'`), `PGRScratchErroringCheck` (run signals `Error` with
description including `'scratch check exploded'`). From frozen E02 `-SDK`
ground (verbatim):

- `PGRRegistrationSpec` — class `name:kind:check:` · `missing:kind:reason:`;
  instance `name` · `kind` · `check` (nil on missing) · `missingReason` (nil on
  resolved). A dumb value; validation is the engine's (C04), never the spec's.
- `PGRVerdict` — class `missingReason: aString` (→ status `#missing`, reason
  stored) · `redFindings: aCollection` · `green`; instance `status` ·
  `isGreen` · `findings` · `registrationName` · `kind` · `durationMillis`, and
  the **internal reader** `missingReason` (recorded E02 agent call: stored for
  E05's report rendering). **Internal engine-stamping setters** (protocol
  `'internal - engine stamping'`, recorded at E02 explicitly for E04 to
  consume): `registrationName: aString` · `kind: aSymbol` ·
  `durationMillis: anInteger`.
- `PGRFinding` — class `target:message:`; instance `target` · `message`.
- `PGRVerdict class>>skipped` exists but is **engine-only for partial-run
  report construction** (D-21/D-32): no code this chunk writes sends it — a
  completed run never emits `#skipped`.

**The new class — `PGRRegistration`, package `Phi-Guardrails-Core`, fully
internal (no frozen surface, D-54):**

- Class-side constructor `fromSpec: aRegistrationSpec` — copies `name`, `kind`,
  `check`, `missingReason` out of the spec (the spec is boundary information;
  this class is engine mechanism).
- Instance readers `name` · `kind`; `isResolved` → true iff the check is
  non-nil.
- `run` → a `PGRVerdict`, always — never an exception escape, never nil:
  - **unresolved:** `PGRVerdict missingReason: missingReason` — missing is a
    verdict, not an exception (§1.5); the run completes and the gate (E05)
    turns it into a nonzero exit.
  - **resolved:** delegate to the check's argument-less `run`; an unhandled
    `Error` from it converts to `PGRVerdict redFindings: { one PGRFinding }`
    (D-21: "engine crashed" blocks exactly like "check failed"). Finding shape
    (agent call, veto-open — recorded in chunks.md): `target:` = the check's
    class name, `message:` = the error's description.
  - **stamping, on every verdict answered** (missing included): send the E02
    internal setters — `registrationName:` name, `kind:` kind,
    `durationMillis:` the elapsed integer milliseconds of the `run` (0 is fine
    for the missing arm's near-instant path — the assertion is integer ≥ 0,
    never a magnitude).
- Duration spelling ⟨verify-in-image⟩, delegated to the implementer with
  record-in-report duty (the E06 precedent): candidate
  `Time millisecondsToRun: [ … ]`; any substitute must answer integer
  milliseconds. Confirm in the work image before use; record the spelling in
  the completion report.

**Constitution rules that bite here:** no global state (a registration is
per-run, constructed by the registry each `fromConfiguration:` — nothing
cached); class-side named constructor `fromSpec:` over `new`+setters; no
`isKindOf:`/`class ==` (resolvedness is `check` nil-ness, not a type test);
comments state constraints the code cannot show; R-04 — no SUnit/Renraku/RB
reference anywhere in `-Core`.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export
to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present,
D-15); hand-writing class files is not allowed — the committed form must be what
the tooling emits. After export, a fresh `tools/build-image.sh` load from the
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Guardrails-Core/PGRRegistration.class.st` — create (class comment
  states: fully internal, wraps one spec, D-54; check authors never see it).
- `src/Phi-Guardrails-Tests-Core/PGRRegistrationTest.class.st` — create (the
  six tests below).
- LOC budget: target 120 / ceiling 200.

## TESTS FIRST

Test methods on `PGRRegistrationTest`:

- `testResolvedSpecWrapsResolved` — given
  `PGRRegistrationSpec name: 'scratch/G1' kind: #scratch check:
  (PGRScratchGreenCheck packages: #('P1'))` / when `fromSpec:` / then `name` =
  `'scratch/G1'`, `kind` = `#scratch`, `isResolved` true.
- `testMissingSpecWrapsUnresolved` — given
  `PGRRegistrationSpec missing: 'scratch/M1' kind: #scratch reason: 'engine
  absent'` / when wrapped / then `isResolved` false, `name`/`kind` preserved.
- `testRunStampsVerdict` — given the wrapped green-check spec / when `run` /
  then the verdict `isGreen`, `registrationName` = `'scratch/G1'`, `kind` =
  `#scratch`, `durationMillis` is an Integer ≥ 0.
- `testRedVerdictPassesThrough` — given a wrapped red-check spec / when `run` /
  then `status` = `#red`, exactly one finding with message `'planted scratch
  violation'` (the check's verdict, stamped, otherwise untouched).
- `testMissingRunAnswersMissingVerdict` — **P-GATE-MISSING, core half's
  machinery witness** — given the missing spec above / when `run` / then
  `status` = `#missing`, internal `missingReason` = `'engine absent'`, and all
  three stamps present (missing is a verdict, not an exception — §1.5).
- `testErroringCheckYieldsRed` — **the ch.-9-named P-ERR-IS-RED registration
  arm** — given a wrapped erroring-check spec / when `run` / then no exception
  escapes, `status` = `#red`, and one finding whose message includes
  `'scratch check exploded'`; stamps present.

Fixtures: E04-C01's scratch checks; specs built inline — no configuration, no
STON, no registry needed at this stage.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 6 new `PGRRegistrationTest`
          methods, the 7 `PGRScratchCheckFixturesTest` methods, **plus every
          previously accepted suite** — membership plus a floor (≥ 101 run),
          never an exact ceiling.

OUT OF SCOPE
- `PGRRegistry` and everything configuration-driven — C03.
- Conformance / kind-agreement / duplicate validation — C04 (a registration
  trusts the spec it is handed; strictness happens before wrapping).
- Emitting `#skipped` anywhere (engine-only partial-run reserve, D-21/D-32 —
  no v1 code path).
- Validating what a check's `run` answers (a non-verdict answer is undefined
  behavior at this layer; protocol conformance is C04's, on selectors).
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `E04-C02: PGRRegistration wrapping and run semantics` (D-73)
          before reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet · the verified duration spelling (P5
  record duty).
