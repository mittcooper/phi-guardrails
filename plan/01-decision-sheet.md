# 01 · Decision Sheet — phi-guardrails

*Produced by Prompt 1 (Consolidate). Ordered so decisions blocking the v1 skeleton come
first. Recommendations are the agent's; **rulings are the human's** — each ruling becomes a
numbered entry in `plan/decision-log.md`. Spec chapters referenced are the pack §8 outline
(ch. 1–8).*

---

**Q-01 · Registry representation, registration format, and "missing" semantics**
*→ RULED: option (a) — see `plan/decision-log.md` D-01.*
— The pack ships "one extension model — the **check registry**" (Pack P3), yet family
principle 4 says "No defaults, no singletons, no registries — every wiring is explicit at
the call site" (family §3), and Pack §5 forbids global state (R-35). The registry must also make "missing" detectable per
check kind (R-06, R-24) and be something the working agent cannot edit around (P6). How
registrations are declared and discovered decides the shape of the whole core.
· **Options:** (a) a declarative per-project **configuration artifact** (e.g. STON file in
the client repo) that a gate run loads into an explicit, inspectable `PGRegistry` object;
(b) **pragma-annotated** class-side methods discovered by image scan; (c) **subclass
discovery** — registering = subclassing a kind's base class.
· **Recommendation: (a).** An explicit artifact is the only shape that satisfies all three
masters at once: it is explicit wiring (family 4), one named owner of "what runs" (family 6,
P6), and diffable/reviewable in git so the agent can't quietly deselect checks — image scans
(b, c) make "registered" depend on what happens to be loaded, which is exactly the silence
R-24 forbids. Global-scope catalog = a shipped default artifact the project one extends.
· **Blocks:** ch. 1 (registry), ch. 7 (gate), R-01/02/06/24/35.

**Q-02 · The image-verification pass — when, and who bootstraps the toolchain**
*→ RULED: option (a) — see `plan/decision-log.md` D-02.*
— P5 forbids design statements resting on unverified spellings, and the spec (Prompt 2)
must state Renraku base classes, rewriter API, severity hooks, SUnit skip mechanics,
smalltalkCI critics option, Epicea event names, author-stamp API, the compiled-method
referenced-classes query (`literals` / `isBehavior` — the query the skeleton architecture
test is built on), and the `PG` prefix survey. No Pharo 13 VM or image exists on this machine today, so the pass has a real
setup cost.
· **Options:** (a) a dedicated **verification session before Prompt 2** — bootstrap Pharo 13
headless + smalltalkCI, run a probe script, record every spelling in the decision log;
(b) verify **during** spec writing, per chapter; (c) defer to implementation (M1) and let
the spec hedge.
· **Recommendation: (a).** P5 is categorical, and every ⟨verify⟩ item feeds ch. 2/4/5;
verifying piecemeal (b) invites a spec that is half-checked, and (c) is what P5 exists to
prevent. This is also the natural moment to bootstrap the M0 toolchain the verify command
needs anyway.
· **Blocks:** ch. 2, 4, 5 (every spelling-dependent statement); R-39; M0 toolchain.

