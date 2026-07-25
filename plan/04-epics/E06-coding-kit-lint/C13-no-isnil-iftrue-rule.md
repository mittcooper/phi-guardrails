# C13 · PCKNoIsNilIfTrueRule with fixture pair      [E06 · depends: — · parallel: yes]

GOAL      Land the v1 catalog rule `PCKNoIsNilIfTrueRule` — an AST rewrite rule,
          severity `#error` — with the bad/good fixture pair proving it fires on
          the plant and stays silent on clean code (P-CAT-FIXTURES, lint).

TRACE     ch. 3 §3.2 (the catalog entry) · ch. 2 §2.2 (authoring contract,
          canonical form) · D-04 · D-15 (spellings) · D-20 (severity `#error`) ·
          R-15, R-37 · P-CAT-FIXTURES.

## CONTEXT DIGEST

**Authoring contract** (ch. 2 §2.2 — Pharo 13 hooks, D-15-corrected: all three
**class-side**): `ruleName` (short imperative title) · `severity` (exactly one of
`#error` / `#warning` / `#information`; this rule: `#error`, D-20) · `rationale`
(≥1 full sentence: why the pattern is banned and what to do instead — this text is
the agent guidance emitted with every finding). Base class for rules with an
autofix: `ReNodeRewriteRule` (verified, D-15).

**Canonical form to implement** (ch. 2 §2.2, verbatim — this IS the shipped rule;
Tonel-export it, do not hand-write the file):

```smalltalk
ReNodeRewriteRule << #PCKNoIsNilIfTrueRule
    package: 'Phi-Coding-Kit-Rules'

PCKNoIsNilIfTrueRule class >> ruleName   ^ 'isNil ifTrue: should be ifNil:'
PCKNoIsNilIfTrueRule class >> severity   ^ #error          "D-20"
PCKNoIsNilIfTrueRule class >> rationale
    ^ 'x isNil ifTrue: [...] re-tests a nil you already have; ifNil: is one send and
       reads as intent. The rewrite is behavior-preserving — apply the autofix.'
PCKNoIsNilIfTrueRule >> initialize
    super initialize.
    self replace: '`@x isNil ifTrue: [`.@block]' with: '`@x ifNil: [`.@block]'
```

(`replace:with:` in `initialize`, and the exact pattern → rewrite pair, were
verified end-to-end in a live image — D-15. The pattern string is a *literal*
inside `initialize`; a string literal is not an AST send, so the rule never
critiques its own definition.)

**Placement.** Rule class in `Phi-Coding-Kit-Rules` (production role; `PCK` class
prefix, D-56). Fixtures and test in `Phi-Coding-Kit-Tests-Rules` — a tests-role
package, safe for bad fixtures because lint and architecture read
**production-role packages only** (D-25, the D-33 ruled trade), and a behavioral
run executes only `TestCase` classes, to which plain fixture classes are inert
(ch. 3 §3.2 / ch. 9 §9.3). Add class files only; no `package.st` or baseline edit.

**Fixtures** (plain `Object` subclasses; class comments must say they are declared
bad/good lint fixtures, the R-37/D-26 sanctioned exception to the idiom ban; their
methods are never executed — they exist to be read by the rule):

- `PCKLintBadFixture` — exactly one method carrying the plant:

  ```smalltalk
  withIsNilIfTrue
      | x |
      x := nil.
      x isNil ifTrue: [ ^ #bad ].
      ^ #good
  ```

- `PCKLintGoodFixture` — the near-miss clean twin, using the idiom the rationale
  prescribes:

  ```smalltalk
  withIfNil
      | x |
      x := nil.
      x ifNil: [ ^ #good ].
      ^ #also
  ```

**Verified headless run recipe** (D-15, verbatim — the tests use it directly; the
check wrapper is C15's, not this chunk's):
`ReSmalllintChecker new rule: {r}; environment: (RBPackageEnvironment
packageName: 'Phi-Coding-Kit-Tests-Rules'); run; criticsOf: r`.

**⟨verify-in-image⟩ (P5):** the accessor from a critique (an element of
`criticsOf:`'s answer) to its critiqued method is not yet a recorded spelling.
Probe it live in the work image before writing assertions (candidates:
`critique entity` · `critique sourceAnchor entity`); use the confirmed form and
**record it in the completion report** — the first recorded consumer of this
spelling in the repo.

**Constitution rules that bite here:** glossary exactly — gate-runnable things are
*checks*, non-blocking findings are *advisories*, "pattern" means the AST sense;
never write `isNil ifTrue:` in test code (the idiom ban — only the declared bad
fixture carries it); tests assert behavior, a test that cannot fail is a defect;
no `skip`/`expectedFailures`; comments state constraints the code cannot show.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export
to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present,
D-15); hand-writing class files is not allowed — the committed form must be what
the tooling emits. After export, a fresh `bash tools/build-image.sh` load from
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against
it.

## DELIVERABLES

- `src/Phi-Coding-Kit-Rules/PCKNoIsNilIfTrueRule.class.st`
- `src/Phi-Coding-Kit-Tests-Rules/PCKLintBadFixture.class.st`
- `src/Phi-Coding-Kit-Tests-Rules/PCKLintGoodFixture.class.st`
- `src/Phi-Coding-Kit-Tests-Rules/PCKNoIsNilIfTrueRuleTest.class.st`
- LOC budget: target 110 / ceiling 200.

## TESTS FIRST

Test methods on `PCKNoIsNilIfTrueRuleTest` (names fixed by ch. 3 §3.2's
fixture-pair row):

- `testFiresOnBadFixture` — given the D-15 checker recipe over
  `'Phi-Coding-Kit-Tests-Rules'` / when collecting `criticsOf:` the rule / then
  exactly one critique's critiqued method is `PCKLintBadFixture>>#withIsNilIfTrue`
  (filter by critiqued method — the package will gain other classes in later
  chunks; the plant is named, P-CAT-FIXTURES).
- `testSilentOnGoodFixture` — given the same run / then zero critiques whose
  critiqued method belongs to `PCKLintGoodFixture` (the clean twin passes — the
  rule is precise, not merely trigger-happy).

Fixtures: `PCKLintBadFixture` / `PCKLintGoodFixture` (this chunk's own
deliverables, above).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 2 `PCKNoIsNilIfTrueRuleTest`
          methods plus every previously accepted suite — the 24 E01/E02 tests
          (19 SDK + 5 smoke), any accepted E06 siblings, and any accepted
          parallel-track (E03) suites (regression guard; membership + floor,
          never an exact ceiling).

OUT OF SCOPE
- The check wrapper `PCKLintRuleCheck` (C15) and any registration machinery
  (C16+).
- Applying the rewrite — the `replace:with:` recipe is the rule's declaration;
  invocation is E08's fix command.
- Touching `package.st` files, the baseline, or anything outside the manifest.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files, one
          commit `C13: PCKNoIsNilIfTrueRule with fixture pair` before reporting
          for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · the
  confirmed critique→method accessor spelling · deviations from the work order
  (each with one-line justification) · new questions for the decision sheet.
