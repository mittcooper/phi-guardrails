# 01 · Requirement Inventory — phi-guardrails

*Produced by Prompt 1 (Consolidate). Sources: **S1** = `sources/agentic-engineering-in-pharo-v2.md`
(build-time sections only); **Pack** = `pack.md` (§n / Pn). The pack's binding principles
P1–P6 are the tie-breakers. Scope tags per Pack §4: `v1-skeleton` (walking skeleton of
enforcement) · `v1-widen` (stacks after) · `later`.*

*Kind: **F** functional · **N** non-functional · **C** constraint. `TBD → Q-nn` marks an
unfilled budget or undefined mechanism carried to `plan/01-decision-sheet.md`.*

## A · Core — check registry and gate

| ID | Requirement (outcome language) | Source | Kind | Scope |
|---|---|---|---|---|
| R-01 | The framework ships **one extension model, the check registry**: every check kind (lint rule, architecture test, behavioral suite) accepts registrations at **global scope** (the kit's shipped catalog — *global means across projects, per kit, never across kits*) and **project scope** (the client's extension package + configuration). *(Amended by D-51: one scope — the file; registrations come only from the project's `guardrails.ston` kit blocks; the shipped catalog becomes the kit's documented recommended block, composed in at authoring time.)* | Pack P3, §1; S1 Rosetta "Shared team guardrails", Phase 8; D-01 | F | v1-skeleton |
| R-02 | A registration binds a check to a **client-declared target**: the client supplies its baseline + group roles (and layer map, R-19) through its own configuration; the framework learns about the client only from that configuration and its baseline. Registration format `TBD → Q-01`. *(Amended by D-25: package scope derives from the Metacello baseline; the artifact never lists packages.)* | Pack P3; S1 Phase 8; Pack §8 probe list | F | v1-skeleton |
| R-03 | A project-scope check can be **promoted** to the global catalog when it proves generally useful, without breaking the client that bred it. Mechanics `TBD → Q-16`. *(Amended by D-51: promotion = inclusion in the kit's recommended block — documentation, not mechanism; "without breaking the client" now holds trivially, since no adopter's enforcement changes until they edit their own file.)* | Pack §1, P3 | F | v1-widen |
| R-04 | The **core is domain-neutral**: domain kits load as separate packages; the core carries no SUnit (or other kit-specific) shape, so a future non-coding kit fits without core changes. | Pack §1 | C | v1-skeleton |
| R-05 | The framework **never names a client project** in code, configuration defaults, or catalog. | Pack P3 | C | v1-skeleton |
| R-06 | The **gate fails** (nonzero exit) when any registered check is **missing, skipped, or red**; it passes only when every registered check ran and is green. "Missing" semantics per kind `TBD → Q-01`. | Pack P6, §4; S1 Phase 6 | F | v1-skeleton |
| R-07 | The gate runs **headless, unattended, from a script** — CI is the contract; in-browser display is a bonus. | Pack P4; S1 Phase 6 (`guardrails.sh`) | F | v1-skeleton |
| R-08 | The agent whose work is being checked **cannot select, skip, or weaken** the checks that apply to it; only registration decides what runs. | Pack P6 | C | v1-skeleton |
| R-09 | The deterministic gate is **cheap and fast** enough to run before any judgment (agent or human) is spent — seconds-scale on a v1-sized codebase. Numeric budget `TBD → Q-14`. | Pack P2; S1 Phase 2 ("run instantly"), Phase 7 ("headless in seconds") | N | v1-skeleton |

## B · Coding kit — lint / AST rules

