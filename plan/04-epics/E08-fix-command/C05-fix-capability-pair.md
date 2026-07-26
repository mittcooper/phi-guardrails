# E08-C05 · The fix capability pair on PCKLintRuleCheck   [depends: E08-C01, E08-C04 · parallel: no]

GOAL      `PCKLintRuleCheck` declares the SDK fix capability — `canFix` true
          exactly when its wrapped rule is a rewrite rule, `fixCommandOn:`
          answering a configured `PCKFixCommand` — discharging P-CAT-AUTOFIX
          on the catalog rule.

TRACE     R-11 (fix half) · R-15 (the autofix, capability leg) · ch. 1 §1.3
          (`PGRCheck` capability rows, D-54.2) · ch. 3 §3.3 (the pair's
          division of labor) · **D-74 (Q-33 ruled: capability = mechanical
          fact; no flag-only category; judgment at the preview)** ·
          P-CAT-AUTOFIX (ch. 9, this chunk's owed property) · scheduled
          amendment of one E06 test line (below — E06's own papers deferred
          it here).

## CONTEXT DIGEST

**What exists when this chunk starts:** E08-C01 accepted (`PCKLintRuleCheck`
runs through `lintEnvironmentOver:`; `PCKLintRuleCheckTest` has 5 tests);
E08-C04 accepted (`PCKFixCommand` complete: `rule:packages:` guarded by
`PGRNotAutofixable`, `previewOn:` → count, `apply` → applied changes with the
`PGRFixStale` re-read, `changes`). E08-C02's completion report recorded the
confirmed `isRewriteRule` form (class-side or via `new`) — **reuse that
recorded form**; do not re-derive.

**The capability contract (frozen E02 SDK — the check protocol's fix rows,
D-54.2, verbatim from the digest):** `canFix` (skeleton default false) +
`fixCommandOn:` (required when `canFix`; takes the fix target — packages, the
same target language as ch. 3 §3.3 — and answers an object conforming to the
fix-invocation protocol: construct → `previewOn:` → `apply` → `changes`). The
skeleton's `fixCommandOn:` is a `subclassResponsibility` marker (D-68:
`canFix`-false checks are never sent it).

**The implementation (this chunk, both on `PCKLintRuleCheck` instance side):**

```smalltalk
canFix
    "True exactly when the wrapped rule carries a rewrite recipe (D-74:
     capability is the mechanical fact; apply-time judgment lives at the
     mandatory preview)."
    ^ <the confirmed isRewriteRule form over the `rule` class>

fixCommandOn: aCollectionOfPackageNames
    "Answers the coding kit's fix-invocation implementation, bound to the
     wrapped rule and the handed target (never this check's own packages —
     the invoker chooses the fix target, §1.3)."
    ^ PCKFixCommand rule: rule packages: aCollectionOfPackageNames
```

(`rule` is the E06-frozen internal reader. Note the deliberate asymmetry:
`run` reads `self packages` — the gate's targets; `fixCommandOn:` takes its
own — the invoker's. For a recipe-less rule's check, `fixCommandOn:` would
signal `PGRNotAutofixable` via the constructor — legitimate: a conforming
caller consults `canFix` first and never sends it, D-68.)

**The capability under D-74 (Q-33 ruled — this paragraph supersedes the cut's
original "flag-only counterparty" premise).** There is no flag-only category:
`canFix` is the mechanical fact alone, and per-application safety judgment
belongs to the mandatory preview (D-74 guidance: appliers run the suite after
apply; deletion diffs warrant reading the surrounding method).
`ReCodeCruftLeftInMethodsRule` **is** a `ReNodeRewriteRule` — probed live at
E08-C02; its recipe deletes the matched statement — so its check answers
`canFix` **true**. The recipe-less counterparty for the false arm is
`ReEmptyExceptionHandlerRule` (the C02-recorded non-rewrite built-in; reuse
that report's `isRewriteRule` record). Ch. 3 §3.2b's "flag-only" sentence
gains its erratum at the owner's next spec pass (D-74), matching the D-70/D-72
pattern.

**The scheduled E06 test amendment.** `PCKLintRuleCheckTest>>#testKindIsLint`
currently ends with:

```smalltalk
    "canFix stays the inherited false: the fix capability is E08's, not this chunk's."
    ...
    self deny: check canFix
```

That deny was E06's explicit placeholder for this chunk (its work order C15:
"the capability pair on the catalog rule is E08's"). Remove the `deny:` line
and the stale comment sentence; the kind assertion stays byte-identical. This
is scheduled ground executed on schedule, not a frozen-surface amendment — the
E06 digest froze the class's surface (constructor, `kind`, `rule`, verdict
mapping), none of which changes; annotate the removal in your completion
report all the same.

