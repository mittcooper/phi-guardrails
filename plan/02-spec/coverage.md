# Spec coverage check — every v1-scoped requirement → chapter sections

*Gate-2 exit artifact. All 38 `v1-skeleton` requirements from `plan/01-requirements.md`:
37 covered, 1 formally superseded (R-28 → D-37; R-47 added by D-45). Sections cite
chapter files in this directory (`ch. N §x.y`). A requirement with no satisfying section
and no superseding ruling would read **NONE — UNCOVERED**; there are none.*

| Req | Requirement (short) | Satisfied by |
|---|---|---|
| R-01 | one extension model: the registry — one scope, the file, since D-51 (kit blocks; recommended blocks replace the shipped catalog) | ch. 1 §1.2, §1.4, §1.5 |
| R-02 | registration binds check to client-declared target; framework learns client only from configuration + its baseline (amended by D-25) | ch. 1 §1.1, §1.3; ch. 8 §8.1 |
| R-04 | core is domain-neutral, no SUnit shape | ch. 0 §0.1; ch. 1 §1.3, §1.4; ch. 9 P-CORE-NEUTRAL |
| R-05 | framework never names a client | ch. 0 §0.4 (agnosticism, both directions); ch. 1 §1.1; ch. 8 preamble; ch. 9 P-CORE-NEUTRAL (kit/core reference tests) |
| R-06 | gate fails on missing/skipped/red; passes only all-green | ch. 7 §7.1; ch. 1 §1.5 |
| R-07 | gate headless, unattended, from script | ch. 7 §7.3; ch. 9 P-GATE-HEADLESS |
| R-08 | checked agent cannot select/skip/weaken checks | ch. 1 §1.4 (last ¶); ch. 9 P-GATE-COMPLETE |
| R-09 | gate cheap and fast (seconds-scale) | ch. 7 §7.6 (D-13 working target) |
| R-10 | lint rules are Renraku rules, one object both surfaces | ch. 2 §2.1 |
| R-11 | AST pattern with meta-variables; fixes where safe | ch. 2 §2.2; ch. 3 §3.2; ch. 9 P-CAT-AUTOFIX |
| R-12 | autofix only via explicit user-invoked action; gate never rewrites | ch. 3 §3.3; ch. 9 P-GATE-PURE, P-FIX-GATE-WALL |
| R-13 | every rule carries a rationale doubling as agent guidance | ch. 2 §2.2; ch. 7 §7.2 (rationale in report lines) |
| R-14 | every rule carries a severity; taxonomy defines blocking | ch. 2 §2.2, §2.5; ch. 7 §7.1 |
| R-15 | one real lint rule with working autofix, self-hosted | ch. 3 §3.2; ch. 9 P-SELF-HOSTED |
| R-18 | architecture via reflective queries over loaded system | ch. 4 §4.2 |
| R-19 | generic engine; client-supplied layer map via configuration | ch. 4 §4.1, §4.2; ch. 1 §1.1 |
| R-20 | violations name offenders precisely | ch. 4 §4.2; ch. 9 P-FINDING-PRECISE |
| R-21 | new architectural constraint = one more registration | ch. 4 §4.3 |
| R-23 | behavioral suites enforced per tests-role package (patterns superseded by D-25); red test fails gate | ch. 5 §5.1, §5.2 |
| R-24 | registration resolving to nothing fails as missing | ch. 1 §1.1 (scope law), §1.5; ch. 5 §5.1, §5.2; ch. 9 P-GATE-MISSING, P-SCOPE-TOTAL |
| R-25 | no-skips meta-rule (skips + expected failures) | ch. 5 §5.3; ch. 9 P-GATE-SKIP |
| R-28 | secrets-leak check in the gate | **superseded by D-37** — withdrawn from scope (pattern detection ruled false security); detection → method layer, prevention → phi-llm constitution; ch. 6 is a withdrawal notice |
| R-29 | CI integration — amended by D-45: CI is just a caller; the framework's own CI is two visible steps (smalltalkCI tests + headless gate invocation) | ch. 7 §7.1, §7.3, §7.4 |
| R-30 | same checks in-image and headless, identical verdicts | ch. 7 §7.2; ch. 9 P-SAME-VERDICT |
| R-31 | adoption — amended by D-45: one configuration file (R-47); baseline dependency only for the optional extension package, development-scoped | ch. 8 §8.1 |
| R-32 | end-to-end toy demonstration, red → green | ch. 8 §8.2, §8.3 |
| R-35 | no global state; explicit inspectable registry | ch. 0 §0.4 (runs share nothing, incl. nested); ch. 1 §1.3; ch. 5 §5.4; ch. 9 P-REG-FRESH |
| R-36 | packaging/naming tree, PGR prefix, Tonel, baseline | ch. 1 §1.3 (packages per class table); constitution §2; D-17 (added `-Coding` package) |
| R-37 | every shipped check has bad + good fixture tests | ch. 3 §3.2; ch. 4 §4.4; ch. 5 §5.5; ch. 9 P-CAT-FIXTURES |
| R-38 | self-hosting from the first rule | ch. 3 §3.2; ch. 7 §7.5; ch. 9 P-SELF-HOSTED |
| R-39 | no design statement on unverified spellings | decision-log D-15 (executed pass); ch. 9 P-SPELLINGS |
| R-40 | kit anatomy: five supplies | ch. 1 §1.4; ch. 2–6 (the coding kit instantiates each) |
| R-41 | loading is not activation | ch. 1 §1.4; ch. 8 §8.1 step 3 (the dev-scoped extension load activates nothing) |
| R-42 | run flow: core hands sections to kits, aggregates verdicts | ch. 1 §1.4; ch. 7 §7.2 |
| R-43 | one working architecture test, red on toy plant | ch. 4 §4.2, §4.4; ch. 8 §8.3 |
| R-44 | behavioral enforcement demonstrated: red test + skip each fail | ch. 5 §5.5; ch. 8 §8.2, §8.3 |
| R-45 | gate streams verdicts live | ch. 7 §7.2 (streaming); ch. 9 P-STREAM |
| R-47 | adoption is one configuration file; the project is the gate's subject, never its operator (D-45, pack P7) | ch. 0 §0.2; ch. 7 §7.3; ch. 8 §8.1; ch. 9 P-NO-DEFAULT-PATH, P-ROLES-FROM-CONFIG |

