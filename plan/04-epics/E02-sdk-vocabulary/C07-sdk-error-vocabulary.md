# C07 · SDK error vocabulary      [E02 · depends: — · parallel: yes]

GOAL      Land the four frozen SDK error classes — `PGRConfigurationError`,
          `PGRNotAutofixable`, `PGRFixNotPreviewed`, `PGRFixStale` — each an `Error`
          subclass catchable by class, with the tests that pin catchability,
          reason-carrying, and mutual disjointness.

TRACE     R-04 (boundary half — engine-free vocabulary) · spec ch. 1 §1.3
          (`PGRConfigurationError` row) · ch. 3 §3.3 (the three fix-invocation
          errors) · ch. 0 §0.1/§0.3 (class inventory; surfaces) · D-53 (SDK
          vocabulary), D-54.4 (`PGRNotAutofixable` rename), D-60 ruling 1
          (signalling-side grants).

## CONTEXT DIGEST

**What exists (E01, frozen):** `src/Phi-Guardrails-SDK/` and
`src/Phi-Guardrails-Tests-SDK/` are empty package stubs (`package.st` only) in the
frozen 21-directory inventory; `BaselineOfPhiGuardrails` already groups them
(production / tests roles). Adding classes to existing packages touches no frozen
surface; the baseline is **not** edited.

**The four classes — all direct `Error` subclasses in `Phi-Guardrails-SDK`, no
state beyond the inherited `messageText` ("an `Error` subclass carrying a one-line
reason" — the reason is the text handed to `signal:`; its wording is human-facing
and explicitly not an API):**

| Class | Meaning (class comment must carry this) | Signalled by (later epics) | Caught by |
|---|---|---|---|
| `PGRConfigurationError` | a defect in the configuration artifact or its use: unknown key, malformed block, duplicate registration name, undeclared kit class, nonconforming check; the gate run fails before producing a report | core validation (E03/E04); a kit that cannot resolve or validate its own block (D-60); a check whose construction-time parameters are invalid (D-60) | any caller, by class |
| `PGRNotAutofixable` | fix invocation on a check that has no autofix — *not* a configuration error: the artifact is not at fault when a caller hands the fix command a flag-only rule (ch. 3 §3.3) | the fix-invocation implementation (E08) | fix invoker, by class |
| `PGRFixNotPreviewed` | `apply` before `previewOn:` ran on the same command instance — the machine-checkable meaning of D-06's mandatory preview | the fix-invocation implementation (E08) | fix invoker, by class |
| `PGRFixStale` | a fix target changed between preview and apply; nothing was applied — the diff the invoker confirmed is the diff that applies | the fix-invocation implementation (E08) | fix invoker, by class |

**Flatness is contract:** none of the four subclasses another of the four —
catching one class must never swallow a sibling (catch-by-class precision). All
four are direct subclasses of `Error`.

**This chunk ships classes only, no signalling sites** — the sites land with their
owners (E03+). The tests signal directly to prove the contract.

**Constitution rules that bite here:**
- *Naming:* framework classes in `-SDK` are prefixed `PGR`; glossary terms exactly
  ("configuration error" is the artifact-defect concept, never "invalid config
  warning").
- *Boundary (R-04):* nothing in `Phi-Guardrails-SDK` may reference SUnit, Renraku,
  or RB classes — plain `Error` subclasses satisfy this trivially; keep it that way.
- *Comments* state constraints the code cannot show — the class comments above are
  exactly that; no method comments narrating the obvious.
- *Tests:* SUnit; a test that cannot fail is a defect; no `skip`/`expectedFailures`.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits (see `src/Phi-Guardrails-Tests-Core/PGRBaselineSmokeTest.class.st`
for the emitted shape: leading comment block, `Class { #name : … }`, per-method
`{ #category : … }` headers). After export, a fresh `tools/build-image.sh` load
from the committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds
`.build/work/phi.image` from committed `src/` (Metacello, group `CI`);
`bash tools/verify.sh` runs the pack's verify command
(`test --fail-on-failure "(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*"`) against it
and asserts the run count plus the 5 smoke tests.

## DELIVERABLES

- `src/Phi-Guardrails-SDK/PGRConfigurationError.class.st`
- `src/Phi-Guardrails-SDK/PGRNotAutofixable.class.st`
- `src/Phi-Guardrails-SDK/PGRFixNotPreviewed.class.st`
- `src/Phi-Guardrails-SDK/PGRFixStale.class.st`
- `src/Phi-Guardrails-Tests-SDK/PGRSdkErrorsTest.class.st` — one test home for the
  four near-empty classes (descriptive `PGR*Test` precedent — E01's
  `PGRBaselineSmokeTest` call; an agent call, veto-open at the spot-check).
- LOC budget: target 60 / ceiling 120.

## TESTS FIRST

Test methods on `PGRSdkErrorsTest` (fill in, watch fail — the classes don't exist
yet — then implement to green):

- `testEachErrorClassIsSignallableAndCatchableByClass` — given each of the four
  classes / when `Cls signal: 'boom'` inside `should:raise:` for that same class /
  then each raises and is caught as its own class.
- `testMessageTextCarriesTheReason` — given
  `[PGRConfigurationError signal: 'the reason'] on: PGRConfigurationError do:` /
  when reading the caught exception's `messageText` / then it equals `'the reason'`
  (the one-line-reason contract; real message *wording* is never asserted anywhere —
  not an API).
- `testErrorClassesAreDisjoint` — given the four classes / then each
  `inheritsFrom: Error` and none inherits from another of the four — catch-by-class
  stays precise.

Fixtures: none.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 3 `PGRSdkErrorsTest` methods
          **and** the 5 `PGRBaselineSmokeTest` methods (regression guard).

OUT OF SCOPE
- Any signalling site, retry logic, error codes, or state on the errors — they are
  vocabulary, nothing more.
- Every other SDK class (`PGRVerdict`, `PGRFinding`, `PGRRegistrationSpec`,
  skeletons — sibling chunks).
- Editing `BaselineOfPhiGuardrails`, any `package.st`, or anything outside the
  manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md`
          (`bash tools/precheck.sh` once C06 is accepted; else by eye — D-67).
          Postcondition: exactly the manifest files, one commit
          `C07: SDK error vocabulary` before reporting for review; nothing left
          uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
