# C15 · PCKLintRuleCheck      [E06 · depends: C13 · parallel: no]

GOAL      Land the lint kind's check: `PCKLintRuleCheck` wraps one rule class
          plus its target package names, and `run` answers the D-03 verdict —
          `#error`-severity critiques become red findings, sub-`#error`
          critiques become advisories on a green verdict, no critiques means
          green.

TRACE     ch. 2 §2.3 (the run recipe + severity mapping) · ch. 1 §1.3
          (`PGRCheck` protocol row) · D-03 (two-tier severity) · D-25/D-33
          (production-role targets) · R-10, R-13, R-14 · glossary *finding* /
          *advisory*.

## CONTEXT DIGEST

**What exists when this chunk starts:** C13 accepted — `PCKNoIsNilIfTrueRule`
(class-side `ruleName` / `severity ^ #error` / `rationale`; `ReNodeRewriteRule`
subclass) in `Phi-Coding-Kit-Rules`, and `PCKLintBadFixture` (method
`withIsNilIfTrue` carrying `isNil ifTrue:`) beside `PCKLintGoodFixture` in
`Phi-Coding-Kit-Tests-Rules`; C13's completion report recorded the confirmed
critique→method accessor spelling. The E02-frozen SDK (below). Nothing else.

**The class.** `PCKLintRuleCheck` in `Phi-Coding-Kit-Rules`; kind `#lint`;
subclass of the frozen `-SDK` skeleton `PGRCheck` (subclassing is the convenience
path; conformance is what registration requires, D-53). Frozen skeleton
signatures it builds on (verbatim, E02 digest):

```smalltalk
PGRCheck class >> packages: aCollectionOfPackageNames
    "answers a new instance storing the handed names (copied to Array;
     private setter setPackages:)"
PGRCheck >> packages      "reader — a check's run reads its targets here"
PGRCheck >> canFix        "^ false — fixing is opt-in"
PGRCheck >> run           "subclassResponsibility — answers a PGRVerdict"
PGRCheck >> kind          "subclassResponsibility — answers a Symbol"
```

