# Quickstart 2 — Write your own check

*Audience: a developer adding a project-specific check (check author). Derived from
spec ch. 1 §1.3–§1.4, ch. 2 §2.2, ch. 3 §3.3, ch. 8 §8.1 step 3. Samples are
unexecutable until milestone **M1** and are marked ⟨verify⟩; at that milestone a test
executes each sample verbatim (spec ch. 9, P-GUIDE-EXEC).*

A check is anything the gate can run that answers one verdict. The contract is a
**protocol, not a superclass**: your class must answer the class-side constructor
`packages:` (the kit that names your check instantiates it with this, handing the
target package names — everything your check knows, it was given at construction;
`run` takes no arguments and pulls nothing), and instance-side `run` (→ a
`PGRVerdict`), `kind` (a `Symbol`), and `canFix` (a `Boolean`; `fixCommandOn:`
additionally, only when `canFix` is true). Conformance is validated loudly when the
registry is built — a registered class missing a selector is a configuration error
naming the class and the selector, never a strange mid-run failure. One agreement to
keep: the `kind` you answer must match the kind your block key implies
(`#architectureChecks` → `#architecture`); a mismatch is a configuration error at
registry build naming the registration, both kinds, and your class.

Your only dependency is the boundary package **`Phi-Guardrails-SDK`** — never the
engine — and it is development-scoped: your shipped product never depends on a
checking framework.

## 1 · With the skeleton

`PGRCheck` is an optional convenience superclass: it documents the protocol, defaults
`canFix` to false, and implements `packages:` for you — storing the handed list,
readable in your `run` as `self packages`. ⟨verify⟩

```smalltalk
PGRCheck << #AcmeClassCommentCheck
    package: 'Acme-Guardrails'

AcmeClassCommentCheck >> kind
    ^ #architecture

AcmeClassCommentCheck >> run
    | offenders findings |
    offenders := self packages flatCollect: [ :pkgName |
        (PackageOrganizer default packageNamed: pkgName) definedClasses
            select: [ :cls | cls comment isNil or: [ cls comment isEmpty ] ] ].
    findings := offenders collect: [ :cls |
        PGRFinding
            target: cls name
            message: 'class has no comment'
            rationale: 'Every published Acme class carries an intention comment;
                write one sentence on what the class is for.' ].
    ^ findings isEmpty
        ifTrue: [ PGRVerdict green ]
        ifFalse: [ PGRVerdict redFindings: findings ]
```

Registered in `#architectureChecks`, your check is handed the production-role package
names; registered in `#metaRules`, the tests-role names — the role your block key
implies.

The verdict constructors available to you: `PGRVerdict green` ·
`greenAdvisories:` (ran clean, with non-blocking notes) · `redFindings:` ·
`missingReason:` (you could not resolve your own target — never answer green for
"found nothing to check"). Findings: `PGRFinding target:message:` or
`target:message:rationale:`. Write the rationale as instructions to whoever sees the
red line — it is emitted with every finding. If the handed targets are malformed for
your check, signal `PGRConfigurationError` at construction — loud beats lenient.

## 2 · As a plain class — no ancestry required

The same check with no framework superclass registers identically; you then write
the constructor and `canFix` yourself: ⟨verify⟩

```smalltalk
Object << #AcmeClassCommentCheck
    package: 'Acme-Guardrails'

AcmeClassCommentCheck class >> packages: names
    ^ self new setPackages: names

AcmeClassCommentCheck >> kind      ^ #architecture
AcmeClassCommentCheck >> canFix    ^ false
AcmeClassCommentCheck >> run       "as above"
```

## 3 · The fixture pair — prove it fires, prove it stays silent

Every check earns its place with two committed fixtures and two named tests: a **bad
fixture** it must flag and a **good fixture** it must ignore. Without the bad half, a
check that never fires (a typo in your matching logic) reports green forever —
a rule finding nothing looks exactly like a rule with nothing to find. ⟨verify⟩

