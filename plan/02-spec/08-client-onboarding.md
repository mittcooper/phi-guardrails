# Spec ch. 8 — Client onboarding and the toy demonstration

*Satisfies: R-31, R-32, R-43 (demo half), R-44 (demo half), R-05 · D-12, D-17. The
framework never names a client (R-05); this chapter is written from the client's side.*

## 8.1 Adoption steps (R-31)

A project adopts phi-guardrails by **adding one configuration file** (R-47, D-45) — no
change to its source, baseline, or tests:

1. **Write `guardrails.ston`** (schema §1.1) — anywhere the project's callers can point
   at (an explicit path, §7.3); in-repo at the root is the recommended default for a
   project that owns its config. The minimum honest artifact declares `#schemaVersion`,
   `#project`, `#kits`, `#baseline`, and `#roles` — matchers over the baseline's
   packages, so **the client's baseline needs no role groups** (existing groups may be
   named as a convenience, D-45). **Nothing is enforced by default** (D-51): the file is
   the complete statement of what runs — the init command's draft composes in the kit's
   recommended block (the two catalog lint rules and the no-skips meta-rule), and a
   hand-written minimal config is, honestly, minimally checked. Add `#architectureChecks` + `#layerMap`
   when the project has layers to declare, and `#src` if it registers the dead-src check
   (§7.5). **The init/generate command drafts this file:** one class-side message,
   `PGRConfigurationDraft class>>draftFor:` (a baseline name) → draft STON text — a
   dedicated authoring-time class on the config-author surface (D-53;
   `PGRConfiguration` is purely run-time), draft-only semantics (D-49): it inspects
   the loaded baseline, composes the kits' published stanzas, and proposes a
   `guardrails.ston` for human review; generation may guess,
   the run-time gate may never infer (D-45 ruling 4).
2. **Point a caller at it.** Any caller satisfies §7.3's contract: a CI job invoking the
   reference runner (`guardrails.sh path/to/guardrails.ston`), an agent loop, a
   Playground, another tool. A CI setup that also runs the project's own tests keeps
   that as a **separate step** — the two-step shape of §7.4; the gate is never wrapped
   inside the test run.
3. **Extension package** (optional, only when the client writes custom checks): one
   package (e.g. `<Client>-Guardrails`, production-role) holding the client's own
   rule/check classes, each registered by name in the client's kit block — **your check
   need not subclass `PGRCheck`**: conformance to the check protocol, not ancestry, is
   what registration requires, validated loudly at registry construction (D-53; the
   skeleton is a convenience). The client's dependency is on **`Phi-Guardrails-SDK`**,
   the published boundary — never the engine. Each check comes with a fixture pair in the client's tests (R-37 applies to clients by
   convention, enforced for promoted checks). **The convention is unenforced in v1,
   knowingly:** a client rule that never fires — bad AST pattern, typo in the matcher —
   reports green, because a rule finding nothing looks exactly like a rule with nothing
   to find. A meta-rule making it machine-checkable by naming convention (registered
   check `Foo` ⇒ class `FooTest` in a tests-role package) is **R-46** —
   `PCKCheckFixturePairMetaRule`, v1-widen, landing with ch. 5's mirror-test-packages
   meta-rule at M5 (§5.5, D-44). A client check that proves generally useful is
   *promoted* by inclusion in the kit's recommended block — documentation, not
   mechanism (§1.6, D-51). This is the **one** case where a client loads the
   framework, and the dependency is **development-scoped** — never in the client's
   `default` group, so no client ships a checking framework to its consumers.

New projects start pre-hardened with **zero commits to their own source** — steps 1–2
touch only the configuration file and the caller's own wiring. **Residual caveat
(D-45):** do not invoke the gate on this repo's own config from inside this repo's swept
tests — the recursion is no longer designed against, only advised against.