**P-CAT-AUTOFIX (ch. 9, verbatim):** test
`PCKNoIsNilIfTrueRuleTest>>#testProvidesAutofix` — "the check declares the fix
capability (`canFix` true) and the violation it reports on the bad fixture
carries a previewable change — in the coding kit's implementation these are
Renraku's `isRewriteRule`/`providesChange`, the engine spellings behind the
SDK's neutral ones." `PCKNoIsNilIfTrueRuleTest` (committed, C13) has a helper
`runRuleCritiques` — the D-15 checker recipe scoped to
`'Phi-Coding-Kit-Tests-Rules'`, answering the rule's critiques; the plant
critique is selected as
`each entity == (PCKLintBadFixture >> #withIsNilIfTrue)`.

**Constitution rules that bite here:** a test that cannot fail is a defect;
never `isKindOf:`/`class ==` type predicates — assert conformance by behavior
(responds-to plus an actual preview), not by class identity; comments state
constraints the code cannot show; touching any file outside the manifest is a
review rejection.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and
export to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `bash tools/build-image.sh` load from
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Coding-Kit-Rules/PCKLintRuleCheck.class.st` — add `canFix` and
  `fixCommandOn:`; update the class-comment sentence that says the capability
  "stays inherited-false until E08" (that E08 is now).
- `src/Phi-Coding-Kit-Tests-Rules/PCKLintRuleCheckTest.class.st` — the
  `testKindIsLint` amendment + the three new tests below.
- `src/Phi-Coding-Kit-Tests-Rules/PCKNoIsNilIfTrueRuleTest.class.st` — add
  `testProvidesAutofix`.
- LOC budget: target 75 / ceiling 150.

## TESTS FIRST

On `PCKLintRuleCheckTest`:

- `testCanFixTrueForRewriteRule` — **given** `PCKLintRuleCheck rule:
  PCKNoIsNilIfTrueRule packages: #('Phi-Guardrails-SDK')` / **then** `canFix`
  is true — the catalog rule's check advertises its autofix (P1: fixes, not
  flags); **and** the check wrapping `ReCodeCruftLeftInMethodsRule` also
  answers true (D-74: it carries a recipe — mechanical fact, no policy
  overlay).
- `testCanFixFalseForRecipelessRule` — **given** the check wrapping
  `ReEmptyExceptionHandlerRule` (the C02-recorded non-rewrite built-in) /
  **then** `canFix` is false — no recipe exists to offer; the capability is
  per-rule fact, never a blanket true.
- `testFixCommandOnAnswersWorkingCommand` — **given** the catalog-rule check /
  **when** `fixCommandOn: #('Phi-Coding-Kit-Tests-Rules')` / **then** the
  answer responds to `previewOn:`, `apply`, and `changes` (protocol
  conformance, behaviorally), and sending it `previewOn:` on a scratch
  `WriteStream` answers exactly 1 with the stream naming
  `'withIsNilIfTrue'` — the command is *bound*, not merely shaped; no `apply`
  is sent (this test mutates nothing).

On `PCKNoIsNilIfTrueRuleTest`:

- `testProvidesAutofix` — **given** the plant critique from
  `runRuleCritiques` (selected by `entity`, the committed helper) and the
  catalog-rule check / **then** the check's `canFix` is true **and** the plant
  critique answers `providesChange` true — **P-CAT-AUTOFIX** (ch. 9's named
  test, verbatim name and assertions).

Fixtures: all committed already (C13's pair, the shipped built-in). No source
mutation in this chunk's tests.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 8 `PCKLintRuleCheckTest`
          methods, the 3 `PCKNoIsNilIfTrueRuleTest` methods, and the 9
          `PCKFixCommandTest` methods plus every previously accepted suite;
          ≥102 run (the 88 cut-time accepted tests + E08's 14); accepted
          parallel-track (E05/E07) suites add to the count — membership +
          floor, never an exact ceiling. This chunk's green run is the E08
          exit-checkpoint leg 1 (see `chunks.md` §checkpoint).

OUT OF SCOPE
- Any `PCKFixCommand` edit — it is complete as of E08-C04.
- Any `PGRCheck`/SDK edit — the skeleton's marker and default are frozen E02
  ground.
- Kit or registration machinery (`PCKKit` is E07's to touch after E06), and
  any edit to `PCKKitTest`, `package.st` files, or the baseline.
- The gate: nothing here may reference `-Gate`, and nothing in `-Gate` may
  reference this (P-FIX-GATE-WALL is E09's machine witness).

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files,
          one commit `E08-C05: fix capability pair on PCKLintRuleCheck`
          (qualified ID, D-73) before reporting for review; nothing left
          uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · the
  `isRewriteRule` form reused from E08-C02's record (state it) · the
  `testKindIsLint` amendment noted · deviations from the work order (each with
  one-line justification) · new questions for the decision sheet.
