# Spec ch. 4 — Architecture-test kit

*Satisfies: R-18, R-19, R-20, R-21, R-43 · D-07, D-15, D-35. Package
`Phi-Guardrails-Coding-Architecture`. All queries are reflective — the engine asks loaded
classes, never parses files (R-18); the class-reference query is
`CompiledMethod>>referencedClasses` (the `literals`/`isBehavior` sketch is wrong in
Pharo 13 — D-15 correction 3).*

## 4.1 The layer-map section format (D-07 assigned it here)

`#layerMap` — a project-scope map section with two mandatory keys and one optional:

- `#layers` — map: layer name (String) → list of package names (String). Layer names are
  the client's vocabulary; packages must be disjoint across layers (a package in two
  layers is a configuration error), **production-role packages of the baseline** (naming
  a package outside the production role is a configuration error, D-25), and loaded (an
  unloaded package makes the registration missing, §1.5).
- `#allowed` — list of two-element lists `[ from, to ]`, each naming declared layers: code
  in layer *from* may reference classes in layer *to*. Naming an undeclared layer is a
  configuration error.
- `#unlayered` — optional list of production-role package names deliberately outside
  every layer (extension/glue packages holding no layered domain code). Unlayered
  packages are unwalked and unjudged — by visible declaration, not omission.

**Completeness law (D-35 — ch. 1's scope-law lesson applied to the map):** when
`#layerMap` is present, the layers and `#unlayered` must **jointly cover every
production-role package, each in exactly one place**. Configuration errors: a production
package in no layer and not in `#unlayered` · a package in two layers, or in a layer
*and* `#unlayered` · an `#unlayered` entry naming a package outside the production role,
or unknown. A production package added later therefore fails loudly instead of silently
escaping the walk. The omission is also restated at run time: the check's verdict carries
one **advisory line** naming the `#unlayered` packages, so every report repeats what the
map declines to judge (defense in depth beside the artifact diff; property
P-LAYERMAP-TOTAL, ch. 9).

Implicit rules, fixed: a layer may always reference itself · allowed pairs are directed
and **not** transitive (`ui→domain` and `domain→persistence` do not grant
`ui→persistence`) · references to classes in no declared layer (kernel, frameworks,
anything unmapped) are ignored — the check polices only declared layers.

## 4.2 The check (v1's one shipped architecture test, R-43)

**`PGRLayerMapCheck`** — a `PGRCheck` (kind `#architecture`), registered by name in the
kit block's `#architectureChecks` (the class ships with the kit — generic engine,
client-supplied map, R-19; the client writes the entry, D-51). Registration name:
`architecture/PGRLayerMapCheck`.

`run`, for the layer map in the configuration:

1. Resolve each declared package via `PackageOrganizer default packageNamed:ifAbsent:`
   (D-15 correction 2).
2. For every layer `L`, every class defined in `L`'s packages, every method of that class
   **including class-side methods**, collect `method referencedClasses`; normalize each to
   its `instanceSide`.
3. For each referenced class that is defined in some declared layer `M` with `M ≠ L`: if
   `[L, M]` is not in `#allowed`, emit a finding.
4. Verdict: red iff ≥1 finding, else green. No advisories — architecture always blocks
   (D-03).

**Finding precision (R-20):** each finding's target is the offending method printed as
`Class>>#selector`; its message names both ends and the verdict of the map, e.g.
`PGRToyWidget>>#render references PGRToyDatabase — layer 'ui' → 'persistence' is not allowed`.
One finding per (method, referenced class) pair; a method reaching two forbidden classes
yields two findings.

**Known bounds (stated so reviewers don't rediscover them):** the §4.2 walk attributes
methods **by defining class, not by owning package** — a method another package extends
onto a layer-L class is judged as L's, and L's own extensions on foreign classes go
unwalked. Accepted for v1 (immaterial for the fixtures and the toy); if it bites a real
client at implementation, it becomes a decision-sheet entry then. Second bound:
`referencedClasses` sees
static references only; a lookup via `Smalltalk globals at:` evades the check. That
dynamic escape is precisely how the framework's own core stays kit-neutral (§1.4) and is
acceptable for v1; a rule banning `Smalltalk at:` writes lands in the widened lint catalog
(R-16), which closes the loudest abuse. Third bound, probed live and **closed**:
trait-provided methods are walked at each using class (and at the trait itself when its
package is layered) with working `referencedClasses` on both sides — one trait defect may
yield findings in several layers, honest duplication; see the D-15.b trait addendum.

## 4.3 One more constraint = one more registration (R-21)

Adding an architectural constraint never edits the framework: tightening the map is an
artifact edit; a genuinely new kind of constraint is a new `PGRCheck` class in the
client's extension package plus one `#architectureChecks` entry — same section, project
scope, promotable later (§1.6). The kit's engine (map parsing, reference walking) is
reusable by such client checks but their contract is only `PGRCheck`'s (`run` → verdict).

## 4.4 Fixture pair and self-hosting

Fixture pair (R-37): a three-package mini-fixture in `Phi-Guardrails-Tests-Coding-Architecture`
with one planted forbidden reference — `PGRLayerMapCheckTest>>#testFiresOnForbiddenReference`
asserts exactly the expected finding (target and both layer names);
`>>#testSilentOnConformingMap` asserts green on the same packages under a map that allows
the reference. The toy client (ch. 8) plants the demonstration violation
(`Phi-Guardrails-Toy-UI` reaching directly into `-Toy-Persistence`), which R-43's
demo test drives red → fixed → green.

Self-hosting (R-38): the framework's own `guardrails.ston` declares its layer map —
layers `sdk` (`Phi-Guardrails-SDK`), `core` (`Phi-Guardrails-Core`), `gate`
(`Phi-Guardrails-Gate`), `kit`
(`Phi-Guardrails-Coding`, `-Coding-Rules`, `-Coding-Architecture`, `-Coding-Behavioral`);
allowed: `core → sdk`, `gate → core`, `gate → sdk`, `kit → sdk` (D-53). Everything
else — the SDK reaching anywhere, gate reaching into kit packages, **kits reaching the
engine** (this is what keeps SUnit and Renraku out of the boundary, checking away from
fixing, and over-reach structural) — is a violation (properties P-CORE-NEUTRAL,
P-FIX-GATE-WALL, P-SDK-EDGE, ch. 9). Kits answer `PGRRegistrationSpec` values (`-SDK`);
`PGRRegistration` is engine-internal — the residency edge closed by D-54.