**Baseline groups** (`BaselineOfPhiGuardrails`; R-36/D-22/D-25 as amended by D-45 —
normative composition for the *framework's own* baseline). Two kinds: **role groups**
(leaf, packages only, pairwise disjoint — the framework's own `#roles` names these as
its matchers, the D-45 convenience form; §1.1's scope law holds over the expansion) and
**convenience composites** (may overlap freely; never named in `#roles`). Clients need
neither kind (D-45): their `#roles` matchers can name packages and patterns directly.

| Group | Kind | Loads |
|---|---|---|
| `production` | role | `Phi-Guardrails-SDK` (D-53), `-Core`, `-Gate` + `Phi-Coding-Kit`, `-Rules`, `-Architecture`, `-Behavioral` (D-57) |
| `tests` | role | every `Phi-Guardrails-Tests-*` |
| `fixtures` | role (exempt) | every `Phi-Coding-Kit-Fixtures-*` |
| `toy` | role (exempt) | every `Toy-*` |
| `Core` | composite | `Phi-Guardrails-Core`, `-Gate` |
| `Coding` | composite | `production` |
| `Tests` | composite | `production` + `tests` + `fixtures` + `toy` (the demo test in `Tests-Toy` needs the toy loaded, D-46) |
| `Toy` | composite | `production` + `toy` |
| `CI` | composite | `Tests` (retained as the workflow's load name) |
| `default` | composite | `production` — what a client with an extension package loads, development-scoped (§8.1 step 3) |

*(The former `ci-tests` role group and `Phi-Guardrails-CI-Tests` package are retired by
D-45 — no adapter, no privileged caller; the demo test lives in the tests-role
`Phi-Guardrails-Tests-Toy`, D-46.)*

## 8.2 The toy client (D-12 (a); the fixture farm and living documentation)

The toy ships its own **`BaselineOfToy`**, defined *inside*
`Toy-Core` (a baseline class needs its own package only when Metacello
loads it from disk by name, as the root baseline is; the toy baseline is introspected,
never Metacello-loaded in v1 — same trick as `BaselineOfPCKFixture`, §5.5; it moves to
its own package when the toy is copied out, §8.4). Under D-45 it declares **no role groups** —
the toy's artifact assigns roles by matcher (§1.1's example), which lets the toy
demonstrate R-47 exactly: adoption changed nothing in the adopted project's baseline. It
is the toy artifact's `#baseline` (§1.1's example), it models step 1 of the adoption
recipe faithfully, and it travels unchanged
when the toy is copied out for the external adoption proof (§8.4). The framework's own
baseline loads the same packages via its exempt-role `toy` group — the framework never
sweeps them; the toy's own artifact does.

Packages, loaded (from the framework's side) by the `toy` role group via the
`Tests`/`Toy`/`CI` composites (D-46 — the demo test needs them wherever the tests run):

| Package | Contents | Planted violation (R-32) |
|---|---|---|
| `Toy-Core` | mini domain logic | one `isNil ifTrue:` (the catalog rule, §3.2) · one `Transcript show:` (the registered built-in, §3.2b) · one `isNil ifFalse:` (the toy's own rule, registered in its kit block) |
| `Toy-UI` | mini UI layer | one direct reference to a `-Toy-Persistence` class (architecture) |
| `Toy-Persistence` | mini persistence layer | — (the target of the UI plant's forbidden reference; its own secrets plant was withdrawn with the check, D-37) |
| `Toy-Rules` | the toy's extension package: `ToyNoIsNilIfFalseRule` (a flag-only lint rule per §2.2 matching `` `@x isNil ifFalse: [`.@block] ``, severity `#error`; re-pointed from `Transcript show:` when the D-28 built-in took that ground) | — (this is the client's-own-checks extension demo; R-32's pre-D-51 "project-scope" phrasing) |
| `Toy-Tests` | the toy's tests-role suite | one failing test · one `skip:` test (behavioral, R-44) |

The toy's artifact is §1.1's example, verbatim (it already registers
`ToyNoIsNilIfFalseRule`). **In-repo embodiment:** it is committed as class-side STON
text — `BaselineOfToy class>>guardrailsSTON` (D-18's mechanism) — because
the repo root's `guardrails.ston` is the framework's own (§7.5) and no other committed
file location exists inside the write boundary; the demo test reads it with
`PGRConfiguration fromString:`. (A `fromString:` config has no directory, so the toy's
artifact declares no `#src` and registers no dead-src check — §1.1's optional-`#src`
rule, D-45.) It becomes a real root `guardrails.ston` file only in
the §8.4 external copy, where it *is* the repo's artifact. The toy models the client-side fixture-pair convention
(§8.1 step 3) on its own rule: `ToyNoIsNilIfFalseRuleTest>>#testFiresOnBadFixture` /
`>>#testSilentOnGoodFixture` in `Toy-Tests`, against small fixture
classes in that same package. The toy is committed **in the red state** —
its planted violations are real, current code; the toy is **exempt-role** in the
*framework's* artifact (§7.5), so the framework's own gate never sweeps it while the toy
exists to go red under its own artifact.

## 8.3 The demonstration test (R-32, R-43, R-44)

`ToyDemoTest`, in **`Phi-Guardrails-Tests-Toy`** — an ordinary tests-role package
(D-46; the exempt `CI-Tests` home is retired with D-45). The placement is safe by the
termination argument: recursion needs the *target config's* tests role to contain the
package holding the gate-driving test, and the demo runs the gate on the **toy's**
config, whose tests role is only `Toy-Tests` — the demo's own package can
never enter that set. A framework self-hosted run therefore *nests* (outer gate →
behavioral check runs `Tests-Toy` → demo runs an inner gate on the toy config →
terminates); it does not recurse. The move also improves enforcement: in a tests-role
package the demo is machine-swept — the no-skips meta-rule covers it, where the old
exempt home was reviewer-enforced. Accepted costs (D-46): the `Tests` composite loads
the toy, and every local verify runs the red → fixed → green cycle — seconds, and
running the framework's most valuable test often is a feature. D-26's committed red
state, D-43's protections (`ensure:` restoration + the `setUp` planted-state guard), and
R-44's demonstration all carry over unchanged. It drives the full story
red → fixed → green inside one test class.

**Protecting the toy's red state (D-43).** The toy's committed red state *is* the fixture,
and these tests rewrite the toy's live source, so restoration is not left to `tearDown`
alone:

- **Restoration is exception-safe.** Each mutation saves the original source and is
  wrapped so the recompile runs whether the body succeeded, failed, or errored
  (`ensure:`). A test that blows up mid-way cannot leave the toy partly fixed in the
  image — which would otherwise make the *next* test fail (or, worse, pass) for a reason
  having nothing to do with the gate.
- **`setUp` asserts the planted state.** Before each test, the toy is checked to be in its
  expected planted (all-red) condition. A leak from any source — a failed restoration, an
  interrupted run, a Playground session, a future test — then fails loudly at its cause
  instead of surfacing as a confusing failure elsewhere.

The three tests:

- `testGateIsRedOnPlantedViolations` — run the gate on the toy artifact; assert the report
  is not clean and contains **exactly** the expected non-green verdicts: red
  `lint/PCKNoIsNilIfTrueRule`, red `lint/ReCodeCruftLeftInMethodsRule` (the registered
  built-in, §3.2b), red `lint/ToyNoIsNilIfFalseRule`, red
  `architecture/PCKLayerMapCheck` (R-43), red `behavioral/Toy-Tests`, red
  `behavioral/PCKNoSkippedTestsMetaRule` (R-44) — six registrations, all red — and that
  each names its planted target precisely. The exact count is asserted **deliberately**:
  when the recommended block grows at M5 and the toy's artifact composes the new entries
  in, this test breaks, and that is the intended behavior — a new shipped check must
  arrive with a decision about how the toy demonstrates it, not slip in unnoticed behind
  a `>=` assertion.
- `testLintAutofixThenGreen` — apply `PCKFixCommand` (preview, then apply) for
  `PCKNoIsNilIfTrueRule` to `Toy-Core`; re-run the gate; assert that
  registration alone turned green (D-06 exercised end-to-end).
- `testAllFixedThenClean` — fix every plant in-image (rewrite, remove the reference, the
  failing assertion, the skip); re-run; assert `report isClean` and exit code 0.

This satisfies R-32 — adoption, the client's own extension checks (the requirement's
pre-D-51 "project-scope extension" phrasing), planted violations caught, gate
red → green — against a client the framework does not know.

## 8.4 External adoption proof (D-12 (b) — exit criterion at widening, not v1)

Before the framework is declared ready for general client use: copy the toy packages into
their own repository (`../phi-guardrails-toy`), with their own git history, their own
baseline depending on `BaselineOfPhiGuardrails` **via Metacello only**, their own
`guardrails.ston` and `.smalltalk.ston`; CI in that repo must load the framework as a true
external dependency and run the gate red → fixed → green. phi-llm's onboarding later
re-confirms on a real codebase. Checklist form lives here so the widening milestone can
execute it without returning to the decision log.
