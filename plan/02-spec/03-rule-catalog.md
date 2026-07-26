# Spec ch. 3 — Rule catalog v1, and the fix command

*Satisfies: R-11, R-12, R-15, R-37 (for rules) · D-04, D-06, D-20. Chapter 2 defines the
authoring contract; this chapter lists what v1 ships and specifies the only code path that
may mutate client source.*

## 3.1 Catalog entry format

Every catalog entry (now and at widening) states: **AST pattern** (verbatim) ·
**autofix** (the replacement, or `flag-only` with one line of why no safe rewrite exists) ·
**severity** · **rationale** (the full class-side string) · **fixture pair** (the two test
method names that prove it, R-37).

## 3.2 The v1 catalog — one rule (D-04, R-15)

**`PCKNoIsNilIfTrueRule`** — package `Phi-Coding-Kit-Rules`; the recommended
coding-kit block includes it (drafted into adopters' files by the init command, D-51),
registration name `lint/PCKNoIsNilIfTrueRule`.

| Field | Value |
|---|---|
| AST pattern | `` `@x isNil ifTrue: [`.@block] `` |
| Autofix | rewrite to `` `@x ifNil: [`.@block] `` (verified end-to-end in a live image, D-15) |
| Severity | `#error` (D-20) |
| Rationale | §2.2's text, verbatim in the class |
| Fixture pair | `PCKNoIsNilIfTrueRuleTest>>#testFiresOnBadFixture` (rule critiques `PCKLintBadFixture>>#withIsNilIfTrue`) · `>>#testSilentOnGoodFixture` (zero critiques on `PCKLintGoodFixture`) |

Fixture classes live in `Phi-Coding-Kit-Tests-Rules` beside the tests — a
tests-role package, which is safe because lint and architecture checks target
**production-role** packages only (D-25; a ruled trade — D-33), and the behavioral run of a tests-role package
executes only its `TestCase` classes, to which plain fixture classes are inert. Fixtures
are exercised by their tests, never swept by the standing gate; only fixtures containing
red *tests* need the exempt-role escape (§5.5, D-22).

Self-hosting (R-38): the framework's own `guardrails.ston` registers this rule over all
`Phi-Guardrails-*` production packages from M1 onward; the codebase must stay clean under
it.

## 3.2b The v1 catalog — one registered built-in (D-28, revising D-19)

**`ReCodeCruftLeftInMethodsRule`** — ships with Pharo; the recommended coding-kit block
includes it by name (D-51; the D-05 register-a-built-in mechanism exercised in earnest),
registration name `lint/ReCodeCruftLeftInMethodsRule`.

| Field | Value |
|---|---|
| AST pattern | built-in matcher — fires on `self halt`, `self haltIf:`, `Transcript show:`, `self flag:` (verified live, D-28); silent on clean code |
| Autofix | flag-only — the fix deletes statements, which is never a safe automatic rewrite (same reasoning that deferred no-`self halt` in D-04) |

*Erratum (D-74, M1 gate): there is **no flag-only category**. `canFix` is the mechanical fact alone (the rule carries a rewrite recipe or it does not — this rule does); per-application safety judgment lives at the mandatory preview. The "never a safe automatic rewrite" rationale was a producer-invented intent tracing to no ruling; D-06 already placed the whole safety model in explicit invocation + preview.*
| Severity | `#error` (its shipped class-side value, verified D-28) — it blocks |
| Rationale | its shipped string: "Breakpoints, logging statements, etc. should not be left in production code." |
| Fixture pair | `PCKCodeCruftBuiltInTest>>#testFiresOnBadFixture` — **the bad fixture pins the rule's match set (D-55 item 4)**: it contains each send form this entry claims the rule catches (`self halt`, `self haltIf:`, `Transcript show:`, `self flag:`), one asserted critique per form, so the match set is a permanent regression guard rather than a one-time probe · `>>#testSilentOnGoodFixture` — R-37 applies to registered built-ins like any catalog rule |

**Severity pin (D-34):** this entry's blocking status is inherited from the image, not
declared by our code — a Pharo upgrade could silently demote the rule to `#warning`, and
under D-03 the gate would stop blocking on debug cruft with no signal anywhere. A third
test beside the fixture pair, `PCKCodeCruftBuiltInTest>>#testSeverityStillBlocks`,
asserts the class-side `severity == #error`, turning drift into a red test. The pin is
the pattern for registered built-ins: every built-in entering the catalog at M5 arrives
with one (property P-BUILTIN-PINNED, ch. 9).

Self-hosting consequence: no `halt`, `Transcript show:`, or `self flag:` anywhere in the
framework's production code (the constitution already bans the first two as idiom and
`flag:`-style TODO markers as process; this rule is their machine enforcement).

