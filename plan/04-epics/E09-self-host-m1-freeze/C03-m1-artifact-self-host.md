# E09-C03 · `guardrails.ston` — the M1 artifact, self-hosted green    [E09 · depends: — · parallel: yes]

GOAL      Commit the framework's own configuration artifact in its M1 form
          and prove the repo green under its own gate
          (`./guardrails.sh guardrails.ston` → exit 0), planting the two
          real pin tests without which the tests role cannot be complete.

TRACE     R-38 (M1 form) · R-15 (self-hosting) · R-47 (self-adoption
          proof) · R-05 (the framework eats its own rule) · ch. 7 §7.5
          (minus the M2 entries) · ch. 9 P-SELF-HOSTED (M1 form) ·
          constitution §3 ("from M1 the repo's own gate must also pass") ·
          D-25, D-26, D-51, D-57 · D-75 (citable: the unloadable-image
          relay is irrelevant to this green path) · roadmap §1 M1
          checkpoint.

## CONTEXT DIGEST

**The M1 artifact form (owner-ruled ground):** ch. 7 §7.5 **minus** the two
architecture entries and `#layerMap`/`#src` — the artifact grows as checks
land (constitution §3); do not anticipate M2 entries. Concretely, commit
exactly this at the repo root as `guardrails.ston` (pure-data STON, D-16;
`#project : 'PhiGuardrails'` is this cut's naming call, recorded veto-open
in `chunks.md` — it feeds only the human-facing report header):

```ston
{
	#schemaVersion : 2,
	#project : 'PhiGuardrails',
	#baseline : 'BaselineOfPhiGuardrails',
	#roles : {
		#production : [ 'production' ],
		#tests : [ 'tests' ],
		#exempt : [ 'fixtures', 'toy' ] },
	#exemptNamePatterns : [ 'Phi-Coding-Kit-Fixtures-.*', 'Toy-.*' ],
	#kits : [ {
		#kit : 'PCKKit',
		#lintRules : [ 'PCKNoIsNilIfTrueRule', 'ReCodeCruftLeftInMethodsRule' ],
		#metaRules : [ 'PCKNoSkippedTestsMetaRule' ] } ]
}
```

