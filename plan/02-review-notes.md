# Gate 2 — human review record (CLOSED 2026-07-22)

*Closing record of the Gate-2 human review of `plan/02-spec/`. Chapters 1–4 reviewed
2026-07-13; chapters 5–9 and the architecture arc 2026-07-19 → 07-22. Every finding
below is ruled, routed, or knowingly recorded — nothing is open. The decision log
(D-32 … D-54) is the binding record; this file is the review's narrative index.*

## Outcome in one paragraph

All nine chapters reviewed and remediated; chapter 6 (secrets) **withdrawn** as false
security; chapter 0 (**architecture**) backfilled and made binding on the chapters. The
review's largest outcomes were architectural, driven by owner first-principles
questioning: **P7 — the project is the subject of the gate, never its operator** (D-45,
dissolving the CI-adapter/exempt-package machinery); **composition over defaults**
(D-51 — one scope, the file is the complete statement of what runs); and the **SDK
architecture** (D-53/D-54 — four SDKs, protocol contracts with registry-build
conformance, the `Phi-Guardrails-SDK` boundary package). The spec then passed the
coupling / subject-operator / why-chain audits with each pass finding less. Gate 2 is
closed; the stage is ready for Prompt 3.

## Chapter verdicts (final)

| Ch. | Verdict | Key rulings |
|---|---|---|
| 0 · Architecture | backfilled, binding | D-48 surfaces → D-53 SDKs; fulfillment rule; diagrams (object + call-flow) with surface map |
| 1 · Check registry | strong | D-32 (exempt loading, `#skipped` producer, §1.5 rows); D-51 (blocks, one scope); D-54 (`PGRRegistrationSpec` crosses the boundary, engine wraps) |
| 2 · Rule engine | solid | D-41 explicit severity (no fail-open default); D-33 tests-not-linted (knowing, B-04) |
| 3 · Catalog + fix | strongest of 1–8 | D-34 severity pin + stale guard; D-42 fix-on-self permitted with caution; D-53/54 fix protocols hoisted generic (`canFix` + `fixCommandOn:`), machinery stays kit-side |
| 4 · Architecture kit | both findings resolved | D-35 layer-map totality; trait attribution retired by live probe (D-15.b, `plan/probes/`) |
| 5 · Behavioral | strong | D-36 meta-rule pulls per package (order-independence, no fail-open); zero-test-method class = knowing M5 hole |
| 6 · Secrets | **WITHDRAWN** (D-37) | pattern lists = false security; detection → method-layer credential scan; prevention → phi-llm constitution |
| 7 · CI gate | approvable, reshaped by D-45 | D-39 never-undecided (exit 0/1/2 law); D-40 independence = safety property (bootstrap argument); §7.3 promoted to the invocation contract |
| 8 · Onboarding | reshaped by D-45/D-51 | adoption = one config file, zero source changes (acceptance requirement); D-43 mutating-test protections; R-46 fixture-pair meta-rule (D-44 routing: ruled-in scope is a requirement, not backlog) |
| 9 · Properties | strongest chapter | every law a named, decidable property; P-DETERMINISTIC labeled stopgap (B-01 supersedes); shell wrapper + surface freeze machine-checked (D-49) |

## The architecture arc (what changed the design)