**v1-widen / later requirements** (not in scope for this table, recorded where the spec
touches them): R-03 → ch. 1 §1.6 · R-16 → ch. 3 §3.2 (widened list) · R-17, R-34 → D-15
corrections 4–5 hold the verified spellings for M5 · R-26, R-27, **R-46** → ch. 5 §5.5
(R-46 also ch. 8 §8.1 step 3) · R-22, R-33 → none (later).

**Gate-2 amendment note:** D-25 (ruled at this gate) rederives package scope from the
Metacello baseline; rows R-02/R-23/R-24 above reflect the amended readings, and the new
properties P-SCOPE-TOTAL / P-ROLE-MISFILE / P-NO-DEAD-SRC (ch. 9 §9.2) machine-close the
scope holes raised at review. **Post-gate remediation note:** D-37 withdrew the
secrets-leak check (R-28 row above); the toy demonstration is six registrations and
P-REDACT left ch. 9 with it. **Architecture addendum (D-48):** ch. 0
(`00-architecture.md`) now owns the system-level facts — component map, invocation
model (P7), the public surfaces and the internal-by-default law, system
invariants, and the fulfillment mapping table (its two-direction gap report is in
D-48). **Composition ruling (D-51):** one scope — the file; kit blocks; no shipped
catalog; P-MERGE-LAW deleted with the merge; schema version 2; rows R-01/R-03/R-40/
R-41/R-42 carry their amendments in `plan/01-requirements.md`. **SDK ruling (D-53):**
surfaces recomposed as four SDKs; `Phi-Guardrails-SDK` is the published boundary;
conformance-not-ancestry (P-CONFORMANCE), the SDK layer edge (P-SDK-EDGE), and
opt-in fixing (P-CANFIX-DEFAULT) join ch. 9; R-40 carries the D-53 annotation.
