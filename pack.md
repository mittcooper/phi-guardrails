# Project Pack — phi-guardrails

*Prepended verbatim (as `{{PACK}}`) to every prompt of `../phi/method/prompt-suite-method.md`.*

## 1 · Identity

- **Project:** phi-guardrails
- **Mission:** a generic, extensible **guardrails framework** for agentic work in Pharo:
  one **check registry** (kits contributing composable blocks to a single per-project
  configuration artifact) and a
  headless **gate** that fails on anything registered that is missing, skipped, or red. The
  core is domain-neutral; **domain kits** plug in as packages — the first is the **coding
  kit**: lint/AST rules (with autofix), architecture tests (engine + client layer map), and
  behavioral-test enforcement (runner + test-discipline meta-rules). Client projects extend
  every kind at their own scope; the framework knows no client. Future kits (research, …)
  must not find the core SUnit-shaped — deterministic-first (P2) is a property of the coding
  kit, not of the framework.
- **Technology:** Pharo 13 only.
- **Family context:** `../phi/phi-overview.md` — the Phi vision ("the agent is the
  image"), component map, and family principles (§3 + enforcement map §3.1). Context, not
  a requirements source.
- **Project folder:** `/Users/mitt/dev/projects/phi-guardrails/` — **its own git
  repository**; source documents under `sources/`, plan artifacts under `plan/`, code under
  `src/`

## 2 · Source documents (read in this order)

| # | Document (path) | Role | Authority |
|---|---|---|---|
| 1 | `sources/agentic-engineering-in-pharo-v2.md` — **build-time sections only** (the harness split, guardrails/Phase 2/4/5/6, deterministic-first review of Phase 7) | WHAT + SHAPE — the mechanisms, the playbook, and the generic Pharo rule targets | binding on what the framework must provide; its ⟨verify-in-image⟩ marks are open questions, not facts |

- **Entry stage:** 1 — the playbook needs real consolidation into numbered requirements.
- **Out of scope (→ the future agent-platform project):** everything the source marks
  **run-time** — evals, trajectory scoring, sandboxing, observability at scale, deployment —
  and the Active/Draft self-modification model.

## 3 · Binding principles (the tie-breakers)

*Each shelters under the Phi family principles (`../phi/phi-overview.md` §3 / §3.1).*

- **P1 · Machine-enforced, not prose** *(family §3.1 — a principle nothing checks is a hope)*. A coding rule earns its place by being checkable
  automatically; where possible it *fixes* (rewrite), not merely flags.
- **P2 · Deterministic first** *(cost ordering; no single family parent)*. Free, precise machine checks run before any judgment (agent
  or human) is spent.
- **P3 · Generic core, extensible edges** *(family 0 · 9)*. The framework ships project-independent machinery
  with one extension model — the **check registry**: kits contribute self-contained blocks
  to the project's single configuration artifact, and the file is the complete statement
  of what runs. The framework never names a client project; a check that proves generally
  useful is promoted into a kit's **recommended block** — a documented template, never
  run-time machinery.
- **P4 · The gate is headless** *(family 4)*. Every check runs unattended from a script and exits nonzero
  on violation — badge-in-the-browser is a bonus, CI is the contract.
- **P5 · Verify the spellings** *(family 1)*. Every Pharo class/selector the sources mark
  ⟨verify-in-image⟩ is confirmed in a live image before any design statement depends on it.
- **P6 · Registration decides what runs** *(family 4 · 6)*. The gate enforces everything in the registry; a
  registered check that is missing, skipped, or red fails the build. The agent doing the
  work never chooses which checks apply to it.
- **P7 · The project is the subject, never the operator** *(family 3 · 5)*. phi-guardrails
  is a standalone instrument: anyone or anything may run it on any repo, and the only
  requirement is the configuration artifact. A target project never depends on, invokes,
  or arranges for its own gate — adoption is one config file, zero changes to its source,
  baseline, or tests. (Gate-2 ruling; supersedes the earlier in-project CI-adapter
  machinery.)

## 4 · v1 scope rule

v1 is a **walking skeleton of enforcement**: the loadable framework (core + gate + coding
kit) with the check registry and one working check of each coding kind — (a) one real lint rule with autofix,
(b) one reflective architecture test driven by a client-supplied layer map, (c) behavioral
enforcement: suites derived from the baseline's tests-role group plus one test-discipline
meta-rule (no skipped/disabled tests), (d) withdrawn (decision-log D-37), (e) a CI gate that fails on anything
registered that is missing, skipped, or red — demonstrated against a toy client package.
Widening (the fuller rule and meta-rule catalogs, coverage floors, author-scoping,
change-log mining helpers) stacks after.

## 5 · Technology standards seed

- **Naming:** framework packages `Phi-Guardrails-*` (`-SDK`, `-Core`, `-Gate`; `-SDK`
  is the published boundary authors build against); **kit packages carry the kit's own
  namespace** — the coding kit is `Phi-Coding-Kit-*` (`-Rules`, `-Architecture`,
  `-Behavioral`); the toy's packages model a real adopter (`Toy-*`). Class
  prefixes: framework (`-SDK`, `-Core`, `-Gate`) classes are `PGR` (D-11, Gate 1;
  supersedes the earlier `PG`); **kit classes carry their kit's own prefix, disjoint
  from `PGR`** — the coding kit is `PCK` (Phi Coding Kit) — and the toy models a real
  client with no framework prefix (`Toy*`). (Gate-2 amendment to D-11.)
- **On-disk format:** Tonel under `src/`, loaded by `BaselineOfPhiGuardrails` (Metacello).
- **Test framework & conventions:** SUnit; `<Subject>Test` in its subject family's
  `-Tests-*` packages; a rule's
  test = it fires on a bad-code fixture and stays silent on a good one.
- **Non-negotiables:** rules carry a `rationale` string (it doubles as agent guidance); no
  global state; the framework never mutates client code except through an explicit,
  user-invoked autofix.
- **Constitution page limit:** ≤2 pages (small project).

## 6 · Verification

- **Verify command:** `<pharo-vm> <image> test --fail-on-failure "(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*"`
  (exit 0; the alternation spelling is ⟨verify⟩ against the test CLI's regex dialect)
- **CI (two steps):** step 1, validation — `smalltalkci -s .smalltalk.ston` (runs the
  test suites independently of the gate, D-40); step 2, enforcement — `./guardrails.sh
  guardrails.ston` (the gate headless on this repo's own artifact, P7).
- **Machine checks beyond tests:** none available yet — this project *builds* them; it
  polices itself with its own rules as soon as they exist (self-hosting from the first rule
  onward).

## 7 · Dependencies

| Dependency | Provides | Status |
|---|---|---|
| — none — | | |

## 8 · Suggestions to later stages (non-binding)

### Spec chapter outline

0. **Glossary** — the ubiquitous language: every domain term, one meaning, aliases to
   avoid (family principle 1).
1. **The check registry** — check kinds, kit blocks, registration format, recommended
   blocks.
2. **Rule-engine integration** — Renraku base classes, severity, badge + headless duality.
3. **Rule catalog v1** — each rule: pattern, autofix?, rationale, fixture pair.
4. **Architecture-test kit** — layer map format, reflective query approach.
5. **Behavioral enforcement** — suites derived from the baseline's tests-role group;
   test-discipline meta-rules: mirror packages, no-skips, regression set stays green.
6. **Secrets-leak test** — *withdrawn at Gate 2 (decision-log D-37); the chapter is a
   withdrawal notice.*
7. **CI gate configuration** — fails on missing/skipped/red registrations.
8. **Client onboarding** — how a project adopts and extends the framework.
9. **Testing properties** — every binding principle and invariant restated as ≥1 named,
   decidable property (added at Gate 2).

### Milestone shape

| Milestone | Delivers |
|---|---|
| **M0** | repo + baseline + one green test |
| **M1** | check registry + first lint rule with autofix, self-hosted |
| **M2** | architecture-test kit + layer map |
| **M3** | behavioral enforcement (registration + no-skips meta-rule) |
| **M4** | CI gate enforcing the full registry |
| **M5** | catalogs widened from the playbook's remaining targets |

### Probe list (Prompt 1, Task B)

- Every ⟨verify-in-image⟩ spelling in the source: Renraku base classes,
  `RBParseTreeSearcher/Rewriter` API, critic severity hooks, smalltalkCI critics option.
- How a client supplies its layer map and package list.
- How autofix is invoked safely.
- What "serious violation" means (severity taxonomy).
- How the registry detects a skipped/disabled test and a missing registration
  (SUnit skip/expected-failure mechanics).
- Whether the `PG` class prefix collides with anything loaded (old Postgres drivers).

### Validation extras (Gate 2)

- Every shipped rule and meta-rule has a bad-fixture *and* a good-fixture test.
- The CI chapter states the exact failure condition
  (missing ∨ skipped ∨ red registration ∨ `#error` criticism).
- Every check kind is registrable from a kit block, and by a project's own extension
  checks.
- Walk each SDK as its audience: anything missing, anything extra? (Complete-and-minimal
  is judgment-tier — D-54; P-SURFACE-CONFORMS covers only existence/arity.)