1. **D-45 · Invocation model (P7).** Owner questioning ("why does any project need to
   know about the Gate?", "a guardrails.ston for any existing repo should just work")
   dissolved the gate-as-a-test design: adapter, exempt CI-Tests package, D-23
   no-self-sweep, and the recursion hazard all removed as *causes*, not patched.
   Five implementation rulings (D-47): no default config location · `#src` declared
   (optional, §1.5 pattern) · schema versioning (D-49 policy: every change bumps; strict
   validation admits no "compatible" change) · caller provides everything, reference
   runner = convenience · public surface usable cold.
2. **D-48/D-49 · Public surfaces.** Four audiences + everything-else-internal law;
   the eight gap items ruled (constructors and read protocols onto the caller surface,
   catchable errors, fix-invoker surface, init command, P-SURFACE-CONFORMS, wrapper
   self-test, schema policy). The embedded diagrams exposed three of the gaps
   (drawing forces totality).
3. **D-51/D-52 · Composition over defaults.** `globalCatalogSTON` and the two-scope
   model removed: kits contribute self-contained blocks; defaults exist only as a kit's
   *recommended block* composed at authoring time; a framework upgrade can no longer
   change a project's enforcement without a visible diff. R-46 re-anchored by
   provenance (project's own baseline packages).
4. **D-53/D-54 · SDK architecture.** Surfaces recomposed as four SDKs
   (check author ⊂ kit author; gate caller ∥ fix invoker, split by mutation rights —
   the P-FIX-GATE-WALL embodied in API shape). Contract = protocol, conformance
   validated at registry build; abstract-class skeletons (not traits — B-03's
   attribution edges); `Phi-Guardrails-SDK` package = protocols + skeletons + frozen
   vocabulary, layer-map-enforced; kit handoff narrowed to block + role lists
   (over-reach impossible, not caught); kit contract = `kitName` ·
   `registrationsFrom:productionPackages:testsPackages:` · `recommendedBlock`
   (self-validating stanza); `PGRRegistrationSpec` carries information across the
   boundary, the engine owns mechanism (family 3); `PGRNotAutofixable` renamed generic.

## Knowing trades and review-tier items (recorded, not open)

- Tests-role code unlinted (D-33) → B-04 · empty test methods pass (M5 sweep) ·
  P-DETERMINISTIC deny-list is a stopgap until B-01 · extension-method attribution
  bound → B-05 · trait lint-environment probe → B-03 (M1) · SDK complete-and-minimal is
  judgment-tier (validator checklist line; P-SURFACE-CONFORMS covers existence/arity) ·
  third-party kit purity is trust, not machinery · fix-invocation protocol is generic
  but implemented only by the coding kit (revisit on second fixing kit).

## Method lessons exported (already applied)

- Credential scan = judgment-tier reviewer instruction, seeded, in template 5c.
- Backlog vs requirement routing: ruled-in scope is a requirement (D-44).
- Architecture-first for specs: chapter 0 pattern; method amendment **parked** until
  the format proves out (owner hold).
- Diagrams as review instruments: drawing exposes what prose reviews miss (D-48 gaps,
  the stale-label catches).
- One editor per file: the fence held in both directions (producer↔owner), catching
  drift four times.

## Postscript — post-close rounds (D-55 → D-60, 2026-07-22)

*Gate 2's close was followed by a validation-and-hardening arc before Prompt 3; this
record's statements above describe the state at close and are superseded where the log
says so.* Highlights: **D-55** no default sink (caller provides everything, incl. the
verdict stream's destination) · **D-56/D-57** the naming split (kit classes `PCK`,
packages `Phi-Coding-Kit-*`; toy models a real adopter: `Toy*`/`Toy-*`/`BaselineOfToy`;
fixtures kit-side) · **D-59** the three quickstart guides (`docs/quickstarts/`,
P-GUIDE-EXEC) — writing them surfaced eight SDK gaps · **D-60** the G-slate ruled: the
kit contract is now **two messages** (`kitName` dropped; `recommendedBlock` answers
STON text), checks receive targets at construction (`packages:`), conformance +
kind-agreement validate on the **specs kits answer** (blocks stay opaque; external and
resident kits share one validation path).

## Pipeline position

Gate 2 **closed**. Next: **Prompt 3** (roadmap). Its entry check must expect: chapters
0–9 with 6 withdrawn · requirements at 36 covered + 1 superseded + R-46/R-47-class
additions per coverage.md · backlog dispositions required for B-01–B-05 (B-02 carries
phi-llm's M0 deadline; B-06 promoted-out → R-46; B-07 retired by D-45) · the D-53/D-54
package set (`-SDK`, `-Core`, `-Gate`, kit families) in the baseline outline.