```smalltalk
AcmeClassCommentCheckTest >> testFiresOnBadFixture
    | verdict |
    verdict := (AcmeClassCommentCheck packages: #('Acme-Guardrails-Fixtures')) run.
    self deny: verdict isGreen.
    self assert: (verdict findings anySatisfy:
        [ :f | f target = 'AcmeUncommentedFixture' ])

AcmeClassCommentCheckTest >> testSilentOnGoodFixture
    self assert: (AcmeClassCommentCheck packages: #('Acme-Guardrails-GoodFixtures'))
        run isGreen
```

The convention is unenforced in v1 (a meta-rule making it machine-checkable is
scheduled — spec ch. 5 §5.5); write the pair anyway.

## 4 · Register it

One line in your own `guardrails.ston` kit block: ⟨verify⟩

```ston
#architectureChecks : [ 'PCKLayerMapCheck', 'AcmeClassCommentCheck' ]
```

Loading is not activation — the class sitting in your image runs nothing until the
file names it. The registration appears in every report as
`architecture/AcmeClassCommentCheck`.

**Lint rules are a different authoring path:** a lint check is a Renraku rule class
registered in `#lintRules` (spec ch. 2 §2.2 — Pharo's rule classes, AST patterns,
autofix via rewrite). One framework requirement binds them: a registered rule class
must implement class-side `severity` itself (`#error` blocks; `#warning` /
`#information` inform) — relying on the inherited default is a configuration error.

## 5 · Optional: the fix capability

A check that can safely repair what it flags declares it — and the declaration is a
pair: `canFix` answers true, and `fixCommandOn:` answers a **complete working fix
object** you own. Below is the whole thing for our running example — the fix object
first, then the two methods that wire it onto the check *(verified executable: the
M1 sample test runs this fence verbatim — D-76/D-77)*:

```smalltalk
Object << #AcmeCommentFix
    slots: { #packages. #pending. #previewed };
    package: 'Acme-Checks'

AcmeCommentFix class >> onPackages: names
    ^ self new setPackages: names

AcmeCommentFix >> setPackages: names
    packages := names.
    pending := OrderedCollection new.
    previewed := false

AcmeCommentFix >> previewOn: aStream
    pending := OrderedCollection new.
    packages do: [ :pkgName |
        ((PackageOrganizer default packageNamed: pkgName) definedClasses
            select: [ :cls | cls comment isEmpty ])
            do: [ :cls | pending add: cls ] ].
    pending do: [ :cls |
        aStream nextPutAll: cls name;
            nextPutAll: ' -> will gain the comment (was empty)'; cr ].
    previewed := true.
    ^ pending size

AcmeCommentFix >> apply
    previewed ifFalse: [ self error: 'preview first - the diff you saw is the diff that applies' ].
    pending do: [ :cls | cls comment: 'TODO: describe this class (written by AcmeCommentFix)' ].
    ^ pending

AcmeCommentFix >> changes
    ^ pending copy

AcmeClassCommentCheck >> canFix
    ^ true

AcmeClassCommentCheck >> fixCommandOn: packageNames
    ^ AcmeCommentFix onPackages: packageNames
```

That is the entire fix-invocation protocol, working: construct → `previewOn:` (emits
the before/after per target; mandatory — `apply` refuses without it) → `apply` →
`changes`. The kit's own `PCKFixCommand` adds what production fixes also need — the
staleness re-read (`PGRFixStale` when a target drifted between preview and apply,
nothing applied) — and three errors are catchable by class: `PGRNotAutofixable`
(the check has no fix), `PGRFixNotPreviewed` (`apply` before any preview),
`PGRFixStale`. The gate itself never invokes a fix; checking never mutates. See
spec ch. 3 §3.3 for the coding kit's reference implementation.

---
*Spec citations: ch. 1 §1.3 (protocol table, the `packages:` constructor,
verdict/finding constructors), §1.4 (conformance validation,
loading-is-not-activation) · ch. 2 §2.2/§2.2b (lint authoring, explicit severity) ·
ch. 3 §3.1–§3.3 (fixture-pair format, fix command) · ch. 4 §4.3 (client architecture
checks) · ch. 8 §8.1 step 3 (extension package, SDK-only, development-scoped). Ruling
trail (log numbers, for maintainers): D-41, D-53, D-54, D-59, D-60.*
