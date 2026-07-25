# E08-C03 · PCKFixCommand: previewOn: and changes   [depends: E08-C01, E08-C02 · parallel: no]

GOAL      `previewOn:` runs the wrapped rule over the target packages through
          the D-72 environment, collects each critique's change object, emits
          the per-change preview (target, old source, new source), answers the
          pending count — and `changes` exposes the pending change objects.

TRACE     R-11 (fix half) · R-15 (the autofix, preview leg) · ch. 3 §3.3
          (`previewOn:` contract) · D-06 (mandatory preview) · D-15 (change-
          object spellings) · D-72 (one attribution story across check and fix).

## CONTEXT DIGEST

**What exists when this chunk starts:** E08-C02 accepted — `PCKFixCommand`
with `rule:packages:` (guarded by `PGRNotAutofixable`), guard-only `apply`
(signals `PGRFixNotPreviewed`), `changes` answering an empty `Array`
pre-preview, instance variables `rule` (a rule class), `packages` (an `Array`
of package names), `pendingChanges`. E08-C01 accepted — the class-side
environment single-source on the lint check:

```smalltalk
PCKLintRuleCheck class >> lintEnvironmentOver: aCollectionOfPackageNames
    "The D-72 environment law, single-sourced: trait-provided methods are
     linted at each using class's package."
```

**The contract (spec ch. 3 §3.3, condensed inline — the whole of it):**
`previewOn: aWriteStream` runs the rule (as ch. 2 §2.3 steps 1–2), collects
each critique's change object, and emits per prospective change: the target
(`Class>>#selector`), the old source, the new source (the change objects'
`oldVersionTextToDisplay` / `textToDisplay` — spellings verified, D-15).
Answers the **number of pending changes**. This is D-06's machine-checkable
"mandatory preview": for a headless agent invocation, the preview lands in its
transcript/log before anything changes. `changes` answers the pending change
objects after a preview (inspectable). Preview mutates nothing — mutation is
`apply`'s monopoly (E08-C04).

**The run recipe (ch. 2 §2.3 steps 1–2, as amended by D-72 — run the rule
exactly the way the check does):**

```smalltalk
ruleInstance := rule new.
checker := ReSmalllintChecker new
    rule: { ruleInstance };
    environment: (PCKLintRuleCheck lintEnvironmentOver: packages);
    run;
    yourself.
critiques := checker criticsOf: ruleInstance.
```

(All checker spellings verified D-15/C15. Referencing `PCKLintRuleCheck` from
`PCKFixCommand` is package-internal — both live in `Phi-Coding-Kit-Rules`.)

**Critique → change (verified spellings, D-15):** critique `providesChange` →
`change` (an `RBAddMethodChange`); preview text via the change's
`textToDisplay` (new source) / `oldVersionTextToDisplay` (old source). Collect
**only** critiques answering `providesChange` true into `pendingChanges`
(keep them as the change objects — `changes` hands exactly these back). The
critiqued entity is reached as critique `entity` (confirmed C13/C15; the D-71
probe also used `sourceAnchor entity`) — its `printString` is the confirmed
`Class>>#selector` target form (C15 record).

