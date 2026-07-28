# E12-C04 · The toy's committed artifact: `BaselineOfToy class>>guardrailsSTON`  [depends: E12-C01, E12-C02 · parallel: yes (disjoint from C03/C05; runs after C02 in pick order)]

GOAL      Commit the toy's own configuration artifact — §1.1's complete example,
verbatim minus its reader-only annotations — as class-side STON text on
`BaselineOfToy`, and pin in the swept family that it parses, validates, and yields
exactly the six expected registrations in order.

TRACE     R-05 (the artifact is the only place the client is known) · R-32 (adoption
modeled: the artifact is step 1 of §8.1) · R-47 (one file, zero baseline changes) ·
spec ch. 1 §1.1 (the example artifact — "normative for schema, and the actual
committed toy artifact") · ch. 8 §8.2 (the in-repo embodiment as class-side STON
text; no `#src`, no comments) · D-18 (the class-side-STON mechanism, cited as
technique provenance) · D-45 (`fromString:` configs have no directory → no `#src`) ·
D-51 (every check named explicitly) · frozen E10 digest (the `#layerMap` sub-map
format this text uses).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**The in-repo embodiment (spec ch. 8 §8.2, condensed):** the toy's artifact is §1.1's
example, verbatim. In-repo it is committed as **class-side STON text** —
`BaselineOfToy class>>guardrailsSTON` — because the repo root's `guardrails.ston` is
the framework's own and no other committed file location exists inside the write
boundary. The demo test (E14) reads it with `PGRConfiguration fromString:`. A
`fromString:` config has no directory, so the toy's artifact declares **no `#src`**
and registers no dead-src check. It becomes a real root file only in the §8.4
external copy. **The committed text carries no STON comments** — STON's comment
support is unverified and nothing may depend on it (P5); the §1.1 rendering's quoted
annotations are for the spec reader only and are stripped here.

**The exact method to commit** (the §1.1 example minus its quoted annotation strings
— the spec rendering's reader-only quotes, all of them;
this precise text was parsed raw at cut time — probes.md P33: a Dictionary with keys
`#schemaVersion #project #baseline #roles #kits`, the kit block carrying the five
canonical keys, `#lintRules` the three rules, `#unlayered` `#('Toy-Rules')`; inside
the Smalltalk string literal every `'` below is doubled):

```
{
	#schemaVersion : 2,
	#project : 'Toy',
	#baseline : 'BaselineOfToy',
	#roles : {
		#production : [ 'Toy-(Core|UI|Persistence|Rules)' ],
		#tests : [ 'Toy-Tests' ] },
	#kits : [ {
		#kit : 'PCKKit',
		#lintRules : [ 'PCKNoIsNilIfTrueRule',
			'ReCodeCruftLeftInMethodsRule',
			'ToyNoIsNilIfFalseRule' ],
		#architectureChecks : [ 'PCKLayerMapCheck' ],
		#layerMap : {
			#layers : {
				'ui' : [ 'Toy-UI' ],
				'domain' : [ 'Toy-Core' ],
				'persistence' : [ 'Toy-Persistence' ] },
			#allowed : [ [ 'ui', 'domain' ], [ 'domain', 'persistence' ] ],
			#unlayered : [ 'Toy-Rules' ] },
		#metaRules : [ 'PCKNoSkippedTestsMetaRule' ] } ]
}
```

Method shape: `BaselineOfToy class >> guardrailsSTON` answering that text as one
literal String; method comment states it is §1.1's example verbatim (the committed
toy artifact, D-45/D-51) and why no `#src` and no STON comments.

**Why it validates (accepted E03 envelope law, condensed):** `#schemaVersion` 2 is
the parse set · `BaselineOfToy` resolves to a loaded `BaselineOf` subclass (C01) ·
the `#production` matcher is a full-match regex over the baseline's packages
(resolution order group-name → package-name/pattern; the baseline declares no groups,
so patterns it is — live-probed: the pattern matches exactly the four runtime
packages and not `Toy-Tests`, probes.md P9) · `'Toy-Tests'` matches as a package
name · roles are disjoint and jointly total over the baseline's five packages (the
scope law) · all five are loaded in the verify image (the `CI` group loads `Toy-*`).

