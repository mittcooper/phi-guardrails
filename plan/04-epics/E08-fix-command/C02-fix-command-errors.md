# E08-C02 · PCKFixCommand: construction and error paths   [depends: — · parallel: yes (disjoint with E08-C01 only)]

GOAL      Land `PCKFixCommand`'s state machine skeleton: the `rule:packages:`
          constructor with the not-autofixable guard, the apply-before-preview
          error, and `changes` in its pre-preview state — the three-error
          vocabulary wired to real signals.

TRACE     R-12 (invocation half — the explicit, preview-first fix path) ·
          ch. 3 §3.3 (constructor + error roster) · ch. 1 §1.3 (fix-invocation
          protocol shape, D-53.4/D-54.2) · D-06 (mandatory preview) ·
          P-FIX-PREVIEW (first of its three named tests lands here).

## CONTEXT DIGEST

**What this class is.** `PCKFixCommand` — package `Phi-Coding-Kit-Rules` — is
the coding kit's implementation of the SDK's generic fix-invocation protocol
(D-53.4: construct → `previewOn:` → `apply` → `changes`, staleness detection
required), realized over methods and the refactoring engine. It is the **only**
framework code path that mutates client source; the gate never invokes it
(P-FIX-GATE-WALL — no deliverable here touches `-Gate`). The protocol, frozen
at M1 (spec ch. 3 §3.3, verbatim):

```smalltalk
fix := PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Toy-Core').
fix previewOn: aWriteStream.   "mandatory first step"
fix apply.                     "only after a preview was emitted"
fix changes.                   "the pending/applied change objects, inspectable"
```

**This chunk builds the constructor and error paths only** — `previewOn:` is
E08-C03's, `apply`'s real body (staleness, execution) is E08-C04's. Here
`apply` implements exactly its guard clause; `previewOn:` does not exist yet.

**Constructor contract (§3.3):** `rule:packages:` — named constructor; the rule
class must answer `isRewriteRule` true, else signal `PGRNotAutofixable`
(reason wording along the lines of 'check has no autofix' — human-facing, not
an API; tests catch by class only). Not a configuration error: the artifact is
not at fault when a caller hands the fix command a flag-only rule. Store the
rule class and the handed package names (copy the collection to `Array` — the
E02 no-shared-mutable-state precedent).

**⟨verify-in-image⟩ (P5) — probe live before use, record in the completion
report:** which side answers `isRewriteRule` — D-15 verified the selector in
the `ReNodeRewriteRule` API but not its side; ch. 3 says "the rule class must
answer" it. Candidates: class-side `aRuleClass isRewriteRule`, or instance-side
via `aRuleClass new isRewriteRule`. Use whichever form the live image confirms;
E08-C05 reuses your recorded form.

**The three errors (frozen E02 `-SDK` vocabulary — direct `Error` subclasses,
catchable by class, mutually disjoint; already committed):**
`PGRNotAutofixable` · `PGRFixNotPreviewed` · `PGRFixStale`. Signal with
`signal: 'one-line reason'`; never assert wording in tests.

**State machine (this chunk's slice):**

- fresh instance: not previewed, no pending changes;
- `changes` → an empty `Array` (agent call, veto-open — "the pending/applied
  change objects" reads as empty before any preview);
- `apply` → signal `PGRFixNotPreviewed` ("mandatory first step" is D-06's
  machine-checkable meaning: for a headless agent invocation the preview lands
  in its transcript/log before anything changes);
- instance variables: `rule`, `packages`, and `pendingChanges` (initialized
  empty — `changes` answers it; E08-C03 fills it at preview time); the
  previewed/applied state flags are C03/C04's to add, not yours; private
  setters, class-side named constructor (Pharo idiom rule).

**The flag-only rule for the red arm:** `ReCodeCruftLeftInMethodsRule` ships
with Pharo and is flag-only by catalog entry (§3.2b: "the fix deletes
statements, which is never a safe automatic rewrite") — it is not a rewrite
rule, so construction over it must signal. The rewrite rule for the green arm:
`PCKNoIsNilIfTrueRule` (committed at E06 C13 — `ReNodeRewriteRule` subclass,
class-side `severity ^ #error`).

**Constitution rules that bite here:** class-side named constructors over
`new`+setters; no global state; glossary — gate-runnable things are *checks*,
and this command is not one (it is invoked explicitly, never by the gate);
comments state constraints the code cannot show; a test that cannot fail is a
defect; touching any file outside the manifest is a review rejection.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and
export to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `bash tools/build-image.sh` load from
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Coding-Kit-Rules/PCKFixCommand.class.st` — new class: class comment
  (the §3.3 role in two or three sentences, citing D-06/D-53), class-side
  `rule:packages:` with the `PGRNotAutofixable` guard, instance-side `changes`
  and the guard-only `apply`, private setters.
- `src/Phi-Coding-Kit-Tests-Rules/PCKFixCommandTest.class.st` — new test class
  (home `Phi-Coding-Kit-Tests-Rules`, beside the machinery it tests — the E06
  `PCKKitTest` residency precedent, recorded as an agent call in `chunks.md`).
- LOC budget: target 90 / ceiling 200.

## TESTS FIRST

Test methods on `PCKFixCommandTest`:

- `testFlagOnlyRuleSignalsNotAutofixable` — **given** the shipped flag-only
  `ReCodeCruftLeftInMethodsRule` / **when** `PCKFixCommand rule:
  ReCodeCruftLeftInMethodsRule packages: #('Phi-Coding-Kit-Tests-Rules')` /
  **then** `PGRNotAutofixable` is signalled (`should:raise:`, caught by class —
  never by wording).
- `testApplyWithoutPreviewSignals` — **given** a freshly constructed command
  over `PCKNoIsNilIfTrueRule` and `#('Phi-Coding-Kit-Tests-Rules')` / **when**
  `apply` with no prior `previewOn:` / **then** `PGRFixNotPreviewed` is
  signalled — **P-FIX-PREVIEW leg 1** (ch. 9's named test, verbatim name).
- `testChangesEmptyBeforePreview` — **given** the same fresh command
  (construction over a rewrite rule succeeds — this test also witnesses the
  guard's green arm) / **then** `changes` answers an empty collection and no
  error is signalled.

Fixtures: none new — both rules are already loaded (catalog rule committed at
C13; built-in ships with Pharo).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 3 new `PCKFixCommandTest`
          methods plus every previously accepted suite; ≥91 run (the 88
          cut-time accepted tests + this chunk's 3); accepted E08 siblings and
          parallel-track (E05/E07) suites add to the count — membership +
          floor, never an exact ceiling.

OUT OF SCOPE
- `previewOn:` (E08-C03) and `apply`'s staleness/execution body (E08-C04) —
  here `apply` is exactly the guard.
- The capability pair on `PCKLintRuleCheck` (E08-C05).
- Any edit to `PCKLintRuleCheck`, the SDK error classes, `PCKKitTest` (E07's
  file), `package.st` files, or the baseline.
- A fourth error class or any SDK amendment — the E02-frozen roster is exactly
  three fix errors.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files,
          one commit `E08-C02: PCKFixCommand construction and error paths`
          (qualified ID, D-73) before reporting for review; nothing left
          uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · the
  confirmed `isRewriteRule` side/form (P5 record duty — E08-C05 reuses it) ·
  deviations from the work order (each with one-line justification) · new
  questions for the decision sheet.
