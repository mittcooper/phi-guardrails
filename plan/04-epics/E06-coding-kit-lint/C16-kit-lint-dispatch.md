# C16 · PCKKit: block envelope + lint dispatch (D-41 enforced)      [E06 · depends: C15 · parallel: no]

GOAL      Land `PCKKit` with strict block validation (all five schema keys
          recognized, unknown keys are configuration errors) and the complete
          `#lintRules` pipeline — missing-specs for unresolved names,
          configuration errors for non-rule classes and D-41 severity
          omissions, `PCKLintRuleCheck` construction for the rest.

TRACE     ch. 1 §1.4 (kit duty, block schema, canonical order) · §1.5 `#lint`
          row (missing vs configuration error) · §1.3 (registration names) ·
          ch. 2 §2.2b (D-41 explicit severity) · §2.4 (built-ins registrable by
          name) · D-51 (block opacity) · D-53 · D-56 (`PCKKit` name) · R-40 ·
          P-SEVERITY-EXPLICIT.

## CONTEXT DIGEST

**What exists when this chunk starts:** C13/C15 accepted —
`PCKNoIsNilIfTrueRule` (class-side `severity ^ #error`) and `PCKLintRuleCheck`
with the frozen kit-side constructor
`PCKLintRuleCheck class >> rule: aRuleClass packages: aCollectionOfPackageNames`
(instance readers `rule`, `packages`; `kind` ^ `#lint`), both in
`Phi-Coding-Kit-Rules`. The E02-frozen SDK (signatures below). The shipped
built-in `ReCodeCruftLeftInMethodsRule` (class-side `severity ^ #error`,
verified D-28).

**The class.** `PCKKit` in package `Phi-Coding-Kit` (the root — ch. 1 §1.3:
"the kit class `PCKKit` lives in `Phi-Coding-Kit`"; class name ruled D-56),
subclass of the frozen `-SDK` skeleton `PGRKit`. All class-side; kits are
stateless — **no class-side variables** (constitution: no global state). Frozen
contract signature it implements (verbatim, E02 digest):

```smalltalk
PGRKit class >> registrationsFrom: aBlock productionPackages: productionNames testsPackages: testsNames
    "aBlock is the kit's verbatim block - a Dictionary from the artifact's #kits
    array; productionNames/testsNames are the resolved role package-name lists,
    never the configuration object (D-53). Answers an ordered collection of
    PGRRegistrationSpec values, never fewer than the block names. The kit
    validates its own block strictly: an unknown key inside it raises
    PGRConfigurationError, raised by the kit."
```

`recommendedBlock` stays inherited (`subclassResponsibility`) until C18 —
overriding it here is a manifest violation.

**Block schema** (canonical, ch. 1 §1.4 — frozen at E06 acceptance): `#kit` ·
`#lintRules` · `#architectureChecks` · `#layerMap` · `#metaRules`. Behavioral
suites have no block key (their targets are the tests-role packages — E07's
derivation).

**Envelope validation, this chunk:**

- Any key outside the five → `PGRConfigurationError` whose message names the
  key (D-51: blocks are opaque to the core, so only the kit can catch this).
- `#kit` is tolerated verbatim (the engine resolved it to reach us; its value is
  not re-validated here).
- A present `#lintRules` must be a collection of strings — any other shape →
  `PGRConfigurationError` naming the key.
- `#architectureChecks` / `#layerMap` / `#metaRules` are **recognized** (no
  unknown-key error) but produce no specs yet — C17 completes them; this
  chunk's tests use lint-only blocks. All keys are optional: an absent
  `#lintRules` simply contributes no lint specs.

**`#lintRules` pipeline** — per name, in block order (ch. 1 §1.5 + ch. 2 §2.2b):

1. Resolve the name to a loaded class: `Smalltalk globals at: name asSymbol
   ifAbsent: [ nil ]` — a **read**; the constitution bans only `Smalltalk
   at:put:` *writes*. ⟨verify-in-image⟩: confirm this lookup spelling live
   before use; record it in the completion report.
2. Unresolved → `PGRRegistrationSpec missing: 'lint/' , name kind: #lint
   reason:` a one-line reason naming the name (§1.5: missing is a verdict-level
   fact, not an exception — the run completes and the gate fails).
3. Resolved but **not a Renraku rule class** — `(cls inheritsFrom:
   ReAbstractRule) not` → `PGRConfigurationError` naming the class (§1.5: a
   loaded non-rule is a configuration error at construction, not a missing
   spec).
4. Resolved rule **without its own class-side `severity`** — `(cls class
   includesSelector: #severity) not` (local implementation, exactly D-41's
   "does not itself implement"; the inherited `#warning` is not a legal state
   for a registered rule) → `PGRConfigurationError` naming the class and the
   missing hook. This is **P-SEVERITY-EXPLICIT**'s subject.
5. Otherwise → `PGRRegistrationSpec name: 'lint/' , name kind: #lint check:
   (PCKLintRuleCheck rule: cls packages: productionNames)` — lint targets the
   production role (D-25).

Registration names are `<kind>/<ClassName>` (§1.3); duplicate-name rejection is
the **engine's** (E04) — the kit answers what the block says.

**Frozen `PGRRegistrationSpec` signatures** (verbatim, E02 digest):