**Kit-side constructor** (ch. 2 §2.3: the check is the kit's own class, "so a
richer kit-side constructor carrying the rule class is legitimate; the promised
`packages:` constructor is for classes the kit does not own"). Class-side:

```smalltalk
PCKLintRuleCheck class >> rule: aRuleClass packages: aCollectionOfPackageNames
    ^ (self packages: aCollectionOfPackageNames)
        setRule: aRuleClass;
        yourself
```

(The `rule:packages:` spelling mirrors ch. 3 §3.3's fix-command constructor —
one target language; recorded as an agent call in `chunks.md`, veto-open.)
Instance side: private setter `setRule:`, internal reader `rule` (E08 and C16's
tests read it), `kind` answering `#lint`. `canFix` stays the inherited false at
this chunk — the capability pair on the catalog rule is E08's, not yours.

**`run`** (ch. 2 §2.3, condensed inline — the whole recipe):

1. Instantiate the rule; build `ReSmalllintChecker new rule: { rule }` with
   `environment:` an `RBPackageEnvironment` over `self packages`; `run` it;
   collect the rule's critiques via `criticsOf:` (all spellings verified, D-15).
2. Map each critique to a `PGRFinding`: target = the critiqued entity printed
   precisely (`Class>>#selector`), message = the rule class's `ruleName`,
   rationale = its `rationale` (R-13: the rationale travels with every finding).
3. Verdict (D-03): if the rule's class-side `severity` is `#error`, any critique
   is a **finding** → `PGRVerdict redFindings:`; at `#warning` / `#information`
   all critiques are **advisories** → `PGRVerdict greenAdvisories:`; zero
   critiques → `PGRVerdict green`. One rule = one registration = one verdict.
4. The gate never applies a rule's rewrite (R-12): read critiques only.

**Frozen SDK constructors used** (verbatim, E02 digest):
`PGRFinding class >> target:message:rationale:` (readers `target` · `message` ·
`rationale`) · `PGRVerdict class >> green` / `greenAdvisories:` / `redFindings:`
(readers `status` · `findings` · `advisories` · `isGreen`; handed collections are
copied to `Array` at construction).

**⟨verify-in-image⟩ (P5) — probe live before use, record confirmed spellings in
the completion report:**
(a) the **multi-package** environment constructor — D-15 verified
`RBPackageEnvironment packageName:` (singular); confirm the collection form
(candidate: `RBPackageEnvironment packageNames:`) since `packages` is a
collection;
(b) the critique→critiqued-method accessor — C13's report recorded it
(candidates were `entity` / `sourceAnchor entity`); confirm the same form holds
here;
(c) the precise print form — a `CompiledMethod`'s `printString` is expected to
be `'Class>>#selector'`; confirm, else build the string from the method's class
name and selector.

**Test targets, chosen to be stable:** red arm = `'Phi-Coding-Kit-Tests-Rules'`
(contains C13's bad fixture; filter assertions by target so sibling fixtures
never break them); green arm = `'Phi-Guardrails-SDK'` (frozen E02 code, clean
under this rule — the constitution's own `ifNil:` idiom mandate); advisory arm =
a scratch sub-`#error` rule, this chunk's fixture:

- `PCKWarningSeverityStubRule` in `Phi-Coding-Kit-Tests-Rules` —
  `ReNodeRewriteRule` subclass, class-side `ruleName` (`'warning-severity
  stub'`), `severity ^ #warning`, `rationale` (one sentence), `initialize` with
  the same verified `replace: '`@x isNil ifTrue: [`.@block]' with: '`@x ifNil:
  [`.@block]'` — it fires on the same bad fixture but at `#warning`. A loaded,
  never-registered rule is harmless (§2.1: loaded-but-unregistered never
  blocks); the class comment says it is a test fixture.

**Constitution rules that bite here:** glossary — blocking results are
*findings*, non-blocking are *advisories* (never "warnings" for the objects;
`#warning` is only the severity Symbol); class-side named constructors over
`new`+setters; no global state; comments state constraints the code cannot show;
no `skip`/`expectedFailures`; a test that cannot fail is a defect; never write
`isNil ifTrue:` in your own code (only the declared bad fixture carries it).

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export
to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present,
D-15); hand-writing class files is not allowed — the committed form must be what
the tooling emits. After export, a fresh `bash tools/build-image.sh` load from
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Coding-Kit-Rules/PCKLintRuleCheck.class.st`
- `src/Phi-Coding-Kit-Tests-Rules/PCKWarningSeverityStubRule.class.st`
- `src/Phi-Coding-Kit-Tests-Rules/PCKLintRuleCheckTest.class.st`
- LOC budget: target 140 / ceiling 250.

## TESTS FIRST

Test methods on `PCKLintRuleCheckTest`:

- `testKindIsLint` — given `PCKLintRuleCheck rule: PCKNoIsNilIfTrueRule
  packages: #('Phi-Guardrails-SDK')` / then `kind` == `#lint` and `canFix` is
  false (the inherited default, intact at this chunk).
- `testRedOnBadFixturePackage` — given the check over
  `#('Phi-Coding-Kit-Tests-Rules')` with `PCKNoIsNilIfTrueRule` / when `run` /
  then the verdict's `isGreen` is false, `findings` is non-empty, and the
  finding targeting the plant has: target containing `'PCKLintBadFixture'` and
  `'withIsNilIfTrue'`, message = `PCKNoIsNilIfTrueRule ruleName`, rationale =
  `PCKNoIsNilIfTrueRule rationale` (R-13 end-to-end).
- `testGreenOnCleanPackage` — given the same rule over
  `#('Phi-Guardrails-SDK')` / when `run` / then `isGreen` true, `findings`
  empty, `advisories` empty.
- `testSubErrorSeverityYieldsAdvisories` — given the check with
  `PCKWarningSeverityStubRule` over `#('Phi-Coding-Kit-Tests-Rules')` / when
  `run` / then `isGreen` true, `advisories` non-empty (the bad fixture's
  critique arrived as an advisory), `findings` empty — the D-03 two-tier mapping
  is behavior, not documentation.

Fixtures: C13's `PCKLintBadFixture` (already accepted) ·
`PCKWarningSeverityStubRule` (this chunk's own deliverable).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 4 `PCKLintRuleCheckTest`
          methods plus every previously accepted suite — the 24 E01/E02 tests
          (19 SDK + 5 smoke), all accepted E06 siblings, and any accepted
          parallel-track (E03) suites (regression guard; membership + floor,
          never an exact ceiling).

OUT OF SCOPE
- The kit (`PCKKit`, C16/C17) and any registration or configuration machinery.
- The fix capability (`canFix` true / `fixCommandOn:`) — E08 owns the pair;
  flipping `canFix` here is a review rejection.
- Severity enforcement (D-41) — that is the kit's block-opening duty (C16),
  not the check's.
- Touching `package.st` files, the baseline, or anything outside the manifest.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files,
          one commit `C15: PCKLintRuleCheck` before reporting for review;
          nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · the three
  confirmed ⟨verify-in-image⟩ spellings · deviations from the work order (each
  with one-line justification) · new questions for the decision sheet.