**Why the registry answers six resolved registrations in order (accepted E06/E07/E10
ground, condensed):** the kit emits lint → architecture → behavioral suites →
meta-rules, in-key order; `#lintRules` three entries (all loaded: two catalog rules +
C02's, each with its own class-side `severity` — D-41 satisfied) · `#layerMap`
present and covering the production role (three layers + `#unlayered 'Toy-Rules'` =
the four production packages — the D-35 completeness law; D-79 semantics) with all
layer packages loaded → `architecture/PCKLayerMapCheck` resolved · one tests-role
package containing test classes (C02's `ToyNoIsNilIfFalseRuleTest` at minimum) →
`behavioral/Toy-Tests` resolved (a tests-role package is missing only when it
contains zero test classes) · `#metaRules` names the kit's own
`PCKNoSkippedTestsMetaRule` → resolved. Names, in registry order:

1. `lint/PCKNoIsNilIfTrueRule`
2. `lint/ReCodeCruftLeftInMethodsRule`
3. `lint/ToyNoIsNilIfFalseRule`
4. `architecture/PCKLayerMapCheck`
5. `behavioral/Toy-Tests`
6. `behavioral/PCKNoSkippedTestsMetaRule`

**Surfaces the pin test may use (probed at cut, probes.md P10/P11):** frozen caller
surface `PGRConfiguration class>>fromString:`; the specified-but-internal readers the
accepted suites already use in tests — `project`, `baselineClass`,
`productionPackageNames`, `testsPackageNames`; the specified-but-internal
`PGRRegistry class>>fromConfiguration:` → `registrations` (ordered) / `size`, each
registration answering `name` and `isResolved`. **Construction only — never send
`run`** to any registration here: running the toy's checks against its plants and
asserting verdict outcomes at gate/registry level is E14's demonstration ground.

**Constitution rules that bite here:** configuration artifacts are pure-data STON
(D-16) · tests assert behavior · no `skip` in `Phi-Guardrails-Tests-Toy` · touching
any file outside the manifest is a review rejection · the framework's own
`guardrails.ston` is untouched (the toy has its OWN artifact — owner ground).

DELIVERABLES

Files (Tonel):
- **modify** `src/Toy-Core/BaselineOfToy.class.st` (add the class-side
  `guardrailsSTON` method; the `baseline:` method and class definition stay
  byte-identical)
- **create** `src/Phi-Guardrails-Tests-Toy/PGRToyArtifactTest.class.st`

LOC budget: target ~90 · ceiling 300. (The STON text is fixture data — outside the
budget by the chunking rules.)

TESTS FIRST  (`PGRToyArtifactTest`, package `Phi-Guardrails-Tests-Toy`, superclass
`TestCase`)

- `testArtifactParsesAndValidates` *(§1.1 normative-example pin)* — given
  `PGRConfiguration fromString: BaselineOfToy guardrailsSTON`; when the configuration
  is read; then `project` = `'Toy'`, `baselineClass` name = `#BaselineOfToy`,
  `productionPackageNames asSortedCollection asArray` =
  `#('Toy-Core' 'Toy-Persistence' 'Toy-Rules' 'Toy-UI')` and `testsPackageNames`
  contains exactly `'Toy-Tests'` — the matcher-assigned roles land whole (R-47: no
  baseline group involved).
- `testArtifactYieldsTheSixRegistrationsInOrder` *(D-51: the file is the complete
  statement of what runs)* — given
  `PGRRegistry fromConfiguration: (PGRConfiguration fromString: BaselineOfToy guardrailsSTON)`;
  when its `registrations` are read; then `size` = 6, the six `name`s equal the
  digest's list **in that order**, and every registration `isResolved` (nothing
  missing: the map covers, the rules resolve, the tests role is non-empty). No `run`
  is sent.

Fixtures: C01's baseline and app classes; C02's rule and test class (the tests-role
non-emptiness the sixth-registration resolution rests on).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors; both `PGRToyArtifactTest` cases
          listed by name, every previously accepted suite green — ≥254 run once
          E12-C01/C02 are in per the listed serial pick order (250 + C01's 2 + these
          2); ≥259 once C03 is also in; membership + floor, never an exact ceiling.
          **Plus the self-hosted regression leg:**
          `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
          → exit 0, **12 registrations unchanged**, `GATE: GREEN`.

OUT OF SCOPE
- Sending `run` to any toy registration, building a report, or asserting verdict
  colors over the toy config (E14's `ToyDemoTest` ground — do not pre-build).
- A root-level `guardrails.ston` for the toy (that is the §8.4 external copy, M5
  scope) or ANY edit to the framework's own `guardrails.ston`.
- Adding `#src`, `#exempt`, or `#exemptNamePatterns` to the toy artifact (§8.2: none
  of the three belongs in it).
- Touching C01's committed `baseline:` method, any framework package, or any accepted
  test file.

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition:
one commit `E12-C04: the toy artifact — BaselineOfToy class>>guardrailsSTON`, nothing
uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output (sweep + gate
  leg) · deviations (each one-line justified) · new questions for the decision sheet.
