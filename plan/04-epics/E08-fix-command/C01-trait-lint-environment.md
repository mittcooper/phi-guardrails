# E08-C01 · Trait-aware lint environment (the D-72 amendment)   [depends: — · parallel: yes (disjoint with E08-C02 only)]

GOAL      Widen `PCKLintRuleCheck`'s lint-run environment so a trait-provided
          method is linted at each **using class's** package (Q-32 ruled option a),
          closing the D-71 escape, with a regression test reproducing the D-71
          probe scenario.

TRACE     D-72 (the ruling) · D-71 (the probe evidence) · D-15.b (attribution
          facts) · Q-32 · ch. 2 §2.3 (the run recipe this amends — gains its
          erratum at the owner's next spec pass, D-72) · R-10 · amendment to
          E06's frozen surface **through the decision-sheet path** (D-72 is the
          authorization; this is not a silent edit).

## CONTEXT DIGEST

**Why this chunk exists.** E06's `PCKLintRuleCheck>>run` scopes the checker with
`RBPackageEnvironment packageNames:` (spelling confirmed live at C15). The D-71
probe proved that this environment attributes a trait-provided method **only to
the trait's defining package**: a lint run scoped to the using class's package
sees nothing (raw probe output, verbatim — rule `ReCodeCruftLeftInMethodsRule`,
trait `TCruftProbe` in `ProbeB-Traits` with method `probeCruft self flag: #probe`,
class `ProbeBUser` in `ProbeB-User` using it):

```
ProbeB-User -> 0 critique(s)
ProbeB-Traits -> 1 critique(s)
  TCruftProbe>>#probeCruft
```

So a trait defined in an exempt-role package but used from a production class
escapes lint. D-72 rules option (a): the environment is widened so **the using
package's role governs** — matching the architecture walk's attribution (D-15.b:
trait-provided methods surface in each using class's `methods`, both sides, with
working `referencedClasses`; `CompiledMethod>>package` answers the trait's
package). Duplication when several targeted packages use one trait — or when the
trait's own defining package is also targeted — is the same accepted
defense-in-depth D-15.b recorded.

**The class as committed (E06-accepted ground; the frozen E06 digest binds
`rule:packages:`, `kind` `#lint`, internal reader `rule`, and the D-03 verdict
mapping — none of which this chunk changes). Current `run`, verbatim:**

```smalltalk
PCKLintRuleCheck >> run
    | ruleInstance checker critiques mapped |
    ruleInstance := rule new.
    checker := ReSmalllintChecker new
        rule: { ruleInstance };
        environment: (RBPackageEnvironment packageNames: self packages);
        run;
        yourself.
    critiques := checker criticsOf: ruleInstance.
    critiques ifEmpty: [ ^ PGRVerdict green ].
    mapped := critiques asArray collect: [ :each |
        PGRFinding
            target: each entity printString
            message: rule ruleName
            rationale: rule rationale ].
    ^ rule severity == #error
        ifTrue: [ PGRVerdict redFindings: mapped ]
        ifFalse: [ PGRVerdict greenAdvisories: mapped ]
```

