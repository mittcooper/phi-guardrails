# Constitution — phi-guardrails

*Standing policy. Every implementer and reviewer subagent receives this file verbatim;
it states standards, never design substance (that lives in `plan/02-spec/`). On any
conflict, `plan/decision-log.md` wins.*

## 1 · Binding principles (the tie-breakers; Pack §3, sheltering under `../phi/phi-overview.md` §3/§3.1)

- **P1 · Machine-enforced, not prose.** A coding rule exists only if a machine checks it
  automatically, and where a safe rewrite exists the rule fixes rather than flags.
- **P2 · Deterministic first.** Free, precise machine checks run before any agent or human
  judgment is spent on the same question.
- **P3 · Generic core, extensible edges.** The core ships project-independent machinery
  with one extension model — the check registry: kits contribute self-contained blocks to
  the project's single configuration artifact, the file is the complete statement of what
  runs, and a generally useful check is promoted into a kit's recommended block (a
  documented template, never run-time machinery) — and never names a client project.
- **P4 · The gate is headless.** Every check runs unattended from a script and exits
  nonzero on violation; CI is the contract, in-browser display is a bonus.
- **P5 · Verify the spellings.** No design or code statement rests on a Pharo
  class/selector spelling that has not been confirmed in a live Pharo 13 image (verified
  inventory: decision-log D-15).
- **P6 · Registration decides what runs.** The gate enforces everything in the registry —
  a registered check that is missing, skipped, or red fails the build — and the agent whose
  work is checked never chooses which checks apply to it.

## 2 · Technology standards (Pharo 13 only)

**Naming.**

```
Phi-Guardrails-*
├── -SDK · -Core · -Gate                framework (-SDK = published boundary)
├── -Coding · -Coding-Rules ·           coding kit
│   -Coding-Architecture · -Coding-Behavioral
├── -Tests-*                            mirroring tests
├── -Toy-*                              demo client
└── -Fixtures-*                         red/skipped-test fixtures — unswept (D-22)
```

Every class is prefixed `PGR` (D-11; `BaselineOf*` excepted — Metacello's convention); test classes are `<Subject>Test`. Names use glossary terms
(`plan/02-spec/glossary.md`) exactly — never a listed alias. The three that bite everywhere: gate-runnable things are **checks**
(SUnit owns "tests"), non-blocking findings are **advisories** ("warning" = severity), and "pattern" is always qualified (secret · AST). Work orders inline any
further glossary rows their chunk needs.

**On disk.** Tonel under `src/`, loaded by `BaselineOfPhiGuardrails` (groups: spec
ch. 8). Configuration artifacts are pure-data STON (D-16).

**Tests.** SUnit. A rule's or check's test is a **fixture pair**: it fires on the
bad-code fixture and stays silent on the good one (R-37) — both named, both asserted. Test methods assert behavior; a test that cannot fail is a defect. No
`skip`/`expectedFailures` in `Phi-Guardrails-Tests-*` (machine-caught, D-08) — the rule
is total; no test package is exempt. Red/skipped fixture tests
exist only in `-Fixtures-*`/`-Toy-*` packages,
which the framework's artifact, verify command, and smalltalkCI never match
(D-22; the toy's *own* artifact deliberately sweeps its suite).

**State & purity.** No global state: no singletons, no class-side caches, no
`Smalltalk at:put:` writes; a gate run receives all *configuration* as explicit objects
(R-35) — reflective queries of the checked image are the checks' subject matter, not state. Configuration parsing is strict — malformed or unknown input raises a
configuration error, never a silent default (family 7).

**Secrets.** No credential-shaped literal anywhere except declared bad fixtures and
planted violations; fake ones only (documented example keys).

**Pharo idiom.** Class-side named constructors over `new`+setters; `ifNil:`/`ifNotNil:`
over `isNil ifTrue:` (self-hosted: spec §3.2); no `isKindOf:`/`class ==` type predicates —
dispatch polymorphically; no `self halt`, `Transcript show:`, or `self flag:`
debugging leftovers/markers, and no empty exception handlers, in committed code (bad
fixtures and planted violations excepted — they exist to be caught, R-37/D-26); every rule carries a rationale on the
Pharo 13 class-side hooks (D-15; authoring contract: spec ch. 2);
comments state constraints the code cannot show, nothing else.

**Mutation discipline.** The framework never mutates client code except through the
explicit, preview-first fix command (D-06); the gate only reports. Nothing in this repo
may write files outside `src/`, `plan/`, the root artifacts and CI workflow the
spec names (`guardrails.ston`, `.smalltalk.ston`, `guardrails.sh`,
`.github/workflows/ci.yml` — spec ch. 7), and scratch files a test creates and deletes in
`setUp`/`tearDown` — or call the network.

## 3 · Chunk discipline

- **Size.** Target 50–150 LOC per chunk *including tests*; hard ceiling 300. Fixture
  data (payloads, recorded samples) is outside the budget — data files or fixture
  chunks (method rule 2). Too big, even via tests, means stop and report a split;
  never blow the budget.
- **Tests first.** Fill in the work order's test skeletons, watch them fail, implement
  to green; done = the verify command exits 0, never "looks right".
- **Verify command.** `<pharo-vm> <image> test --fail-on-failure "Phi-Guardrails-Tests-.*"`
  (exit 0; verified, D-15). CI equivalent: `smalltalkci -s .smalltalk.ston`.
  Self-hosting: from M1 the repo's own gate (`guardrails.ston`) must also pass — run
  `./guardrails.sh` alongside.
- **Completion report** (fill in verbatim, from the work order): files touched · LOC
  added/changed · test names + final run output · deviations with one-line
  justifications · new questions for the decision sheet.
- **Forbidden moves.**
  - Touching any file outside the work order's deliverables manifest.
  - Changing a frozen interface (frozen at epic acceptance); amendments need a
    decision-sheet entry.
  - Adding a dependency — package, project, or external tool — without a decision-log
    entry (v1's dependency list is empty, Pack §7).
  - Weakening, skipping, or unregistering a check to make a build pass (P6).
  - `skip`/`expectedFailures`/empty test bodies in `Phi-Guardrails-Tests-*` (fixture
    classes under `-Fixtures-*`/`-Toy-*` are the sanctioned exceptions, D-22).
- **Machine enforcement of the above** (P1 applied to ourselves — self-hosting, R-38): the no-skips meta-rule catches skipped/expected-failure tests; the
  repo's own layer map catches forbidden cross-layer reaches (map: spec §4.4); the
  catalog rules catch `isNil ifTrue:` and debugging leftovers incl. `flag:`
  (spec §3.2/§3.2b, D-28). Credential literals are reviewer-caught (the method's
  credential scan; the deterministic secrets check was withdrawn, D-37). Each registers in this
  repo's `guardrails.ston` as it lands (M1–M4). Manifest and LOC conformance stay
  reviewer-checked.
- **Decisions.** Anything the spec doesn't settle is a numbered decision-sheet entry —
  recommend, never rule. No TODO comments in lieu of decisions.
