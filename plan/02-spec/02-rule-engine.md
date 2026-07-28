# Spec ch. 2 — Rule-engine integration (Renraku)

*Satisfies: R-10, R-11, R-13, R-14 · D-03, D-05, D-15, D-19. All spellings in this chapter
were verified live (decision-log D-15); Renraku vocabulary ("critique", `Re*` classes)
appears only here and in chapter 3 — this is the engine boundary (family 9).*

## 2.1 One rule object, two surfaces (R-10)

A lint rule is a Renraku rule class. Because Renraku's browser tooling discovers every
loaded `ReAbstractRule` descendant, the *same class* appears in the Critic Browser and the
live editor badge when an image is interactive — that surface is free and needs no
framework code. The **gate** is the other surface: it runs only rules the registry names
(D-05); a loaded-but-unregistered rule may show in the browser but never blocks a build.
smalltalkCI's own critics option is not used — it does not exist for Pharo (D-15 §6), so
only the gate runs rules headless.

## 2.2 Authoring contract (Pharo 13 hooks — corrected spellings, D-15)

Every rule in ch. 3's catalog (shipped with the kit) or a client extension package implements:

| Hook | Side | Contract |
|---|---|---|
| `ruleName` | **class** | short imperative title shown in report and browser |
| `severity` | **class** | exactly one of `#error`, `#warning`, `#information` (R-14). **Mandatory for any registered rule** — the class must implement it *itself*; relying on the inherited `#warning` is a configuration error (D-41, §2.2b) |
| `rationale` | **class** | ≥1 full sentence: *why* the pattern is banned and what to do instead — this text is the agent guidance emitted with every finding/advisory (R-13) |

### 2.2b Explicit severity, no default (D-41)