```smalltalk
PGRRegistrationSpec class >> name: aNameString kind: aKindSymbol check: aCheck
PGRRegistrationSpec class >> missing: aNameString kind: aKindSymbol reason: aReasonString
"instance readers: name · kind · check (nil on missing) · missingReason (nil on resolved)"
```

`PGRConfigurationError` is the frozen `-SDK` error class, catchable by class;
kit-side signalling is its ruled grant (D-60): `PGRConfigurationError signal:
'...'`. Its message *text* is human-facing, not an API — tests assert the class
and that the message names the offender, never exact wording.

**Fixture** — `PCKInheritedSeverityStubRule` in `Phi-Coding-Kit-Tests-Rules`:
`ReNodeRewriteRule` subclass with class-side `ruleName` and `rationale` but
**no `severity`** (it inherits `#warning` — the exact illegal-when-registered
state D-41 names). `initialize` may match anything harmless (reuse the verified
`replace: '`@x isNil ifTrue: [`.@block]' with: '`@x ifNil: [`.@block]'`); class
comment says it is a test fixture, never registered outside tests.

**Test home — agent call, recorded in `chunks.md`, veto-open:** `PCKKitTest`
lives in `Phi-Coding-Kit-Tests-Rules`. The frozen E01 naming tree has no root
kit tests package, and creating one would edit the frozen baseline (forbidden
without a decision-sheet entry); `-Tests-Rules` is where the kit's E06
(lint-kind) behavior is exercised. E07 extends the class in place.

**Constitution rules that bite here:** glossary — *kit block*, *registration*,
*check* exactly; no global state (all class-side methods, no class-side
variables); strict parsing — malformed or unknown input raises a configuration
error, never a silent default (family 7); comments state constraints the code
cannot show; no `skip`/`expectedFailures`; a test that cannot fail is a defect.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export
to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present,
D-15); hand-writing class files is not allowed — the committed form must be what
the tooling emits. After export, a fresh `bash tools/build-image.sh` load from
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Coding-Kit/PCKKit.class.st`
- `src/Phi-Coding-Kit-Tests-Rules/PCKInheritedSeverityStubRule.class.st`
- `src/Phi-Coding-Kit-Tests-Rules/PCKKitTest.class.st`
- LOC budget: target 150 / ceiling 280.

## TESTS FIRST

Test methods on `PCKKitTest` (build blocks as `Dictionary`s with Symbol keys —
what the engine hands verbatim from the artifact's `#kits` array; no
configuration machinery exists yet, and none is needed: the kit contract takes
the block directly):

- `testLintRegistrationsFromBlock` — given block `{#kit → 'PCKKit'. #lintRules
  → #('PCKNoIsNilIfTrueRule' 'ReCodeCruftLeftInMethodsRule')}`, production
  `#('Phi-Guardrails-SDK')`, tests `#()` / when
  `registrationsFrom:productionPackages:testsPackages:` / then exactly 2 specs
  in block order named `'lint/PCKNoIsNilIfTrueRule'` and
  `'lint/ReCodeCruftLeftInMethodsRule'`, kinds `#lint`, each `check` a
  `PCKLintRuleCheck` whose `packages` equals the production list and whose
  `rule` is the named class — a built-in registers exactly like a catalog rule
  (§2.4).
- `testUnresolvedLintRuleAnswersMissingSpec` — given `#lintRules →
  #('PCKNoSuchRule')` / then exactly one spec: `name` =
  `'lint/PCKNoSuchRule'`, `kind` = `#lint`, `check` nil, `missingReason`
  containing `'PCKNoSuchRule'` (§1.5: missing, not an exception).
- `testUnknownBlockKeySignals` — given a block with key `#lintRulez` / then
  `PGRConfigurationError` is signalled and its message names `'lintRulez'`
  (strict validation, D-51).
- `testRuleWithoutOwnSeveritySignals` — given `#lintRules →
  #('PCKInheritedSeverityStubRule')` / then `PGRConfigurationError` naming the
  class — **P-SEVERITY-EXPLICIT (method name fixed by ch. 9)**: the inherited
  `#warning` is not a legal state for a registered rule; the kit raises when it
  opens its block, before any check runs.
- `testNonRuleClassSignals` — given `#lintRules → #('PGRFinding')` (loaded, no
  Renraku descent) / then `PGRConfigurationError` naming the class (§1.5's
  loaded-but-not-a-rule arm).

Fixtures: `PCKInheritedSeverityStubRule` (this chunk's own deliverable) · C13's
rule and C15's check (accepted).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 5 `PCKKitTest` methods plus
          every previously accepted suite — the 24 E01/E02 tests (19 SDK +
          5 smoke), all accepted E06 siblings, and any accepted parallel-track
          (E03) suites (regression guard; membership + floor, never an exact
          ceiling).

OUT OF SCOPE
- Spec production for `#architectureChecks` / `#metaRules` and `#layerMap`
  handling beyond key recognition (C17).
- `recommendedBlock` (C18).
- Behavioral-suite derivation (E07), any engine-side validation — conformance,
  kind agreement, duplicate names (E04), the configuration object (E03).
- Touching `package.st` files, the baseline, or anything outside the manifest.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files,
          one commit `C16: PCKKit block envelope and lint dispatch` before
          reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · the
  confirmed class-lookup spelling · deviations from the work order (each with
  one-line justification) · new questions for the decision sheet.
