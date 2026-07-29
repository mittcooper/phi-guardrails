# E15-C02 · Guide 1 made real + `testAdoptAndRunSamples`  [depends: E15-C01 · parallel: no]

GOAL      Amend `docs/quickstarts/01-adopt-and-run.md` to D-76's realness law
(every fence genuine and harness-visible, all ⟨verify⟩ markers retired) and add
`PGRQuickstartSamplesTest>>#testAdoptAndRunSamples`, the P-GUIDE-EXEC
adopt-and-run leg that executes guide 1's samples verbatim on every run — the
guides-REAL law's dated debt discharged at its M4 anchor.

TRACE     spec ch. 9 P-GUIDE-EXEC (the `testAdoptAndRunSamples` row — method
name and home are the ch.-9-named surface) · D-59 (one test method per guide;
guide 1's anchor milestone is M4 — confirmed at Gate 3, D-62 item 1) · D-76
(ALL guides REAL; its consequence line binds THIS pass: "illustrative-only
fences are findings there") · D-77 (fence-reshape precedent, option-a species)
· D-64 (real load coordinates) · D-60.a (docs-can't-diverge, the load step) ·
guide 1's own §2 sentence (the CI workflow is the executable, tested copy —
true since E15-C01).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**The harness (accepted E09-C04 surface this chunk drives —
`PGRQuickstartSampleHarness`, package `Phi-Guardrails-Tests-Gate`):**
`samplesIn: aGuideText` → ordered `(infoSymbol -> bodyString)` pairs; a fence
opens/closes on a line **beginning** ``` ``` `` (column 0 — an indented fence is
invisible), info = trimmed lowercased remainder, only `smalltalk`/`ston` fences
are samples. `guideNamed: aFileName` reads `docs/quickstarts/<name>` via the
three-stage locator. `locateUpwardFrom: aDirectory for: partsArray` → file
reference or nil (public enough; the accepted tests use the harness's readers).
`install: body` / `install: body slots: #(…)` compile a fluid-definition +
listing-header sample into the image; `removeInstalled` tears down (callers use
`ensure:`/`tearDown`). The accepted test class `PGRQuickstartSamplesTest` has
`newHarness` (tracked, torn down in the accepted `tearDown`) and the two
accepted methods `testWriteACheckSamples` / `testBuildAKitSamples` — **all
accepted methods stay byte-identical; this chunk only adds.**

**Frozen caller surfaces used (E02/E03/E05/E12 digests; all re-probed live at
cut, probes.md P3):** `PGRConfiguration class>>fromString:` / `fromFile:`
(signals `PGRConfigurationError` on defect, before anything runs) ·
`PGRGate class>>forConfiguration:` · instance `onVerdict:` / `run` →
`PGRReport` (`verdicts` · `isClean` · `exitCode` · `blockingVerdicts`) ·
verdict `registrationName` / `status` / `isGreen` ·
`PGRConfigurationDraft class>>draftFor:` (E12; answers a STON draft string).

**Cut-time probe facts this order builds on (probes.md P3–P5, work image at
head `181709f`, src byte-identical to the E14 checkpoint head):**

- The committed guide 1 yields only **3** harness samples (§1 config · §3
  in-image run · §3 defective-config handler) — its §2 Metacello fence is
  **indented** inside list item 2, so `samplesIn:` never sees it.
  De-indented to column 0 it parses; the guide's own §2 bash fence already sits
  at column 0 after list item 3, so the markdown shape has precedent in-file.
- A scratch Acme world (`BaselineOfAcme` + `Acme-Core`/`Acme-Server`/
  `Acme-Tests`, installed through the harness with a `<baseline>`-pragma
  `baseline:` method) satisfies fence 1 **verbatim**: `fromString:` parses it,
  the gate answers exactly the guide's four registration names in order —
  `lint/PCKNoIsNilIfTrueRule` · `lint/ReCodeCruftLeftInMethodsRule` ·
  `behavioral/Acme-Tests` · `behavioral/PCKNoSkippedTestsMetaRule` — and with
  clean scratch code `isClean` is `true`, `exitCode` `0`.
- `PGRConfigurationDraft draftFor: 'BaselineOfAcme'` answers a draft that
  `fromString:` accepts (project `'Acme'`).
- Block-wrap execution is sound: `OpalCompiler new evaluate:`
  `'[:path | ' , fenceBody , ' ]'`, then `value: aPathString` — the fence bytes
  stay verbatim inside the wrapper; a fence whose temps line leads
  (`| config gate report |`) is legal as a block body.
- Growing the baseline with an unmatched `Acme-Benchmarks` makes `fromString:`
  signal `PGRConfigurationError` (`Packages assigned to no role:
  Acme-Benchmarks`) — guide §5 failure 1's class, exactly.
- The rule-name typo variant (`PCKNoIsNilIfTrue`) yields a `#missing` verdict
  named `lint/PCKNoIsNilIfTrue` and `exitCode` 1 — §5 failure 2; the
  loaded-but-nonconforming variant (`OrderedCollection`) signals
  `PGRConfigurationError` at `fromString:`.
- **Syntax-check spelling:** `OCParser parseExpression: src` answers a node
  whose `isFaulty` is `false` for the clean Metacello expression and **signals
  `OCCodeError`** on broken source (`OpalCompiler new source:…; parse` is NOT
  discriminating — it method-parses and answers faulty nodes for both; do not
  use it).
- `harness locateUpwardFrom: FileSystem workingDirectory for:
  { '.github'. 'workflows'. 'ci.yml' }` finds the committed workflow from the
  test image locally. **In CI the working-directory walk is NOT the path that
  works** (B-26: the guide reader's green in CI validated the
  SmalltalkCI-global / image-directory fallbacks as the real CI path) — so the
  workflow read MUST chain all three locator stages exactly as the harness's
  own `guideNamed:` does:

  ```smalltalk
  parts := { '.github'. 'workflows'. 'ci.yml' }.
  found := (harness locateUpwardFrom: FileSystem workingDirectory for: parts)
      ifNil: [ (harness smalltalkCILocateFor: parts)
          ifNil: [ harness locateUpwardFrom: FileLocator imageDirectory for: parts ] ].
  ```

  (all three sends are existing accepted harness methods; `found contents`
  answers the text; a nil after all three is a loud assertion failure, never
  a skip).
- Scratch-file idiom (accepted `PGRConfigurationTest` shape): a
  `FileSystem workingDirectory / 'pgr-e15-scratch'` directory created at the
  arm's start and `ensureDeleteAll`'d in an `ensure:` block.

**Guide amendments this chunk makes (the D-76/D-77-species reshapes, exact
target texts; agent-judged at cut, recorded veto-open in `chunks.md`):**

1. **Header paragraph** (the italic block ending "…P-GUIDE-EXEC).*"): replace
   with: `*Every sample below is executed verbatim on every test run by`
   `` `PGRQuickstartSamplesTest>>#testAdoptAndRunSamples` `` `(spec ch. 9,
   P-GUIDE-EXEC) — a sample the framework no longer satisfies is a red test,
   not a stale document.*` — this retires the guide-1 untested-claim marker
   (the M1-gate note) and the "unexecutable until M4" sentence.
2. **§2 Metacello fence**: de-indent to column 0 (list item 2's prose keeps its
   number; the fence follows at column 0 exactly as the §2 bash fence already
   does) and replace `<org>` with the D-64 real coordinates. Target fence body:

   `Metacello new` / `    baseline: 'PhiGuardrails';` /
   `    repository: 'github://mittcooper/phi-guardrails:main/src';` / `    load.`

3. **§3 fence**: `config := PGRConfiguration fromFile:
   '/path/to/acme/guardrails.ston'.` becomes `config := PGRConfiguration
   fromFile: path.`, and the prose sentence before the fence gains: "with
   `path` holding your config file's location as a string". Everything else in
   the fence byte-unchanged.
4. **§3's defective-config fence (the guide's 4th sample, lines 131–135)**:
   the handler becomes
   `do: [ :err | err messageText "one line naming the offending key, package, or class" ]`
   — a comment-only handler answers nil and demonstrates nothing (D-76:
   stub bodies wearing sample costume are defects); `err messageText` is real,
   probed behavior.
5. **All ⟨verify⟩ markers retired** (9 occurrences — lines 5 · 22 · 60 · 66 ·
   69 · 95 · 111 · 129 · 147 of the committed guide: header, §1 config, §1
   draft prose, §2 recipe, §2 load fence, §2 report shape, §3 no-default
   output, §3 defective config, §5 wording note — confirm the count by grep
   before and after: after = 0). Each is discharged by a named arm below or by
   E15-C01's live CI legs (the §2 recipe/report-shape/exit-code rows: the
   committed workflow now executes the recipe and prints the real report on
   every run). The §5 "wording is representative, not contractual" disclaimer
   sentence STAYS — P-GUIDE-EXEC pins error *classes*, never wording.

No other guide content changes; §2's bash fence, the exit-code table, the
report-shape untagged fence, §4's and §5's prose, and the closing citation block stay
(the citation block may gain nothing — ruling trails are maintainer-facing
history).

**Consumers of the amended surfaces (scripted at cut over the 136-file
committed code+docs+infra scope; re-run before commit):** no committed `src/`
file references `01-adopt-and-run` (the harness test pins guides 2 and 3
only); the sole committed reference to the guide's workflow sentence is the
guide itself. **Amended accepted surface: none** — the accepted
`PGRQuickstartSamplesTest` methods are byte-identical (reviewer diffs this);
the guide is producer-owned documentation whose M4 amendment D-76's
consequence line schedules explicitly.

**Constitution rules that bite here:** tests assert behavior (every arm below
has a failure mode); no network at test run time (constitution §2 — the
Metacello fence is therefore executed to the **compile boundary** in-image,
its live execution being E15-C01's hosted load on every CI run; the arm also
pins guide↔workflow textual equivalence so the docs cannot diverge — D-60.a's
standing form); scratch files are created and deleted by the test; no
`isKindOf:`/`class ==` (assert error classes via `should:raise:`, never by
type predicate on a caught instance).

DELIVERABLES

Files:
- **modify** `docs/quickstarts/01-adopt-and-run.md` (the five amendments
  above, exactly; amendment 4's target is §3's second — defective-config —
  fence, the guide's 4th sample).
- **modify** `src/Phi-Guardrails-Tests-Gate/PGRQuickstartSamplesTest.class.st`
  — add `testAdoptAndRunSamples` plus the fixture helpers below; extend the
  class comment with one sentence naming the new leg; accepted methods
  byte-identical.

Methods to add (`PGRQuickstartSamplesTest`):
- `acmeWorldSources` (fixtures) — answers the ordered collection of
  harness-`install:` source strings for the scratch Acme world:
  `BaselineOfAcme` (in package `'BaselineOfAcme'`, with the `<baseline>`
  pragma method declaring packages `'Acme-Core'` `'Acme-Server'`
  `'Acme-Tests'`), one clean class in `Acme-Core`, one in `Acme-Server`, and
  one passing `TestCase` in `Acme-Tests` (e.g. `AcmeSmokeTest>>testTruth`,
  `3 + 4 = 7`) — clean under both catalog lint rules and the no-skips
  meta-rule.
- `installAcmeWorldOn: aHarness` (fixtures) — installs each source via
  `aHarness install:`. The baseline source's probed shape (P3 — reuse it):

  ```
  BaselineOf << #BaselineOfAcme package: 'BaselineOfAcme'
  BaselineOfAcme >> baseline: spec
  	<baseline>
  	spec for: #common do: [ spec package: 'Acme-Core'; package: 'Acme-Server'; package: 'Acme-Tests' ]
  ```

- `committedWorkflowText` (fixtures) — reads `.github/workflows/ci.yml` via
  the three-stage locator chain from the context digest; loud error on nil.
- `testAdoptAndRunSamples` (tests) — the contract skeleton below; one method,
  the D-59 shape, arms failing individually with named assertions.

LOC budget: target ~140 (test + helpers; the guide's prose edits are
documentation, counted loosely) · ceiling 300.

TESTS FIRST  (`PGRQuickstartSamplesTest>>#testAdoptAndRunSamples`)

Given/when/then per arm — fill in, watch it fail against the *unamended*
guide (arm 1 fails on count 3 ≠ 4: the tests-first red), amend the guide,
implement to green:

1. **Inventory pin** — given the committed guide 1 via
   `harness guideNamed: '01-adopt-and-run.md'`; then `samples size` = 4 and
   `(samples collect: [ :s | s key ]) asArray` =
   `#(ston smalltalk smalltalk smalltalk)` (the amended fence inventory —
   an indented or re-tagged fence reds this arm).
2. **Acme world** — given `installAcmeWorldOn: self newHarness` (tracked
   harness; teardown removes all).
3. **Sample 1 (the config) runs the gate** — when
   `PGRGate forConfiguration: (PGRConfiguration fromString: s1)` runs; then
   the report's `registrationName`s equal, in order,
   `#('lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule'
   'behavioral/Acme-Tests' 'behavioral/PCKNoSkippedTestsMetaRule')`, and
   `isClean` is true, `exitCode` 0 — the guide's four registrations, green on
   a clean adopter.
4. **The draft prose claim** — when
   `draft := PGRConfigurationDraft draftFor: 'BaselineOfAcme'`; then
   `PGRConfiguration fromString: draft` answers without signaling (the §1
   "answers a draft of this file" claim, made testable).
5. **Sample 2 (the load expression) compiles clean and cannot diverge from
   the workflow** — then `(OCParser parseExpression: s2) isFaulty` is false
   (an `OCCodeError` signal also reds the arm); and s2 includes both
   `baseline: 'PhiGuardrails'` and
   `repository: 'github://mittcooper/phi-guardrails:main/src'`; and
   `self committedWorkflowText` (the three-stage locator helper) includes the
   same two substrings — guide and workflow carry the one real load form
   (D-60.a's standing witness; live execution is the CI run's).
6. **Sample 3 executes verbatim under the path binding** — given scratch dir
   `pgr-e15-scratch` containing `acme.ston` = s1's bytes; when
   `(OpalCompiler new evaluate: '[:path | ' , s3 , ' ]') value: thePath`;
   then it answers the fence's last expression — `blockingVerdicts` — empty
   on the clean world (and the evaluation itself proves every line of §3
   runs: `fromFile:` → `forConfiguration:` → `onVerdict:` → `run` → the three
   readers). Wrap in `ensure:` deleting the scratch dir.
7. **Sample 4 executes verbatim, both ways** — when the same block-wrap runs
   s4 with a path to a scratch `bad.ston` (malformed STON bytes, e.g.
   `'{ #schemaVersion : 2, #junk }'`); then it answers the handler's
   `err messageText` (a non-empty String — the error was caught); when run
   with the good `acme.ston` path, it answers the parsed configuration —
   asserted duck-typed (`result project` = `'Acme'`, probed P3; never a type
   predicate); and directly,
   `should: [ PGRConfiguration fromFile: badPath ] raise:
   PGRConfigurationError` — "a defective configuration signals before
   anything runs", by class, never wording.
8. **§5 failure 2 — the typo is a missing verdict** — when the gate runs
   `s1 copyReplaceAll: 'PCKNoIsNilIfTrueRule' with: 'PCKNoIsNilIfTrue'`;
   then one verdict is named `'lint/PCKNoIsNilIfTrue'` with `status`
   `#missing` and the report's `exitCode` is 1; and the nonconforming
   variant (`with: 'OrderedCollection'`) makes `fromString:` signal
   `PGRConfigurationError` — §5's exit-1-vs-exit-2 split, asserted by class
   and verdict, not wording.
9. **§5 failure 1 — a package in no role (LAST: it mutates the scratch
   baseline)** — when `Acme-Benchmarks` is installed (harness) and
   `BaselineOfAcme`'s `baseline:` is recompiled (harness listing-header
   install) to include it; then `PGRConfiguration fromString: s1` signals
   `PGRConfigurationError` — the §5-1 claim; no restoration needed (teardown
   removes the world; no arm follows).

Fixtures: `acmeWorldSources` (this chunk); the committed guide; the committed
workflow; scratch dir per arms 6–7.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors — all THREE
          `PGRQuickstartSamplesTest` methods listed by name
          (`testAdoptAndRunSamples` new) + every previously accepted suite,
          ≥267 run (266 at cut + this 1); membership + floor.
          **Plus the self-hosted regression leg:**
          `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
          → exit 0, **12 registrations unchanged**, `GATE: GREEN`.
          **Plus:** `grep -c '⟨verify⟩' docs/quickstarts/01-adopt-and-run.md`
          → 0. **Plus the CI leg re-proving on this head** (the two-step
          workflow from E15-C01 sweeps the new test in step 1):
          `gh run list --workflow=ci.yml --limit 1` → `completed success`.

OUT OF SCOPE
- Any edit to `PGRQuickstartSampleHarness` (frozen-shape accepted machinery;
  a fence the harness cannot parse is a guide reshape per D-77, never a
  harness extension).
- Any edit to guides 2/3, the accepted test methods, `.github/`,
  `guardrails.sh`, `tools/`, or the spec.
- Executing the Metacello load over the network in-image (constitution §2;
  the compile-boundary + equivalence arm is the ruled shape here — a
  stop-and-report if it proves insufficient, never a silent network call).
- The D-13 timings (E15-C03).

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67).
Postcondition: one commit `E15-C02: guide 1 REAL + testAdoptAndRunSamples`,
nothing uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output (sweep +
  gate leg + CI run id) · the marker-retirement count (9 → 0) · deviations
  (each one-line justified) · new questions for the decision sheet.