| ID | Requirement | Source | Kind | Scope |
|---|---|---|---|---|
| R-10 | Lint rules are **Renraku rules**: one rule object serves both the live badge / Critic Browser (when an image is interactive) and the headless gate — no dual maintenance. | S1 Phase 4, Rosetta guardrails table; Pack §8 ch. 2 | F | v1-skeleton |
| R-11 | A structural rule matches an **AST pattern with meta-variables**; where a safe rewrite exists the rule **fixes** (rewrite) rather than merely flags. | Pack P1; S1 Phase 4 (`RBParseTreeSearcher`/`Rewriter`) | F | v1-skeleton |
| R-12 | **Autofix mutates client code only through an explicit, user-invoked action**; the gate itself never rewrites anything. Invocation/safety model `TBD → Q-05`. | Pack §5 non-negotiables | C | v1-skeleton |
| R-13 | Every rule carries a **`rationale` string** that doubles as agent guidance (it is the prompt the agent reads on violation). | Pack §5; S1 Phase 6 | C | v1-skeleton |
| R-14 | Every rule carries a **severity**; the severity taxonomy defines which criticisms block the gate. Taxonomy `TBD → Q-03`. | S1 Phase 4 (`severity ^ #error`), Phase 6/8 | F | v1-skeleton |
| R-15 | v1 ships **one real lint rule with a working autofix**, self-hosted on the framework's own code. Rule choice `TBD → Q-04`. | Pack §4(a), §6 | F | v1-skeleton |
| R-16 | The global catalog **widens to the playbook's Pharo targets**: no `self halt` / `Transcript show:` in committed domain code; no `perform:` with a literal selector; no `Smalltalk at:put:` global writes; no `become:` in app code; no empty `ifTrue:`/`ifNil:` blocks; no swallowed errors (empty `on:do:` handler). | S1 Phase 4 note + example; Pack §8 M5 | F | v1-widen |
| R-17 | Rules can be **scoped to authored code** via method author stamps, sparing vendored/framework code. Spelling ⟨verify⟩. | S1 Phase 4 "Scope to your own code"; Pack §4 widening | F | v1-widen |

## C · Coding kit — architecture tests

| ID | Requirement | Source | Kind | Scope |
|---|---|---|---|---|
| R-18 | *(capability)* Architecture constraints are enforced by **reflective queries over the loaded system** — asking the classes, never parsing files. | S1 Phase 2 | F | v1-skeleton |
| R-19 | The engine is **generic**; the client supplies a **layer map** (layers → packages, allowed dependencies) through project-scope configuration. Format `TBD → Q-06`. | Pack §1, §4; S1 Phase 2 ("pin allowed package dependencies") | F | v1-skeleton |
| R-20 | An architecture violation **names the offenders precisely** (method/class level) in its failure output. | S1 Phase 2 example (`offenders printString`) | N | v1-skeleton |
| R-21 | Adding a new architectural constraint is **one more registration** — never a framework edit. | S1 Phase 2 ("encode prevention as one more test"); family 0 via P3 | F | v1-skeleton |
| R-22 | Heavyweight structural analysis (cycles, layering metrics, visualization) can plug in via **Moose/FAMIX** without changing the kit's contract. | S1 Phase 2 | F | later |
| R-43 | *(proof — added at Gate 1, splitting R-18)* v1 **ships one working architecture test** in the coding kit's catalog: a layer-dependency check driven by the toy client's layer map (D-12), red on the planted violation, green after the fix. | Pack §4(b); D-12 | F | v1-skeleton |

## D · Coding kit — behavioral enforcement

| ID | Requirement | Source | Kind | Scope |
|---|---|---|---|---|
| R-23 | A client's behavioral suites are the **tests-role packages of its baseline**; the gate runs every one headless and fails on any red test. Registration unit `TBD → Q-08`. *(Amended by D-25: patterns superseded; suites derive from the tests role.)* | Pack §4(c); S1 Phase 3, Phase 6 | F | v1-skeleton |
| R-24 | A registration that **resolves to nothing** (empty tests-role expansion; suite package without tests; expected class absent) fails the gate as *missing* — silence is never a pass. *(Amended by D-25; the scope law additionally makes an unassigned package a configuration error.)* | Pack P6 | F | v1-skeleton |
| R-25 | Meta-rule **no-skips**: a skipped, disabled, or expected-failure test inside a registered package fails the gate. Detection semantics (SUnit mechanics) `TBD → Q-07`. | Pack §4(c) | F | v1-skeleton |
| R-26 | The meta-rule catalog widens: **mirror test packages** exist for every registered production package; the **regression set stays green** (every fixed bug's test remains present and passing). | Pack §8 ch. 5; S1 Phase 3 ("turn every fixed bug into a test") | F | v1-widen |
| R-27 | **Coverage floors** per registered package, reported and enforced by the gate. Floor values `TBD → Q-17`. | Pack §4 widening; S1 Phase 3, Phase 8 (coverage reports) | F | v1-widen |
| R-46 | *(added at the ch. 8 review, D-44; re-anchored by D-52 after D-51 removed scope)* Meta-rule **every registered check is tested**: for each registered check class **defined in one of this project's own baseline packages** (as opposed to classes loaded from an external kit's packages), a class `FooTest` must exist in a tests-role package — the fixture-pair discipline (R-37) made machine-checkable, closing the hole where a custom rule that never fires (bad AST pattern, typo in the matcher) reports green because a rule finding nothing looks like a rule with nothing to find. Class: `PGRCheckFixturePairMetaRule`, kind `#behavioral`, registered in `#metaRules`. | ch. 8 review; R-37, R-26 | F | v1-widen |
| R-44 | *(proof — added at Gate 1, mirroring R-43)* v1 **demonstrates behavioral enforcement end-to-end**: the toy client's tests-role suite runs in the gate (per D-25); a planted red test and a planted skip each fail it (R-23, R-25 exercised in earnest). | Pack §4(c); D-12 | F | v1-skeleton |