**Widened catalog (M5, R-16 — recorded, not specified here):** no `self halt` /
`Transcript show:` in committed domain code · no `perform:` with a literal selector · no
`Smalltalk at:put:` writes · no `become:` in app code · no empty `ifTrue:`/`ifNil:` blocks
· swallowed errors (empty `on:do:`, flag-only per D-04) · the `isNil ifFalse:` /
`notNil ifTrue:` siblings of the v1 rule. Each arrives with the §3.1 fields complete.

## 3.3 The fix command (R-12, D-06)

`PCKFixCommand` — package `Phi-Coding-Kit-Rules` — is the **coding kit's
implementation of the SDK's generic fix-invocation protocol** (D-53: construct →
`previewOn:` → `apply` → `changes`, staleness detection required), realized over
methods, the refactoring engine, and Epicea; a future kit fixes over its own medium
with its own implementation. The three errors are `-SDK` vocabulary, catchable by
class. A check *declares* the capability with the two-message pair (D-54): `canFix`
(skeleton default false) and `fixCommandOn:` (required when `canFix`; answers an object
conforming to the fix-invocation protocol); the invocation machinery stays kit-side. It remains the **only** framework code path
that mutates client source. The gate never invokes it — the SDK-level invariant (D-53):
**no path from the gate-caller surface reaches fix invocation**, machine-carried by the
framework's own layer map (`Phi-Guardrails-Gate` → `Phi-Coding-Kit-Rules` forbidden;
property P-FIX-GATE-WALL in ch. 9).

**Protocol** (frozen at M1 — the coding kit's implementation of the **Fix-invoker
SDK**, ch. 0 §0.3/D-49/D-53: `rule:packages:`, `previewOn:`, `apply`, `changes`, plus
the three signalled errors — `-SDK` vocabulary, catchable by class):

```smalltalk
fix := PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Toy-Core').
fix previewOn: aWriteStream.   "mandatory first step"
fix apply.                     "only after a preview was emitted"
fix changes.                   "the pending/applied change objects, inspectable"
```

- `rule:packages:` — named constructor; the rule class must answer `isRewriteRule` true,
  else `PGRNotAutofixable` (renamed generic by D-54; 'check has no autofix') — an
  `Error` subclass beside
  `PGRFixNotPreviewed` and `PGRFixStale`, all three `-SDK` vocabulary (not
  configuration errors: the
  artifact is not at fault when a caller hands the fix command a flag-only rule).
- `previewOn:` — runs the rule (as §2.3 steps 1–2), collects each critique's change
  object, and emits per prospective change: the target (`Class>>#selector`), the old
  source, the new source (the change objects' `oldVersionTextToDisplay` /
  `textToDisplay`, D-15). Answers the number of pending changes. Calling `apply` before
  `previewOn:` has run in the same command instance signals `PGRFixNotPreviewed` — this
  is the machine-checkable meaning of D-06's "mandatory preview": for a headless agent
  invocation, the preview lands in its transcript/log before anything changes.
- `apply` — first re-reads every pending change's target: if any method's current source
  differs from the source the preview showed (its `oldVersionTextToDisplay`, D-15),
  signals `PGRFixStale` and applies **nothing** — the diff the invoker confirmed is the
  diff that applies (D-06's substance; a stale command is discarded, and a new instance
  previews afresh). Otherwise executes each pending change via the refactoring engine
  (`change execute`, D-15). Every change is an ordinary recompile: Epicea-recorded,
  listed in `RBRefactoryChangeManager`'s undo history. Answers the applied change
  objects.
- One command instance is one invocation: re-running `apply` is an error; a new fix run
  is a new instance with a new preview.

**Fixing the framework's own code is allowed (D-42).** `PCKFixCommand` may target
`Phi-Guardrails-*` production packages — that is self-hosting taken seriously: we apply
the autofix we ship. Caution, stated because silence made the default "it works until it
doesn't": **do not run a fix from inside a gate run.** Pharo permits recompiling a method
that is currently executing, and a half-rewritten gate is a bad place to be. No runtime
machinery enforces this and none is wanted — a "gate in progress" flag would be exactly
the global state R-35 forbids. The condition holds structurally instead: the framework's
own layer map forbids `Phi-Guardrails-Gate` → `Phi-Coding-Kit-Rules` (P-FIX-GATE-WALL), so the
gate cannot invoke the fix command, and an in-image run is single-threaded, so a gate run
and a fix command cannot interleave in one process.

**Division of labor restated (D-06):** the rule carries the recipe; `PCKFixCommand`
applies it; the invoker (human or agent) triggers and confirms; the gate only ever
reports. A gate run mutates nothing — tested as property P-GATE-PURE (ch. 9).