Role matchers are baseline **group names** (resolution order: group name
first — E03's frozen pipeline); the groups exist frozen since E01:
`production` = the seven production packages, `tests` = the seven
`*-Tests-*` packages, `fixtures` = `Phi-Coding-Kit-Fixtures-Behavioral`,
`toy` = the five `Toy-*` packages. Every exempt-role package full-matches
one of the two `#exemptNamePatterns` and no production/tests package
matches any — the committed baseline satisfies this today.

**What the gate will derive from it (10 registrations, four-stage order):**
`lint/PCKNoIsNilIfTrueRule` · `lint/ReCodeCruftLeftInMethodsRule` (both
over the production role) · `behavioral/<pkg>` for each of the seven
tests-role packages (each runs that package's suite; `#missing` if the
package holds **zero test classes** — the frozen E07 semantics) ·
`behavioral/PCKNoSkippedTestsMetaRule` (over the tests role, riding the
same run cache). Exit 0 iff all ten are green.

**The forced move this chunk carries (agent call, recorded veto-open in
`chunks.md` — forced by R-38 × the frozen E07 missing semantics × the
§7.5 roles; only the *content* of the tests is chosen):** two tests-role
packages are classless stubs today — `Phi-Guardrails-Tests-Toy` (filled at
E14) and `Phi-Coding-Kit-Tests-Architecture` (filled at E10) — so their
derived registrations would be `#missing` and the gate could never answer
0. Each gets **one real test class now** (below): real, decidable,
permanent facts — never `assert: true` placeholders (a test that cannot
fail is a defect). E10/E11/E14 extend these packages additively; E11's cut
amends the M1-form pin by schedule when the artifact grows.

**Pin class 1 — `PGRToySweepExemptionTest`** (package
`Phi-Guardrails-Tests-Toy`; subject: the toy family's sweep exemption,
D-26/D-57 — the guard that lets the toy be committed red at M4 without
reddening the verify sweep). Baseline introspection idiom (the accepted
`PGRBaselineSmokeTest` spellings — duplicate them locally; helper
duplication across test classes is deliberate self-containment, the
E05-C03 recorded stance):

```smalltalk
version        ^ (Smalltalk globals at: #BaselineOfPhiGuardrails) project version
packageNamesFor: aGroupName
               ^ ((self version packagesForSpecNamed: aGroupName)
                     collect: [ :each | each name ]) asSortedCollection asArray
```

Pattern matching: full-match regex (`matchesRegex:` — the D-57/E03 dialect;
⟨verify⟩ the exact spelling in-image, record it). The two tests-family
patterns, verbatim: `'Phi-Guardrails-Tests-.*'` and
`'Phi-Coding-Kit-Tests-.*'`.

**Pin class 2 — `PCKArtifactBlockM1FormTest`** (package
`Phi-Coding-Kit-Tests-Architecture`; subject: the architecture kind's
not-yet state — the coding-kit block of the framework's own artifact is
M1-form: no architecture entries yet, and everything it does name resolves).
It reads the committed `guardrails.ston` from disk (tests may do file I/O —
P-DETERMINISTIC binds production packages only) and drives **only**
`PCKKit class>>registrationsFrom:productionPackages:testsPackages:` with
scratch role lists — reading the repo's own config is not invoking the gate
on it (§8.1's residual caveat bans only the gate invocation). **P-SDK-EDGE
bites here:** this class may reference `STON`, `PCKKit`, and SDK classes,
but never `PGRConfiguration`, `PGRRegistry`, or any `-Core`/`-Gate` class
(the E07-recorded reading covers kit tests).

Repo-root locator for pin class 2 (duplicated tiny helper, same stance):
walk upward (≤ 8 levels) from `FileSystem workingDirectory`, then from
`FileLocator imageDirectory`, for a directory containing `guardrails.ston`;
none found → `self error:` (loud — never skip). Local runs launch from the
repo root; the work image sits at `.build/work/`, two levels under it.

**PCKKit facts you build against (frozen E06/E07 surface, verbatim from
the accepted source):** `registrationsFrom:productionPackages:testsPackages:`
validates the block strictly (unknown key → `PGRConfigurationError`),
answers specs in the four-stage order — for the M1 block over
`productionPackages: #('P-One') testsPackages: #('T-One')` exactly:
`lint/PCKNoIsNilIfTrueRule` · `lint/ReCodeCruftLeftInMethodsRule` ·
`behavioral/T-One` · `behavioral/PCKNoSkippedTestsMetaRule`, each spec
answering `name`/`kind`/`check` (`check` non-nil = resolved;
`PGRRegistrationSpec` readers, E02-frozen).

**The self-hosted run (the chunk's second instrument):** after
`bash tools/build-image.sh` (fresh work image from the committed tree):

```bash
PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo \
IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston
```

expected exit **0**, stdout: header `PGR gate · PhiGuardrails · 10
registrations`, ten `[ GREEN ]` verdict lines, summary `GATE: GREEN — 0
blocking of 10 · exit 0` (assert exit code and GREEN/10 substrings, never
byte-exact renderings — the printed text is not an API). The committed
`guardrails.sh` (E05-frozen) relays 0/1/2 and maps anything else to 3.

**If the run is red on accepted ground** (a lint hit or failing suite in
accepted code): **stop and report** (decision sheet) — fixing files outside
this manifest is forbidden. Pre-flight at cut time found production code
clean under both rules and no skips anywhere; the residual risk is the
built-in cruft rule's exact match set.

**Constitution rules that bite here:** the gate is headless, CI is the
contract (P4) — but CI *step 2* is E15's per the frozen roadmap: **this
chunk does not touch `.github/workflows/ci.yml`** (the E05-C07 aside "step
2 arrives at E09" refers to the artifact's availability; the two-step
upgrade is E15's row — divergence note recorded in `chunks.md`). Nothing
in this repo writes outside the sanctioned roots — `guardrails.ston` is a
named root artifact (constitution §2).

## DELIVERABLES

- `guardrails.ston` — new, repo root: the M1 artifact, byte-content as
  specified above.
- `src/Phi-Guardrails-Tests-Toy/PGRToySweepExemptionTest.class.st` — new:
  3 tests.
- `src/Phi-Coding-Kit-Tests-Architecture/PCKArtifactBlockM1FormTest.class.st`
  — new: 3 tests + the locator helper.
- Nothing else — no CI change, no baseline change, no `tools/` change.
- LOC budget: target 110 / ceiling 300 (the artifact is configuration
  data — outside the code budget; counted anyway it adds ~15).

## TESTS FIRST

`PGRToySweepExemptionTest`:
- `testToyTestsPackageMatchesNeitherTestsFamilyPattern` — given the name
  `'Toy-Tests'`; when full-matched against both tests-family patterns;
  then neither matches — the D-26 committed-red discipline's guard: the
  toy's future red tests can never enter the verify sweep.
- `testEveryToyPackageMatchesTheExemptNamePattern` — given the baseline's
  `toy` group expansion; then every member full-matches `'Toy-.*'` and the
  expansion is non-empty (the §7.5 `#exemptNamePatterns` fact).
- `testToyGroupIsTheFiveToyPackages` — given the baseline's `toy` group;
  then it expands to exactly `Toy-Core` · `Toy-UI` · `Toy-Persistence` ·
  `Toy-Rules` · `Toy-Tests` (sorted — the frozen E01 inventory pin).

`PCKArtifactBlockM1FormTest`:
- `testCodingKitBlockIsTheM1Form` — given the committed `guardrails.ston`
  parsed with `STON fromString:`; then `#kits` holds exactly one block,
  its keys are exactly `#kit` / `#lintRules` / `#metaRules` (no
  `#architectureChecks`, no `#layerMap`), and the artifact map carries no
  `#src` key (E11 amends this test by schedule when the artifact grows).
- `testM1BlockRegistersLintAndMetaOnly` — given that block handed to
  `PCKKit registrationsFrom:productionPackages: #('P-One')
  testsPackages: #('T-One')`; then the spec names are exactly
  `#('lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule'
  'behavioral/T-One' 'behavioral/PCKNoSkippedTestsMetaRule')` in order —
  no `architecture/` name at M1.
- `testEveryNamedCheckResolves` — given the same specs; then every spec's
  `check` is non-nil — the committed artifact names no unloadable check
  (a missing registration in the self-hosted gate is a build failure,
  P6/R-38).

Fixtures: the committed artifact itself; no scratch files.

VERIFY    Two instruments, same commit:
          1. `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
             0 failures, 0 errors; output lists the 6 new methods (3
             `PGRToySweepExemptionTest` + 3 `PCKArtifactBlockM1FormTest`)
             **plus every previously accepted suite** — membership plus a
             floor (≥ 180 run = 174 + 6; parallel-landed E09 chunks add to
             the count), never an exact ceiling.
          2. `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo
             IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
             — exit 0; stdout carries `PhiGuardrails`, `10 registrations`,
             and `GATE: GREEN` (paste the full output into the completion
             report).

OUT OF SCOPE
- `#src`, `#architectureChecks`, `#layerMap` in the artifact (M2 — E10/E11).
- `.github/workflows/ci.yml` (E15's two-step upgrade) and `.smalltalk.ston`.
- Any edit to `guardrails.sh`, the baseline, or any accepted file; any fix
  to accepted code if the gate runs red — stop and report instead.
- A placeholder/trivial test in either stub package — the pin tests above
  are the whole grant.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `E09-C03: M1 guardrails.ston, self-hosted green` (D-73) before
          reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  the full `./guardrails.sh guardrails.ston` output and exit code ·
  the recorded ⟨verify⟩ spellings (`matchesRegex:` form, STON read form) ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