**Emission shape:** per pending change, write to the handed stream: one target
line, the old source, the new source (labels/layout are implementer latitude —
human-facing text, explicitly not an API; the tests below assert *content*
substrings only, never layout). After emission, mark the instance previewed
(whatever state flag E08-C04's guard will read — lay it down now) and answer
`pendingChanges size`.

**Why exact-count assertions are safe here:** the only `isNil ifTrue:` **send**
in `Phi-Coding-Kit-Tests-Rules` is the declared plant
`PCKLintBadFixture>>#withIsNilIfTrue` (the stub rules' pattern strings are
literals, which no AST rule matches — C13 precedent), and the constitution
bans the idiom in all non-fixture code. The exact count doubles as a guard on
`apply`'s blast radius (E08-C04 applies *every* pending change): a second
plant appearing in this package must redden this suite loudly, never be
silently rewritten.

**The plant, verbatim (committed at C13):**

```smalltalk
PCKLintBadFixture >> withIsNilIfTrue
    | x |
    x := nil.
    x isNil ifTrue: [ ^ #bad ].
    ^ #good
```

The rule (committed at C13): `PCKNoIsNilIfTrueRule`, `ReNodeRewriteRule`
subclass with `replace: '`@x isNil ifTrue: [`.@block]' with: '`@x ifNil:
[`.@block]'` — its change on the plant rewrites toward the `ifNil:` form (the
D-04 rewrite, verified end-to-end in a live image, D-15).

**Constitution rules that bite here:** no global state (all preview state
lives on the instance); comments state constraints the code cannot show; a
test that cannot fail is a defect; no `Transcript` — the only sink is the
handed stream; touching any file outside the manifest is a review rejection.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and
export to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `bash tools/build-image.sh` load from
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Coding-Kit-Rules/PCKFixCommand.class.st` — add `previewOn:`, extend
  `changes` to answer pending changes post-preview, add the previewed-state
  flag.
- `src/Phi-Coding-Kit-Tests-Rules/PCKFixCommandTest.class.st` — add the three
  tests below.
- LOC budget: target 100 / ceiling 200.

## TESTS FIRST

New test methods on `PCKFixCommandTest` (E08-C02's three stay green
unmodified):

- `testPreviewEmitsTargetAndBothSources` — **given** a command over
  `PCKNoIsNilIfTrueRule` and `#('Phi-Coding-Kit-Tests-Rules')` / **when**
  `previewOn:` a `WriteStream on: String new` / **then** the stream contents
  contain `'PCKLintBadFixture'` and `'withIsNilIfTrue'` (the target), a
  substring of the old source (`'isNil ifTrue:'`) and of the new
  (`'ifNil:'`) — the invoker saw the diff before anything can change (D-06).
- `testPreviewAnswersCountAndExposesChanges` — **given** the same setup /
  **when** previewed / **then** `previewOn:` answered exactly 1, and `changes`
  answers a collection of exactly one change object whose
  `oldVersionTextToDisplay` contains `'isNil ifTrue:'` and whose
  `textToDisplay` contains `'ifNil:'` (the blast-radius guard stated above).
- `testPreviewMutatesNoSource` — **given** the plant's `sourceCode`
  snapshotted before / **when** `previewOn:` runs / **then**
  `(PCKLintBadFixture >> #withIsNilIfTrue) sourceCode` is unchanged — preview
  is pure; mutation is `apply`'s alone (R-12's division of labor).

Fixtures: C13's committed `PCKLintBadFixture` — no new fixture, no source
mutation anywhere in this chunk.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists all 6 `PCKFixCommandTest`
          methods plus every previously accepted suite; ≥95 run (the 88
          cut-time accepted tests + E08-C01's 1 + E08-C02's 3 + this chunk's
          3); accepted parallel-track (E05/E07) suites add to the count —
          membership + floor, never an exact ceiling.

OUT OF SCOPE
- `apply`'s real body — staleness re-read and change execution are E08-C04's;
  the C02 guard stands untouched.
- The capability pair (E08-C05).
- Re-preview semantics on an already-previewed or applied instance — one
  command instance is one invocation (§3.3); nothing here specifies or tests a
  second preview.
- Any edit to `PCKLintRuleCheck` beyond *reading* its class-side helper; any
  edit to `PCKKitTest` (E07's file), `package.st` files, or the baseline.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files,
          one commit `E08-C03: PCKFixCommand previewOn: and changes`
          (qualified ID, D-73) before reporting for review; nothing left
          uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · any
  spelling confirmed beyond the D-15/C15 record (P5) · deviations from the
  work order (each with one-line justification) · new questions for the
  decision sheet.
