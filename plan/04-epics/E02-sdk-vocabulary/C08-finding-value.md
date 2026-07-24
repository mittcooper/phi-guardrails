# C08 · PGRFinding value      [E02 · depends: — · parallel: yes]

GOAL      Land `PGRFinding` — the frozen violation/advisory value: two class-side
          constructors, three readers, and a human-facing (non-API) `printOn:`.

TRACE     spec ch. 1 §1.3 (`PGRFinding` row) · ch. 0 §0.3 (blessed data-crossing:
          check author constructs, caller reads) · glossary *finding* / *advisory* ·
          D-48 (`printOn:` is rendering — explicitly not an API, on no surface) ·
          R-04 (boundary half).

## CONTEXT DIGEST

**What exists (E01, frozen):** `src/Phi-Guardrails-SDK/` and
`src/Phi-Guardrails-Tests-SDK/` are package stubs in the frozen 21-directory
inventory; the baseline already groups them and is **not** edited.

**The class — `PGRFinding` in `Phi-Guardrails-SDK`, a «value» of the boundary
vocabulary.** Frozen surface (freezes at E02 acceptance; from ch. 1 §1.3, verbatim):

- class side (check author): `target:message:` · `target:message:rationale:`
- instance side (caller, reading): `target` · `message` · `rationale`

Meaning (class comment carries this): one blocking violation *or* one non-blocking
advisory inside a verdict — which of the two it is belongs to the verdict that
carries it (`findings` vs `advisories`), not to this object. `target` is the
precisely printed offender (e.g. `'Class>>#selector'` — R-20's precision is the
producing check's duty, not validated here); `message` says what is wrong;
`rationale` is the rule's rationale where one exists — **`nil` when constructed via
`target:message:`** (glossary: "the rule's rationale where one exists").

**Design constraints:**
- Class-side named constructors over `new`+setters (constitution idiom); private
  instance-side setters used only at construction sit in a browser protocol marked
  private.
- Values are dumb: **no validation** in constructors — strictness is the engine's
  concern (E03/E04), never the vocabulary's.
- `printOn:` renders target and message (and the rationale when present) for human
  eyes. It is explicitly **not** an API: the test asserts *content inclusion*
  (substrings), never exact wording or format.
- Contract methods sit in browser protocols named for their surface (D-53
  convention, unenforced): constructors under e.g. `'instance creation'`, readers
  under `'accessing'`, `printOn:` under `'printing'`.
- R-04: nothing in `-SDK` references SUnit/Renraku/RB classes.

**Constitution rules that bite here:** `PGR` prefix; glossary terms exactly (a
finding is never an "issue"/"criticism"; a non-blocking one is an *advisory*, never
a "warning"); no global state; comments state constraints code cannot show; SUnit
tests, no `skip`/`expectedFailures`, a test that cannot fail is a defect.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits (see `src/Phi-Guardrails-Tests-Core/PGRBaselineSmokeTest.class.st`
for the emitted shape). After export, a fresh `tools/build-image.sh` load from the
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it
and asserts run count plus the 5 smoke tests.

## DELIVERABLES

- `src/Phi-Guardrails-SDK/PGRFinding.class.st` — the value class as specified.
- `src/Phi-Guardrails-Tests-SDK/PGRFindingTest.class.st` — its mirror test.
- LOC budget: target 70 / ceiling 140.

## TESTS FIRST

Test methods on `PGRFindingTest`:

- `testTargetMessageConstructor` — given
  `PGRFinding target: 'Foo>>#bar' message: 'does the wrong thing'` / when reading /
  then `target` and `message` answer exactly what was handed and `rationale` is
  `nil`.
- `testTargetMessageRationaleConstructor` — given the three-part constructor / when
  reading / then all three readers answer exactly what was handed.
- `testPrintStringNamesTargetAndMessage` — given a finding with a rationale / when
  taking `printString` / then it includes the target substring, the message
  substring, and the rationale substring — and no exact-format assertion is made
  (rendering is not an API).

Fixtures: none.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 3 `PGRFindingTest` methods and the
          5 `PGRBaselineSmokeTest` methods (regression guard; plus any sibling
          chunks' tests already accepted).

OUT OF SCOPE
- Validation of target format (R-20 precision is the producing checks' duty —
  E06/E10), equality/hashing beyond identity, serialization.
- `PGRVerdict` (C09 — it carries findings; this chunk does not reference it).
- Editing the baseline, any `package.st`, or anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md`
          (`bash tools/precheck.sh` once C06 is accepted; else by eye — D-67).
          Postcondition: exactly the manifest files, one commit
          `C08: PGRFinding value` before reporting for review; nothing left
          uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