A registered lint rule whose class does **not itself implement** class-side `severity` is
a **configuration error**, raised by the coding kit when blocks are opened at registry
construction — inside `forConfiguration:`, so still before any check runs (D-41's
letter, D-51's block opacity: `#lintRules` lives inside the kit's block, which only the
kit reads; ch. 1 §1.1's two-stage statement and §1.4). The inherited `#warning` is not a
legal state for a registered rule.

The hole this closes: ch. 7 §7.1 blocks only at `#error`, so a project that registered a
rule and forgot its severity got real violations reported as advisories and an exit 0 —
the rule *looked* enforced and was not. A rule's blocking status must be a stated fact,
never an inherited accident (P6). Rules merely loaded in the image are unaffected: the
requirement binds registration, not authorship, and Renraku's own default stands wherever
the gate is not involved.

Base class choice: `ReNodeMatchRule` for flag-only structural rules,
`ReNodeRewriteRule` for rules with an autofix (R-11; P1 prefers the latter wherever the
rewrite is safe). Both match AST patterns with meta-variables (`` `@x ``,
`` `.@stmts `` for statement lists), declared in `initialize` via `matches:` /
`addMatchingExpression:` or `replace:with:`. Non-AST rules may subclass any other
`ReAbstractRule` descendant; the registry accepts every descendant by name (§1.5).

Canonical form (this is the shipped v1 rule, catalog entry ch. 3):

```smalltalk
ReNodeRewriteRule << #PCKNoIsNilIfTrueRule
    package: 'Phi-Coding-Kit-Rules'

PCKNoIsNilIfTrueRule class >> ruleName   ^ 'isNil ifTrue: should be ifNil:'
PCKNoIsNilIfTrueRule class >> severity   ^ #error          "D-20"
PCKNoIsNilIfTrueRule class >> rationale
    ^ 'x isNil ifTrue: [...] re-tests a nil you already have; ifNil: is one send and
       reads as intent. The rewrite is behavior-preserving — apply the autofix.'
PCKNoIsNilIfTrueRule >> initialize
    super initialize.
    self replace: '`@x isNil ifTrue: [`.@block]' with: '`@x ifNil: [`.@block]'
```

## 2.3 How the gate runs a lint registration

`PCKLintRuleCheck` (package `Phi-Coding-Kit-Rules`; kind `#lint`) wraps one rule
class plus the configuration's production-role packages (D-25) — constructed by the
kit at registry construction (the kit's own class, so a richer kit-side constructor
carrying the rule class is legitimate; the promised `packages:` constructor is for
classes the kit does not own — D-60, ch. 1 §1.4). Its `run`:

1. Instantiate the rule; build `ReSmalllintChecker new rule: { rule }`, with
   `environment:` a `RBPackageEnvironment` over the target packages.

*Erratum (D-71/D-72, M1 gate): the package-scoped run as written attributes a trait-provided method only to the trait's **defining** package (probed live, D-71). Ruled: trait methods are linted at each **using** class's package — realized by the kit's widened environment composition (`PCKLintRuleCheck class>>lintEnvironmentOver:`, the E08-C01 amendment); the recipe here describes the narrow pre-amendment form. Extension (B-18a/D-82,
M2 doc pass): the widened composition covers a package's defined classes' methods
including trait-acquired ones, but — unlike the old `RBPackageEnvironment` — not the
package's extension methods on foreign classes (and conversely it sees foreign
extensions on its own classes); intended by D-72's defined-class wording, moot
in-repo (no `*.extension.st` exists), and joining B-05's extension-attribution
family for extension-heavy clients. Its strict `packageNamed:` raises Pharo's raw
`NotFound`, not a domain-shaped configuration error — B-18(b) if an error taxonomy
ever grows at this layer.*
2. `run` it; collect the rule's critiques via `criticsOf:`.
3. Map each critique to a `PGRFinding`: target = the critiqued entity printed precisely
   (`Class>>#selector`), message = `ruleName`, rationale = `rationale`.
4. Verdict (D-03): if the rule's class-side `severity` is `#error`, any critique is a
   **finding** and the verdict is red; at `#warning`/`#information` all critiques are
   **advisories** and the verdict is green. One rule = one registration = one verdict, so
   "an `#error`-severity critique exists" and "a lint registration is red" are the same
   statement (the ch. 7 failure condition depends on this identity).

The gate never applies a rule's rewrite (R-12): `PCKLintRuleCheck` reads critiques only;
applying changes is the fix command's monopoly (ch. 3).

**Scope boundary, stated as the knowing trade it is (D-33):** lint — like architecture —
reads **production-role packages only** (D-25's role→target mapping).
Tests-role code is deliberately outside lint's reach: debug cruft in a test package
(`Transcript show:`, `self flag:`, a halt on an unexecuted line) escapes the rules
entirely. This is the trade that lets bad fixtures live beside their tests in the
mirroring `Tests-*` packages (ch. 3 §3.2) — sweeping tests-role would redden the gate on
its own fixtures. Partial mitigation: a `self halt` on an executed line of a test method
errors that test headless, so the behavioral suite reddens anyway. Widening lint over
tests-role is an M5 option and rides the fixture relocation to `Phi-Coding-Kit-Fixtures-*`
(D-33).

## 2.4 Built-in Renraku rules (D-05, D-19 as revised by D-28)

The image ships 185 `ReAbstractRule` descendants (D-15). Any of them **that declares its
own class-side `severity`** is registrable by name in `#lintRules`, and the registry
treats it exactly like a catalog rule. One consequence of D-41 is accepted knowingly: we
do not own `ReAbstractRule`, so its inherited default cannot be flipped, and a built-in
relying on that default is **unregistrable** — a narrow restriction on this mechanism,
preferred over letting an unstated severity decide whether the gate blocks (the rejected
alternatives were a reporting-only advisory and a per-registration override). The
**recommended coding-kit block includes exactly one** (drafted into adopters' files by
the init command, D-51), selected by probe evidence (D-28):
`ReCodeCruftLeftInMethodsRule` (catalog entry
§3.2b — severity `#error`, fires on debugging leftovers). Widening adds further proven
built-ins to the recommended block at M5, each entering with a fixture pair like any
catalog rule.

## 2.5 Severity is the only tiering (D-03)

There is no per-registration blocking threshold and no severity on non-lint checks:
architecture and behavioral checks block on any finding. The two-tier rule is
final for v1: **`#error` critiques block; `#warning`/`#information` critiques inform.**
