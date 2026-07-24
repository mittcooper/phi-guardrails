# Decision Log — phi-guardrails

*Numbered, append-only record of rulings. Each entry cites its decision-sheet question.
Per the standing rules, this log wins on any conflict with older prose.*

---

## D-01 · Registry representation: declarative per-project configuration artifact

- **From:** Q-01 (`plan/01-decision-sheet.md`) · **Ruled by:** human, Gate 1 · **Date:** 2026-07-09
- **Ruling:** Option (a). Registrations are declared in a per-project **configuration
  artifact** (STON file in the client repo). A gate run loads it into an explicit,
  inspectable registry object (`PGRegistry`) — no global state, no image-scan discovery.
  The global-scope catalog is a shipped default artifact that the project artifact extends.
- **Why it holds:** explicit wiring (family 4), one named owner of "what runs" (family 6,
  P6), and the registration set is diffable in git — an agent cannot quietly deselect a
  check without a visible diff (P6).
- **Consequences:** "missing" is decidable per kind (a named rule class not loaded, a
  pattern matching nothing); the layer map travels in the same artifact per Q-06's
  recommendation (still to be ruled); spec ch. 1 specifies the artifact's schema.

**Illustrative example only** — field names and classes are spec (Prompt 2) material, not
part of this ruling:

```ston
PGProjectConfig {
    #project : 'Toy-Client',
    #packages : [ 'Toy-Core', 'Toy-UI', 'Toy-Persistence' ],

    #lintRules : [
        'PGNoIsNilIfTrueRule',          "from the shipped global catalog"
        'ToyNoDirectLoggingRule'        "the client's own, from its extension package"
    ],

    #layerMap : PGLayerMap {
        #layers : {
            'ui'          : [ 'Toy-UI' ],
            'domain'      : [ 'Toy-Core' ],
            'persistence' : [ 'Toy-Persistence' ]
        },
        #allowed : [ [ 'ui', 'domain' ], [ 'domain', 'persistence' ] ]
    },

    #testPackages : [ 'Toy-Tests-.*' ]
}
```

Reading it: `packages` = "here is my code; check these" · `lintRules` = the rule classes
that apply, shipped and project-own in one list (the two scopes) · `layerMap` = "UI may
talk to domain, domain to persistence, nothing else" · `testPackages` = suites that must
exist, run, and be green — a pattern matching nothing is *missing* and fails the gate.

---

## D-02 · Image-verification pass: dedicated session before Prompt 2

- **From:** Q-02 (`plan/01-decision-sheet.md`) · **Ruled by:** human, Gate 1 · **Date:** 2026-07-09
- **Ruling:** Option (a). A dedicated verification session runs **before the spec stage
  (Prompt 2)**: bootstrap Pharo 13 headless + smalltalkCI on this machine, run a probe
  script covering every in-scope ⟨verify-in-image⟩ spelling, and record each confirmed or
  corrected spelling in this log. No spec statement may rest on an unverified spelling (P5).
- **Scope of the probe** (from Q-02's list): Renraku rule base classes and hooks ·
  `RBParseTreeSearcher`/`RBParseTreeRewriter` API · critic severity hooks · SUnit
  skip/expected-failure mechanics · smalltalkCI critics option · Epicea event names
  (`EpMethodModification`, …) · method author-stamp API · the compiled-method
  referenced-classes query (`literals` / `isBehavior`) · `PG` class-prefix survey (feeds
  Q-11) · the pack's verify-command spelling (`test --fail-on-failure`).
- **Why it holds:** P5 is categorical — verify before any design statement depends on the
  spelling; piecemeal or deferred verification is the half-checked spec P5 exists to
  prevent. The toolchain bootstrap is M0 prework the verify command needs anyway.
- **Consequences:** the Pharo 13 VM/image + smalltalkCI install happens now-ish, before
  Prompt 2; probe results land here as D-entries or an appendix; Q-11 (PG prefix) is
  answered by the same session's survey.

**Appendix D-02.a · Probe map** — what each ⟨verify-in-image⟩ element is used for, and
which guardrail area it serves:

| Element to verify | Used for | Guardrail it maps to |
|---|---|---|
| **Renraku base classes** | The class our rules subclass — makes them appear in the Critic Browser/badge and be runnable by the gate | Lint / Code Quality |
| **Rewriter API** (`RBParseTreeSearcher`/`Rewriter`) | Searcher matches the bad code pattern in the AST; Rewriter performs the autofix | Lint / Code Quality |
| **Severity hooks** | How a rule declares `#error` vs `#warning` — feeds D-03's "only errors block" | Lint / Code Quality |
| **SUnit skip mechanics** | How the no-skips meta-rule detects a skipped or expected-failure test in a test result | Behavioral Tests |
| **smalltalkCI critics option** | The CI flag that runs critics headless — Q-13/Q-10 decide whether it or our gate does the running | CI |
| **Epicea event names** | Change-log mining: tally repeatedly-rewritten methods → candidate new rules (v1-widen; eval harness itself is out of scope) | Improvement / Evals |
| **Author-stamp API** | "Apply rules only to my code" scoping (v1-widen) | Lint / Code Quality (scoping) |
| **`literals` / `isBehavior` query** | Asks a compiled method which classes it references — the query behind the layer-dependency test | Architecture |
| **`PG` prefix survey** | One-time check that no loaded class already starts with `PG` (Q-11) | — (naming hygiene, M0) |

---

## D-03 · Severity taxonomy: two-tier — warnings are not errors

- **From:** Q-03 (`plan/01-decision-sheet.md`) · **Ruled by:** human, Gate 1 · **Date:** 2026-07-09
- **Ruling:** Option (a), two-tier. **Lint rules** block the gate only at `#error`
  severity; lower severities (warning, information) are reported in the gate's output and
  surface as agent guidance, but never fail the build. **Architecture tests and behavioral
  suites always block** — a broken layer or a red test has no warning grade. The gate's
  full failure condition stays: missing ∨ skipped ∨ red registration ∨ `#error` criticism.
- **Why it holds:** P6 is preserved by definition — a rule registered at `#error` *is* red
  when it fires; sub-`#error` findings are advisory context (R-13), matching S1 Phase 6 and
  smalltalkCI convention. Blocking on every nit would push clients to unregister rules,
  defeating P6 socially; a per-client threshold is a knob v1 doesn't need (family 5).
- **Consequences:** resolves the P6 ↔ S1 conflict cited at Gate 1; spec ch. 2 defines the
  severity set and the blocking rule; ch. 7 states the failure condition verbatim; each
  catalog rule declares its severity explicitly (R-14).

---

## D-04 · v1 skeleton lint rule: `isNil ifTrue:` → `ifNil:` (with autofix)

- **From:** Q-04 (`plan/01-decision-sheet.md`) · **Ruled by:** human, Gate 1 · **Date:** 2026-07-09
- **Ruling:** Option (a). The one v1 lint rule (R-15) matches `` `@x isNil ifTrue: [`@block] ``
  and autofixes to `` `@x ifNil: [`@block] `` — a semantics-preserving rewrite, self-hosted
  on the framework's own code, shipped with the standard bad/good fixture pair (R-37).
- **Why it holds:** the only candidate whose fix is genuinely automatic *and* provably
  behavior-preserving — P1's "fixes, not flags" in full; it is also the source's own
  rewriter example, so pattern spelling is already sketched (verified per D-02).
- **Consequences:** spec ch. 3's first catalog entry; M1's demo. Swallowed-error joins the
  widened catalog flag-only; no-`self halt` is a later second rule.

---

## D-05 · Built-in Code Critics: excluded unless explicitly registered by name

- **From:** Q-13 (`plan/01-decision-sheet.md`) · **Ruled by:** human, Gate 1 · **Date:** 2026-07-09
- **Ruling:** Option (a). The gate runs **only registered checks**. Pharo's shipped Renraku
  rules do not block implicitly; **a few proven built-ins may be added to the global
  catalog by name** (they are rules like any other). smalltalkCI's own critics option stays
  off in favor of the gate's registry.
- **Why it holds:** P6 — registration decides what runs; the blocking set stays explicit
  and diffable (family 4 · 6) instead of tracking whatever rule set the image ships.
- **Consequences:** spec ch. 2 defines how a built-in is registered by name; selecting
  *which* proven built-ins enter the v1 catalog (possibly none) is a spec-stage choice,
  informed by the D-02 session's look at what Pharo 13 actually ships.

---

## D-06 · Autofix invocation: explicit command with mandatory preview; agent may invoke

- **From:** Q-05 (`plan/01-decision-sheet.md`) · **Ruled by:** human, Gate 1 · **Date:** 2026-07-09
- **Ruling:** Option (b). Autofixes are applied only by an **explicit fix command** scoped
  to a target ("apply fix F to package P"), with a **mandatory preview step**: the
  before/after diff is produced and confirmed before anything changes. Changes go through
  the refactoring engine — Epicea-recorded and undoable.
  **The invoker may be the human or the working agent**: an agent running the fix command
  (and confirming its preview) during its edit loop is a legitimate explicit invocation.
  What remains forbidden is silent mutation as a side effect of *checking* — the gate only
  reports, never rewrites.
- **Division of labor:** the **rule** carries the recipe (pattern → replacement); the
  **framework's fix command** applies it; the **invoker** (human or agent) triggers and
  confirms it; the **gate** does none of this.
- **Why it holds:** preview makes "user-invoked" (Pack §5) auditable — instrument, not
  appliance (family 5, 7); wiring fixes into the gate would collide with R-12.
- **Consequences:** spec ch. 3 defines the fix command, its preview form (including what
  "confirm" means for a headless agent invocation: the diff is emitted to the transcript/log
  before apply), and undo/recording guarantees.

---

## D-07 · One config artifact answers every "how does a client provide it" question

- **From:** Q-06, Q-08, Q-16, Q-17, and one slice of Q-09 · **Ruled by:** human, Gate 1 ·
  **Date:** 2026-07-10
- **Shape recognized:** several sheet questions share the shape *"how do clients provide
  configuration information to the framework?"* — distinct from each item's *format*.
  This ruling answers the shared shape **once**: all client-supplied configuration reaches
  the framework through the **single per-project artifact of D-01** (which extends the
  shipped global-catalog artifact). No second channel — no code-built maps, no side files,
  no per-check mechanisms.
- **Per question:**
  - **Q-06 · layer map** — provided as the artifact's layer-map section. Fully ruled;
    section format is spec ch. 4 material.
  - **Q-08 · behavioral suites** — provided as the artifact's test-package section.
    Provision ruled; form adopts the sheet recommendation as working default (**name
    patterns**; a pattern matching zero loaded packages fails as *missing*, R-24) —
    flagged for veto at Gate 2.
  - **Q-16 · promotion** — under one-file-per-side, *promote* concretely means: move the
    registration entry from the project artifact to the global catalog and move the rule
    class into the shipped package, fixtures along. Manual, documented procedure; no
    tooling in v1 (per recommendation).
  - **Q-17 · coverage floors** — declared per registration in the artifact; **no shipped
    default** — values set at M5 from measured baselines (per recommendation).
  - **Q-09 · secrets check (slice only)** — whatever check is ruled, its client-extensible
    pattern list is provided in the artifact. The check's own spec (scan surface, kind,
    shipped patterns) **remains open**.
- **Why it holds:** D-01's principle finished — one diffable file owns "what runs"
  (family 6, P6); a second provisioning channel would reopen the hidden coupling family 0
  forbids.
- **Consequences:** spec ch. 1 defines the artifact schema with one section per check
  kind; chs. 4/5/6 each define their section's format. After this ruling the only open
  question still touching the artifact is Q-09's core.

---

## D-08 · No-skips detection: what the test runner reports — skips and expected failures

- **From:** Q-07 (`plan/01-decision-sheet.md`) · **Ruled by:** human, Gate 1 · **Date:** 2026-07-10
- **Ruling:** Option (a). The no-skips meta-rule (R-25) reads the **test result object** of
  each registered suite's run: any **skipped test or expected failure** in a registered
  package reddens the gate. No static heuristics in this rule.
- **Why it holds:** these are exactly the two escape hatches SUnit officially provides,
  read precisely from the result — machine-checkable with zero false alarms (P1), and
  "skipped" is verbatim one of P6's three failure states. Exact result-object selectors
  are confirmed by the D-02 verification session.
- **Consequences:** spec ch. 5 defines the rule on result-object counts; the
  suspicious-shapes sweep (empty test methods, never-run tests) becomes a **separate
  widened meta-rule** at M5, so its heuristics never muddy this rule's precision.

---

## D-09 · Secrets-leak check: in-image sweep of loaded source

- **From:** Q-09 core (`plan/01-decision-sheet.md`; provision slice ruled in D-07) ·
  **Ruled by:** human, Gate 1 · **Date:** 2026-07-10
- **Ruling:** Option (a). The secrets-leak check (R-28) **sweeps the loaded code in the
  image**: every registered package's method source, string literals, and class comments,
  matched against a pattern list (known token shapes, key-like strings). It registers and
  runs like any other check, ships with the standard bad/good fixture pair (R-37), and its
  pattern list is client-extensible via the D-01 artifact (D-07).
- **Why it holds:** covers the realistic v1 leak surface — code is what agents commit —
  and stays in the framework's reflective idiom (ask the objects, don't parse files);
  fully machine-checkable (P1).
- **Consequences:** spec ch. 6 defines the sweep and the shipped starter pattern list
  (spec-stage choice); the **file-side Tonel/config sweep becomes a widened addition**
  (M5) covering non-code files — a second surface, not part of this check.

---

## D-10 · CI plumbing: plain-object gate + one thin SUnit adapter test

- **From:** Q-10 (`plan/01-decision-sheet.md`; runner half ruled in D-05) · **Ruled by:**
  human, Gate 1 · **Date:** 2026-07-10
- **Ruling:** Option (a). The **gate is a plain object** (no SUnit knowledge), invocable
  from script, agent loop, or Playground. CI reaches it through **one thin adapter
  TestCase** in the tests package — a single test that runs the gate against the project's
  D-01 artifact and asserts the report is clean — so smalltalkCI picks it up as an
  ordinary test. One CI stage, one verdict.
- **Why it holds:** SUnit stays at the edge, core stays kit-neutral (R-04, family 9 —
  foreign shapes live only at the owning boundary); the same gate object serves in-image
  and headless runs (R-30). Gate-as-tests would bake SUnit into the core; a separate CI
  script step doubles plumbing and splits the verdict.
- **Consequences:** spec ch. 7 defines the gate's plain API, the adapter, and the
  `.smalltalk.ston` configuration; the adapter is disposable — removing it changes nothing
  but CI plumbing.

---

## D-11 · Class prefix: `PGR`, decided outright

- **From:** Q-11 (`plan/01-decision-sheet.md`) · **Ruled by:** human, Gate 1 · **Date:** 2026-07-10
- **Ruling:** The class prefix is **`PGR`** ("Phi GuardRails"), chosen now instead of
  surveying `PG` for collisions. The old PostgresV2 driver's `PG…` names make `PG` a known
  (if unlikely) hazard; `PGR` avoids the question entirely and no code exists yet, so the
  rename is free. The `PG` prefix survey is **dropped from the D-02 probe list** (moot).
- **Amendments:** pack §5 and R-36 updated from `PG` to `PGR`. Class names appearing in
  earlier entries (`PGRegistry`, `PGGate`, `PGProjectConfig`, `PGLayerMap`, …) were
  illustrative only (per D-01) and are not renamed retroactively; the spec (Prompt 2)
  assigns the real `PGR…` names.
- **Consequences:** every class in `src/` starts `PGR`; spec (Prompt 2) assigns the real
  names.

---

## D-12 · Toy client: in-repo fixtures for v1, cross-repo proof before broad use

- **From:** Q-12 (`plan/01-decision-sheet.md`) · **Ruled by:** human, Gate 1 · **Date:** 2026-07-10
- **Ruling:** Both options, staged. **(a) now:** the v1 skeleton is demonstrated against
  in-repo fixture packages (`Phi-Guardrails-Toy-*`) — a mini layered app with deliberate
  violations of every v1 check, loaded only by the test/demo baseline group, doubling as
  the bad-fixture farm for R-37. **(b) before broad use:** a genuinely external client
  repository must adopt the framework via Metacello (`BaselineOfPhiGuardrails` dependency +
  its own D-01 artifact) and run the gate green in its own CI **before the framework is
  declared ready for general client use**. phi-llm's onboarding naturally satisfies (b).
- **Definition of the external adoption proof (amended same gate):** (b) is satisfied by a
  **copy of the `Phi-Guardrails-Toy-*` packages moved into its own repository** (e.g.
  `../phi-guardrails-toy`): own git history, own baseline that depends on
  `BaselineOfPhiGuardrails` **via Metacello only** (no source copy of the framework), own
  `guardrails.ston`, own `.smalltalk.ston` — CI loads the framework as a true external
  dependency and runs the gate red → fixed → green. phi-llm's later onboarding then
  re-confirms (b) on a real codebase, but is not required to unblock broad use.
- **Why it holds:** (a) keeps v1 self-contained and CI-runnable with no second repo to
  sync; (b) is the only honest test of cross-repo adoption (R-31) — an in-repo demo cannot
  prove the loading, versioning, and configuration story a real client hits.
- **Consequences:** R-32 (demo) is satisfied by (a) in v1; (b) becomes an exit criterion
  at widening (roadmap: M5 or first-client onboarding, whichever comes first); spec ch. 8
  describes both the toy and the external-adoption checklist.

---

## D-13 · Gate time budget: measure at M4, then rule — working target noted

- **From:** Q-14 (`plan/01-decision-sheet.md`) · **Ruled by:** human, Gate 1 · **Date:** 2026-07-10
- **Ruling:** Option (b). v1 carries **no hard wall-clock budget**. At **M4** (full gate
  running in CI against framework + toy), real timings are measured and the budget is then
  ruled from evidence — a numbered follow-up entry in this log. Until then the **informal
  working target** is: full gate in CI **< 60 s**, in-image incremental run **< 10 s**.
- **Why it holds:** a number invented before anything runs is fake precision (family 1);
  same evidence-first logic as D-08 and P5. The working target keeps R-09's "cheap enough
  to run constantly" pressure real without pretending to knowledge we lack.
- **Consequences:** spec ch. 7's NFR line states the working target as non-binding and
  names the M4 measurement as the point where it becomes a ruled budget.

---

## D-14 · Formatter: out of the v1 gate; format-at-write belongs to the writing tool

- **From:** Q-15 (`plan/01-decision-sheet.md`) · **Ruled by:** human, Gate 1 · **Date:** 2026-07-10
- **Ruling:** Option (a). The v1 gate does **not** enforce formatting. Refinement from the
  ruling discussion: Pharo's formatter is editor tooling only — **programmatically written
  methods (how a Phi agent writes code) bypass it entirely** — so formatting-at-write is
  assigned to the *writing tool*: **phi-agent-runtime's `write_method` should format the
  source string before compiling** (handed to that project's requirements; noted here so it
  isn't lost). A gate-side *detection* rule ("method source differs from formatter output",
  with autofix) remains the **M5 backstop** for code that arrived any other way.
- **Why it holds:** formatting has no failure state worth a v1 build break, and a
  formatter check is the one whose fix the gate itself would be tempted to apply —
  colliding with D-06's check/change separation. Format-at-write keeps the fix at the
  moment of creation, where no approval question even arises.
- **Consequences:** nothing in the v1 spec; M5 catalog gains the detection rule; a
  requirement note travels to phi-agent-runtime when that project's pack is written.

---

## D-15 · Verification session results: every D-02 probe item confirmed or corrected

- **From:** execution of D-02 (the ruled verification pass) · **Ruled by:** live-image
  evidence, recorded by the specification agent · **Date:** 2026-07-10