(`self packages` is the frozen E02 skeleton reader — `PGRCheck class>>packages:`
stores the handed names copied to `Array`; `each entity` is the critique→method
accessor confirmed at C13/C15; the probe also reached it as
`sourceAnchor entity` — both live. Frozen E02 readers the new test consumes:
`PGRVerdict>>isGreen` and `>>findings` — an `Array` of `PGRFinding`s, each
answering `target` — a `String`, the critiqued entity's `printString`.)

**The amendment.** Replace the `environment:` argument with a composition under
which the checker critiques, for every class **defined in** a target package,
that class's own `methods` — which D-15.b confirms include trait-provided
methods on both instance and class side. Single-source the composition as a
class-side method so E08-C03's fix command runs the rule through the identical
environment (one attribution story across check and fix, D-72's intent):

```smalltalk
PCKLintRuleCheck class >> lintEnvironmentOver: aCollectionOfPackageNames
    "The D-72 environment law, single-sourced: trait-provided methods are
     linted at each using class's package. The fix command (E08-C03) runs
     the rule through this same composition."
```

(`run` then scopes with `environment: (self class lintEnvironmentOver:
self packages)`. The helper name is an agent call, veto-open — recorded in
`chunks.md`.)

**⟨verify-in-image⟩ (P5) — the exact spelling is this chunk's implementer work,
per D-72; probe live before use, record the confirmed form in the completion
report.** Candidates:

(a) `RBSelectorEnvironment` populated from each target package's
    `definedClasses`, adding every (class, selector) from each class's `methods`
    and its class-side equivalent — the direct transcription of D-15.b's
    attribution fact;
(b) `RBClassEnvironment` over the union of the packages' `definedClasses` (and
    metaclasses) — acceptable **only if** a live probe shows its method
    iteration covers trait-provided methods in the class's local method
    dictionary (the D-71 scenario is the probe).

Behavioral contract, either way: (i) every **defined-class** method the old
package environment covered stays covered — the four existing
`PCKLintRuleCheckTest` tests are the regression guard (extension methods a
package defines on classes elsewhere are outside this contract either way:
their attribution is backlog B-05, deferred on record, and `src/` currently
carries none); (ii) a trait-provided method whose using class is defined in
a target package is now critiqued — the new test below; (iii) coverage derives
from classes *defined in* the target packages only — never methods inherited
from superclasses outside them (D-15.b's attribution is a class's own `methods`,
flattened trait methods included; `Package>>definedClasses` is the verified
inventory query, D-15). The green arm stays green by construction:
`Phi-Guardrails-SDK` classes use no traits.

**Scratch-fixture spellings (verified — the D-71 probe file
`plan/probes/b03-lint-env-trait-probe.st` executed exactly these fluid forms,
exit 0; reuse them with the names below):**

```smalltalk
(Trait << #PCKScratchCruftTrait
    package: 'PCKScratchB03-Traits';
    install) compile: 'probeCruft self flag: #probe'.
Object << #PCKScratchCruftUser
    traits: { (Smalltalk globals at: #PCKScratchCruftTrait) };
    package: 'PCKScratchB03-User';
    install.
```

(`Smalltalk globals at:` is a **read** — the constitution bans only `at:put:`
writes; the read spelling is the E06 C16 precedent. The scratch package names
match neither tests-family pattern `(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*`
nor any smalltalkCI-swept pattern, and neither scratch class is a `TestCase`,
so a mid-test scratch is invisible to both sweeps. `self flag: #probe` here is
a **string literal compiled at runtime into the scratch trait** — a planted
violation in fixture-construction code (R-37/D-26 sanctioned), not a committed
`flag:` send; the committed source carries only the literal, which no AST rule
matches — the C13 pattern-string precedent.)

**Removal (tearDown duty, ⟨verify-in-image⟩, record confirmed spellings):**
remove the using class first, then the trait, then the two scratch packages —
candidates `removeFromSystem` on class and trait;
`(PackageOrganizer default packageNamed: '…') removeFromSystem` or
`PackageOrganizer default removePackage:` for the packages
(`PackageOrganizer default packageNamed:` is D-15-verified). Removal must run
even when an assertion fails — build, run, and assert inside a block protected
by `ensure: [ removal ]`. The work image is rebuilt from committed `src/` on
every verify run, so a crash cannot leak scratch state across runs.

**Constitution rules that bite here:** frozen interfaces change only through a
decision-sheet entry — D-72 **is** that entry, cite it in the class comment
line you touch; no global state; comments state constraints the code cannot
show; a test that cannot fail is a defect; touching any file outside the
manifest is a review rejection.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and
export to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `bash tools/build-image.sh` load from
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Coding-Kit-Rules/PCKLintRuleCheck.class.st` — add class-side
  `lintEnvironmentOver:`; repoint `run`'s `environment:` line; one class-comment
  sentence citing D-72. Nothing else on this class changes (the E06-frozen
  constructor, `kind`, `rule`, verdict mapping stay byte-identical in behavior).
- `src/Phi-Coding-Kit-Tests-Rules/PCKLintRuleCheckTest.class.st` — add the one
  regression test below.
- LOC budget: target 80 / ceiling 150.

## TESTS FIRST

New test method on `PCKLintRuleCheckTest` (the four existing tests —
`testKindIsLint`, `testRedOnBadFixturePackage`, `testGreenOnCleanPackage`,
`testSubErrorSeverityYieldsAdvisories` — are the regression guard and must stay
green unmodified):

- `testTraitProvidedMethodLintedAtUsingClassPackage` — **given** the scratch
  trait `PCKScratchCruftTrait` (package `PCKScratchB03-Traits`, plant
  `probeCruft self flag: #probe`) and scratch class `PCKScratchCruftUser`
  (package `PCKScratchB03-User`) using it, built with the verified fluid
  spellings above / **when** `(PCKLintRuleCheck rule: ReCodeCruftLeftInMethodsRule
  packages: #('PCKScratchB03-User')) run` executes inside the `ensure:`-guarded
  block / **then** the verdict is red (`deny: isGreen`) and at least one finding's
  `target` contains `'probeCruft'` — the D-71 escape (0 critiques at the using
  package) is closed. Do not over-assert the target's class half: whether the
  finding prints the trait or the using class is implementation-determined; the
  ruled substance is that the using-package-scoped run **sees** the method.

Fixtures: the runtime scratch pair above (built and removed inside the test —
no committed fixture, no baseline edit); `ReCodeCruftLeftInMethodsRule` ships
with Pharo (severity `#error`, D-28 — red verdict guaranteed by the D-03
mapping).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the new
          `testTraitProvidedMethodLintedAtUsingClassPackage` plus every
          previously accepted suite; ≥89 run (the 88 cut-time accepted tests +
          this chunk's 1); accepted E08 siblings and parallel-track (E05/E07)
          suites add to the count — membership + floor, never an exact ceiling.

OUT OF SCOPE
- The fix command (E08-C02..C04) and the capability pair (E08-C05) — `canFix`
  stays the inherited false here.
- Any edit to `PCKNoIsNilIfTrueRuleTest`, `PCKCodeCruftBuiltInTest`, or
  `PCKKitTest` (their private checker recipes keep the narrow
  `RBPackageEnvironment` deliberately — they pin rule behavior, not environment
  law; and `PCKKitTest` is E07's file to extend, untouchable in this epic).
- Ch. 2 §2.3's erratum note — the owner's spec pass owns it (D-72).
- A committed cross-package trait fixture, any new package, any `package.st`
  or baseline edit.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files,
          one commit `E08-C01: trait-aware lint environment (D-72)` (qualified
          ID, D-73) before reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · the
  confirmed environment-composition spelling and the confirmed scratch-removal
  spellings (P5 record duty) · deviations from the work order (each with
  one-line justification) · new questions for the decision sheet.
