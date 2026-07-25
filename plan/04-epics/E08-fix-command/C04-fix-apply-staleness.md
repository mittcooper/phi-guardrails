# E08-C04 · PCKFixCommand: apply and the staleness guard   [depends: E08-C03 · parallel: no]

GOAL      `apply` re-reads every pending change's target and signals
          `PGRFixStale` (applying nothing) on any drift from the previewed
          source, otherwise executes each pending change via the refactoring
          engine and answers the applied change objects — one command instance,
          one invocation.

TRACE     R-12 (invocation half) · R-15 (the autofix, apply leg) · ch. 3 §3.3
          (`apply` contract) · D-34.2 (the stale-apply guard) · D-06 (the
          confirmed diff is the applied diff) · D-42 (framework self-targeting
          allowed — context only) · P-FIX-PREVIEW (legs 2 and 3 land here).

## CONTEXT DIGEST

**What exists when this chunk starts:** E08-C03 accepted — `PCKFixCommand`
holds, after `previewOn:`, its `pendingChanges` (the critiques' change
objects, `RBAddMethodChange`s), a previewed-state flag, and `changes`
answering the pending objects; `apply` still signals `PGRFixNotPreviewed`
unconditionally when no preview has run (E08-C02's guard). The E02-frozen
errors `PGRFixStale` / `PGRFixNotPreviewed` are committed `-SDK` classes,
catchable by class.

**The `apply` contract (spec ch. 3 §3.3 + D-34.2, condensed inline — the
whole of it):**

1. Guard: no preview on this instance → `PGRFixNotPreviewed` (already C02's).
2. **Staleness re-read:** for every pending change, re-read the target
   method's **current** source; if any differs from the source the preview
   showed (the change's `oldVersionTextToDisplay`, D-15), signal `PGRFixStale`
   and apply **nothing** — all-or-nothing; the diff the invoker confirmed is
   the diff that applies (D-06's substance). A stale command is discarded; a
   new fix run is a new instance with a new preview.
3. Execute each pending change via the refactoring engine: `change execute`
   (verified D-15 — it recompiled the method, before/after source checked).
   Every change is an ordinary recompile: Epicea-recorded, listed in
   `RBRefactoryChangeManager`'s undo history (no code here manages that —
   stated for the class comment).
4. Answer the applied change objects; `changes` continues to answer them.
   Re-running `apply` on this instance is an error — signal
   `PGRFixNotPreviewed` (agent call, veto-open, recorded in `chunks.md`: one
   preview authorizes one apply, so the second `apply` finds its preview
   consumed; the frozen SDK roster is exactly three fix errors, so no new
   class may be minted).

**⟨verify-in-image⟩ (P5) — probe live before use, record in the completion
report:** how to reach the target method's current source from an
`RBAddMethodChange` — candidates: `change changeClass` + `change selector` →
`(changeClass >> selector) sourceCode`. And the comparison form: whether the
unmutated method's current `sourceCode` is textually identical to the change's
`oldVersionTextToDisplay` (whitespace/formatting drift between the two
renderings is the known subtlety — the roadmap's E08 risk row). The two
acceptance instruments decide: the green arm (`testPreviewThenApplyRewrites`)
must pass with **no** stale signal on an untouched fixture, and the red arm
(`testStaleApplySignals`) must signal on a real mutation. Record the confirmed
accessor chain and comparison.

**The plant and its saved-source discipline (ch. 9 P-FIX-PREVIEW, verbatim
duty):** "The rewrite test saves the fixture method's source in `setUp` and
recompiles it in `tearDown` — the fixture must be bad again for whatever test
runs next (idempotence)." The plant, committed at C13:

```smalltalk
PCKLintBadFixture >> withIsNilIfTrue
    | x |
    x := nil.
    x isNil ifTrue: [ ^ #bad ].
    ^ #good
```

`setUp` snapshots `(PCKLintBadFixture >> #withIsNilIfTrue) sourceCode` into an
instance variable; `tearDown` recompiles the snapshot back **when the current
source differs** (candidates: `PCKLintBadFixture compile:` /
`compile:classified:` — preserve the method's protocol; ⟨verify-in-image⟩,
record the confirmed form). This runs for every test in the class — harmless
for C02/C03's non-mutating tests, load-bearing for this chunk's.

**Constitution rules that bite here:** the framework never mutates client code
except through this explicit, preview-first command (mutation discipline —
this chunk is the one sanctioned mutation site, and its tests restore what
they mutate via `tearDown`); no global state; a test that cannot fail is a
defect; never assert error wording, only the class; touching any file outside
the manifest is a review rejection.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and
export to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `bash tools/build-image.sh` load from
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Coding-Kit-Rules/PCKFixCommand.class.st` — `apply`'s real body
  (staleness re-read → execute → applied state), the applied-state flag,
  `changes` post-apply behavior; class comment gains the Epicea/undo sentence
  and the one-instance-one-invocation rule.
- `src/Phi-Coding-Kit-Tests-Rules/PCKFixCommandTest.class.st` — `setUp` /
  `tearDown` (saved-source discipline) + the three tests below.
- LOC budget: target 115 / ceiling 250.

## TESTS FIRST

New test methods on `PCKFixCommandTest` (C02/C03's six stay green under the
new `setUp`/`tearDown`):

- `testPreviewThenApplyRewrites` — **given** a command over
  `PCKNoIsNilIfTrueRule` and `#('Phi-Coding-Kit-Tests-Rules')`, previewed onto
  a scratch `WriteStream` / **when** `apply` / **then** the plant's current
  `sourceCode` contains `'ifNil:'` and no longer contains `'isNil ifTrue:'`
  (the D-04 rewrite landed), and `apply` answered a collection of exactly one
  change object; `tearDown` restores the plant — **P-FIX-PREVIEW leg 2**
  (ch. 9's named test, verbatim name).
- `testStaleApplySignals` — **given** a previewed command, then the plant
  recompiled to a *different, still-bad* body (inline in the test, e.g. the
  same method with `^ #stale` in place of `^ #bad`) / **when** `apply` /
  **then** `PGRFixStale` is signalled (by class) **and no source changed**:
  the plant's current source is still the mutated form, verbatim — stale
  applies nothing (D-34.2's all-or-nothing); `tearDown` restores the canonical
  plant — **P-FIX-PREVIEW leg 3** (ch. 9's named test, verbatim name).
- `testSecondApplySignals` — **given** a previewed command whose `apply`
  succeeded / **when** `apply` again / **then** `PGRFixNotPreviewed` is
  signalled (the agent-call reading above) and the plant's source is exactly
  what the first apply produced (nothing applied twice); `tearDown` restores.

Fixtures: C13's committed `PCKLintBadFixture`, mutated and restored per the
saved-source discipline — never left rewritten past any test's end.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists all 9 `PCKFixCommandTest`
          methods plus every previously accepted suite; ≥98 run (the 88
          cut-time accepted tests + E08-C01's 1 + E08-C02's 3 + E08-C03's 3 +
          this chunk's 3); accepted parallel-track (E05/E07) suites add to the
          count — membership + floor, never an exact ceiling. Run the sweep
          **twice in one image build** if in doubt about restoration — the
          second run must be identical (idempotence).

OUT OF SCOPE
- The capability pair (E08-C05).
- Undo machinery, `RBRefactoryChangeManager` interaction beyond what
  `change execute` does on its own — v1 fixes forward only.
- A fourth error class, any SDK edit, any `PCKLintRuleCheck` edit.
- Any edit to `PCKKitTest` (E07's file), `package.st` files, or the baseline.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files,
          one commit `E08-C04: PCKFixCommand apply and staleness guard`
          (qualified ID, D-73) before reporting for review; nothing left
          uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · the
  confirmed change→current-source accessor chain, comparison form, and
  recompile spelling (P5 record duty) · deviations from the work order (each
  with one-line justification) · new questions for the decision sheet.