- **Setup:** Pharo 13 stable (`Pharo13.0-SNAPSHOT-64bit-4c3e4714cc`, image build of
  2026-07-09) + `pharo-vm-Darwin-arm64-stable`, run headless on this machine. Probe scripts
  and raw output: session scratchpad (`probe1.st`–`probe4.st` + eval probes); every claim
  below was executed, not read from docs. smalltalkCI options were verified against the
  hpi-swa/smalltalkCI documentation (file-side, not in-image).

**Confirmed as sketched in S1** (spec may rely on these spellings):

| Element | Verified spelling (Pharo 13) |
|---|---|
| Renraku bases | `ReAbstractRule`, `ReNodeMatchRule`, `ReNodeRewriteRule` (both under `RePatternCodeRule`); checker `ReSmalllintChecker` |
| Rewrite rule API | `ReNodeRewriteRule>>replace:with:` (in `initialize`); `addMatchingExpression:rewriteTo:`, `replaceMethod:with:`; `isRewriteRule` |
| Searcher/Rewriter | `RBParseTreeSearcher`/`RBParseTreeRewriter`: `matches:do:`, `executeTree:`, `executeTree:initialAnswer:`; rewriter `replace:with:`, result via `tree formattedCode`; `CompiledMethod>>ast` |
| The D-04 rewrite | `'`@x isNil ifTrue: [`.@block]'` → `'`@x ifNil: [`.@block]'` executed end-to-end on a parsed method — matched and produced `ifNil:` source (note the `` `.@ `` statement-list wildcard) |
| Severity values | `#error` / `#warning` / `#information`; default `#warning` (`ReAbstractRule class>>severity`) |
| Headless lint run | `ReSmalllintChecker new rule: {r}; environment: (RBPackageEnvironment packageName: 'X'); run; criticsOf: r` — produced the expected critique on a live fixture |
| Critique → autofix | critique `providesChange` → `change` (an `RBAddMethodChange`) → `execute` recompiled the method (verified before/after source); preview text via `textToDisplay` / `oldVersionTextToDisplay`; `RBRefactoryChangeManager` provides undo |
| SUnit result object | `TestResult`: `skippedCount`/`skipped`, `expectedDefectCount`/`expectedDefects`, `failureCount`, `errorCount`, `passedCount`, `runCount`, `hasPassed`. Live semantics: skipped tests are **not** in `runCount`; an expected failure counts as passed **and** as an `expectedDefect` — so D-08's rule reads exactly `skippedCount > 0 or expectedDefectCount > 0` |
| Skip mechanics | `TestSkipped`, `TestCase>>skip`, `skip:`, `expectedFailures` |
| Suite building | `TestCase class>>buildSuite` (abstract classes: `isAbstract`), `TestSuite>>run` → `TestResult`; `matchesRegex:` is **full-match** (`'XSUnit-Tests' matchesRegex: 'SUnit-.*'` is false) |
| Verify command | `<vm> <image> test --fail-on-failure "<regex>"`: green → exit 0, red → exit 1, **pattern matching zero packages → exit 0** (evidence that R-24's missing-fails rule must live in our gate; the stock runner has the silence hole) |
| Packages | `PackageOrganizer default packageNamed:` / `packageNamed:ifAbsent:`; `Package>>definedClasses`, `>>methods` (includes class-side methods), `>>classes`; `Smalltalk packages`; `class package` |
| Secrets raw material | class `comment`, method `sourceCode`, `allLiterals` (string literals reachable); regex substring scan via `'…' asRegex search: text` (`String>>asRegex` present) |
| Epicea (v1-widen) | `EpMonitor current log` → `EpLog`, `>>entries`; `EpMethodModification` present |
| Infrastructure | `STON` present (round-trip verified); `Metacello`, `BaselineOf`, `TonelWriter`, `IceRepository` present; `Smalltalk exit:`; `Stdio stdout` |
| Prefix survey | zero loaded classes start with `PGR` (or `PG`) in stock Pharo 13 — D-11's choice is collision-free |
| Built-in rules | 185 `ReAbstractRule` subclasses ship in the image (D-05/D-19 context) |

**Corrected — S1's sketch is wrong in Pharo 13** (spec must use the right-hand forms):

1. **Rule hooks moved class-side and `name` was renamed.** `ReAbstractRule` deprecates
   instance-side `name`/`severity`; the Pharo 13 convention (followed by shipped rules,
   e.g. `ReBadMessageRule`) is **class-side `ruleName`, `severity`, and `rationale`**.
   Our rules implement all three class-side.
2. **`RPackage` / `RPackageOrganizer` no longer exist.** The S1 example's
   `RPackage organizer packageNamed:` must be `PackageOrganizer default packageNamed:`.
3. **`literals` + `isBehavior` does not find referenced classes.** Method literals are
   binding objects; `isBehavior` is false on them (verified). The correct query — S1's own
   alternative — is **`CompiledMethod>>referencedClasses`** (verified live: returns the
   classes a method references; empty when none). The architecture engine is specified on
   `referencedClasses`.
4. **`Author` class is gone** (R-17, v1-widen): author scoping must use
   `CompiledMethod>>author` / `>>stamp` / `>>timeStamp` (all present).
5. **Epicea affected-selector spelling** (R-34, v1-widen): not `affectedSelector` but
   `methodAffectedSelector` (also `methodAffected`, `affectedPackageName`).
6. **smalltalkCI has no critics/code-checks option for Pharo** (checked against its
   current documentation; `#testing` supports `#packages`, `#classes`, `#categories`,
   `#failOnZeroTests`, `#defaultTimeout`, …; `Pharo64-13` is a supported platform). D-05's
   "smalltalkCI's own critics option stays off" is therefore not just ruled but **forced**;
   the gate is the only critic runner.
7. **Clap is incomplete in the stock image** (`ClapCommand` absent): the gate's headless
   entry is invoked via the stock `eval` handler, not a Clap command.
- **Consequences:** R-39/P5 is discharged for every v1-relevant spelling; the spec cites
  only verified forms. The corrected spellings (1)–(3) are binding on chapters 2, 4, 5.

**Appendix D-15.b · Trait attribution in the §4.2 walk** *(probed live by the human,
D-31.a toolchain, 2026-07-13 — added with D-35's review round).* Fixture: trait `TProbe`
(instance- and class-side methods referencing `PFTarget`) used by classes in two
packages. Findings:

1. Trait-provided methods surface in each using class's `methods` with working
   `referencedClasses`, instance and class side — the §4.2 walk judges them in each
   using class's layer; finding targets name the using class. One trait defect → one
   finding per using class.
2. `CompiledMethod>>package` answers the **trait's** package and `origin` the trait —
   irrelevant to the walk (which attributes by defining class), but binding on any
   future package-filtered method query. *(Agent note, flagged ⟨verify at M1⟩, not
   assumed: §2.3's `RBPackageEnvironment` is such a query — if it attributes
   trait-provided methods to the trait's defining package, trait methods are linted
   where the trait is defined, which the role law keeps in scope; a trait defined in an
   exempt-role package and used from production would then escape lint. Probe when the
   lint check is built.)*
3. The trait itself appears in its own package's `definedClasses`, so a layered trait
   package additionally yields the finding at `TraitName>>#selector` in the trait's
   layer — duplication accepted as defense in depth.

**Consequence:** no blind spot either way (trait package layered → judged at trait and
users; unlayered/undeclared → still judged at every using class); no code change;
ch. 4's Known bounds gains one sentence citing this appendix.

---

## D-16 · Configuration artifact concrete form: `guardrails.ston`, pure-data STON, strict

- **From:** spec stage (implements D-01/D-07) · **Ruled by:** agent-decided, **veto-open**
  · **Date:** 2026-07-10
- **Ruling:** the project artifact is a file named **`guardrails.ston`** at the client repo
  root. It is **pure-data STON** — one map with `Symbol` keys, lists, and nested maps; no
  class-tagged STON objects — parsed and validated by the framework into an explicit
  configuration object. Validation is strict (family 7): an unknown top-level key (owned by
  neither the core nor a declared kit), a malformed section, or a duplicate registration
  name is a configuration error that fails the gate run outright. Merge law for a kit's
  global catalog with the project artifact: **list sections concatenate (global entries
  first); map sections may appear in only one source**.
- **Why:** pure data keeps the file readable and diffable without any framework class
  loaded (D-01's why), and strict validation makes every artifact defect loud instead of a
  silent non-registration (P6, R-24).

---

## D-17 · Package `Phi-Guardrails-Coding` added; kits are declared in the artifact

- **From:** spec stage (implements R-40/R-42) · **Ruled by:** agent-decided, **veto-open**
  · **Date:** 2026-07-10
- **Ruling:** one package is added to R-36's naming tree: **`Phi-Guardrails-Coding`**,
  hosting the kit class `PGRCodingKit` (the kit's section schema + registration building +
  shipped global catalog). The three engine packages (`-Coding-Rules`, `-Coding-Architecture`,
  `-Coding-Behavioral`) stay as ruled. A project declares its kits explicitly in the
  artifact (`#kits : [ 'PGRCodingKit' ]`) — no kit discovery by image scan (family 4;
  loading is not activation, R-41).
- **Why:** the kit contract (R-40) needs a named owner that is none of the three engines;
  explicit kit declaration keeps "what runs" in one diffable place (P6).

---

## D-18 · Global catalog embodiment: a class-side STON method on the kit class

- **From:** spec stage (implements D-01's "shipped default artifact") · **Ruled by:**
  agent-decided, **veto-open** · **Date:** 2026-07-10
- **Ruling:** each kit's global-scope catalog is the STON text answered by
  **`<Kit> class>>globalCatalogSTON`** (e.g. `PGRCodingKit class>>globalCatalogSTON`) —
  same schema as the project artifact's kit sections. It is Tonel-versioned and diffable in
  git like any artifact, and it travels with the kit through Metacello loading (a loose
  file would not reach clients).
- **Why:** D-01's substance is *diffable, explicit, reviewable*; a class-side method in
  Tonel satisfies all three and removes the "where does the file live in a client image"
  problem. Promotion (D-07) = move the entry into this method + move the class into the
  shipped package.

---

## D-19 · v1 global catalog registers zero built-in Renraku rules

- **From:** D-05's explicit spec-stage choice ("possibly none") · **Ruled by:**
  agent-decided, **veto-open** · **Date:** 2026-07-10
- **Ruling:** none of the 185 shipped Renraku rules (D-15) enters the v1 global catalog.
  The registration-by-name mechanism is specified and tested (any `ReAbstractRule` subclass
  name is a valid `#lintRules` entry), but the shipped catalog stays minimal for the
  walking skeleton. Selecting proven built-ins is M5 widening work.
- **Why:** the walking skeleton demonstrates the *mechanism*; auditing 185 rules for
  fixture pairs and severity fitness is exactly the catalog-widening work Pack §4 defers.

---

## D-20 · The shipped lint rule blocks: `PGRNoIsNilIfTrueRule` severity is `#error`

- **From:** spec stage (D-03 × D-04 × R-32) · **Ruled by:** agent-decided, **veto-open** ·
  **Date:** 2026-07-10
- **Ruling:** the v1 rule declares class-side `severity ^ #error`. Under D-03 only `#error`
  criticisms block; the toy demonstration (R-32/R-44) requires the planted lint violation
  to redden the gate, so the one shipped rule must block.
- **Why:** a walking skeleton whose only lint rule cannot fail the build would demonstrate
  nothing (P6).

---

## D-21 · Non-green semantics: check errors are red; `#skipped` is the fail-closed reserve

- **From:** spec stage (P6's three failure states need total semantics) · **Ruled by:**
  agent-decided, **veto-open** · **Date:** 2026-07-10
- **Ruling:** a resolved check whose `run` signals an unhandled exception yields a **red**
  verdict carrying the error description (never a crash of the gate, never a pass). The
  `#skipped` status exists in the verdict vocabulary and fails the gate (P6), but a
  *completed* gate run never emits it — every registration is either missing (unresolvable),
  red, or green; `#skipped` marks registrations left unrun by an aborted/partial run, so
  any partial report still fails closed. (Skipped *tests* are a different thing: they
  redden the no-skips meta-rule per D-08.)
- **Why:** P6 needs the four states to be total and decidable; "engine crashed" must block
  exactly like "check failed".

---

## D-22 · Red-test fixtures live under `Phi-Guardrails-Fixtures-*`, outside the test namespace

- **From:** Gate-2 validation finding 1 (remediation) · **Ruled by:** agent-decided,
  **veto-open** — rides the same mechanism as sheet-02 Q-19 · **Date:** 2026-07-11
- **Ruling:** fixture classes that must contain red, skipped, or expected-failure
  **tests** (the behavioral kind's fixture pairs, §5.5) live in
  **`Phi-Guardrails-Fixtures-*`** packages (v1: `Phi-Guardrails-Fixtures-Behavioral`).
  That namespace does not full-match `Phi-Guardrails-Tests-.*` — so the framework's own
  `#testPackages`, the pack §6 verify command, and smalltalkCI's `#testing` pattern never
  run them — and it appears in no committed artifact's `#packages`. It is loaded by the
  `Tests` baseline group so the kit's tests can target it through scratch configurations.
  Fixtures without red tests (lint bad code, architecture mini-packages) stay beside their
  tests in the mirroring `-Tests-*` package as before.
- **Why it holds:** without this, the spec was self-contradictory (validation finding 1):
  committed red fixtures inside `Tests-.*` made P-SELF-HOSTED unsatisfiable and the verify
  command permanently red. The fix is Q-19's toy mechanism (`Toy-Tests`, not `Tests-Toy`)
  applied uniformly: everything committed-red lives outside every registered and swept
  namespace.
- **Consequences:** ch. 5 §5.5, ch. 9 §9.3, and constitution §2/§3 amended; the naming
  tree (R-36/D-17) gains the `-Fixtures-*` family; sheet-02 Q-19's ruling now covers both
  the toy and the fixture namespace.

---

## D-23 · Gate-driving tests live in `Phi-Guardrails-CI-Tests`, outside every swept namespace

- **From:** Gate-2 validation round 4, finding 1 (remediation) · **Ruled by:**
  agent-decided, **veto-open** — sheet-02 Q-21 carries the question · **Date:** 2026-07-11
- **Ruling:** a **gate-driving test** — any test whose body runs the gate on a committed
  artifact — must live in a package its artifact's own `#testPackages` does not match;
  otherwise the gate's behavioral suite runs the test that runs the gate and the run
  recurses without terminating. For this repo: `PGRGateCIAdapterTest` (D-10's adapter) and
  `PGRToyDemoTest` (which also mutates sources mid-test) move to
  **`Phi-Guardrails-CI-Tests`** — full-matched by neither `Phi-Guardrails-Tests-.*` (the
  framework's `#testPackages` and the pack verify command) nor any `#packages` list.
  smalltalkCI's `#testing` selects it explicitly alongside the mirrored test packages;
  the baseline's `CI` group loads it. The rule is stated generally in spec §7.4 and
  applied to clients in §8.1 step 4 (a client putting its adapter inside its own
  registered test namespace would reproduce the recursion).
- **Amends D-10's letter, not its substance:** the adapter is still one thin TestCase
  smalltalkCI picks up — only "in the tests package" becomes "in the CI-tests package",
  because the tests package is exactly what the artifact sweeps.
- **Why it holds:** third application of the namespace-escape mechanism (toy → Q-19, red
  fixtures → D-22): everything the gate must not sweep lives outside every registered and
  swept namespace. Without it, `guardrails.sh` never exits on this repo, P-SELF-HOSTED is
  unsatisfiable, and CI hangs at M4.
- **Consequences:** spec §7.4/§7.5 example config, §8.1 step 4, §8.3, baseline `CI`
  group, §9.3 (enforcement tier stated honestly: review convention; a violation hangs
  P-SELF-HOSTED's CI run, which is the de-facto machine check), constitution §2 naming,
  R-36 naming tree.

---

## D-24 · No exclusion mechanism in v1: every global-catalog check runs for every adopter

- **From:** Q-18 (`plan/02-decision-sheet.md`) · **Ruled by:** human, Gate 2 · **Date:** 2026-07-11
- **Ruling:** Option (a), as specified. The project artifact only extends the shipped
  catalog; no `#exclusions` section, no severity override. A client that cannot pass a
  global check fixes its code or delays adoption. Revisit only on demonstrated demand
  (earliest: phi-llm onboarding / M5), compatibly — an explicit exclusion section could be
  added without breaking existing artifacts.
- **Spec text:** already written to this ruling (ch. 1 §1.2); no amendment needed.

---

## D-25 · Package scope derives from the Metacello baseline; residual holes machine-closed

- **From:** Q-22 (`plan/02-decision-sheet.md`, raised and driven by the human at Gate-2
  review) · **Ruled by:** human, Gate 2 · **Date:** 2026-07-11
- **Ruling:** Option (a) **with residual remediation included in v1**. The baseline is
  the only package inventory; the gate derives scope from it:
  - The artifact drops `#packages` and gains `#baseline` (the name of a loaded
    `BaselineOf` subclass) and `#roles` (map: `#production` / `#tests` / `#exempt` →
    baseline group names). Inventory comes from Metacello; roles come from the artifact;
    no list of packages is ever written by hand.
  - **Scope law (closes the opt-in hole structurally):** role-named groups must exist in
    the baseline, be pairwise disjoint after expansion, and jointly cover every package
    the baseline defines — each package in exactly one role. Any violation is a
    configuration error, so an unassigned new package fails the gate run outright.
  - **Residual 1 (misfiling), machine-closed:** optional `#exemptNamePatterns` (regex
    list); when present, every exempt-role package must match one and no
    production/tests-role package may match any — configuration error otherwise. The
    framework sets them (`Phi-Guardrails-Toy-.*`, `-Fixtures-.*`, `-CI-Tests`).
  - **Residual 2 (dead code), machine-closed:** `PGRSrcInventoryTest` (in
    `Phi-Guardrails-CI-Tests`) reds when a `src/` directory corresponds to no package
    the baseline defines.
  - **Residual 3 (spellings), discharged:** verified this session (appendix below).
- **Folded-in consequences:** amends **D-16** (schema: `#packages` → `#baseline` +
  `#roles`), **R-02/R-23/R-24** (targets and suites derive from roles), restates
  **D-23** (`CI-Tests` is an exempt-role group member; the no-self-sweep rule becomes a
  checkable group fact); **Q-20 is closed as moot** (no test-package patterns remain —
  behavioral targets are the tests-role packages; zero-match-missing becomes
  empty-role-missing). The toy gains its own `BaselineOfPhiGuardrailsToy` (which also
  strengthens D-12 (b): the external copy carries its baseline unchanged). The
  **three-tier run model** agreed in the same discussion (edit-time advisory · chunk-time
  advisory · CI authoritative, scoping lawful only where verdicts are local and only in
  advisory tiers) is written into spec ch. 7.
- **Why it holds:** membership in the product and membership in the checked inventory
  become the same fact — CI and clients load via the baseline (§7.4, R-31), so escaping
  the inventory means not shipping at all; two-inventories-plus-reconciliation (the
  rejected meta-rule) was a seam, not a fix (family 6). What cannot be closed (lying in
  the one authoritative file) is at least loud: every escape is a visible diff.

**Appendix D-25.a · Verified Metacello/FileSystem spellings** (same Pharo 13 image as
D-15; scratch baseline with packages + composite groups):

| Element | Verified spelling | Note |
|---|---|---|
| Project/version | `<BaselineOf subclass> project version` → `MetacelloVersion` | project class `MetacelloMCBaselineProject` |
| Own packages | `version packages` (specs; `name`) | dependencies are separate: `version projects` |
| Groups | `version groups` (specs; `name`, `includes` = direct members) | |
| **Group expansion** | `version packagesForSpecNamed: 'group'` | transitive; composite groups expand correctly (verified on a 5-group fixture) |
| **Trap** | unknown group name answers **empty**, no error | validation must pre-check membership in `version groups` before expanding |
| BaselineOf test | `cls inheritsFrom: BaselineOf` | |
| Dead-src raw material | `FileSystem workingDirectory`, `directories`, `basename`, `exists` | |
| Empty group *(addendum, validation round 6)* | `group: 'x' with: #()` is declared, listed in `groups`, expands to `#()` | lets `BaselineOfPGRFixture` satisfy §1.1's mandatory `#production` |

---

## D-26 · Toy committed red; everything deliberately red lives exempt-role, declared

- **From:** Q-19 (`plan/02-decision-sheet.md`) · **Ruled by:** human, Gate 2 · **Date:** 2026-07-11
- **Ruling:** Option (a). The toy client is committed **in the red state** — its planted
  violations (lint, project rule, architecture, secrets, one failing test, one skip) are
  real, current code. The framework's own gate never sweeps it: the toy (like the
  red-test fixtures, D-22, and the gate-driving tests, D-23) is **exempt-role by
  declaration** in the framework baseline (D-25), checked by the scope law and
  `#exemptNamePatterns` — no honor-system naming. The demo test drives red → fixed →
  green in-image and restores in `tearDown`; nothing committed changes. The ruling
  ratifies the mechanism for both applications (toy and `Phi-Guardrails-Fixtures-*`).
- **Why it holds:** the committed red state is the honest fixture — it is what a real
  adopter's first gate run looks like, readable in place; runtime-injected violations
  (option b) would hide the bad half of every fixture pair inside test code.
- **Spec text:** already written to this ruling (ch. 5 §5.5, ch. 8 §8.2/§8.3, ch. 7
  §7.5); no amendment needed.

---

## D-27 · Gate-driving tests confirmed in `Phi-Guardrails-CI-Tests` (exempt-role)

- **From:** Q-21 (`plan/02-decision-sheet.md`; applied as working default D-23 during
  validation remediation) · **Ruled by:** human, Gate 2 · **Date:** 2026-07-11
- **Ruling:** Option (a), confirming D-23 as amended by D-25: tests whose body runs the
  gate on a committed artifact (`PGRGateCIAdapterTest`, `PGRToyDemoTest`) live in
  `Phi-Guardrails-CI-Tests`, a member of the baseline's exempt-role `ci-tests` group —
  never a tests-role package — so the gate can never recurse through them. smalltalkCI
  selects the package explicitly beside the tests-role packages. The no-self-sweep rule
  is normative for clients too (spec §7.4, §8.1 step 5). Rejected: per-class carve-outs
  from the swept roles (fragile, reopens silent-unswept holes) and an in-gate recursion
  guard (hides the design flaw, leaves the demo test's mid-run mutation unsolved, flirts
  with global state).
- **Known bound, accepted:** a `skip:` inside `CI-Tests` is the one skip no machine
  catches — reviewer-enforced (constitution §2/§3); a recursion accident cannot pass
  silently since CI hangs visibly rather than greening.
- **Spec text:** already written to this ruling (ch. 7 §7.4/§7.5, ch. 8 §8.1/§8.3,
  ch. 9 §9.3); no amendment needed. D-23's veto window closes ratified.

---

## D-28 · Gate-2 ratifications; D-19 revised — one built-in enters the v1 catalog

- **From:** human review of the veto-open entries · **Ruled by:** human, Gate 2 ·
  **Date:** 2026-07-11
- **Ratified as they stand (veto windows closed):** D-16 (artifact form; its `#packages`
  slice was already superseded by D-25), D-17 (`Phi-Guardrails-Coding` package), D-18
  (global catalog as class-side STON method), D-21 (error→red; skipped = fail-closed
  reserve), D-22 (red-fixture namespace; also ratified via D-26), D-23 (gate-driving-test
  namespace; also ratified via D-27). **D-20 was not named and stays veto-open.**
- **D-19 revised (option (a) of the selection probe):** the v1 global catalog registers
  **one built-in Renraku rule by name: `ReCodeCruftLeftInMethodsRule`** — verified live
  this session: class-side severity `#error` (it blocks); rationale "Breakpoints, logging
  statements, etc. should not be left in production code."; fires on `self halt`,
  `self haltIf:`, `Transcript show:`, and `self flag:`; silent on clean code. This is
  R-16's "no debugging leftovers" target arriving early through a proven built-in, and it
  exercises D-05's register-by-name mechanism in earnest.
- **Accepted knock-ons:**
  1. `self flag:` markers become build-breakers for every adopter (consistent with the
     constitution's no-TODO-in-lieu-of-decisions rule; no exclusions per D-24).
  2. The built-in covers `Transcript show:`, colliding with the toy's demonstration rule
     — `PGRToyNoTranscriptRule` is **re-pointed as `PGRToyNoIsNilIfFalseRule`** (matches
     `` `@x isNil ifFalse: [`.@block] ``, the verified sibling pattern of D-04's rule,
     flag-only — which also gives v1 a live instance of the flag-only base class). The
     toy's `Transcript show:` plant stays and now demonstrates the built-in; a new
     `isNil ifFalse:` plant demonstrates the project rule. The toy registry grows to
     seven registrations, all red in the committed state.
  3. The built-in is registered, so R-37 applies: it gets a fixture pair in our tests
     like any catalog rule.
- **Consequences:** spec ch. 2 §2.4, ch. 3 catalog (second entry), ch. 7 §7.2 counts /
  §7.5, ch. 8 §8.2/§8.3, ch. 1 §1.1 example artifact.

---

## D-29 · D-20 ratified — the veto-open ledger is empty; Gate 2 rulings complete

- **From:** human review of the last veto-open entry · **Ruled by:** human, Gate 2 ·
  **Date:** 2026-07-11
- **Ruling:** D-20 stands as decided: `PGRNoIsNilIfTrueRule` ships at class-side
  severity `#error` — the autofix flagship blocks, and its violation is one
  `PGRFixCommand` apply away from green. With this, every agent-decided entry
  (D-16–D-23) is explicitly ratified or revised by the human (D-26, D-27, D-28, D-29),
  and every sheet-02 question is closed (D-24–D-27). **No open decisions remain at
  Gate 2**; the gate awaits only the spec re-validation (fresh session) covering the
  D-25 and D-28 amendments.

---

## D-30 · Post-pass amendments awaiting re-validation (session close-out record)

- **From:** Gate-2 close-out; session state flush · **Ruled by:** agent-decided,
  **veto-open** (the substantive inputs were the human's) · **Date:** 2026-07-11
- **Record:** after the spec validation PASS (round 6) and constitution PASS (round 4),
  the following amendments landed and have **not yet been re-validated**:
  1. **Constitution §3 Size bullet** aligned to the human's method update (method rule 2
     restored to "50–150 LOC including tests, ceiling 300" + two refinements): fixture
     data (payloads, recorded samples) outside the budget; tests that cannot fit the
     ceiling = split finding ("stop and report a split"), never a budget exception.
  2. **Constitution §2 Naming** reformatted as a tree (human's request; content-neutral;
     annotations trimmed to hold the 2-page ceiling — file is exactly 1000 words).
  3. **Constitution carve-outs** from its validation rounds 3–4 (already validator-seen
     in round 4's PASS): BaselineOf* prefix exception, write-boundary additions
     (`.github/workflows/ci.yml`, test-scoped scratch files), `self flag:` ban, bad
     fixtures/planted-violations exceptions, `./guardrails.sh` token, "(self-hosted:
     spec §3.2)".
  4. **Spec edits made during constitution remediation, after the spec's own PASS**
     (validator should re-check consistency of exactly these): ch. 7 §7.4 names
     `.github/workflows/ci.yml` as the only committed file outside src/plan/root
     artifacts; ch. 8 §8.2 commits the in-repo toy artifact as class-side STON text
     (`BaselineOfPhiGuardrailsToy class>>guardrailsSTON`, D-18's mechanism — becomes a
     real root `guardrails.ston` only in the §8.4 external copy); ch. 1 §1.1 example
     framing line updated to match.
- **External item (not this repo):** a phi-llm constitution draft (not on disk under
  `../phi-llm` — no `plan/` exists there) reportedly says "50–150 LOC of production code
  (tests excluded)", contradicting the method; fix belongs to the phi-llm pipeline.
- **Consequences:** one fresh-session constitution re-validation (items 1–2 are the only
  unseen changes) plus a spot re-check of spec ch. 1/7/8 (item 4) before Prompt 3 starts.
  *(Discharged — see D-31.)*

---

## D-31 · Prompt-2 close-out: D-30 discharged, handoff retired, Gate 2 closed

- **From:** Prompt-2 close-out (resumed session; handoff `plan/02-handoff.md`, since
  deleted) · **Ruled by:** record entry, recorded by the specification agent · **Date:**
  2026-07-12
- **Record:** D-30's re-validation consequence is **discharged**. Per the session-close
  handoff (updated after the fact, human-confirmed 2026-07-11): the constitution
  validation ran PASS in a fresh session *after* the D-30 items 1–2 amendments; the
  D-30 item-4 spec touches (ch. 1 §1.1, ch. 7 §7.4, ch. 8 §8.2) were cross-read by that
  validation's contradiction check with no finding. This close-out session independently
  re-read all three touchpoints and confirms consistency (toy-artifact embodiment
  §1.1 ↔ §8.2; `.github/workflows/ci.yml` in §7.4 ↔ constitution §2's write boundary;
  the seven-registration toy count agreeing across ch. 1/7/8). D-30's veto window closes.
- **Close-out checks (Prompt 2 exit criteria):** coverage check re-verified — 37 rows in
  `plan/02-spec/coverage.md` match the 37 v1-skeleton requirements one-for-one, no
  UNCOVERED entries; no STATUS/RESUME markers remain in any artifact; both decision
  sheets closed; the sheet-02 status line updated (it stated the re-validation as still
  pending — stale against the handoff; per the resume protocol the discrepancy is
  resolved by this entry). `plan/02-handoff.md` deleted; its only content not already in
  a durable artifact is preserved in the appendix below.
- **Consequences:** Prompt 2 is complete; **Gate 2 is closed**. Next stage: Prompt 3
  (roadmap) in a fresh session. Prompt-3 seeds already on record: sheet-02's
  amendment-time notes (freeze-vocabulary mapping, constitution 2-page ceiling), spec
  §8.3 (toy = seven registrations, all red *(six since the secrets withdrawal — D-37)*),
  pack §8 (M0–M5 shape), and appendix D-31.a (M0 toolchain).

**Appendix D-31.a · Toolchain bootstrap (M0 prerequisite; preserved from the handoff).**
Pharo 13 headless as used for every D-15/D-25.a probe — M0 must install this permanently:

```bash
mkdir pharo13 && cd pharo13
curl -sSLo image.zip https://files.pharo.org/get-files/130/pharoImage-arm64.zip
curl -sSLo vm.zip https://files.pharo.org/get-files/130/pharo-vm-Darwin-arm64-stable.zip
unzip -oq image.zip && unzip -oq vm.zip -d vm && xattr -dr com.apple.quarantine vm
./vm/Pharo.app/Contents/MacOS/Pharo --headless Pharo13.0-*.image eval "3 + 4"   # → 7
# scripts:  ... st probe.st        · eval "expr"
# verify:   ... test --fail-on-failure "<regex>"   (green→0, red→1, zero-match→0!)
```

Image used for all probes: `Pharo13.0-SNAPSHOT-64bit-4c3e4714cc` (2026-07-09 build).
The probe scripts' content is reproducible from D-15/D-25.a's tables — every claim there
was executed; the two tables are the spellings inventory.

---

## D-32 · Ch. 1 clarifications from post-Gate-2 human review

- **From:** human review of spec ch. 1 (three findings + one process flag) · **Ruled
  by:** human-confirmed agent edits, **veto-open** · **Date:** 2026-07-13
- **Three clarifications, none changing ruled ground:**
  1. **Exempt-role loading:** only production- and tests-role packages must be loaded;
     an exempt-role package absent from the image is not an error — no check targets it,
     and role validation works on baseline introspection alone (D-25.a). §1.1's roles
     row and the glossary's *group role* entry drop the misleading "loaded" wording.
  2. **`#skipped` producer stated:** no v1 code path emits a `skipped` verdict — a
     completed run never does (D-21: an erroring check is red, so the run loop cannot
     abort) and v1 ships no partial-run reporter; the constructor exists for verdict-
     vocabulary totality over P6's states, and its only legitimate producer is report
     construction over a partially-run registry. One sentence added to §1.4 so the
     frozen protocol's unused constructor cannot be mistaken for an open door.
  3. **§1.5 rows are the v1 catalog's, knowingly:** the `#architecture` and `#sweep`
     missing-conditions name `#layerMap` / `#secretPatterns` — parameters of the v1
     checks, not generic kind semantics. Recorded as a deliberate trade (a generic
     required-sections protocol is machinery without demand, family 5); a future check
     with different parameters amends its row. Footnote added under the §1.5 table.
- **Process note (the review's fourth flag, accepted by the human):** the current ch. 1
  text has not been seen by a dedicated fresh-session *spec* validator — the round-6
  PASS predates the D-30 item-4 touch. The human accepted the incidental cross-read by
  the final constitution validation plus the D-31 close-out re-check, with Prompt 3's
  entry check as the remaining backstop; this entry's edits ride the same acceptance.
- **Consequences:** ch. 1 §1.1/§1.4/§1.5 and glossary *group role* amended as above; no
  other chapter or requirement is touched; nothing reopens sheet-02.

---

## D-33 · Test code is not linted — ratified as a knowing v1 trade

- **From:** human review of spec ch. 2 (2026-07-13) · **Ruled by:** human ("agreed
  proceed" on option (a)) · **Date:** 2026-07-13
- **Ruling:** lint — like architecture and the sweeps — targets **production-role
  packages only**; tests-role code is deliberately outside lint's reach. Debug cruft in
  a test package (`Transcript show:`, `self flag:`, a halt on an unexecuted line, cruft
  in non-test helpers) escapes `ReCodeCruftLeftInMethodsRule` and every other lint rule.
  Confirmed as a ruled choice, not an accident of the role table.
- **Provenance:** the mapping is D-25's own text ("production groups →
  lint/architecture/secrets targets; tests-role group → behavioral suites"), ruled at
  Gate 2 — but this consequence was never spotlighted there; this entry closes that gap.
- **Why it holds (load-bearing, not just tolerable):** ch. 3 §3.2 places the lint bad
  fixtures (committed `isNil ifTrue:` code; §3.2b's planted `self halt` +
  `Transcript show:`) in the mirroring `Tests-*` packages *because* lint never sweeps
  them — widening lint over tests-role would redden the framework's own gate on its own
  fixtures. The alternative (fixtures relocated to exempt `Phi-Guardrails-Fixtures-*`,
  D-22's mechanism) is coherent but is exactly the catalog/fixture churn Pack §4 defers.
- **Partial mitigation, stated precisely:** a `self halt` on an *executed* line of a
  test method errors that test in a headless run, so the behavioral suite reddens
  anyway; the no-skips meta-rule covers the test-discipline escapes. What escapes fully:
  `Transcript show:` / `self flag:` in tests-role code and cruft on unexecuted paths.
- **Revisit path (M5):** widening lint over tests-role is a legitimate M5 option and
  rides the fixture relocation to `Phi-Guardrails-Fixtures-*` in the same stroke.
- **Also from the same review:** the concern that §2.4's registered built-in lacks a
  fixture pair was checked and found already satisfied (ch. 3 §3.2b lists
  `PGRCodeCruftBuiltInTest>>#testFiresOnBadFixture` / `>>#testSilentOnGoodFixture`);
  ch. 9's P-CAT-FIXTURES citation tightened to name §3.2b explicitly.
- **Consequences:** ch. 2 §2.3 gains the scope-boundary paragraph; ch. 9 P-CAT-FIXTURES
  citation amended; no requirement text changes; nothing reopens sheet-02.

---

## D-34 · Ch. 3 amendments: built-in severity pin; stale-apply guard on the fix command

- **From:** human review of spec ch. 3 (2026-07-13) · **Ruled by:** human-confirmed
  agent edits · **Date:** 2026-07-13
- **Two amendments, one already-discharged finding:**
  1. **Severity pin for registered built-ins.** §3.2b's blocking behavior rested on
     `ReCodeCruftLeftInMethodsRule`'s *shipped* class-side `#error` (verified D-28) — a
     Pharo upgrade demoting it to `#warning` would, under D-03, silently stop the gate
     blocking on debug cruft. New third test beside the fixture pair:
     `PGRCodeCruftBuiltInTest>>#testSeverityStillBlocks` asserts `severity == #error`,
     making drift a red test. Ruled as the **pattern**: every built-in registered at M5
     arrives with a severity pin. New named property P-BUILTIN-PINNED (ch. 9 §9.2).
  2. **Stale-apply guard.** `previewOn:` collects change objects; `apply` executed them
     later — source drift between the two would apply a diff nobody previewed, breaking
     D-06's substance (the confirmed diff is the applied diff). `apply` now re-reads
     every pending change's target first: any mismatch with the preview-time source
     (`oldVersionTextToDisplay`) signals **`PGRFixStale`** and applies nothing
     (all-or-nothing; a new instance previews afresh). `PGRFixStale` joins
     `PGRFixNotPreviewed` as a non-configuration error in `-Coding-Rules`. P-FIX-PREVIEW
     gains `>>#testStaleApplySignals`.
  3. *(No change needed:)* the review also asked that the lint-scope/fixture-placement
     dependency be recorded before ruling — already discharged: D-33 was ruled with that
     dependency spotlighted ("Why it holds"); §3.2 now cross-cites D-33 so chapter-3
     readers see the ruling pointer.
- **Consequences:** ch. 3 §3.2 (cross-cite), §3.2b (pin paragraph), §3.3 (`apply`
  contract + error roster); ch. 9 P-FIX-PREVIEW amended, P-BUILTIN-PINNED added. The
  frozen-at-M1 fix-command protocol changes shape *before* M1 — legal now, load-bearing
  later; nothing reopens sheet-02.

---

## D-35 · Layer-map completeness law: layers + `#unlayered` jointly total over the production role

- **From:** human review of spec ch. 4, finding 1 (2026-07-13) · **Ruled by:** human —
  option (a) · **Date:** 2026-07-13
- **Ruling:** when `#layerMap` is present, every production-role package must appear in
  **exactly one place**: one layer, or the map's new optional `#unlayered` list.
  Configuration errors: a production package in no layer and not in `#unlayered` · a
  package in two layers, or in a layer *and* `#unlayered` · an `#unlayered` entry naming
  a non-production or unknown package. Unlayered packages stay unwalked and unjudged —
  by visible declaration. **Report line:** the check's verdict carries one advisory line
  naming the `#unlayered` packages, so every gate report restates what the map declines
  to judge (defense in depth beside the artifact diff).
- **Why it holds:** ch. 1's scope-law lesson applied one level down — and the drift was
  already live: the toy's production role has four packages while its map covered three
  (`Phi-Guardrails-Toy-Rules` silently invisible). Partial maps stay legal, but the
  omission is declared and repeated, never silent. Architecture remains opt-in per
  project: no map → no law — that absence is itself a visible artifact fact.
- **Consequences:** ch. 4 §4.1 (third key + the law); ch. 1 §1.1 toy example gains
  `#unlayered : [ 'Phi-Guardrails-Toy-Rules' ]`; ch. 9 gains P-LAYERMAP-TOTAL; glossary
  *layer map* and *advisory* entries amended. The framework's own map (§4.4) is already
  total over its six production packages — no change. The companion trait finding from
  the same review closed evidence-first as appendix D-15.b (probed by the human; no code
  change).

---

## D-36 · No-skips meta-rule pulls per package — order-independence replaces the ordering guarantee

- **From:** human review of spec ch. 5 (2026-07-13) · **Ruled by:** human-approved
  design change · **Date:** 2026-07-13
- **Defect:** the meta-rule read `allResults` — whatever the suite registrations had
  already left in the run cache. Severity, stated precisely: the verdict-of-record was
  never exposed (a full CI run always runs suites first, §1.4), but any narrowed
  advisory-tier run (chunk mode, a single-registration re-run, a Playground invocation)
  saw an empty cache and went **green on nothing** — a fail-open in exactly the tier
  agents steer by; and correctness rested on two cross-chapter promises (§1.4 emission
  order, gate iteration order) that ch. 5 cited but nothing proved — breakable silently.
- **Ruling:** remove the dependency instead of guaranteeing it. The meta-rule iterates
  the configuration's tests-role package names (the same derived list §5.1 builds suite
  registrations from) and asks the cache `resultsForPackage:` per package; the lazy
  cache runs any suite not yet run. Ordering becomes irrelevant, the single-run
  guarantee holds (the cache never runs a suite twice), and the meta-rule can never see
  "nothing". **`allResults` is deleted** from `PGRSuiteRunCache`'s protocol — the
  meta-rule was its only consumer, and an unused accessor in a frozen-at-M1 contract
  invites misuse (same reasoning as D-32's `#skipped` clarification).
- **Ordering demoted, not dropped:** suites-before-meta-rules registry order (§1.4)
  stays normative as a nicety — honest duration attribution (suite wall time lands on
  suite verdicts, not inside the meta-rule's) and report shape. P-SUITES-BEFORE-META
  survives with its justification rewritten; correctness is carried by the cache alone.
- **New fixture assertion:**
  `PGRNoSkippedTestsMetaRuleTest>>#testFiresInIsolationWithoutPriorSuiteRuns` — fresh
  cache, no prior suite runs, same findings; added to P-GATE-SKIP.
- **Consequences:** ch. 5 §5.3 (per-package pull, vacuity note reworded), §5.4 (protocol
  is one message; ordering reframed), §5.5 (isolation test); ch. 1 §1.4 cross-reference
  softened; ch. 9 P-GATE-SKIP and P-SUITES-BEFORE-META amended. Routed per rule 9 as
  current-stage remediation (defect in a DONE chapter), not backlog.

---

## D-37 · Secrets-leak check withdrawn: pattern detection is false security, out of scope

- **From:** Gate-2 human review of spec ch. 6 · **Ruled by:** human — binding scope
  ruling (notice of 2026-07-13) · **Date:** 2026-07-13
- **Ruling:** secrets detection **leaves phi-guardrails entirely**. Pattern matching
  against well-known key formats is brittle, costly to maintain, and — decisively —
  **false security**: the check catches only formats it already knows; a new provider's
  token format passes silently while green is read as "no secrets." A guard that
  silently ages into blindness while reporting success is worse than no guard. An
  agentic (LLM-based) in-gate redesign was assessed and **rejected**: it breaks the
  gate's deterministic contract (same code → same verdict, offline), breaks fixture
  discipline (R-37), and inverts the dependency (the framework would need an LLM client
  — and an API key in CI).
- **Where the concern now lives (neither relocation is this repo's task):**
  **detection** → the method layer (`../phi/method/`) as an agentic review instruction
  in the chunk-reviewer/integrator prompts — judgment-tier (family §3.1), advisory,
  format-agnostic, seedable with the known regexes as hints, improved through the
  method's eval/correction cycle, making no deterministic-gate promise; **prevention**
  → phi-llm's constitution (credentials only via a provider abstraction, never
  literals) — phi-llm's decision.
- **Supersedes:** R-28 and D-09 in full; D-07's Q-09 provisioning slice (the
  `#secretPatterns` section) becomes moot; the `#sweep` check kind leaves the coding
  kit (no other check ever held it). **B-04's secrets-fixture-relocation clause is
  moot** — the backlog stays append-only; the supersession lives here, not in an edit
  to B-04.
- **Consequences (spec amendments, this ruling):** ch. 6 replaced by a withdrawal
  notice (file retained; chapters 7–9 keep their numbers) · ch. 1 drops the `#sweep`
  kind, the `#sweeps`/`#secretPatterns` sections, the sweep registration-name example,
  and the sweep row of §1.5 (the D-32 footnote narrows to `#architecture`) · ch. 2
  §2.3/§2.5 and ch. 3 §3.2 drop sweep phrasing · ch. 5 §5.3's informal
  "suspicious-shapes sweep" renamed to avoid the withdrawn term · ch. 7 §7.1/§7.2/§7.5
  (failure condition, toy count 7 → **6**, self-hosting catalog) · ch. 8
  §8.1/§8.2/§8.3 (no fake-key plant, no secrets demo arm, six registrations) · ch. 9
  (P-REDACT removed; P-CAT-FIXTURES and §9.3 narrowed) · glossary (*sweep* and *secret
  pattern* marked withdrawn; *check*, *check kind*, *group role*, collision note
  amended) · coverage (R-28 → superseded by D-37; 36 covered of 37) ·
  `plan/01-requirements.md` R-28 row and naming-tree line annotated (precedent: the
  D-25 annotations).

---

## D-38 · D-37 knock-on questions ruled: pack amended by owner; toy asymmetry accepted; counts stand

- **From:** the three questions raised in D-37's application report · **Ruled by:**
  human (dispositions), with two verifications delegated to and discharged by the
  specification agent · **Date:** 2026-07-13
- **1 · Pack conflict — amend, don't annotate.** The pack must be the correct charter on
  every read; no annotation convention exists and none is invented. **The pack edit is
  the owner's, made outside this agent's remit.** Spots verified exhaustive by grep —
  exactly three: §4(d) (drop the secrets-leak test), §8 outline item 6 (mark withdrawn,
  cite D-37), the M4 milestone row (→ "CI gate enforcing the full registry" alone).
  *Lettering note for the edit:* R-28's source citation is "Pack §4(d) *only*" — keeping
  the remaining letters stable (rather than relabeling (e)→(d)) preserves that
  historical trace.
- **2 · Toy-Persistence stays plantless — coverage verified, not symmetry.** The R-44
  criterion is that every shipped check kind keeps a toy demonstration, and it holds
  after the withdrawal: the fix command's preview→apply cycle is demonstrated end-to-end
  by §8.3 `testLintAutofixThenGreen` against the `isNil ifTrue:` plant in **Toy-Core**
  (plus unit-level P-FIX-PREVIEW / P-CAT-AUTOFIX), and every remaining kind is planted —
  three lint plants (Toy-Core), architecture (UI → Persistence), behavioral suite
  (failing test) and meta-rule (skip) in Toy-Tests. Six registrations, all red, every
  kind exercised. Persistence earns its keep as the UI plant's forbidden target; no new
  plant.
- **3 · Counts stand.** Requirements keeps "v1-skeleton 37" with R-28 annotated
  superseded; requirement IDs are history and are never renumbered. **Consequence made
  explicit for Prompt-3 assembly:** the entry check must expect **36 covered + 1
  superseded (R-28 → D-37) = 37**, not "37 covered" — write that expectation into the
  entry check when Prompt 3 is assembled or it will false-fail at stage start.
  *(Correction, freeze round: D-45 added R-47 to v1-skeleton, so the current expectation
  is **37 covered + 1 superseded = 38** — as `coverage.md` and the requirements counts
  already state. This seed's numbers are superseded; the principle — covered + superseded,
  never "all covered" — stands.)*
- **Consequences:** no spec files change under this entry (verification only); pack
  amendment subsequently delegated by the owner to the specification agent and executed
  same-day (three spots, letters kept stable — §4's "(d) withdrawn (decision-log
  D-37)"); the Prompt-3 expectation lives here and rides D-31's seeds pointer.

---

## D-39 · The gate never ends without deciding a number (Q-23)

- **From:** Q-23, `plan/02-decision-sheet.md` (reopened round) · **Ruled by:** human,
  post-gate spec review · **Date:** 2026-07-20
- **Ruling:** the review's three-part recommendation in full.
  1. **Per registration (confirmation of D-21, not new):** a check whose `run` raises is
     caught, yields a **red** verdict carrying the error description, and the remaining
     registrations still run. Already specified (ch. 1 §1.4, P-ERR-IS-RED); ch. 7 was
     silent on it, which is why the review could not see it — the chapter now restates it.
  2. **Top level (new):** both `runHeadless:` forms wrap the whole run in a handler.
     Anything escaping — registry construction, report rendering, the verdict sink, a
     non-`Error` exception — is caught, one error line is written, and the method answers
     **2**, joining configuration errors as "the run produced no verdict". The contract
     is stated as a law: *the gate never ends without deciding a number.*
  3. **Fixtures (new):** a check whose `run` throws, and a kit that throws during registry
     construction — asserting nonzero exit, one error line, and (for the first) that later
     registrations still ran. Without these the arm is untested by construction, since
     nothing else in the suite crashes on purpose.
- **Why it holds:** the failure it prevents is the worst this framework can produce — a
  crashed gate whose exit code CI reads as success. D-21 closed the unbounded case for
  checks; this closes it one level up.
- **Consequences:** ch. 7 §7.3 (handler contract, exit-code table, the law) and §7.1's
  per-registration clause; ch. 9 P-EXIT-CODES extended, P-ERR-IS-RED gains the
  registry-construction sibling.

---

## D-40 · The tests-role suites run independently of the gate — a safety property, not waste (Q-24)

- **From:** Q-24 · **Ruled by:** human, post-gate spec review · **Date:** 2026-07-20
- **Ruling:** option (a). §7.4 states the duplication as a **safety property**: the
  tests-role suites are run independently by smalltalkCI so that a defect in the gate
  cannot suppress the tests that detect it. Paired with a "can the judge convict" test on
  the gate object — a deliberately red registration ⇒ report red, exit code 1.
- **Why it holds (the bootstrap argument):** CI loads the committed source, so a change to
  the gate is judged by the changed gate; no older gate is held in reserve. Given a defect
  that greens regardless (broken verdict tally, a sink dropping reds, an early return in
  `run`), the independent smalltalkCI run still fails on the fixture tests and CI goes
  red; with the gate as sole runner, the broken gate runs those same tests and reports
  green anyway — the one test that could detect the bug is swallowed by the bug.
  Self-hosting proves the framework's code obeys the rules; the independently-run fixture
  tests prove the rules work. Both are needed, in that order.
- **Accepted cost:** every tests-role suite executes twice per CI run — seconds at v1 size
  (§7.6's non-binding target unaffected), and the price of the independence. Written down
  precisely so a future reader cannot mistake it for redundancy and "optimize" it away.
- **Consequences:** ch. 7 §7.4 gains the safety-property paragraph; ch. 9 gains
  P-JUDGE-CONVICTS.

---

## D-41 · Registered lint rules must declare severity explicitly; no default (Q-25)

- **From:** Q-25 · **Ruled by:** human, post-gate spec review · **Date:** 2026-07-20
- **Ruling:** a registered lint rule whose class does **not itself implement** class-side
  `severity` is a **configuration error**, signalled by `PGRGate class>>forConfiguration:`
  before any check runs. **No default:** the inherited `#warning` is no longer a legal
  state for a *registered* rule. (Unregistered rules loaded in the image are unaffected —
  Renraku's own default stands where the gate is not involved.)
- **Why it holds:** ch. 2's inherited default and ch. 7's "only `#error` blocks" combined
  into a fail-open — register a rule, forget the severity, and real violations exit 0
  while the rule *looks* enforced. Silence about enforcement level is exactly what P6
  forbids; a rule's blocking status must be a stated fact, not an inherited accident.
- **Accepted consequence (ruled with eyes open):** we do not own `ReAbstractRule`, so a
  shipped built-in relying on the inherited default becomes **unregistrable** — a real,
  narrow restriction on D-05's register-by-name mechanism. The softer alternatives were
  rejected: reporting-only ("registered, not blocking" advisory line) and a
  per-registration severity override (already foreclosed by D-24). v1's catalog is
  unaffected: `PGRNoIsNilIfTrueRule` (D-20) and `ReCodeCruftLeftInMethodsRule` (D-28) both
  declare `#error` explicitly.
- **Consequences:** ch. 2 §2.2 (hook mandatory, no inherited fallback) and §2.4 (the
  built-in restriction stated); ch. 1 §1.1 validation list; ch. 9 gains
  P-SEVERITY-EXPLICIT.

---

## D-42 · The fix command may target the framework's own packages, with a stated caution (Q-26)

- **From:** Q-26 · **Ruled by:** human, post-gate spec review · **Date:** 2026-07-20
- **Ruling:** option (a). `PGRFixCommand` may be pointed at the framework's own production
  packages — that is legitimate self-hosting (we eat the autofix we ship). Ch. 3 §3.3
  carries the caution: the invoker must not run a fix from inside a gate run. That
  condition needs no runtime machinery — the framework's own layer map forbids
  `Phi-Guardrails-Gate` → `-Coding-Rules` (P-FIX-GATE-WALL), so the gate structurally
  cannot invoke the fix command, and an in-image run is single-threaded, so a gate run and
  a fix command cannot interleave in one process.
- **Why it holds:** silence was the real defect — the default behavior was "it just works
  until it doesn't". Refusal (option b) would exempt the framework from its own instrument
  for a risk the wall already covers; a runtime "gate in progress" guard (option c) would
  need exactly the global state R-35 forbids.
- **Consequences:** ch. 3 §3.3 gains the caution paragraph; no protocol change.

---

## D-43 · The toy's red state is protected by `ensure:` restoration and a `setUp` precondition (Q-27)

- **From:** Q-27, `plan/02-decision-sheet.md` · **Ruled by:** human, ch. 8 review ·
  **Date:** 2026-07-20
- **Ruling:** option (a) — **both** additions to `PGRToyDemoTest` (§8.3):
  1. **Restoration is exception-safe.** Each source mutation saves the original and is
     wrapped so the recompile runs whether the body succeeded, failed, or errored
     (`ensure:`) — not left to `tearDown` alone. A test blowing up mid-way cannot leave
     the toy partly fixed in the image.
  2. **`setUp` asserts the planted state.** Each test checks the toy is in its expected
     all-red condition before running, so a leak from any source (failed restoration,
     interrupted run, Playground session, future test) fails loudly at its cause instead
     of surfacing as a confusing failure in an unrelated test.
- **Why it holds:** the toy's committed red state *is* the fixture (D-26), and the three
  demo tests share it as mutable state — `testAllFixedThenClean` deliberately leaves the
  toy green. Without (1) a leak is possible; without (2) a leak is invisible. Each is one
  line, and together they convert an invisible failure mode into a visible one.
- **Amends D-26's letter, not its substance:** D-26 said the demo "restores in
  `tearDown`"; restoration now rides `ensure:` with a `setUp` guard. The toy stays
  committed red and the demo still drives red → fixed → green in-image, changing nothing
  committed. Rejected: mutating scratch copies instead of the committed toy — it would
  trade away exactly the honesty D-26 bought.
- **Consequences:** ch. 8 §8.3 gains the protection paragraph; ch. 9 P-GATE-RED's
  assertion column carries the guarantee.

---

## D-44 · The fixture-pair meta-rule is v1-widen scope (R-46), not a backlog item

- **From:** ch. 8 review finding 2, routing corrected by the human · **Ruled by:** human ·
  **Date:** 2026-07-20
- **Ruling:** the meta-rule making the client fixture-pair convention machine-checkable
  belongs to **v1 widening**, not the backlog. It is carried as requirement **R-46**
  (`plan/01-requirements.md` §D, scope `v1-widen`): for each project-scope registered
  check class `Foo`, a class `FooTest` must exist in a tests-role package. Class
  `PGRCheckFixturePairMetaRule`, kind `#behavioral`, registered in `#metaRules`, landing
  with R-26's mirror-test-packages meta-rule at M5.
- **Why it holds:** §8.1 step 4's convention is the one place the extension model leaves
  silence-as-success unclosed — a client rule that never fires (bad AST pattern, typo in
  the matcher) reports green, because a rule finding nothing is indistinguishable from a
  rule with nothing to find. That is the same defect class chs. 1 and 5 close by rule
  (R-24, the scope law), so it belongs in the requirement inventory the widening
  milestone works from, not in the discretionary backlog Prompt 3 may knowingly defer.
- **Routing correction recorded (method operating rule 9):** the agent had routed it to
  the backlog as B-06; backlog is for items that are genuinely discretionary, and scope
  that is *ruled in* is a requirement. B-06's row is **retained** (the backlog is
  append-only) and marked promoted-out with a pointer to R-46 — the live item is R-46.
- **Consequences:** `plan/01-requirements.md` gains R-46 and its counts move to
  v1-widen 7 / total 46 (the v1-skeleton line also now notes R-28's supersession by
  D-37); ch. 5 §5.5's widened-meta-rule list gains it; ch. 8 §8.1 step 4 cites R-46
  instead of B-06; `plan/02-spec/coverage.md`'s widen line updated; `plan/backlog.md`
  B-06 marked promoted-out.

---

## D-45 · The invocation model: the project is the subject of the gate, never its operator

- **From:** Gate-2 human review, closing architecture ruling (notice §A, 2026-07-20) ·
  **Ruled by:** human — binding · **Date:** 2026-07-20
- **Ruling:** phi-guardrails is a **standalone tool**, project-agnostic in *both*
  directions: the framework knows no client (R-05), and **the client does not know the
  framework**. Anyone or anything may run the gate on any repo — a developer in a
  Playground, a CI job, a shell script, an agent or harness, another tool. No caller is
  privileged and none is required. The gate starts nothing and knows no client; it is
  invoked, reads the configuration and the loaded code, and answers a verdict and an
  exit code. Diagram: `../phi/method/guardrails-invocation-model.svg`. Every hazard the
  review fought downstream of the old model — the exempt `CI-Tests` package, the
  no-self-sweep rule, the recursion hang, §9.3's reviewer-enforced conventions, the
  adapter copy-paste drift (B-07) — existed only because the project had been made the
  *operator* of its own gate.
- **Supersedes:** **D-10** (the CI-adapter mechanism; its plain-object gate half
  stands — the gate keeps no SUnit knowledge, now for a stronger reason) and **D-23**
  (the no-self-sweep rule as designed machinery; a one-sentence residual caveat
  survives). **D-27 becomes moot** (nothing to place). **D-40 survives, restated
  structurally:** the independence it demands is now visible architecture — the test
  runner and the gate are two separate CI steps by construction, not one run wrapped
  inside the other.
- **Acceptance requirement:** recorded as **R-47** (v1-skeleton, per the D-44 routing
  lesson — ruled-in scope is a requirement): *a project adopts phi-guardrails by adding
  one configuration file; no change to its source, baseline, or tests is required.*
- **Five implementation rulings (all human-ruled):**
  1. **No default config location.** `runHeadless:` and `fromFile:` take an explicit
     path; no repo-root convention, no working-directory default. The config need not
     live in the target repo — checking a repo you don't control is a supported case.
     In-repo remains the recommended default for projects that own their config.
  2. **The source root is declared in `guardrails.ston`** (`#src`), never inferred from
     the process working directory. Paths in the config are interpreted relative to the
     config file's own directory. *(Technical note, not an objection: a config loaded
     via `fromString:` — the in-repo toy — has no directory; therefore `#src` is
     specified as optional, required only by a registered check that consumes it, the
     §1.5 parameter pattern. `fromString:` configs simply cannot anchor relative paths.)*
  3. **Schema versioning.** The artifact carries a schema version; the gate reads its
     own version and older ones and **refuses a newer one** with a clear message rather
     than misinterpreting it — tool and target repos version independently now.
  4. **The caller provides everything.** No environment sniffing, no conventions, no
     run-time inference. phi-guardrails ships a **reference runner** (image assembly +
     invocation) as a convenience that must not re-privilege any caller.
  5. **The public interface must be usable cold.** Error text, findings, and the report
     are read by adopters with no decision log; self-explanatory messages and near-zero
     false positives are product requirements, product-tested by §8.4's external
     adoption proof.
- **Structural knock-ons ruled in the same notice:** role *assignment* moves into the
  configuration (`#roles` takes package names/patterns; baseline role groups become an
  optional convenience) while the *inventory* stays baseline-derived — **D-25 intact**:
  a baseline package matching no role is still a configuration error. The dead-code
  guard becomes a **registered check** (it was a test only because tests were the
  invocation path); read-only, R-12 holds. An **init/generate command** drafts a
  `guardrails.ston` from a baseline for human review — generation may guess, the
  run-time gate may never infer. A client loading the framework remains only for the
  optional extension package (step: custom checks), **development-scoped** — never in
  the client's `default` group. §7.6's "checks do no I/O beyond the image" line is
  amended by this ruling: the artifact read and the dead-src check's read-only walk of
  the declared source root are the two file accesses.
- **Consequences (amendments this entry):** ch. 7 §7.3 promoted to the invocation
  contract (wrapper treats any exit code ∉ {0,1,2} as failure), §7.4 rewritten as
  two-visible-steps CI, §7.5 reworked (schema version + `#src`; `ci-tests` machinery
  removed; dead-src check registered); ch. 8 §8.1 rewritten (adoption = one file),
  §8.2/§8.3 adjusted, residual caveat added; ch. 1 schema (schema version, `#src`,
  `#roles` matchers, scope law restated); ch. 5 §5.1 wording; ch. 9 §9.3 conventions
  pruned, properties reworked (P-SELF-HOSTED, P-NO-DEAD-SRC, P-GATE-HEADLESS,
  P-DETERMINISTIC allowlist) and added (P-SCHEMA-REFUSAL, P-NO-DEFAULT-PATH,
  P-ROLES-FROM-CONFIG); glossary (withdrawals + *schema version*, *source root*,
  *reference runner*, *caller*); requirements R-47 added, R-29/R-31 annotated, naming
  tree amended; coverage updated; backlog B-07 retired (B-06 precedent). Agent-decided,
  veto-open, D-16 precedent: the dead-src check's spec details (class
  `PGRSrcInventoryCheck`, kind `#architecture`, registered by name in
  `#architectureChecks` at the framework's own project scope) and the `#roles` matcher
  resolution order (baseline group name first, else package name / full-match pattern;
  a string that is both a group name and a package name is a configuration error).
- **Raised, not resolved (reported to the owner):** the toy demo test's new home · the
  reference runner's home · the **constitution collision** — `plan/00-constitution.md`
  names `Phi-Guardrails-CI-Tests` and D-23's mechanism in §2 (naming tree, write
  boundary) and §3 (the no-skips carve-out); it is a validated artifact at exactly its
  2-page ceiling, so amendment displaces text and is the owner's to make.
  *(All four resolved next session — D-46.)*

---

## D-46 · D-45 knock-on questions ruled: demo test to `Tests-Toy`; runner stays §7.3; owner amends constitution and pack

- **From:** the questions raised in D-45's application report · **Ruled by:** human
  (all four assessments accepted) · **Date:** 2026-07-20
- **1 · Toy demo home: `Phi-Guardrails-Tests-Toy`, an ordinary tests-role package.**
  The termination argument is the load-bearing fact and it holds: recursion needs the
  *target config's* tests role to contain the package holding the gate-driving test;
  the demo runs the gate on the toy's config, whose tests role is only
  `Phi-Guardrails-Toy-Tests` — the demo's own package can never enter that set. A
  self-hosted run *nests* (outer gate → behavioral runs `Tests-Toy` → inner gate on the
  toy config → terminates); it does not recurse — the pattern already proven by scratch
  runs. **Enforcement improves:** in a tests-role package the demo is machine-swept —
  the no-skips meta-rule now covers it; the framework's no-skips discipline becomes
  **total**, no carve-out clause anywhere. **Accepted costs:** the `Tests` composite
  loads the toy, and every local verify runs the red → fixed → green cycle — seconds,
  and running the framework's most valuable test often is a feature.
- **2 · Reference runner stays in §7.3 for v1.** Same reasoning that declined B-07:
  don't abstract from one instance. §8.4's external-adoption proof is the first real
  second consumer; the deferral is recorded **with that trigger** so it cannot become
  permanent by inertia.
- **3 · Constitution: the owner amends** (the collision is an opportunity — dropping
  the CI-Tests carve-out makes the no-skips rule total; removals free space under the
  2-page ceiling; the write boundary absorbs `guardrails.sh`). **4 · Pack §6: the owner
  amends** — the verification section names both CI steps (validation:
  `smalltalkci -s .smalltalk.ston` · enforcement: the gate headless on the framework's
  own config). Both edits are the owner's under the one-editor rule; a completion
  record lands here when both are in (the D-38 precedent).
- **Consequences (spec-side, this entry):** ch. 8 §8.3 (placement + termination
  argument), §8.1 baseline table (`Tests` composite gains `toy`; `CI` = `Tests`,
  retained as the workflow's load name), §8.2 loading note; ch. 9 preamble (no-skips
  now total over all framework test classes); ch. 7 §7.4 (two committed root-adjacent
  files: `ci.yml` + `guardrails.sh`); requirements naming tree gains `-Tests-Toy`.

---

## D-47 · D-45's veto-open details ratified; the `fromString:` anchor edge closed

- **From:** human review of D-45's three agent-decided details · **Ruled by:** human
  (all three accepted, no vetoes) · **Date:** 2026-07-20
- **Ratified:** (1) `PGRSrcInventoryCheck` — kind `#architecture`, registered at the
  framework's own project scope, *not* the global catalog: the check assumes
  Tonel-style directory-per-package layout, which the framework can promise about
  itself but must not impose on arbitrary adopters (the client-respecting choice);
  (2) the `#roles` matcher resolution order with ambiguity-is-an-error (family 7 —
  loud, never a silent pick; a typo'd pattern matching nothing is covered indirectly:
  its intended packages then sit in no role and the scope law fires); (3) `#src`
  optional via the §1.5 parameter pattern — the genuine catch D-45 ruling 2's
  objection channel invited: mandatory `#src` would have broken the toy's `fromString:`
  embodiment (D-18); absence makes a consuming check *missing* (loud), never a
  working-directory fallback.
- **Flag 1 (P-DETERMINISTIC / §7.6 I/O collision) — verified already applied:** the
  D-45 consistency pass had amended both sites: §7.6 reads "checks do no I/O beyond
  the image except the two ruled file accesses — the artifact read and
  `PGRSrcInventoryCheck`'s read-only walk of the declared `#src` root", and
  P-DETERMINISTIC's allowed-sites list names `PGRSrcInventoryCheck` beside `fromFile:`
  and `runHeadless:`. No further amendment needed; the property does not red on day
  one.
- **Flag 2 (the `fromString:` anchor edge) — applied this entry:** a **relative**
  `#src` in a configuration with no anchoring directory is a **configuration error
  whose message names the fix** (use an absolute path, or load via `fromFile:`) —
  cheap to state now, confusing to discover later. Ch. 1 §1.1's `#src` row and strict
  validation list amended.
- **Consequences:** ch. 1 §1.1 (two touches); no other spec change. The owner's
  constitution and pack §6 amendments (D-46 items 3–4) remain in flight; the
  completion record lands when both are in.

---

## D-48 · The public surface, by audience — and the everything-else-is-internal law

- **From:** the Gate-2 architecture addendum (ruled content of the backfill notice) ·
  **Ruled by:** human · **Date:** 2026-07-20 · **Recorded in:** spec ch. 0 §0.3
  (`plan/02-spec/00-architecture.md`)
- **Ruling:** the framework promises exactly four audience surfaces:
  1. **Caller** — `PGRGate class>>runHeadless:` / `runHeadless:on:` + the exit-code
     contract; in-image `forConfiguration:`, `run`, `onVerdict:`; `PGRReport`'s reading
     protocol (`verdicts`, `isClean`, `exitCode`, `blockingVerdicts`, `advisories`).
  2. **Config author** — the `guardrails.ston` schema + `#schemaVersion` and its
     compatibility rule: the complete public *data* surface.
  3. **Check author** — the `PGRCheck` contract; `PGRVerdict`/`PGRFinding`
     constructors; class-side `severity` (D-41); the fixture-pair requirement (R-37/
     R-46).
  4. **Kit author** — the `PGRKit` class-side contract.
  **The law: everything not named in these surfaces is internal and may change without
  notice.** The M1 freeze applies to the surfaces, not to internals — ch. 1 §1.3's
  column label amended accordingly (it conflated *specified* with *public*); each row
  now carries its surface membership or "internal". **The report's printed text is
  human-facing and explicitly not an API** — the machine contract is the exit code and
  the artifact schema. Cold readability of every surface is a product requirement
  (D-45 ruling 5), product-tested by §8.4.
- **Raised, not resolved (the addendum's gap report — candidates for the owner):**
  *surface candidates found while assigning rows:* `PGRConfiguration` construction
  (`fromFile:`/`fromString:`) — the in-image caller path (`forConfiguration:`) has no
  ruled way to obtain its argument · the `PGRVerdict`/`PGRFinding` *reading* protocols —
  an `onVerdict:` sink receives verdicts it has no promised way to read ·
  `PGRConfigurationError` as a caller-catchable signal · `PGRFixCommand` (D-06 gives it
  an external invoker, yet it sits in no audience surface — candidate fifth audience or
  ruled internal tool) · the init/generate command (§8.1 — a public tool with no
  surface). *Coverage holes (architecture elements nothing implements/enforces):* the
  M1 surface freeze has no ch. 9 property or machine check (review-tier today) · the
  reference runner's wrapper rule (∉{0,1,2} → failure) is untested by any property ·
  the schema-version *evolution policy* (when the version increments; what counts as
  breaking) is owned by no chapter — refusal is specced, versioning practice is not.
- **Consequences:** new `plan/02-spec/00-architecture.md` (ch. 0 beside the glossary);
  ch. 1 §1.3 label + surface column; glossary gains *public surface*, *audience*,
  *internal*; coverage carries ch. 0 for R-04/R-05/R-35/R-47 and this ruling.
  *(All eight raised items ruled next session — D-49.)*

---

## D-49 · The eight D-48 gap items, ruled — surfaces completed, freeze and wrapper machine-checked

- **From:** D-48's raised-not-resolved section (five surface candidates + three
  coverage holes), the surface candidates diagram-evidenced by the ch. 0 embeds ·
  **Ruled by:** human — all eight approved · **Date:** 2026-07-21
- **Surface completions (ch. 0 §0.3 amended in place):**
  1. **`PGRConfiguration class>>fromFile:`/`fromString:` → caller surface** — the
     call-flow diagram made the case: `fromFile:` is the second interaction of every
     headless run.
  2. **`PGRVerdict`/`PGRFinding` reading protocols → caller surface; constructors stay
     check-author** — the `onVerdict:` sink now receives objects it is promised to
     read.
  3. **`PGRConfigurationError` → caller surface, catchable by class**; its message
     *text* stays human-facing, not an API.
  4. **`PGRFixCommand` → fifth audience, "fix invoker"** — full D-06 contract
     (`rule:packages:`, `previewOn:`, `apply`, `changes`) plus the three signalled
     errors as catchable classes. Glossary *audience* updated to five.
  5. **Init command → config-author surface**: one class-side message,
     `PGRConfiguration class>>draftFor:` (selector/home an agent detail, veto-open),
     **draft-only semantics** — generation may guess, the run-time gate never invokes
     it.
- **Coverage holes closed:**
  6. **Surface freeze machine-checked — P-SURFACE-CONFORMS** (ch. 9): every surface
     selector exists on the stated side with the right arity, from a test-side manifest
     mirroring ch. 0 §0.3; a renamed or dropped member is a red test.
  7. **Wrapper rule — a CI shell self-test, not a waiver — P-WRAPPER-GUARD**:
     `guardrails.sh` invoked with a deliberately unloadable image must exit 3; three
     lines in `.github/workflows/ci.yml` beside the two main steps.
  8. **Schema versioning policy — ch. 1 owns it (§1.1):** *every* schema change bumps
     `#schemaVersion`; under strict validation there is no "compatible" change (an
     unknown key is already an error, so even additions break older gates); the gate
     reads all prior v1-era versions.
- **Consequences:** ch. 0 §0.3 (five audiences; both diagrams' markers finalized —
  no raised-`~` remains; legend rewritten), mapping table (P-SURFACE-CONFORMS,
  P-WRAPPER-GUARD replace the two gap cells); ch. 1 §1.1 (versioning policy), §1.3
  (surface cells: caller construction/reading, catchable error); ch. 3 §3.3 (protocol
  header names the fix-invoker surface); ch. 7 §7.3 (wrapper self-test); ch. 8 §8.1
  (init message named); ch. 9 (two new properties); glossary (*audience* → five).

---

## D-50 · Owner amendments recorded: constitution and pack aligned to D-37/D-45 (D-38 precedent)

- **From:** owner-amendment notice of 2026-07-21 · **Ruled by:** owner (sole editor of
  both files) · **Date:** 2026-07-21
- **Amendments recorded (verified on disk this entry):**
  1. Constitution §2 naming tree — the `-CI-Tests` row removed (D-45).
  2. Constitution §2 tests paragraph — the CI-Tests carve-out deleted; **the no-skips
     rule is total**: no `skip`/`expectedFailures` in any `Phi-Guardrails-Tests-*`
     package, no exemption clause — consistent with the toy demo's tests-role home
     (D-46), which the no-skips meta-rule now sweeps.
  3. Constitution §3 forbidden moves — same removal in the skip prohibition.
  4. Constitution §3 machine-enforcement bullet — the stale "secrets check catches
     credential literals" claim (D-37) replaced: credential literals are
     reviewer-caught via the method's credential scan; the deterministic check was
     withdrawn. *(Provenance: outside the §A report; flagged in the specification
     agent's D-46 go-ahead as the line-108 item.)*
  5. Pack §6 — CI stated as two steps: validation (`smalltalkci -s .smalltalk.ston`,
     independent of the gate, D-40) and enforcement (`./guardrails.sh guardrails.ston`,
     P7). Pack §3 carries **P7 · The project is the subject, never the operator**
     (family 3 · 5), as ch. 0's backfill assumed.
- **This closes D-46 items 3–4**; the invocation-model artifact trail (D-45 → D-50) is
  complete.
- **Consistency re-check (requested with the notice):** `plan/02-spec/` and the
  glossary contain **no live reference** to `Phi-Guardrails-CI-Tests`, the `ci-tests`
  group, or D-23-as-live-rule — the only hits are the three deliberate retirement
  statements (ch. 7 §7.4, ch. 9 §9.3). **One stale reference survives, in the
  constitution itself, outside this notice's list:** §2's naming discipline still reads
  "'pattern' is always qualified (secret · AST)" (line 42) — the *secret pattern* sense
  was withdrawn with its check (D-37; glossary now has only the AST sense). Flagged in
  the D-46 go-ahead as the line-43 item; owner's to amend (one-editor rule), and its
  removal frees words under the 2-page ceiling.

---

## D-51 · Composition over defaults; per-kit blocks — one scope, the file

- **From:** Gate-2 owner ruling (notice of 2026-07-21) · **Ruled by:** human — binding
  · **Date:** 2026-07-21
- **Ruling 1 — no kit-shipped defaults; defaults are compositional.**
  `globalCatalogSTON` is removed: kits ship no catalog and the core performs no merge.
  **What runs is exactly what the project's `guardrails.ston` names** — the file is the
  complete, diffable truth. P6 strengthened: a framework upgrade can no longer change a
  project's enforcement without a visible diff in that project's repo. A "default check
  set" is a **recommended block** — a pre-written, documented template composed into
  the file at authoring time, by hand or by the init/generate command. The
  global/project scope distinction collapses (one scope: the file); §1.2's merge law is
  removed; **D-24 is moot** (exclusion = don't write it); *promotion* rewords to
  inclusion in the kit's recommended block — a documented template, not a mechanism.
- **Ruling 2 — a kit owns one composable block.** `sectionNames` is removed. `#kits`
  becomes an **ordered array of self-contained blocks**, each naming its kit and
  carrying that kit's entire configuration (`#layerMap` moves inside the coding kit's
  block). The core validates the envelope strictly (D-16) and hands each block
  **verbatim** to its kit; the kit validates its own block strictly — an unknown key
  inside a block is a configuration error raised by the kit. The kit contract shrinks
  to identity plus building registrations from its block.
- **Supersedes / amends:** D-01's global-default-artifact slice and D-18 in full
  (no shipped catalog artifact exists); D-24 (moot); D-07's merge slice (the
  one-artifact principle itself is *strengthened*); D-19/D-28's "enters the v1 global
  catalog" — the selections survive as the recommended coding-kit block's contents;
  D-48's kit-author surface (now two messages); R-01/R-03/R-40/R-41/R-42 annotated in
  the requirements. D-45's invocation model is untouched; behavioral derivation from
  roles (D-25) is untouched.
- **Agent details, veto-open (D-16 precedent):**
  1. **Block shape:** `#kits : [ { #kit : 'PGRCodingKit', #lintRules : [...],
     #architectureChecks : [...], #layerMap : {...}, #metaRules : [...] } ]` — the
     array preserves registry order; each block is opaque to the core.
  2. **Registration `scope` field: removed** (the veto-open recommendation invited by
     the notice). One scope makes provenance meaningless; keeping it as informational
     dead data invites misuse — the D-32 unused-constructor logic. Constructors become
     `name:kind:check:` / `missing:kind:reason:`; the verdict's `scope` reader goes
     with it.
  3. **Kit message signature:** `registrationsFrom: block in: configuration` — the
     block is the kit's verbatim config; the configuration argument carries what
     ruling 2 does not move into blocks (the role-package accessors the behavioral
     derivation needs, D-25). `sectionAt:ifAbsent:` leaves the kit-author surface.
  4. **Schema version → 2** (the ruled D-49 policy applied to the schema's first
     breaking change). Version 1 was the never-shipped pre-D-51 draft: the shipped
     gate's prior-version set is empty at v1, and a version-1 file is refused as
     unknown, not parsed.
- **Consequences:** ch. 1 §§1.1–1.6 (envelope + blocks, one-scope section replaces
  scopes+merge, kit contract, missing table wording, promotion reworded); ch. 2 §2.4,
  ch. 3 §3.2/§3.2b, ch. 5 §5.3 ("recommended block includes it, drafted by init");
  ch. 7 §7.5 (the framework's own artifact names its checks explicitly — we eat the
  explicit-composition rule); ch. 8 §8.1 (block composition; the honest trade: a
  hand-written minimal config is minimally checked); ch. 0 (component map, both
  diagrams, kit-author surface, new invariant: *the configuration file is the complete
  statement of what runs*); ch. 9 (P-MERGE-LAW deleted; P-LOADING-INERT wording);
  glossary (*global catalog*/*scope* withdrawn, *section* → *kit block*, *promotion*
  reworded, new *kit block*/*recommended block*); requirements annotations; coverage.
- **Collisions with ruled owner ground — named, not edited:** pack §1 (mission:
  "check kinds × global/project scopes, with a promotion path"), **P3 itself**
  ("registrations at global scope (the shipped catalog) and project scope … promoted
  to the global catalog"), §8 outline item 1 and the Gate-2 extra "every check kind is
  registrable at both scopes"; constitution §1 ("registrable at global and project
  scope, project checks promotable to the global catalog"). All owner-editor files.
  *(All five discharged by the owner — D-52.)*

---

## D-52 · D-51 round closed: R-46 re-anchored by provenance; owner ground aligned

- **From:** the D-51 follow-back notice · **Ruled by:** human (item 1); owner
  amendments recorded per the D-38 pattern (item 2) · **Date:** 2026-07-21
- **1 · R-46 re-anchored.** D-51 removed the scope concept, killing R-46's defining
  phrase ("project-scope registered check class"). Re-anchored by **provenance**: *for
  each registered check class defined in one of this project's own baseline packages*
  (as opposed to classes loaded from an external kit's packages), a `FooTest` must
  exist in a tests-role package. The meta-rule's design is otherwise unchanged.
  Amended: `plan/01-requirements.md` R-46 row; ch. 5 §5.5's quotation. (Ch. 8 §8.1
  step 3 and backlog B-06 quote no scope wording — untouched; D-44's own text is
  append-only history.) *(Correction, freeze round: half of that parenthetical was
  wrong — B-06's retained original context **does** quote "project-scope registered
  check class"; it stands as append-only history with the live pointer re-anchored to
  R-46, which is why no edit was or is needed. Only the §8.1 step 3 half of the claim
  was accurate.)* A self-hosting gain falls out: the framework's registered
  checks are all defined in its own baseline packages, so when the meta-rule lands at
  M5 it machine-checks R-37 for the framework too, not only for clients.
- **Provenance edge raised, not resolved:** baseline membership includes **exempt-role
  packages** — e.g. a check class defined in a demo/fixture package (`Phi-Guardrails-
  Toy-Rules` is exactly this in the framework's own baseline) is "own" by this anchor,
  so if such a class were registered, the meta-rule would demand its `FooTest` even
  though the defining package is deliberately never targeted by checks. Probably right
  (the meta-rule checks test *existence*, not sweeping) — but whether exempt-role
  provenance counts as "own" for R-46 is a call the M5 implementer should not make
  silently. Same shape, milder: a check class defined in a *tests-role* package.
- **2 · Owner amendments recorded (verified on disk):** pack §1 mission ("kits
  contributing composable blocks to a single per-project configuration artifact") ·
  **P3 rewritten compositionally** (kits contribute self-contained blocks; the file is
  the complete statement of what runs; promotion = recommended block, a documented
  template, never run-time machinery) · pack §8 outline item 1 ("check kinds, kit
  blocks, registration format, recommended blocks") · the Gate-2 validation extra
  ("Every check kind is registrable from a kit block, and by a project's own extension
  checks") · constitution §1 P3 rewritten to match. All 2026-07-21. **The D-51
  collision list is fully discharged**; owner ground and spec agree.

---

## D-53 · The SDK architecture: four SDKs, protocol contracts, the boundary package

- **From:** Gate-2 owner rulings (SDK notice, 2026-07-21) · **Ruled by:** human —
  binding · **Date:** 2026-07-21 · Amends D-48/D-50's audience presentation (content
  preserved, framing recomposed); completes D-51's kit-block model.
- **1 · Surfaces are SDKs, and there are four** — each **complete** (everything its
  audience needs) and **minimal** (nothing else). Producer side, nested: Check-author
  SDK (check protocol, verdict/finding constructors, fix capability); Kit-author SDK
  (contains it, plus the kit protocol and the kit's published stanza). Consumer side,
  split by mutation rights: Gate-caller SDK (read-only — **no mutating message by
  construction**); Fix-invoker SDK (mutating, preview-first). P-FIX-GATE-WALL restated
  at SDK level: no path from the gate-caller surface reaches fix invocation. Config
  author: not a code SDK — the schema plus the init tool. Data-crossing blessed:
  `PGRVerdict`/`PGRFinding` sit in two SDKs by design (constructors producer-side,
  readers consumer-side) — boundary vocabulary, not coupling.
- **2 · The contract is the protocol, not the class.** `PGRCheck`/`PGRKit` become
  optional **skeletons** (abstract classes — not traits: slot-freedom is redundant
  under duck-typed conformance and trait attribution is live backlog B-03).
  **Registry construction validates conformance**: a named, loaded class that does not
  respond to its protocol is a configuration error naming class and missing selector,
  before any check runs. Contract methods sit in a browser protocol named for the
  surface (human-visible convention, unenforced).
- **3 · The boundary package `Phi-Guardrails-SDK`:** protocol declarations, the two
  skeletons, the frozen vocabulary (`PGRVerdict`, `PGRFinding`,
  `PGRConfigurationError`, the fix-invocation errors). Engine (`PGRRegistry`,
  registration machinery, configuration internals) stays in `-Core`. Layer-map edge:
  kit and check packages reference `-SDK`, never the engine. Gate/Report stay in
  `-Gate`. Owner naming ground verified on disk: pack §5 and the constitution tree
  carry `-SDK`.
- **4 · Fix recomposed:** authoring is a **capability of the check** — skeleton default
  `canFix` false; a fixing check overrides and produces a previewable change
  (engine-neutral SDK spellings; Renraku names are the coding kit's implementation).
  The **fix-invocation protocol hoists to `-SDK`, generic** (construct → `previewOn:`
  → `apply` → `changes`, staleness required, three errors); `PGRFixCommand` becomes the
  coding kit's implementation over methods/RB/Epicea; invocation machinery stays
  kit-side. Supersedes the "fix invoker = coding-kit surface" framing.
- **5 · Kit handoff narrowed structurally** (completes D-51; supersedes D-51's
  whole-configuration second argument): kits never receive the configuration object —
  the protocol takes the kit's block plus the resolved role package lists. Over-reach
  becomes impossible, not caught. A kit block has exactly **one** common field
  (`#kit`); new common fields require a ruling and a schema bump. Published stanza ≡
  recommended block (one concept: documented schema + shipped starter block).
- **6 · The init command is its own tool:** `draftFor:` leaves `PGRConfiguration`
  (purely run-time) for a dedicated authoring-time class on the config-author surface.
- **Agent details chosen, veto-open:** kit selector
  `registrationsFrom:productionPackages:testsPackages:` (the notice's example) · init
  tool `PGRConfigurationDraft` (class-side `draftFor:`), homed in `-Core` beside what
  it drafts (authoring-time, not boundary vocabulary; no new package for one class) ·
  `-SDK` contents list: `PGRCheck`, `PGRKit` (skeletons) + `PGRVerdict`, `PGRFinding`,
  `PGRConfigurationError`, `PGRFixNotPreviewed`, `PGRFixStale`,
  `PGRRuleNotAutofixable` (vocabulary) · the three fix-error *names* kept (noting
  `PGRRuleNotAutofixable` is coding-flavored for a now-generic protocol — flagged,
  not renamed).
- **Raised, not resolved:** (a) **`PGRRegistration`'s home contradicts the edge** —
  kit-author constructors (D-48/D-51) live on a class ruling 3 keeps in `-Core`, yet
  kits may reference only `-SDK`: either the registration (or a registration-spec
  value) joins the SDK vocabulary, or the kit protocol returns plain data the engine
  wraps — owner's call; (b) the **fix-capability message set beyond `canFix`** (the
  engine-neutral spelling for "produces a previewable change"); (c) **how the init
  tool obtains a kit's starter block** — a kit protocol message would re-widen the
  two-message contract; embedding it in documentation leaves the tool hand-maintained;
  (d) no kit-overreach self-test existed in ch. 9 to retire — the structural fix
  landed with nothing to remove.
- **Consequences:** ch. 0 (§0.3 as four SDKs; component map + both diagrams; new
  invariant *conformance is validated before any check runs*; stale SVG label fixed);
  ch. 1 (conformance validation, handoff signature, one-common-field rule, §1.3
  package/kind columns); ch. 3 (kit implements the SDK fix protocols); ch. 4 §4.4 +
  ch. 7 §7.5 (four layers, seven production packages); ch. 8 (baseline gains `-SDK`;
  init tool; conformance-not-ancestry in step 3); ch. 9 (P-CONFORMANCE, P-SDK-EDGE,
  P-CANFIX-DEFAULT; P-CAT-AUTOFIX re-anchored); glossary; requirements/coverage
  annotations. *(The raised slate ruled next entry — D-54.)*

---

## D-54 · SDK-round slate ruled: specs cross the boundary; capability and stanza messages; the round closes

- **From:** owner rulings on D-53's report (follow-back, 2026-07-21) · **Ruled by:**
  human · **Date:** 2026-07-21 · Completes D-53.
- **1 · `PGRRegistration` residency — kits return data.** New `-SDK` vocabulary value
  **`PGRRegistrationSpec`**: name, kind, and either a conforming check instance or a
  missing-reason (`name:kind:check:` / `missing:kind:reason:` move here). The kit
  protocol answers a collection of **specs**; the engine wraps them into its internal
  `PGRRegistration` (resolution state, `run`, verdict production), which stays in
  `-Core`, unreferenced by kits. *The boundary carries information; the engine owns
  mechanism* (family 3). **P-SDK-EDGE's day-one red is resolved.**
- **2 · Fix capability, two messages:** `canFix` (skeleton default false) +
  `fixCommandOn:` (required when `canFix`; answers an object conforming to the
  fix-invocation protocol). Shape ruled; exact spellings stay veto-open agent details.
- **3 · Kit contract gains `recommendedBlock`** (third message): the published stanza,
  **single-sourced on the kit class** — the init tool composes from it, docs quote it.
  New ch. 9 property (**P-STANZA-VALID**): each shipped kit's `recommendedBlock`
  parses cleanly and every check it names registers and conforms — self-validating
  documentation (P1). *This also closes D-53 raised item (c): the init tool's stanza
  source is the message, not hand-maintained docs.*
- **4 · Rename `PGRRuleNotAutofixable` → `PGRNotAutofixable`** — generic protocol,
  generic name; renames are free pre-code (family 1).
- **5 · Complete-and-minimal stays review-tier, eyes open:** P-SURFACE-CONFORMS covers
  existence/arity; completeness and minimality of each SDK are judgment-tier. One line
  added to the Gate-2 validator checklist (pack §8 validation extras — **delegated
  pack edit, this ruling**): *walk each SDK as its audience — anything missing,
  anything extra?*
- **Consequences:** ch. 1 §1.3 (`PGRRegistrationSpec` row; `PGRRegistration` fully
  internal; `PGRCheck` + `fixCommandOn:`; `PGRKit` + `recommendedBlock`), §1.4 (kit
  answers specs; engine wraps); ch. 0 §0.1/§0.3 + both diagrams (spec box in the SDK;
  edges re-pointed; residency parentheticals removed); ch. 3 §3.3 (capability pair;
  error renamed); ch. 9 (P-SDK-EDGE note cleared, P-STANZA-VALID added, P-CANFIX row
  extended); glossary (*vocabulary* + spec; *published stanza* single-sourced); pack
  §8 line (delegated). The two-direction check re-run over the final state — result in
  the round-closing report.

---

## D-55 · No default sink: the gate writes only to what it is given (Q-28)

- **From:** Q-28, `plan/02-decision-sheet.md` (the freeze validator's F-1 — the
  four-way collision: §7.2/R-45's Transcript default × D-28's registered built-in over
  production-role `-Gate` × the constitution's idiom ban × D-24's foreclosed
  exclusions) · **Ruled by:** human · **Date:** 2026-07-22
- **Ruling:**
  1. **There is no default sink.** §7.2's "default sink writes to the Transcript" is
     struck. The gate streams verdicts only to a caller-supplied sink (`onVerdict:`)
     or stream (`runHeadless:on:`); given neither, verdicts accumulate in the report
     and nothing streams. R-45's substance is unchanged, restated conditionally:
     *when a sink is provided*, it receives one verdict per registration, in registry
     order, before `run` returns.
  2. **Framework production code never references Transcript** — not as default, not
     as fallback, not via environment lookup (`Smalltalk at: #Transcript` is evasion
     of our own guard and is named as such). The Playground convenience becomes
     caller-side documentation: `gate onVerdict: [:v | Transcript crShow: v
     reportLine]` — typed by a developer, never committed, never swept.
     *(Correction, freeze round — agent-decided, veto-open: `reportLine` exists on no
     surface and in no protocol (the verdict-line format is `PGRReport>>printOn:`'s,
     explicitly not an API); the spec's snippet uses `v printString` — universal print
     protocol, human-facing display, no surface member implied. Promoting `reportLine`
     to the caller surface instead is a surface ruling the owner may still make.)*
  3. **Why:** the make-it-impossible move (the D-42/D-53 pattern) — the built-in keeps
     its full force, D-24 stays foreclosed (the framework grants itself no exception:
     the credibility line), the constitution's ban holds without exception, and P7 is
     honored once more: the caller provides the destination, like everything else.
  4. **The P5 gap routes to M1, strengthened:** the built-in's match set beyond
     `Transcript show:` is not probed now — instead §3.2b's **fixture pair must pin
     the match set**: the bad fixture contains each send form the rule claims to
     catch, one asserted critique each, so the answer is a permanent regression guard
     instead of a one-time probe.
- **Consequences:** ch. 7 §7.2 (sink contract, conditional R-45, protocol comment,
  Playground snippet as caller docs); ch. 3 §3.2b (match-set pin note); ch. 9
  (P-STREAM cites the amendment; new **P-NO-TRANSCRIPT** in the architecture self-test
  family); ch. 0 §0.2 (caller-provides-everything gains this instance); requirements
  R-45 annotated; coverage R-45 row. Q-28 closes ruled.

---

## D-56 · Kit prefix `PCK` (D-11 amended); first-kit stance; full object-model inventory

- **From:** owner rulings, pre-Prompt-3 verification of ch. 0 (notice of 2026-07-22) ·
  **Ruled by:** human — binding; amends D-11 · **Date:** 2026-07-22 · Owner ground
  (pack §5, constitution §2 naming) verified aligned on disk before recording (the
  D-38/D-50 pattern).
- **1 · Kit classes carry their kit's own prefix.** The coding kit is a *client of the
  SDK*, not part of the framework — its classes must not wear the framework's prefix.
  Framework (`-SDK`, `-Core`, `-Gate`) stays `PGR`; **kit classes carry their kit's
  prefix, regex-disjoint from `PGR`** — coding kit = **`PCK`** (`PCKLayerMapCheck`,
  `PCKFixCommand`, `PCKNoIsNilIfTrueRule`, …); **the toy models a real client and uses
  no framework prefix** (`ToyWidget`, `ToyNoIsNilIfFalseRule`, …). SDK vocabulary stays
  `PGR` — including the three fix-invocation errors (boundary property, not kit
  property). Package names unchanged (prefixes mark *class* family). Tests and
  fixtures follow their subject's family (`PCKLayerMapCheckTest`,
  `BaselineOfPCKFixture`, `ToyDemoTest`). Riders: (a) a one-line collision probe for
  `PCK` and `Toy` joins the M0/M1 probe work (D-31.a toolchain — D-11's house style);
  (b) a **naming-boundary check** (framework packages only `PGR*`, kit packages only
  their prefix) joins the future catalog candidates.
- **2 · First-kit stance:** ch. 0 §0.1 now states, normatively: *the coding kit is the
  first kit — resident in this repo for v1 convenience, privileged in nothing; any kit
  could be extracted without touching core, gate, or SDK.* The **external-kit proof**
  is backlogged (B-08): a trivial kit built outside this repo against
  `Phi-Guardrails-SDK` only, composed into a project — the decision point for
  extracting the coding kit.
- **3 · Full object-model inventory:** ch. 0 §0.1 gains the **class inventory table**
  (24 v1 production classes: 9 SDK, 4 core, 2 gate, 9 coding-kit — the seven
  previously absent kit classes now indexed) with the one-line disposition for
  test/fixture/toy classes and the shipped built-in; both diagram views gain the
  **ghost/elision note** in the CodingKit namespace ("…plus the kit's concrete checks,
  catalog rules, and run cache — chapter-owned; see the §0.1 inventory").
- **Agent details, veto-open:** the kit class is **`PCKKit`** (not `PCKCodingKit` —
  the prefix already says *coding kit*; `PCKCodingKit` would stutter), and its test is
  `PCKKitTest` · the naming-boundary rider is routed via the **backlog** (B-09, M5
  widened-catalog candidate) rather than the widened-catalog list in ch. 3 (rule 9:
  it blocks nothing and Prompt 3 must disposition it visibly).
- **Consequences:** prefix sweep applied across every spec chapter, the glossary,
  ch. 9's test names, the §1.1/§7.5 artifact examples and registration-name strings
  (`#kit : 'PCKKit'`, `lint/PCKNoIsNilIfTrueRule`, `'ToyNoIsNilIfFalseRule'`, …), and
  both diagram views — old spellings survive nowhere except decision-log/sheet/backlog
  history (append-only); requirements R-36 and the naming tree annotated (D-11 as
  amended); backlog gains B-08/B-09. The pre-D-56 spellings in D-01…D-55 entries are
  history and stand as written.

---

## D-57 · Kit packages rename too: `Phi-Coding-Kit-*` and `Toy-*` (completes D-56; supersedes its "packages unchanged" line)

- **From:** owner addendum to the prefix notice (2026-07-22) · **Ruled by:** human —
  binding · **Date:** 2026-07-22 · Owner ground (pack §5 naming + verify command,
  constitution §2 tree + verify command) verified aligned on disk before recording.
- **Ruling:** naming's second half. (1) Coding-kit packages:
  `Phi-Guardrails-Coding`* → **`Phi-Coding-Kit`** root + `-Rules`, `-Architecture`,
  `-Behavioral`; kit tests `Phi-Coding-Kit-Tests-*`. (2) Toy packages:
  `Phi-Guardrails-Toy-*` → **`Toy-*`** — the toy models a real adopter in packages as
  in classes (restores D-01's original example shape). (3) **Symmetry law**, stated in
  ch. 0 §0.1 as the naming-boundary check's spec (B-09): `Phi-Guardrails-*` ⇔ `PGR*` ·
  `Phi-Coding-Kit-*` ⇔ `PCK*` · `Toy-*` ⇔ `Toy*`.
- **Ripples swept:** baseline role groups and composites (ch. 8 §8.1) · §4.4's layer
  map · the framework artifact's `#roles`/`#exemptNamePatterns`
  (`'Phi-Coding-Kit-Fixtures-.*'`, `'Toy-.*'`) · `.smalltalk.ston` `#testing` now
  lists **both tests families** · the verify-command regex is
  `"(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*"` — **alternation spelling flagged
  ⟨verify⟩ for the M0 probe** (owner files already carry it) · ch. 0 component map +
  class inventory + both diagram views (SVG namespace label included) · glossary and
  every chapter's package mentions · requirements naming tree restructured (three
  families) · backlog B-04's live fixture-family pointer.
- **Veto-open (agent calls, recorded):** (a) the kit's behavioral red-test fixtures
  **move kit-side** — `Phi-Coding-Kit-Fixtures-Behavioral` — family symmetry (a kit's
  fixtures are the kit's), consistent with `BaselineOfPCKFixture`'s D-56 family;
  D-22's mechanism survives intact: the package is exempt-role, full-matches
  `'Phi-Coding-Kit-Fixtures-.*'` in `#exemptNamePatterns`, and matches neither tests
  pattern. (b) One ripple beyond the notice's list: **`BaselineOfPhiGuardrailsToy` →
  `BaselineOfToy`** — "the toy models a real adopter in packages as in classes"
  extends naturally to its baseline's name, and the toy's `#project` display name is
  now `'Toy'`; revert on veto.
- **Consequences:** 100 replacements across all ten spec chapters + glossary + the
  SVG + requirements; short-form (`-Coding-Rules`) and regex sites hand-amended; the
  pre-D-57 package spellings in D-01…D-56 entries are append-only history and stand.

---

## D-58 · Bookkeeping rider recorded: D-50's constitution thread discharged; `BaselineOfToy` joins the M0 collision probe

- **From:** owner rider notice of 2026-07-22 (two bookkeeping items) · **Ruled by:**
  owner; recorded per the D-38/D-50 pattern, owner ground verified on disk before
  recording · **Date:** 2026-07-22
- **1 · The D-50 owner thread on the constitution's "pattern" line is discharged.**
  D-50 flagged the stale `"'pattern' is always qualified (secret · AST)"` wording as
  the owner's to amend; the owner amended it during the round-7 fixes — the line now
  reads *"'pattern' means the AST sense only (the secret sense left with its check,
  D-37)"* (verified on disk this entry, `plan/00-constitution.md` line 52). No open
  owner-amendment thread remains from D-50.
- **2 · The M0 collision probe (D-56 rider a) gains `BaselineOfToy`** alongside the
  `PCK` and `Toy` class prefixes — a plausibly-colliding name in a shared image. The
  acceptance was the owner's rider from the package round (D-57), given in review but
  never carried into a notice, so the log's probe list did not record it until now.
- **Consequences:** none in the spec — the probe list lives only in this log (verified
  by sweep: no spec chapter, glossary, requirements, pack, or backlog site carries the
  collision-probe list), so this entry is the complete record; the M0 executor reads
  the probe as: `PCK` prefix · `Toy` prefix · `BaselineOfToy` class name, each
  confirmed collision-free in the stock Pharo 13 image (D-31.a toolchain, D-11's house
  style).

---

## D-59 · Quickstart guides: one per audience, written against the frozen surfaces — a design test wearing documentation's clothes

- **From:** owner update notice of 2026-07-22 (quickstart guides) · **Ruled by:**
  human — binding · **Date:** 2026-07-22 · Owner ground verified on disk before
  recording (D-38 pattern): the constitution's write boundary admits `docs/`
  ("product documentation", line 84).
- **Ruling:** new artifact family **`docs/quickstarts/`** — three guides, one per
  audience pairing, each writable using **only** the messages, files, and error
  classes its audience's SDK promises (ch. 0 §0.3 + the schema). The guides execute
  ch. 0's review-tier complete-and-minimal test (D-54.5's judgment-tier walk, now
  performed in earnest): anything a guide needs that is unpromised is a **surface
  gap — raised, never patched**. The guides are producer-owned, join the
  freeze-check/validator scope, become Prompt 3's milestone anchors ("the guide's
  sample runs end-to-end"), and script §8.4's external-adoption proof (D-45 ruling
  5 — usable cold). Tone: a Pharo developer who has never heard of Phi; no
  decision-log numbers in bodies (footers carry the ruling trail).
- **Produced (this entry):** `docs/quickstarts/01-adopt-and-run.md` (config author +
  gate caller: schema, recommended-block composition, `guardrails.sh`, exit codes
  0/1/2/3, in-image run with caller-supplied sink, `PGRConfigurationError`, missing
  semantics, the two likely first-run failures) ·
  `docs/quickstarts/02-write-a-check.md` (check author: conformance-not-ancestry
  both ways — skeleton and plain class; verdict/finding constructors; fixture pair;
  registration; lint-rule sidebar with D-41's explicit severity; the fix capability
  and three catchable errors) · `docs/quickstarts/03-build-a-kit.md` (kit author:
  the three-message contract, stanza/`recommendedBlock`, answering
  `PGRRegistrationSpec` values, block-verbatim-plus-role-lists handoff, D-57
  symmetry law, SDK-only edge). Each carries the P5 header: samples unexecutable
  until the guide's anchor milestone, marked ⟨verify⟩, executed verbatim by a test
  at that milestone.
- **Ch. 9 amendment:** §9.2 gains **P-GUIDE-EXEC** (name veto-open) — every sample
  in `docs/quickstarts/*.md` is executed verbatim at its guide's milestone and must
  behave as the guide states (exit codes, verdict names, signalled error *classes* —
  never error wording, which is not an API); a sample the surface no longer
  satisfies is a red test, not a stale document.
- **Surface gaps found while writing (the exercise working — raised, none resolved;
  each is marked descriptively at its site in the guide, with the footer pointing
  here):**
  1. **G-1 · The image-assembly recipe is promised nowhere.** Ch. 0 §0.1 ships the
     reference runner as "`guardrails.sh` (+ image-assembly recipe, §7.3)", but §7.3
     specifies only the invocation script. A cold adopter cannot get from zero to a
     runnable gate (framework + target project loaded; `$PHARO_VM`/`$IMAGE`
     contents) on promised material alone — guide 1's assembly step is an
     inference-marked sketch.
  2. **G-2 · Custom-check instantiation and target handoff are unspecified.** The
     check-author SDK promises `run`/`kind`/`canFix`(+`fixCommandOn:`) but not how a
     class named in `#architectureChecks` (§4.3, §8.1 step 3) is instantiated or
     handed targets/parameters. The v1 checks each receive bespoke parameter keys
     (§1.5's footnote owns that trade), but a client check author has no stated way
     to receive the production packages — guide 2's sample hardcodes its target and
     flags the gap.
  3. **G-3 · Kits must raise `PGRConfigurationError` but it is not in the
     kit-author SDK.** Ch. 1 §1.4 obliges the kit to raise configuration errors on
     unknown block keys; §0.3 lists the class only as gate-caller-catchable
     vocabulary. Guide 3's sample uses the inherited `Error` signalling protocol,
     flagged as unpromised.
  4. **G-4 · `recommendedBlock`'s answer type is unspecified** — STON text or a
     block map? P-STANZA-VALID's "parses cleanly" suggests text; ch. 1 §1.3 is
     silent. Guide 3 samples STON text, flagged.
  5. **G-5 · `kitName`'s consumer is unspecified.** Block resolution uses the class
     name (`#kit : 'PCKKit'` → loaded subclass); nothing states what reads
     `kitName`, so a kit author cannot know what their answer affects.
  6. **G-6 · Spec-kind vs check-kind agreement is unstated.** A
     `PGRRegistrationSpec` carries a kind the kit supplies, and the check itself
     answers `kind`; whether they must agree, and who checks disagreement, is
     specified nowhere.
  7. **G-7 · Conformance validation collides with block opacity for third-party
     kits.** §1.1/§1.4 assign conformance validation of "every check class the
     block names" to the construction machinery, but blocks are opaque to the core:
     for a foreign kit's custom keys the machinery cannot enumerate named classes.
     Either the kit carries an unpromised validation duty, or the machinery
     validates the spec-carried check instances after the kit answers — workable,
     but a different letter than "named … before any check runs", and it never sees
     entries the kit already marked missing. The v1 resident kit masks this; an
     external kit (B-08) exposes it.
  8. **G-8 · "The error text a user actually sees" cannot be promised.** The notice
     asks guide 1 to include it, but error wording is human-facing and explicitly
     not an API (D-48). Resolved editorially, flagged for awareness: the guides show
     representative text labeled illustrative, and P-GUIDE-EXEC asserts signalled
     error classes, never wording.
- **Veto-open choices (D-16 precedent):** the property name **P-GUIDE-EXEC** and its
  test shape — `PGRQuickstartSamplesTest` with one method per guide
  (`testAdoptAndRunSamples` / `testWriteACheckSamples` / `testBuildAKitSamples`),
  home a tests-role package chosen at landing (it drives the gate only on
  sample/scratch configurations — nests and terminates, the D-46 argument) ·
  milestone anchors: adopt-and-run → **M4**, write-a-check and build-a-kit → **M1**
  (working anchors from pack §8's milestone shape; Prompt 3 confirms or moves them)
  · sample namespaces `Acme` (adopter) and `Demo-Kit`/`DK` (kit) — invented,
  framework-neutral, disjoint from `PGR`/`PCK`/`Toy` · in-body gap markers are
  descriptive ⟨verify — open surface item⟩ notes (no G-numbers in bodies), with
  each guide's footer pointing at this entry.
- **Consequences:** `docs/quickstarts/` created (three files; producer-owned;
  freeze-check/validator scope); ch. 9 §9.2 gains P-GUIDE-EXEC; the G-1…G-8 slate
  awaits owner disposition — G-2, G-3, G-6, and G-7 look surface-shaping (candidate
  SDK completions, the D-48→D-49 pattern), G-4 and G-5 look one-line rulings, G-1
  is a §7.3 addendum, G-8 is recorded as handled. No other spec file, requirement,
  or coverage row changes under this entry. *(The slate is ruled next entry — D-60.)*

---

## D-60 · The G-1…G-8 slate ruled: surfaces completed, kit contract to two messages, spec-level validation — the quickstart round closes

- **From:** owner update notice of 2026-07-22 (rulings on D-59's eight surface gaps)
  · **Ruled by:** human — binding; veto-open only where marked · **Date:** 2026-07-22
  · Amends D-53/D-54's surface tables; cites D-59.
- **One-line rulings:**
  1. **G-3 · `PGRConfigurationError` joins the kit-author SDK, signalling side** — a
     kit that cannot resolve or validate its own block raises it; promised to kit
     authors, not just callers. *(Interpretation recorded, veto-open: the notice's
     amendment list also grants it to the **check-author** SDK, signalling side —
     read as deliberate, with construction-time parameter validation as the consumer;
     the layer-map laws (D-35, raised at check construction under G-2's contract)
     are the exemplar. Both tables amended; strike the check-author half on veto.)*
  2. **G-4 · `recommendedBlock` answers STON text** (a string): the init tool
     composes that text into the draft, docs quote it, P-STANZA-VALID parses it.
  3. **G-5 · `kitName` is dropped** — no consumer exists; the class name is the
     identity (block resolution already uses it; one thing, one place). The kit
     contract returns to **two messages**:
     `registrationsFrom:productionPackages:testsPackages:` · `recommendedBlock`.
  4. **G-6 · Spec kind and check kind must agree**, validated at registry
     construction; a mismatch is a configuration error naming the registration, both
     kinds, and the check class. Missing-specs keep their explicit kind (no check
     exists to ask).
  5. **G-8 · Ratified as executed:** illustrative error text stays labeled
     illustrative; P-GUIDE-EXEC asserts error *classes* and exit codes, never
     wording. No further action.
- **Small design rulings:**
  6. **G-1 · §7.3 gains the image-assembly recipe**, documented as what the committed
     CI workflow already does — `.github/workflows/ci.yml` is the *executable copy*;
     the prose recipe states the same steps (fetch headless Pharo 13 → Metacello-load
     the judged code → set `$PHARO_VM`/`$IMAGE`, invoke `./guardrails.sh`) and cites
     the workflow as the tested form, so docs and CI cannot diverge. Spellings
     ⟨verify⟩, queued with the M0 probe list. Guide 1 quotes the recipe; "runnable
     gate from zero" is now reachable on promised material alone.
  7. **G-2 · The instantiation contract:** the kit that names a check instantiates
     it, via one promised class-side constructor handing the check its targets at
     construction; `run` remains argument-less; a check never pulls context — 
     everything it knows, it was given. Joins the check-author SDK; the skeleton
     carries the default implementation. **Spelling chosen, veto-open:**
     **`packages:`** (the notice's example) — takes the target package *names*; the
     role handed is the one the block key implies (`#architectureChecks` →
     production-role, `#metaRules` → tests-role); the skeleton stores the list and
     exposes it to subclasses as instance reader `packages` (agent detail). Kit-side
     riders recorded as agent details in ch. 1 §1.4: a kit's *own* classes may use
     richer kit-side constructors (the parameterized v1 checks, the cache-closing
     behavioral checks); a named class answering neither path is a configuration
     error the kit raises.
  8. **G-7 · Conformance validation operates on the specs kits answer — never on
     block contents.** The core validates every resolved spec's check instance
     (conformance + G-6's kind agreement) at registry construction; blocks stay
     fully opaque, so the resident coding kit and an external kit have *identical*
     validation paths. The kit's stated duty: resolve names inside its own block,
     answering missing-specs or raising `PGRConfigurationError` (per ruling 1).
     P-CONFORMANCE reworded accordingly.
- **Amendments applied (this entry):** ch. 0 §0.3 (check-author gains `packages:` +
  the error; kit-author two messages, STON text, the error), §0.4 conformance
  invariant, §0.2 sequence-diagram notes, **both** object-diagram views (mermaid +
  SVG: `kitName` gone, constructor added, kit header "two messages", STON-text
  arrow) · ch. 1 §1.1 (two-stage paragraph → spec-level validation), §1.3
  (`PGRCheck` constructor row, `PGRKit` two-message row, `PGRConfigurationError`
  signalling surfaces), §1.4 step 2 (kit duty, instantiation law, spec-level
  conformance + kind agreement) · ch. 2 §2.3, ch. 4 §4.3, ch. 5 §5.4 (instantiation
  made explicit where implicit) · ch. 7 §7.3 (assembly recipe) · ch. 9
  (P-CONFORMANCE reworded + `>>#testSpecKindMismatchSignals`; P-SURFACE-CONFORMS
  roster note; P-STANZA-VALID STON text) · glossary (*check* + constructor; *kit* →
  two messages, STON text; *published stanza* → STON text) · the three guides:
  **zero gap markers remain** — guide 1 quotes the §7.3 recipe, guide 2's samples
  use `packages:`/`self packages`, guide 3 is two-message with the kind-agreement
  rule; footers extend the trail to D-60. Requirements, coverage, and backlog:
  verified by sweep — no site names `kitName` or the kit-contract message count, so
  no row changes (per convention, nothing to annotate).
- **Veto-open (agent calls, recorded):** the constructor spelling `packages:` +
  role-by-block-key semantics + skeleton instance reader `packages` (ruling 7) · the
  check-author reading of ruling 1's error grant (item 1 above) · the
  named-class-answering-neither-path error and richer-kit-side-constructor riders
  (§1.4) · the plain-class sample's `setPackages:` setter spelling (guide 2 —
  illustrative, the author's own class).
- **Consequences:** the D-59 G-slate is fully dispositioned (1–7 ruled and applied,
  8 ratified); the quickstart round closes. The guides now cite only promised
  surface; P-GUIDE-EXEC's milestone tests will hold them there.

**Addendum D-60.a · Walkthrough residue: the load expression, two guide polish
items** *(owner mini-notice of 2026-07-22, after a full walkthrough — every sample
selector checked against §0.3, clean; guide 1's four registrations reconcile).*

1. **The Metacello load expression (the G-1 species, one survivor).** §7.3's recipe
   step 2 and guide 1's step 2 named the load without making it executable. Both now
   carry the expression verbatim (`Metacello new baseline: 'PhiGuardrails';
   repository: 'github://<org>/phi-guardrails:main/src'; load`) — placeholder URL,
   ⟨verify⟩-marked, queued with the M0 probe list. **Workflow confirmation deferred,
   raised not resolved:** `.github/workflows/ci.yml` does not yet exist on disk (the
   repo is planning-corpus only; the workflow is an M0/M4 deliverable), so "the
   workflow contains the real form of the same expression" cannot be confirmed
   today — it becomes a landing condition recorded here: when the workflow is first
   committed, its load expression must be the real form of §7.3's, checked with the
   same M0 probe pass (the docs-can't-diverge argument, extended to the load step;
   §7.3 cites this addendum). One wrinkle for the M0 executor, named now: the
   workflow's step 1 loads via smalltalkCI's `SCIMetacelloLoadSpec` (`#directory :
   'src'`, the local checkout), not a `github://` URL — "the real form" is the
   image-assembly load for step 2's gate image; equivalence is judged there, not on
   the smalltalkCI spec. With the expression in place, guide 1's
   "runnable-gate-from-zero on promised material alone" claim holds with no
   prose-only steps.
2. **Guide 3 idiom (advisory, applied):** `self class environment at:` →
   `self environment at:` in the class-side sample — the idiomatic form for teaching
   material; ⟨verify⟩ marking stays.
3. **Guide 2 gains the kind↔block-key trap (advisory, applied):** one sentence after
   the protocol paragraph — the check's `kind` must match the kind its block key
   implies (`#architectureChecks` → `#architecture`); mismatch is a configuration
   error naming the registration, both kinds, and the class (G-6's rule, stated for
   the likelier tripper).

---

## D-61 · Gate-3 remediation slate: the roadmap validator's six findings ruled and applied

- **From:** roadmap validation report (fresh-session validator, verdict reject,
  six findings) + owner remediation notice of 2026-07-22 · **Ruled by:** human —
  binding; veto-open only where marked · **Date:** 2026-07-22 · Amends
  `plan/03-roadmap.md` in place; amends the method's placement check as applied
  to this project.
- **Rulings (a–f):**
  - **a · Placement-annotation law (F-1).** Annotated splitting is legal: a v1
    requirement lands in exactly one epic, **or** in several iff *every*
    occurrence carries a scope annotation naming the part that epic owes; a bare
    occurrence of a multi-placed ID is a finding. Applied: the six bare
    occurrences annotated (R-06/E05 verdict half · R-12/E08 invocation half ·
    R-32/E14 demonstration half · R-36/E01 framework + kit families · R-38/E09
    M1 form · R-47/E09 self-adoption proof); R-15's three "halves" re-cut into
    three named parts — the rule (E06) / the autofix (E08) / the self-hosting
    (E09). *(Agent extension, veto-open: R-05 and R-47 carried the same defect —
    three-way splits with two "half" annotations. Re-cut on this ruling's own
    rationale ("three halves is not a partition"): R-05 → the configuration
    statement (E03) / machine enforcement (E09) / the stand-in client (E12);
    R-47 → the schema (E03) / the invocation contract (E05) / the self-adoption
    proof (E09). Strike back to the ruling's literal punch list on veto.)*
  - **b · Flush probe to E01 (F-2, agreed as found).** Stream-flush-before-
    `Smalltalk exit:` joins E01's probe list — a five-line headless snippet
    writing to stdout then exiting nonzero; the result is recorded against this
    entry at M0, and E05 consumes it rather than discovering it. B-03 stays at
    E06 (its backlog-recorded trigger).
  - **c · M5 row struck (F-3).** §1's milestone table loses the M5 row; §6 is
    the sole record of M5 scope (recorded, not epic-cut; its finish line is
    defined by a roadmap re-entry when M4 closes). The table's rule is thereby
    absolute: every row has an executable checkpoint, no exceptions.
  - **d · E13 merged into E12 (F-4).** The init tool folds into the toy-client
    epic: goal, spec refs (ch. 8 §8.1 step 1 · ch. 0 §0.3), R-31 (draft half),
    and dependencies (E03, E06/E07) join E12; merged estimate ~7 chunks.
    Knock-ons swept: §3 DAG node and edges gone (E15 depends on E14 alone), §4
    float note and the M4 parallel pair removed (M4 is now strictly
    sequential), §7 item 3 rewritten. The label E13 is retired, never reused
    (the corpus's stable-ID convention).
  - **e · Arithmetic (F-5).** §4's headline corrected to match the table:
    **14 epics, ~72 chunks** (the prior "~68" never matched its own rows; the
    track sums 23/17 were correct and stand — the merge is count-neutral).
  - **f · R-03 restored (F-6).** §6's M5 scope-on-record now holds all seven
    v1-widen requirements; R-03 enters as documentation-tier (promotion =
    inclusion in the kit's recommended block, per D-51).
  - **g · R-31 annotation completed (owner ruling on the D-61 report's raised
    question).** R-31 stays single-placed in E12; no epic is invented for the
    adoption half. Its annotation now states the remainder instead of implying
    one: *the adoption half is code-free post-D-45* — documented in ch. 8 §8.1,
    exercised by guide 2's samples (E09) and the toy's extension package (E12),
    with the cross-repo dependency proof at §8.4/M5. Exact wording agent-chosen,
    veto-open; the four facts (code-free · §8.1 · E09/E12 exercise · §8.4/M5
    proof) are the ruling. The sweep gains the companion assertion: no other
    single-placed requirement carries a bare "half" annotation.
  - **h · Post-PASS minor punch list (owner notice; one batch, no re-validation).**
    (1) E02 gains a **Properties** line claiming P-CANFIX-DEFAULT (its test
    subject was already in E02's goal) — every ch. 9 runtime property now has a
    named epic owner. (2) §3's DAG parenthetical discloses **both**
    milestone-barrier stand-in arrows — E09→E10 ("M1 complete"; true deps
    E06/E02) beside E11→E12 ("M2 complete") — so the "arrows are true epic
    dependencies" caption is accurate for both. Sweep companions: all 41
    testable ch. 9 properties (42 minus process-tier P-SPELLINGS) are owned
    under the placement law — Properties-line claims, part-annotated splits
    legal; a property with no Properties-line claim must be named by exactly
    one epic's body (the two such cases: P-FIX-GATE-WALL → E09's goal,
    P-WRAPPER-GUARD → E15's goal — operationalization agent-chosen, veto-open)
    — and both stand-in arrows are named in the parenthetical.
  - **i · E01 "harness" disambiguated (owner ruling).** The Phi family also uses
    "harness" for the TBD agent/orchestration harness that *invokes* the gate
    (the P7 discussions) — explicitly not this project. E01's harness is the
    **build/test harness**: toolchain, verify command, `.smalltalk.ston`, CI
    step 1. Applied: E01's title, the M0 table row name, §0's closing line, and
    the §3 DAG node label all read "build/test harness" (four occurrences). The
    fifth occurrence — E09's risk note, "the verbatim-sample execution
    harness" — is a third thing (test-side sample-execution machinery), judged
    already unambiguous by its own qualifier and left as is (agent judgment,
    veto-open: qualify it too on veto). No occurrence means the agent harness —
    nothing scope-shaped to raise. Sweep companion: every "harness" occurrence
    in the roadmap reads "build/test harness" or "sample execution harness";
    a bare "harness" is a finding.
- **Consequences:** `plan/03-roadmap.md` amended in place; its preamble carries
  the amendment notice. The post-remediation consistency sweep asserts: no
  surviving E13 reference outside merge notes, no M5 row in §1, every
  multi-placed requirement ID annotated at every occurrence, totals matching the
  epic table. Re-validation runs against the amended placement check.

---

## D-62 · Gate 3 closed: the roadmap is approved and frozen

- **From:** owner approval notice of 2026-07-22 (Gate 3) · **Ruled by:** human —
  binding · **Date:** 2026-07-22
- **Ruling:** `plan/03-roadmap.md` is **approved and frozen at D-62**. The three
  §7 items are confirmed, no vetoes:
  1. **Milestone relabeling confirmed** — M3 retired, M4/M5 meanings preserved;
     the D-59 guide anchors as ruled (guides 2–3 → M1, guide 1 → M4).
  2. **Every veto-open spelling and choice closes on the D-16 precedent:** the
     §7 item-2 roster — `packages:` + role-by-block-key + skeleton reader
     (D-60.7) · the check-author `PGRConfigurationError` grant reading (D-60.1)
     · `PCKKit` (D-56) · P-GUIDE-EXEC name and test shape (D-59) · the D-55
     `printString` snippet correction — plus every veto-open accumulated in
     D-61 a–i: the annotation wordings · the R-05/R-47 re-cuts · D-61.b as the
     flush-probe recording anchor · the property-ownership fallback (D-61.h) ·
     the harness allowlist and the E09 left-as-is judgment (D-61.i). **Settled
     ground: never re-litigate.**
  3. **Small-epic item confirmed as rewritten** — no epics outside the 3–10
     band.
- **Validation history:** fresh-session validation REJECT (six findings) →
  remediation D-61 a–f → fresh-session re-validation **PASS** → post-PASS
  owner-ruled minor rounds D-61.g–i (no re-validation required) → approval.
- **Consequences:** the roadmap's preamble carries the frozen-at-D-62 marker
  beside the D-61 amendment notice; §7 is retitled as ruled at gate close, its
  items retained as the record of what was confirmed. The full D-61/D-62 sweep
  suite re-ran clean at freeze. **The stage advances to Prompt 4 (per-epic
  chunk work orders) with the frozen roadmap as its input; no further roadmap
  edits without an owner notice.**

---

## D-63 · (reserved) M0 probe record

*One-line reservation stub: this number is reserved for the M0 probe record that E01/C01 creates at execution time (its deliverable in the Prompt-4 papers); it will be written after D-64/D-65 below — recorded so the log's numbering order is explained.*

---

## D-64 · Q-29 ruled: publish `mittcooper/phi-guardrails`, public, default branch `main`

- **From:** Q-29 (`plan/04-decision-sheet.md`, raised by the Prompt-4 task-writing
  run — the M0 checkpoint requires an actual CI run, but the repo had no remote and
  its local branch was `master` against the spec's `:main` placeholders) · **Ruled
  by:** human — binding, owner notice of 2026-07-23 · **Date:** 2026-07-23
- **Ruling (as recommended):** (a) host coordinates `mittcooper/phi-guardrails` on
  github.com; (b) visibility **public** — keeps the D-60.a hosted-load probe honest
  (no token machinery in the image) and matches the family's open-development
  posture; (c) rename `master` → `main` **before first push**, so the spec's
  placeholder load form (`github://<org>/phi-guardrails:main/src`, §7.3) is the real
  form and no remote ever carries `master`.
- **Consequences:** C03's entry block lifts — its publishing procedure already
  carries these as its ruled values; C04's hosted-load probe runs against
  `github://mittcooper/phi-guardrails:main/src`. The §7.3 `<org>` placeholder stays
  a placeholder in the frozen spec; this entry records the real coordinates, and
  E15's D-60.a landing condition is judged against them.

---

## D-65 · Q-30 ruled: write-boundary reading confirmed; build-infrastructure locations amended

- **From:** Q-30 (`plan/04-decision-sheet.md` — the boundary read literally forbade
  the toolchain download and left `.gitignore` and runner scripts homeless) ·
  **Ruled by:** human — binding, owner notice of 2026-07-23; constitution §2 amended
  by the owner (owner ground) · **Date:** 2026-07-23
- **Ruling:** the reading is **confirmed** — the write boundary governs the product
  (framework, kit, and toy code and their tests at run time), not repo build
  infrastructure — but with **amended locations** (the "name the location instead"
  clause of Q-30):
  - committed harness scripts live in **`tools/`** (repo root), not
    `plan/toolchain/`;
  - **all** uncommitted build state lives in a single git-ignored **`.build/`** —
    toolchain at `.build/pharo/` (version-free path), work images at
    `.build/work/`, probe scratch at `.build/scratch/` — not `pharo13/`.
- **Rationale on record:** `src/` is the Tonel load root and the gate's subject
  (its 21 directories are E01's frozen export, so tooling may never live there);
  `tools/` gives operator-side machinery a named home so the directory tree mirrors
  the subject/operator wall; one `.gitignore` line covers all transient state; no
  version number in a path.
- **Consequences:** constitution §2's mutation-discipline paragraph carries the
  amended reading (owner-amended, verified on disk this entry); the E01 papers
  (C01–C04, chunk index, ledger, decision sheet) are swept to the ruled paths in
  the same notice's sweep; D-31.a's recipe is unchanged as history — its install
  target is henceforth `.build/pharo/`.

---

## D-63 · M0 probe record (E01)

*The full record for the number reserved by the D-63 stub above (its one-line entry
explains the log's numbering order); appended after D-65 at execution time, as the
stub anticipates.*

- **From:** E01/C01 execution — harness `tools/probe-m0.sh` over the
  `tools/install.sh` toolchain; probe sources `plan/probes/m0-flush.st`,
  `plan/probes/m0-regex-setup.st` · **Ruled by:** live-image evidence, recorded by
  the implementer · **Date:** 2026-07-23
- **Toolchain actually installed** (D-31.a recipe at the D-65 location
  `.build/pharo/`): image `Pharo13.0-SNAPSHOT-64bit-4f7563dfe5.image`;
  `SystemVersion current` →
  `Pharo-13.1.0+SNAPSHOT.build.745.sha.4f7563dfe5e465d0cb0a269e3ba58a351b1a8cde (64 Bit)`.
  **Risk line (build drift, noted per the C01 work order — not a failure):** this is
  not the `4c3e4714cc` build (2026-07-09) the D-15/D-25.a spelling inventory was
  verified on; the `get-files/130` channel now serves a 13.1-series snapshot under
  the Pharo13.0 image name. Every spelling below — and every D-15 spelling it leans
  on (`Stdio stdout`, `Smalltalk exit:`, the `test --fail-on-failure` CLI, the
  D-15.b fluid class form) — re-executed green on `4f7563dfe5`. Recommendation, not
  a ruling: if a later chunk hits an inventory mismatch, suspect drift first;
  consider pinning the two zips by checksum then.
- **Probe 1 · D-58 collision probe (stock image).** Spellings as executed:

  ```smalltalk
  (Smalltalk globals keys select: [:k | k beginsWith: 'PCK']) asSortedCollection asArray.
  (Smalltalk globals keys select: [:k | k beginsWith: 'Toy']) asSortedCollection asArray.
  Smalltalk globals includesKey: #BaselineOfToy.
  ```

  | question | outcome |
  |---|---|
  | any global with prefix `PCK`? | `#()` — none |
  | any global with prefix `Toy`? | `#()` — none (no hits, so no class-or-not analysis needed) |
  | exact name `BaselineOfToy` taken? | `false` |

  All three names are collision-free on the stock image (analogue of D-15's `PGR`
  survey).
- **Probe 2 · D-61.b stream flush before `Smalltalk exit:`.** The snippet writes a
  100 000-char payload + `END-OF-REPORT` + lf to `Stdio stdout`, then
  `Smalltalk exit: 7` (`plan/probes/m0-flush.st`; the flush arms insert
  `Stdio stdout flush.` before the exit line). Four arms from the shell, each
  checked for exit code and captured-stdout completeness (100 014 bytes, ending
  `END-OF-REPORT` + lf):

  | arm | invocation | flush? | exit code | stdout complete |
  |---|---|---|---|---|
  | A | `st` | no | 7 | yes |
  | B | `st` | yes | 7 | yes |
  | C | `eval` | no | 7 | yes |
  | D | `eval` | yes | 7 | yes |

  **The sentence E05 builds on: an explicit `flush` is NOT required — stdout written
  immediately before `Smalltalk exit:` reaches the caller intact under both `st` and
  `eval` invocation, and the exit code is preserved exactly.** An explicit flush is
  harmless (arms B/D byte-identical to A/C); E05 may emit one as belt-and-braces,
  but correctness does not depend on it.
- **Probe 3 · D-57 verify-command alternation regex.** On a scratch *copy* of the
  stock image (`.build/scratch/probe.image`), three one-test `TestCase` subclasses
  were created in packages `Phi-Guardrails-Tests-ProbeAlpha`,
  `Phi-Coding-Kit-Tests-ProbeBeta`, and `XPhi-Guardrails-Tests-Gamma`
  (`plan/probes/m0-regex-setup.st`).
  - Class-creation spelling that worked (D-15.b fluid form, `compile:` sent to
    `install`'s result so no statement references a just-created class name):

    ```smalltalk
    (TestCase << #ProbeAlphaTest
        package: 'Phi-Guardrails-Tests-ProbeAlpha';
        install) compile: 'testTruth self assert: 3 + 4 equals: 7'.
    ```

  - Image-save spelling that worked: `Smalltalk snapshot: true andQuit: true`
    (script exited 0; the saved image carried the classes into the next run).
  - Verify run:
    `<vm> <scratch-image> test --fail-on-failure "(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*"`
    → **exit 0**; runner output proving the count: `Running tests in 2 Packages` …
    `2 run, 2 passes, 0 failures, 0 errors.` — one test per alternation branch,
    the `XPhi-…` package excluded (full-match, as D-15 predicts). **Alternation is
    honored; the pack's verify command stands exactly as written.**
- **Local load (D-60.a local form), appended by C02.** Work image built by
  `tools/build-image.sh`: pristine C01 image + `.changes` copied to
  `.build/work/phi.image`/`.changes` (sources symlinked), then, via the VM's `eval`
  on the work image, the expression as executed (one eval string, load then save —
  the image was saved with the same `Smalltalk snapshot: true andQuit: true`
  spelling probe 3 verified, not an `eval --save` flag):

  ```smalltalk
  Metacello new baseline: 'PhiGuardrails';
      repository: 'tonel:///Users/mitt/dev/projects/phi-guardrails/src';
      load: 'CI'.
  Smalltalk snapshot: true andQuit: true
  ```

  → **exit 0**; all 20 packages + `BaselineOfPhiGuardrails` reported
  `MetacelloNotification: Loaded`, `...finished baseline`. No `.properties` file in
  `src/` was needed — the bare Tonel directory tree satisfied the `tonel://` scheme.
  Verify command against the saved image: exit 0,
  `Running tests in 7 Packages` … `5 run, 5 passes, 0 failures, 0 errors.`
  (the smoke suite; fixture/toy stubs contribute none, the regex excludes
  `-Fixtures-`).
  - *Correction (C02 reopen, after C03's CI run 30066695778):* the
    no-`.properties` sentence above holds for the explicit `tonel://` scheme
    only. smalltalkCI's `#directory : 'src'` loading goes through `filetree://`,
    whose format dispatch requires `src/.properties` declaring
    `{ #format : #tonel }` — without it, step 1 fails at `Loading project...`
    with `NotFound: BaselineOfPhiGuardrails`. The file was added at C02 reopen
    (emitted in the exact Iceberg `IceRepositoryProperties>>contentsString`
    form: STON pretty-print, 3 lines); the explicit `tonel://` load above is
    unaffected and re-verified with the file present.
- **CI service (step 1), appended by C03.** Platform **`Pharo64-13`** on
  smalltalkCI, GitHub Actions `ubuntu-latest` (repo published per D-64:
  `mittcooper/phi-guardrails`, public, `main` only). **Green run:**
  <https://github.com/mittcooper/phi-guardrails/actions/runs/30067053566>
  (commit `afb44e8`) — log shows `PGRBaselineSmokeTest` ·
  `Executed 5 Tests with 0 Failures and 0 Errors` · `(5 tests passed)`, so the
  D-15 silence hole is excluded by reading, not just `#failOnZeroTests`. Final
  action spellings that worked (two red iterations first: run 30066654756 —
  `smalltalkci -s .smalltalk.ston` is wrong, `-s` takes the *platform* and the
  config auto-detects at the repo root; run 30066695778 — the `filetree://`
  `NotFound`, cured by the correction sub-bullet above):

  ```yaml
  - uses: actions/checkout@v4
  - uses: hpi-swa/setup-smalltalkCI@v1
    with:
      smalltalk-image: Pharo64-13
  - run: smalltalkci -s Pharo64-13
    shell: bash
    timeout-minutes: 30
  ```
- **Still to land here (stated stubs, per the C01 work order):**
  - *C04 appends:* the hosted load expression
    (`github://mittcooper/phi-guardrails:main/src`, D-64) + the real-family regex
    confirmation on the loaded image.
  - This entry completes at E01 acceptance.
- **Hosted load (D-60.a hosted form), appended by C04.** In a **fresh** copy of the
  pristine C01 image (`.build/scratch/hosted.image` — never the work image), the
  probe `plan/probes/m0-hosted-load.st` ran §7.3 recipe step 2 with the D-64 ruled
  coordinates. The expression as executed, which **worked** (exit 0):

  ```smalltalk
  Metacello new
      baseline: 'PhiGuardrails';
      repository: 'github://mittcooper/phi-guardrails:main/src';
      load: 'CI'.
  ```

  → 21 `MetacelloNotification: Loaded` lines (`BaselineOfPhiGuardrails` + all
  20 packages), each stamped
  `https://github.com/mittcooper/phi-guardrails.git[main](a92faf6e043ab1d1ae04445f71907d5adb721bf3)`,
  then `...finished baseline`. Same-session assertion: `Smalltalk globals
  includesKey: #BaselineOfPhiGuardrails` → true, and
  `PGRBaselineSmokeTest buildSuite run` →
  `5 ran, 5 passed, 0 skipped, 0 expected failures, 0 failures, 0 errors, 0
  passed unexpected` (`hasPassed`; script exits 0 only then). No credential
  machinery needed — the repo is public per D-64. Not blocked; the E15
  workflow-equivalence landing condition (D-60.a) remains E15's, judged against
  these coordinates when step 2 lands.
- **D-57 regex confirmed on the real tree, appended by C04.** C01's probe 3 proved
  the alternation dialect on scratch packages; the same regex
  `"(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*"` now stands confirmed **on the real
  families**: `tools/verify.sh` on the work image reports
  `Running tests in 7 Packages` … `5 run, 5 passes, 0 failures, 0 errors.` (both
  families' tests-role packages matched, `-Fixtures-` excluded, five smoke tests
  named individually), re-run green at C04 on head `a92faf6`; the CI service runs
  the same suite green (runs 30067053566 on `afb44e8`, 30067111092 on `a92faf6`).
  `XPhi…`-style false matches are impossible by full-match, as probe 3 showed.
- **Entry complete (C04 close-out, 2026-07-23).** All four roadmap probe bullets
  are answered above with spellings as executed: **D-57** regex (dialect, probe 3;
  real tree, the row above) · **D-58** collisions (probe 1: `PCK`, `Toy`,
  `BaselineOfToy` all free) · **D-60/D-60.a** load expression (local `tonel://`
  row + hosted `github://` row — hosted ran green, no blocker to record) ·
  **D-61.b** stream flush (probe 2, four arms; the sentence E05 builds on). The
  "completes at E01 acceptance" stub resolves to: complete as of C04, with the M0
  exit checkpoint's three legs green on head `a92faf6` (recorded in
  `plan/04-epics/E01-build-test-harness/chunks.md`). Still open **by design**, not
  a gap here: E15's D-60.a landing condition — workflow load ≡ §7.3 real form
  (`github://mittcooper/phi-guardrails:main/src`), checked when step 2 lands.

---

## D-66 · B-10 ruled: toolchain downloads pinned by checksum

- **From:** B-10 (`plan/backlog.md` — filed at the E01/M0 milestone mining from
  C01's completion report and review: the `get-files/130` channel demonstrably
  drifts; it served `4f7563dfe5`, a 13.1-series snapshot under the Pharo13.0 name,
  not the `4c3e4714cc` build the D-15/D-25.a spelling inventory was verified on) ·
  **Ruled by:** human — binding, owner notice of 2026-07-23 · **Date:** 2026-07-23
- **Ruling (as recommended, accepted):** pin the D-31.a toolchain downloads by
  checksum. The pin target is the build actually installed and re-verified green —
  **`4f7563dfe5`** (`Pharo-13.1.0+SNAPSHOT.build.745`, D-63's toolchain record) —
  and `tools/install.sh` must **fail loudly on mismatch**, never silently install a
  drifted build. An archived copy of the artifacts remains open as the stronger
  later form — not ruled now.
- **Consequences:** implementation is a small chunk cut in E02's Prompt-4
  decomposition run — not the integrator's to build. Until it lands, D-63's risk
  line stands (suspect drift first on any inventory mismatch).

---

## D-67 · B-12 ruled: machine-enforced chunk commit hygiene

- **From:** B-12 (`plan/backlog.md` — the one correction that repeated across the
  E01 milestone mining sweep: uncommitted working-tree state leaked between chunk
  boundaries in all four chunks' reports) · **Ruled by:** human — binding, owner
  notice of 2026-07-23 · **Date:** 2026-07-23
- **Ruling (as recommended, accepted):** commit hygiene becomes machine-enforced
  (P1 applied to the pipeline): a `tools/` precondition check requiring (a) a clean
  working tree — modulo the ledger, the orchestrator's one mutable file — before an
  implementer spawns, and (b) each accepted chunk committed before the next pick.
  Cut as a small E02 chunk in the next Prompt-4 run. From E02 on, work orders state
  commit expectations explicitly.
- **Consequences:** the E02 decomposition carries both the check chunk and the
  work-order-template amendment; the integrator's operating loop gains the
  precondition check as a deterministic-tier step once the tool exists.