**Q-03 · Severity taxonomy — what exactly blocks the gate**
*→ RULED: option (a) — see `plan/decision-log.md` D-03.*
— P6: "a registered check that is missing, skipped, or red fails the build" (Pack §3).
S1's CI passage: "fail on red tests *or* on `#error`-severity criticisms so style
violations also block" (S1 Phase 6) — implying sub-`#error` criticisms do not block. The
two must be reconciled into one stated failure condition (Gate-2 extra, Pack §8: "missing
∨ skipped ∨ red registration ∨ `#error` criticism").
· **Options:** (a) **two-tier**: adopt Renraku severities; lint criticisms block only at
`#error`, lower severities are reported; architecture and behavioral checks always block;
(b) **everything registered blocks** regardless of severity; (c) client-configurable
blocking threshold per registration.
· **Recommendation: (a).** It preserves P6 by definition — a rule registered at `#error`
*is* red when violated; lower severities are advisory context for the agent (R-13) — and it
matches both S1's CI contract and smalltalkCI's convention. (b) makes every style nit a
build break and will push clients to unregister rules, defeating P6 socially; (c) adds a
knob v1 doesn't need (family 5).
· **Blocks:** ch. 2, ch. 7; R-14, R-29.

**Q-04 · Which lint rule is the v1 skeleton rule (with autofix)?**
*→ RULED: option (a) — see `plan/decision-log.md` D-04.*
— v1 needs exactly one real, self-hosted rule with a working autofix (R-15). The source
offers several targets; the choice shapes the first fixture pair and the M1 demo.
· **Options:** (a) **`isNil ifTrue:` → `ifNil:`** — the source's own rewriter example, a
clean semantics-preserving rewrite; (b) empty-`on:do:` swallowed-error — high value but has
no safe automatic fix (what would the handler *do*?); (c) no-`self halt`-in-committed-code —
trivial to detect, fix = delete the statement.
· **Recommendation: (a).** It is the only candidate that is genuinely *autofixable* with a
provably behavior-preserving rewrite (P1's "fixes, not flags" in full), it self-hosts
harmlessly, and the source already sketches the pattern. (b) belongs in the widened catalog
as flag-only; (c) is a good second rule but its "fix" deletes code, a worse first
demonstration of autofix safety.
· **Blocks:** ch. 3; R-15; M1.

**Q-05 · Autofix invocation and safety model**
*→ RULED: option (b), agent may invoke — see `plan/decision-log.md` D-06.*
— The framework must never mutate client code except through an explicit user-invoked
autofix (R-12), and S1 warns the agent's mistake is "corrected automatically" only in the
as-you-type loop. What is the invocation unit, and what protects the user?
· **Options:** (a) explicit command per scope — "apply fix F to package P" — applying
rewrites via the refactoring engine so changes land as ordinary, Epicea-recorded,
undoable edits; (b) same plus a mandatory **preview/diff step**; (c) fix-on-report — the
gate offers `--fix` to apply all autofixes in one run.
· **Recommendation: (b).** Explicit + preview is the instrument-not-appliance shape
(family 5, 7) and makes "user-invoked" auditable. (c) couples the gate to mutation,
violating R-12's spirit (the gate reports; a separate command fixes).
· **Blocks:** ch. 3; R-12.

**Q-06 · Layer-map format and how a client supplies it**
*→ RULED via consolidated D-07 (provision per D-01; section format → spec ch. 4).*
— The architecture engine is generic; the client's layer map drives it (R-19). The probe
list asks how the map and package list arrive.
· **Options:** (a) part of the Q-01 configuration artifact — layers, their packages, and
allowed-dependency pairs declared as data; (b) client code builds a `PGLayerMap` object in
its extension package; (c) both — data artifact canonical, object API underneath.
· **Recommendation: (a)** (which is (c)'s surface anyway: the artifact deserializes into
the object). Keeping the map in the same declarative artifact as registrations gives one
place answering "what does this project enforce" (family 6) and keeps the client's
extension package for genuinely custom checks only.
· **Blocks:** ch. 4; R-19; M2.

**Q-07 · Skipped/disabled-test detection semantics**
*→ RULED: option (a) — see `plan/decision-log.md` D-08.*
— The no-skips meta-rule (R-25) needs a precise definition of "skipped or disabled" in
SUnit terms: `skip`/`TestSkipped` at run time, `expectedFailures`, abstract/ignored test
classes, tests removed from a suite. Mechanics are ⟨verify⟩ (Q-02 confirms spellings).
· **Options:** (a) count **run-time skips and expected failures** in registered suites —
any skip or expected-failure result reddens the gate; (b) (a) plus static sweep for
suspicious shapes (empty test methods, `testXxx` not run); (c) run-time skips only.
· **Recommendation: (a)** for the skeleton — run-time skips and expected failures are
exactly the "skipped" P6 makes a build failure, and they are precisely detectable from the
test result object with no heuristics, which is what P1 demands of anything machine-enforced;
(b)'s static sweep is a good widened meta-rule.
· **Blocks:** ch. 5; R-25; M3.

**Q-08 · Behavioral registration unit**
*→ RULED via consolidated D-07 (provision per D-01; name patterns as working default,
veto-able at Gate 2).*
— What exactly does a client register: package-name **patterns** (`'Phi-Llm-Tests-.*'`),
an explicit package list, or TestCase classes? Interacts with R-24 (a pattern matching
nothing must fail as *missing*) and the widened mirror-package meta-rule.
· **Options:** (a) package-name patterns, with the rule that a pattern matching zero loaded
packages is a *missing* failure; (b) explicit package enumeration; (c) patterns plus a
declared **minimum match count**.
· **Recommendation: (a).** Patterns are how the pack's own verify command and smalltalkCI
already speak, and the zero-match-fails rule closes the silence hole (b) closes, without
(b)'s per-package churn on every addition. (c) is a knob with no v1 demand.
· **Blocks:** ch. 5; R-23/24; M3.

**Q-09 · Secrets-leak test — specification from scratch**
*→ RULED: option (a) — core see `plan/decision-log.md` D-09; pattern-list provision D-07.
Shipped starter patterns are spec ch. 6 material.*
— R-28 exists only as a pack line; no source passage defines scan surface, patterns, or
check kind. A spec chapter cannot be written from a name.
· **Options:** (a) a **behavioral-kind global check** that sweeps loaded source (method
source + class comments + literals) for credential patterns (known token prefixes, key-like
literals), with a client-extensible pattern list; (b) a lint-kind Renraku rule over method
ASTs only; (c) file-side sweep of the Tonel tree (catches non-code files too).
· **Recommendation: (a) with (c) as a widened addition.** In-image sweep matches the
framework's reflective idiom and covers what agents actually commit (code + literals);
Tonel/file sweep adds `.ston`/config coverage later. Whatever is ruled, the check must have
the standard fixture pair (R-37).
· **Blocks:** ch. 6; R-28; M4.

**Q-10 · Gate ↔ smalltalkCI integration shape**
*→ RULED: option (a) — see `plan/decision-log.md` D-10.*
— The gate must be one headless entry point (R-06/07) and CI runs via smalltalkCI
(R-29), but the core must not be SUnit-shaped (R-04). Does CI reach the gate *as* tests,
or as a script step?
· **Options:** (a) the gate is a plain object with a CLI entry; a thin
`PGGateTest`-style SUnit adapter in the *coding kit / tests* lets smalltalkCI run it as one
test; (b) gate logic lives inside SUnit tests directly; (c) gate as separate script step
beside smalltalkCI, two CI stages.
· **Recommendation: (a).** The adapter keeps SUnit at the edge (kit-level), the core
kit-neutral (R-04), and CI single-stage; (b) bakes SUnit into the core; (c) doubles CI
plumbing and splits the verdict into two places.
· **Blocks:** ch. 7; R-29/30; M4.

**Q-11 · `PG` class-prefix collision**
*→ RULED: prefix is `PGR`, decided outright (survey dropped) — see `plan/decision-log.md`
D-11.*
— Older Pharo Postgres drivers used `PG`-prefixed class names; a client loading both would
collide. Cheap to check, expensive to discover late.
· **Options:** (a) survey in the Q-02 verification image (`Smalltalk classNames` for `PG*`
in a stock Pharo 13 + common DB drivers); keep `PG` if clean; (b) preemptively rename
(`PGu`, `PhiG`).
· **Recommendation: (a).** This is P5 applied to our own naming: confirm the spelling
landscape in a live image before a design statement (the class prefix) depends on it.
Stock Pharo 13 ships no Postgres driver; rename only on evidence — preemptive renaming
costs clarity for a hypothetical.
· **Blocks:** R-36; M0 (first class name written).

**Q-12 · Toy client package — shape and location**
*→ RULED: both, staged — (a) in-repo for v1, (b) external repo before broad use — see
`plan/decision-log.md` D-12.*
— The skeleton is demonstrated against a toy client (R-32): adoption, project-scope
extension, planted violations, red → green.
· **Options:** (a) fixture packages **in this repo** (e.g. `Phi-Guardrails-Toy-*`), loaded
only by a `Tests`/`Demo` baseline group, with deliberate violations of every v1 check;
(b) a separate toy repository exercising real cross-repo adoption.
· **Recommendation: (a)** for v1 — self-contained, CI-runnable, and doubles as the fixture
farm for R-37; (b) becomes the real test the day phi-llm adopts (its onboarding *is* the
cross-repo demonstration).
· **Blocks:** ch. 8; R-32; M4 demo.

**Q-13 · Built-in Code Critics — inside the registry or outside the gate?**
*→ RULED: option (a) — see `plan/decision-log.md` D-05.*
— S1's enforcement layer runs "SUnit + critics" headless, and smalltalkCI's critics option
runs Pharo's *shipped* rule set — rules nobody registered. An unregistered built-in critic
that blocks the build means registration did not decide what runs, a direct P6 collision;
no source passage says which built-ins count. Undefined mechanism, no prior Q covers it
(Q-03 decides severity of *registered* rules; Q-10 the adapter shape).
· **Options:** (a) **excluded by default** — the gate runs only registered checks;
the global catalog may explicitly register selected built-in Renraku rules (they are rules
like any other), and smalltalkCI's own critics option stays off in favor of the gate;
(b) all built-in critics implicitly global-registered, blocking at `#error`;
(c) built-ins run but are advisory-only, never blocking.
· **Recommendation: (a).** P6 is categorical — the registry is the single owner of "what
runs" (family 6), and (a) keeps the blocking set explicit and diffable. (b) hands the
failure condition to whatever rule set the image happens to ship, version to version;
(c) spends gate time on output the verdict ignores.
· **Blocks:** ch. 2, ch. 7; R-29.

**Q-14 · Gate wall-clock budget (NFR placeholder)**
*→ RULED: option (b) — see `plan/decision-log.md` D-13.*
— R-09 carries "seconds-scale" with no number. S1 offers qualitative language only
("instantly", "seconds").
· **Options:** (a) budget: full gate on this repo + toy client **< 60 s** in CI, < 10 s
in-image incremental; (b) no numeric budget in v1, measure at M4 and set then.
· **Recommendation: (b)** with (a)'s numbers recorded as the working target — a hard
budget before any measurement exists would be invented precision (family 1 argues against
fake numbers). Revisit as a ruled budget at M4.
· **Blocks:** nothing in the skeleton; spec ch. 7 NFR line.

**Q-15 · Formatter — inside the gate or out?**
*→ RULED: option (a); format-at-write assigned to phi-agent-runtime's `write_method` —
see `plan/decision-log.md` D-14.*
— S1 Phase 4 wires the in-box formatter into the as-you-type loop, but the pack's v1 scope
never mentions formatting, and the formatter is autofix-only (no "red" state).
· **Options:** (a) out of v1 entirely — formatting stays an editor/agent-loop concern;
(b) a widened lint rule "method source differs from formatter output" with autofix.
· **Recommendation: (a)**, revisit as (b) at M5. The gate enforces *registered checks*;
formatting has no failure semantics worth a build break in v1 and would be the one check
whose autofix the gate itself would want to run — colliding with R-12.
· **Blocks:** nothing; records the boundary.

**Q-16 · Promotion path mechanics (project → global)**
*→ RULED via consolidated D-07 (move entry + class between artifacts; manual, no tooling
in v1).*
— R-03 (v1-widen). What does "promote" mean concretely: move the rule class into the
shipped catalog package + move its registration into the global artifact, or a marker?
· **Options:** (a) documented manual procedure (move class, move registration, keep
fixture pair) — promotion is a refactor, not a feature; (b) tooling support (a
`promote:` command).
· **Recommendation: (a)** at v1-widen; (b) only if promotion proves frequent. An
instrument, not an appliance (family 5).
· **Blocks:** ch. 1 (one paragraph); R-03.

**Q-17 · Coverage floors — values and enforcement point (widening)**
*→ RULED via consolidated D-07 (declared per registration; no shipped default; values at
M5 from measured baselines).*
— R-27 (v1-widen) enforces per-package coverage floors, but no source names a number, and
a placeholder budget must reach the decision sheet rather than stop at "decide later".
· **Options:** (a) no shipped default — each client declares its floor per registration;
values chosen at M5 from measured baselines; (b) ship a global default floor (e.g. 80 %)
that clients may override; (c) drop coverage floors from the catalog.
· **Recommendation: (a).** A shipped number before any measurement exists is invented
precision (family 1), and registration-time declaration keeps the threshold where P6 puts
every enforcement decision — in the registry.
· **Blocks:** nothing in the skeleton; R-27, ch. 5 at widening (M5).

---

*Rulings at Gate 1 become `plan/decision-log.md` entries. Ruled so far: Q-01 → D-01,
Q-02 → D-02, Q-03 → D-03, Q-04 → D-04, Q-05 → D-06, Q-13 → D-05; Q-06 · Q-08 · Q-16 ·
Q-17 (+ Q-09's provision slice) → consolidated D-07; Q-07 → D-08; Q-09 core → D-09;
Q-10 → D-10; Q-11 → D-11 (prefix `PGR`); Q-12 → D-12 (both, staged); Q-14 → D-13;
Q-15 → D-14. **All 17 questions ruled — the sheet is closed.***