## E · Secrets-leak test

| ID | Requirement | Source | Kind | Scope |
|---|---|---|---|---|
| R-28 | A **secrets-leak check** runs in the gate and fails when committed code/configuration leaks credentials. **No source passage specifies it** — scan surface, patterns, and kind (lint rule vs behavioral test) `TBD → Q-09`. *(Superseded by D-37 at Gate-2 remediation: pattern detection ruled false security and withdrawn from scope — detection → the method layer, prevention → phi-llm's constitution.)* | Pack §4(d) *only* | F | v1-skeleton |

## F · Gate in CI, onboarding, demonstration

| ID | Requirement | Source | Kind | Scope |
|---|---|---|---|---|
| R-29 | CI runs the whole gate headless via **smalltalkCI** (`.smalltalk.ston`): load the baseline, run everything registered, fail per R-06 plus `#error`-severity criticisms. Integration shape `TBD → Q-10`; built-in-critics inclusion `TBD → Q-13`. *(Amended by D-45: CI is just a caller — the framework's own CI runs two visible steps, smalltalkCI for the test packages and a separate headless gate invocation for enforcement; the D-10 adapter mechanism is superseded.)* | Pack §6; S1 Phase 6 enforcement layer, Phase 8 | F | v1-skeleton |
| R-30 | The **same checks are invocable in-image** during work (agent loop, badge) **and headless in CI** — one engine, two invocation modes, identical verdicts. | S1 Phase 6 (primary vs enforcement), Rosetta | F | v1-skeleton |
| R-31 | A client **adopts by depending on `BaselineOfPhiGuardrails`** and declaring its configuration + extension package; a new project starts pre-hardened. *(Amended by D-45: adoption is one configuration file, R-47 — no framework dependency; the baseline dependency remains only for the optional extension package, development-scoped, never in the client's `default` group.)* | S1 Phase 8 ("ship guardrails as a package"); Pack §8 ch. 8 | F | v1-skeleton |
| R-47 | *(acceptance — added by D-45)* A project **adopts phi-guardrails by adding one configuration file**; no change to its source, baseline, or tests is required. The project is the *subject* of the gate, never its operator: no privileged caller exists and none is required. | D-45 (Gate-2 closing ruling) | F | v1-skeleton |
| R-32 | The walking skeleton is **demonstrated end-to-end against a toy client package**: adoption, project-scope extension, planted violations caught, gate red → green. Toy shape `TBD → Q-12`. | Pack §4 | F | v1-skeleton |
| R-33 | **Per-package policy tiering**: critical packages can get the strictest severity and mandatory-review marking. | S1 Phase 8 (Amazon model) | F | later |

## G · Tightening loop

| ID | Requirement | Source | Kind | Scope |
|---|---|---|---|---|
| R-34 | **Change-log mining helpers** surface recurring corrections as candidate rules — e.g. Epicea method-modification churn tallies (spellings ⟨verify⟩). | S1 Phase 5; Pack §4 widening | F | v1-widen |

**Scope note — why Epicea mining is in but evals and session-log mining are out.** S1's
Step 7 ("observe, evaluate, improve") bundles two different jobs. (1) **Improve** — mine
the records for recurring corrections and promote them into new rules: S1 explicitly
classifies this as *build-time* ("improving the harness — mining repeated corrections into
new rules (Phase 5, the tightening loop) — is itself mostly build-time"), and its output is
**rules** — this framework's product. R-34 is that prospecting tool; it never runs in the
gate and judges nothing — a human or agent decides whether a finding becomes a real
catalog rule through the normal door (written, fixture-tested, registered). (2)
**Evaluate** — judge trajectory and output quality: S1 classifies the judge (task sets,
rubrics, LM judge) as *run-time* and image-external, and Pack §2 sends everything run-time
to the future agent-platform project. Session-log mining is likewise left to the layers
that own the transcripts (phi-agent-runtime / phi-session — family 9); Epicea is the
in-image, code-side record and is ours to query. Deferring evals loses nothing: the
*record* they need (Epicea events + transcripts) exists natively regardless — only the
judge is deferred, and it will read the same logs R-34 mines.

## H · Framework-wide constraints

| ID | Requirement | Source | Kind | Scope |
|---|---|---|---|---|
| R-35 | **No global state**: the registry is an explicit, named, inspectable object a gate run receives — not a singleton mutated from afar. Reconciliation with family "no registries" cited in Q-01. | Pack §5; family 4 · 6 via P6 | C | v1-skeleton |
| R-36 | **Packaging/naming** follows the naming tree below: `Phi-Guardrails-*` packages, `PGR` class prefix (ruled D-11, supersedes `PG`), Tonel under `src/`, loaded by `BaselineOfPhiGuardrails`. | Pack §5; D-11 | C | v1-skeleton |
| R-37 | Every shipped rule and meta-rule has a **bad-fixture *and* good-fixture test** (fires on bad, silent on good). | Pack §5, §8 Gate-2 extras | C | v1-skeleton |
| R-38 | The framework **polices itself with its own rules** from the first rule onward (self-hosting). | Pack §6 | C | v1-skeleton |
| R-39 | *(process)* No design statement depends on a **⟨verify-in-image⟩ spelling** until it is confirmed in a live Pharo 13 image. Verification pass scheduling `TBD → Q-02`. | Pack P5; S1 preamble ("the spellings you should confirm") | C | v1-skeleton |

**Naming tree (R-36).** Package names `-Core`/`-Gate`/`-Coding-*` and test conventions are
Pack §5; the `PGR` prefix is D-11; the Toy packages are D-12. Class names shown are
illustrative (the spec assigns real ones):

```
Phi-Guardrails-*                          the package family
├── Phi-Guardrails-SDK                    published boundary: protocols, skeletons,
│                                         vocabulary (added by D-53)
├── Phi-Guardrails-Core                   neutral core: registry, check kinds, verdicts
├── Phi-Guardrails-Gate                   the headless gate + report
├── Phi-Guardrails-Coding                 coding kit class + global catalog (D-17; its secrets sweep withdrawn D-37)
├── Phi-Guardrails-Coding-Rules           coding kit: lint/AST rules + Renraku/rewriter engine
├── Phi-Guardrails-Coding-Architecture    coding kit: layer-map engine + reflective queries
├── Phi-Guardrails-Coding-Behavioral      coding kit: suite runner + test-discipline meta-rules
├── Phi-Guardrails-Toy-*                  demo client (D-12) — Toy/CI groups only
├── Phi-Guardrails-Fixtures-*             fixtures containing red/skipped tests — outside the
│                                         test namespace so no sweep matches them (D-22)
├── ~~Phi-Guardrails-CI-Tests~~           retired by D-45 (no adapter, no privileged caller);
│                                         was: gate-driving tests outside every swept namespace (D-23)
└── Phi-Guardrails-Tests-*                SUnit tests, mirroring the packages above
    e.g. -Tests-Core · -Tests-Gate · -Tests-Coding-Rules · -Tests-Toy (demo test, D-46) · …

Classes   PGR prefix (D-11)               e.g. PGRRegistry, PGRGate, PGRNoIsNilIfTrueRule
Tests     <Subject>Test                   e.g. PGRRegistryTest, in the mirroring test package
Loading   BaselineOfPhiGuardrails         role groups production · tests · fixtures · toy
                                          (D-25; ci-tests retired by D-45) + composites
                                          Core · Coding · Tests · Toy · CI; the toy ships
                                          BaselineOfPhiGuardrailsToy
On disk   Tonel format under src/
```

## I · Kit model *(added at Gate 1 — clarifications flowing from D-01, D-05, D-07)*

| ID | Requirement | Source | Kind | Scope |
|---|---|---|---|---|
| R-40 | **Kit anatomy.** A domain kit plugs in as a loadable package family supplying five things: (i) **check-kind classes** implementing the core's check contract ("run against a target, return a verdict"); (ii) the **engines** those kinds need (for the coding kit: Renraku, the AST rewriter, the SUnit runner — kit-specific technology never enters the core); (iii) a **shipped global-catalog artifact** naming the kit's default registrations; (iv) a **config-section schema** — the sections of the project artifact the kit owns and interprets; (v) **fixture pairs** for every shipped check. *(Amended by D-51: (iii) becomes the kit's documented **recommended block** template; (iv) becomes its **block schema**, validated by the kit itself. Amended by D-53: (i)'s contract is a **protocol** — conformance, not ancestry, validated at registry construction; the kit builds against `Phi-Guardrails-SDK`, never the engine.)* | Pack §1, P3; R-04; D-01/D-07 | C | v1-skeleton |
| R-41 | **Loading is not activation.** Loading a kit's packages activates nothing; a check runs only when a catalog or project artifact names it. Global catalogs are **per kit** and ship with the kit, so every catalog entry's class is guaranteed loadable with its kit (else it is *missing*, R-24). *(Amended by D-51: only the project artifact names checks — no catalogs ship; loadability of every named class is decided at registry construction, missing rule unchanged.)* | Pack P6; D-01, D-05 | C | v1-skeleton |
| R-42 | **Run flow.** At gate time the core reads the project artifact, hands each kit the sections that kit owns, receives back registrations, runs them, and aggregates verdicts (green / red / skipped / missing). The core never interprets section contents — only kinds and verdicts (family 9 via P3). *(Amended by D-51: the core hands each kit its `#kits` block **verbatim**; "sections" are the block's keys, opaque to the core.)* | Pack P3, P6; D-07, D-10 | F | v1-skeleton |
| R-45 | **Live progress.** The gate streams each registration's name and verdict as it completes (headless: stdout, so it lands in CI logs; in-image: Transcript or equivalent) — a run is never a black box, and an agent can react to the first red verdict without waiting for the full run. Distinct from the excluded cross-run observability view. | Gate-1 addition (single-run UX; supports S1 Phase 6 agent loop) | N | v1-skeleton |

**Run-flow strawman (R-42) — illustrative, non-binding; spec ch. 1 owns the real contract:**

```
gate run
 ├─ core reads guardrails.ston + the extended per-kit global catalogs
 ├─ core hands each kit the sections that kit owns
 │    coding kit ← #lintRules     → builds lint registrations
 │               ← #layerMap      → builds architecture registrations
 │               ← #testPackages  → builds behavioral registrations
 ├─ each registration runs via its kit's engine
 │    lint         → Renraku over the declared packages
 │    architecture → reflective queries against the layer map
 │    behavioral   → SUnit runs matching suites, reads the result object
 ├─ each returns a verdict: green / red / skipped / missing
 └─ core aggregates → one report, exit 0 or nonzero
```

## Counts

| Scope | Count |
|---|---|
| v1-skeleton | 38 (one superseded: R-28 → D-37; R-47 added by D-45) |
| v1-widen | 7 (R-03, R-16, R-17, R-26, R-27, R-34, R-46) |
| later | 2 (R-22, R-33) |
| **Total** | **47** |

## Explicit exclusions (out of scope → the future agent-platform project)

Per Pack §2, everything S1 marks **run-time** produces no requirement here:

- **Evals** (trajectory + quality scoring, rubrics, LM judges) — S1 "Evals" section, harness-split table.
- **Sandbox / isolation** — S1 harness-split table.
- **Observability / tracing at scale** — S1 harness-split table (Epicea *mining helpers* stay in, R-34; the aggregated observability view is out).
- **Deployment / service / scaling** and **cost / token metering** — S1 harness-split table.
- **Active/Draft self-modification model** — Pack §2.
- **The agent loop / in-image bridge itself** (S1 Phase 6 "primary" layer) — belongs to phi-agent-runtime; this framework only guarantees its checks are invocable from it (R-30).
- **Formatter enforcement** — S1 Phase 4 names the in-box formatter; whether the gate ever enforces formatting is `Q-15` (recommended: not in v1).

## Traceability

*(updated at Gate 1 close — all 17 sheet questions are ruled)*

- **Requirement → decision:** every `TBD → Q-nn` marker above resolves through the
  decision sheet: each Q entry carries a *RULED* pointer to its `plan/decision-log.md`
  entry (D-01 … D-14). The markers are kept as written for the audit trail; none is still
  open.
- **Gate-1 additions:** R-40–R-45 (and annexes: naming tree, R-34 scope note, R-42
  strawman) were added during Gate 1 review; each cites its source rulings (D-nn) or is
  marked "Gate-1 addition" in its source column.
- **Decision → spec:** each ruling's *Consequences* line names the spec chapter that must
  implement it.
- **Next stage:** with the sheet closed, every requirement proceeds to spec (Prompt 2)
  after the D-02 verification session confirms the ⟨verify-in-image⟩ spellings (R-39).
