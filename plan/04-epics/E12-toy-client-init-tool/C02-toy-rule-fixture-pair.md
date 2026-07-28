# E12-C02 · `ToyNoIsNilIfFalseRule` and its fixture pair  [depends: — · parallel: yes]

GOAL      Deliver the toy's own extension check — a flag-only lint rule matching
`` `@x isNil ifFalse: [`.@block] `` at severity `#error` in `Toy-Rules` — with the
client-convention fixture pair (`testFiresOnBadFixture` / `testSilentOnGoodFixture`)
in `Toy-Tests`, modeling §8.1 step 3's extension package exactly.

TRACE     R-32 ("project-scope extension" — read post-D-51 as the client's own checks,
registered in its kit block) · R-31 (the extension package is the one case a client
loads the framework tool-side) · spec ch. 8 §8.2 (the `Toy-Rules` row: the rule's
pattern, severity, and flag-only form; the fixture-pair convention modeled in
`Toy-Tests`) · ch. 8 §8.1 step 3 (client-convention fixture pairs) · ch. 2 §2.2/§2.2b
(authoring contract: class-side `ruleName`/`severity`/`rationale`; explicit severity,
D-41) · R-37 (fixture-pair law, applied to clients by convention) · D-26 (the bad
fixture is committed honest code).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**The rule (spec ch. 8 §8.2 row for `Toy-Rules`, verbatim contract):** a **flag-only**
lint rule per §2.2 matching `` `@x isNil ifFalse: [`.@block] ``, severity `#error`.
(History note the class comment may carry: it was re-pointed from `Transcript show:`
when the D-28 built-in took that ground.) Flag-only means base class
**`ReNodeMatchRule`** (ch. 2 §2.2: `ReNodeMatchRule` for flag-only structural rules;
`ReNodeRewriteRule` only for rules with an autofix — the toy's rule ships none), with
the pattern declared in `initialize` via `matches:`. Both the base class and
`matches:`, and the exact pattern's fires/silent behavior, were live-probed at cut
time (probes.md P1/P2: one critique on `^ x isNil ifFalse: [ x printString ]`, zero on
an `ifNotNil:` twin).

**The authoring contract (ch. 2 §2.2, condensed — all three class-side hooks
mandatory):**
- `ruleName` — short imperative title (e.g. `'isNil ifFalse: should be ifNotNil:'`).
- `severity` — `^ #error` (the §8.2 contract; and D-41 makes a registered rule
  without its *own* class-side `severity` a configuration error, so the method must
  be on this class itself).
- `rationale` — ≥1 full sentence: why the pattern is banned and what to do instead
  (the agent guidance emitted with every finding); for this rule: re-testing a nil
  you already have reads backwards — `ifNotNil:` is one send and reads as intent; no
  autofix ships, rewrite by hand.

Canonical shape (the accepted catalog rule, adapted to the match-only base):

```smalltalk
Class {
    #name : 'ToyNoIsNilIfFalseRule',
    #superclass : 'ReNodeMatchRule',
    #category : 'Toy-Rules',
    #package : 'Toy-Rules'
}

ToyNoIsNilIfFalseRule >> initialize [
    super initialize.
    self matches: '`@x isNil ifFalse: [`.@block]'
]
```

**No framework prefix:** the toy models a real client — classes are `Toy*` (R-36 as
amended at Gate 2). The rule class subclasses a **Renraku** base, not `PGRCheck`: lint
registrations resolve rule classes directly (the accepted kit pipeline validates
Renraku descent and D-41 severity), and a client's rule needs nothing from
`Phi-Guardrails-SDK`.

**The fixture pair and its home (spec §8.2, verbatim):** the toy models the
client-side fixture-pair convention on its own rule:
`ToyNoIsNilIfFalseRuleTest>>#testFiresOnBadFixture` / `>>#testSilentOnGoodFixture` in
**`Toy-Tests`**, against small fixture classes in that same package. R-37's law: the
rule fires on the bad-code fixture and stays silent on the good one — both named,
both asserted. The bad fixture's `isNil ifFalse:` occurrence is sanctioned committed
code (D-26/R-37: bad fixtures exist to be caught; `Toy-*` is a sanctioned home —
constitution §2). It sits in the toy's *tests*-role package, which lint never sweeps
(lint reads production-role packages only — the accepted D-33 trade), so it adds no
critique to any gate run.

**The test harness (the D-15 checker recipe, verbatim from the accepted
`PCKNoIsNilIfTrueRuleTest` and re-probed at cut, probes.md P2):**

```smalltalk
runRuleCritiques
    | rule checker |
    rule := ToyNoIsNilIfFalseRule new.
    checker := ReSmalllintChecker new
        rule: { rule };
        environment: (RBPackageEnvironment packageName: 'Toy-Tests');
        run;
        yourself.
    ^ checker criticsOf: rule
```

The critiqued method is reached as `critique entity` (the accepted C13 live-probe
spelling). Filter by entity — the package gains more classes in C03.

**Why this suite is NOT in the verify sweep, and how it is verified instead (the
committed-red discipline, owner ground riding this epic):** `Toy-Tests` full-matches
neither `Phi-Guardrails-Tests-.*` nor `Phi-Coding-Kit-Tests-.*` (D-57's verified
shape, pinned by the accepted `PGRToySweepExemptionTest`), so the verify command and
smalltalkCI never run it — that is what lets C03 commit a red test there without
reddening the sweep. This chunk's pair is green code in an unswept package: its VERIFY
therefore carries an explicit **eval arm** running the class headless (below). Under
the toy's own artifact (E12-C04 onward) the pair also runs inside `behavioral/Toy-Tests`.

**Constitution rules that bite here:** the fixture-pair law (fires + silent, both
asserted) · every rule carries a `rationale` · no `skip`/`expectedFailures` (this
chunk commits none anywhere; C03's skip plant is separately sanctioned) · comments
state constraints the code cannot show · touching any file outside the manifest is a
review rejection.

DELIVERABLES

Files (Tonel):
- **create** `src/Toy-Rules/ToyNoIsNilIfFalseRule.class.st`
- **create** `src/Toy-Tests/ToyRuleBadFixture.class.st`
- **create** `src/Toy-Tests/ToyRuleGoodFixture.class.st`
- **create** `src/Toy-Tests/ToyNoIsNilIfFalseRuleTest.class.st`

Classes/methods:
- `ToyNoIsNilIfFalseRule` (superclass `ReNodeMatchRule`, package `Toy-Rules`) —
  class-side `ruleName`, `severity` (`^ #error`), `rationale`; instance `initialize`
  with the `matches:` declaration above. Nothing else.
- `ToyRuleBadFixture` (superclass `Object`, package `Toy-Tests`) — one method
  `withIsNilIfFalse` whose body carries the plant in the live-probed shape, e.g.
  `| x | x := nil. x isNil ifFalse: [ ^ #reached ]. ^ #clean` (never executed; exists
  to be read by the rule — class comment states this, the accepted
  `PCKLintBadFixture` precedent).
- `ToyRuleGoodFixture` (superclass `Object`, package `Toy-Tests`) — one method
  `withIfNotNil` using the clean `ifNotNil:` twin.
- `ToyNoIsNilIfFalseRuleTest` (superclass `TestCase`, package `Toy-Tests`) — the
  `runRuleCritiques` helper plus the two skeletons below.

LOC budget: target ~100 · ceiling 300.

TESTS FIRST  (`ToyNoIsNilIfFalseRuleTest`, package `Toy-Tests` — test method names
are the spec's, verbatim)

- `testFiresOnBadFixture` *(R-37 fires half)* — given the checker recipe over
  `Toy-Tests`; when the rule's critiques are collected; then exactly one critique's
  `entity` is `ToyRuleBadFixture >> #withIsNilIfFalse` (filtered by entity — the
  package gains other classes in C03).
- `testSilentOnGoodFixture` *(R-37 silent half)* — given the same run; then zero
  critiques' `entity methodClass` is `ToyRuleGoodFixture`.

Fixtures: the two fixture classes this chunk creates.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, every previously accepted suite green — ≥250 run when this
          chunk lands first (this chunk adds **no swept test** — its suite is unswept
          by design); membership + floor, never an exact ceiling ([P] sibling E12-C01
          raises the floor by 2 if picked earlier).
          **Plus the unswept-pair eval arm** (this chunk's own green witness):
          `.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo --headless .build/work/phi.image eval "(ToyNoIsNilIfFalseRuleTest suite run) printString"`
          → the printed result reports **2 run, 2 passes, 0 failures, 0 errors** (the
          exact rendering may vary; the four counts are the assertion).
          **Plus the self-hosted regression leg:**
          `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
          → exit 0, **12 registrations unchanged**, `GATE: GREEN`.

OUT OF SCOPE
- Any autofix arm (`ReNodeRewriteRule`, `replace:with:`) — the rule is flag-only by
  spec.
- The three `Toy-Core` lint plants, the failing/skip test plants, and every witness
  (E12-C03).
- Registering the rule anywhere (the toy's artifact is E12-C04; the kit's
  `recommendedBlock` never includes a client rule — D-51 composition).
- Touching `Toy-Core`/`Toy-UI`/`Toy-Persistence`, any framework package, or any
  accepted test file.

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition:
one commit `E12-C02: ToyNoIsNilIfFalseRule and its fixture pair`, nothing uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output (sweep + eval arm
  + gate leg) · deviations (each one-line justified) · new questions for the decision
  sheet.
