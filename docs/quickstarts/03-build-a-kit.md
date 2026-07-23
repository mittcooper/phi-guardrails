# Quickstart 3 — Build a kit

*Audience: a developer packaging checks for a new domain (kit author). Derived from
spec ch. 1 §1.3–§1.4, ch. 0 §0.1/§0.3. Samples are unexecutable until milestone
**M1** and are marked ⟨verify⟩; at that milestone a test executes each sample
verbatim (spec ch. 9, P-GUIDE-EXEC).*

A kit is a loadable package family that teaches the gate a new domain: its check
classes, the engines they drive, and one composable configuration block. The
framework's core never learns your domain — it hands your block to your kit verbatim
and takes back registrations. Your kit's only framework dependency is
**`Phi-Guardrails-SDK`**; referencing the engine (`Phi-Guardrails-Core`, `-Gate`) is
an architecture violation the framework's own layer map rejects for resident kits,
and the standing rule for external ones.

## 1 · Name your family

The naming law is symmetry between package family and class prefix, in both
directions — pick a prefix disjoint from `PGR` and `PCK`:

```
Demo-Kit            the kit class
Demo-Kit-Checks     your check classes and engines
Demo-Kit-Tests-*    the mirroring tests
```

with every class prefixed `DK` (`DKKit`, `DKClassCommentCheck`, …).

## 2 · The kit class — two messages, both class-side

The kit contract is a protocol; `PGRKit` is its optional skeleton. Kits are
stateless, and your class name is your identity — it is what a project's `#kit`
field names. ⟨verify⟩

```smalltalk
PGRKit << #DKKit
    package: 'Demo-Kit'

DKKit class >> recommendedBlock
    ^ '{ #kit : ''DKKit'', #docChecks : [ ''DKClassCommentCheck'' ] }'

DKKit class >> registrationsFrom: block productionPackages: prodNames testsPackages: testNames
    | unknown |
    unknown := block keys reject: [ :k | #(#kit #docChecks) includes: k ].
    unknown ifNotEmpty: [
        PGRConfigurationError signal: 'unknown key in Demo kit block: '
            , unknown anyOne printString ].
    ^ (block at: #docChecks ifAbsent: [ #() ]) collect: [ :name |
        (self class environment at: name asSymbol ifAbsent: [ nil ])
            ifNil: [ PGRRegistrationSpec
                        missing: 'doc/' , name kind: #doc
                        reason: 'name resolves to no loaded class' ]
            ifNotNil: [ :cls | PGRRegistrationSpec
                        name: 'doc/' , name kind: #doc
                        check: (cls packages: prodNames) ] ]
```

What each message is for:

- **`recommendedBlock`** — your published stanza, answered as STON text: the starter
  block the init command composes into adopters' drafts and your documentation
  quotes. It is single-sourced here, and a framework test (P-STANZA-VALID) keeps it
  honest: every check it names must resolve, register, and conform.
- **`registrationsFrom:productionPackages:testsPackages:`** — the working message.
  You receive your **verbatim block** plus the resolved production- and tests-role
  package name lists — never the configuration object, so over-reach is structurally
  impossible. Your duty: validate your block strictly (an unknown key inside it is a
  `PGRConfigurationError` **you** raise) and resolve every name inside it, answering
  one `PGRRegistrationSpec` per entry — never fewer than your block names: a live
  check instance (`name:kind:check:` — instantiate a class you don't own via its
  promised `packages:` constructor, as above) or the reason it cannot run
  (`missing:kind:reason:`). Silence is never an option; a spec you don't answer is a
  check that silently doesn't run, which the contract forbids.

The order of your answered specs is registry order for your kit — make it stable and
meaningful (cheap checks first is the house pattern).

## 3 · Registration names and kinds

Name each spec `<kind>/<discriminator>` — the check class name, or the target name
for derived registrations. Names must be unique per configuration; duplicates are a
configuration error, not a dedupe. Your kind symbols are your own vocabulary
(`#doc` above): the core treats kinds as opaque labels — but the kind you put in a
spec must equal what the spec's check instance itself answers for `kind`; the engine
validates the agreement when the registry is built, and a mismatch is a configuration
error naming the registration, both kinds, and the class. A missing-spec keeps the
kind you gave it (there is no check to ask).

## 4 · What adopters do with it

An adopter composes your block into their `guardrails.ston` beside any other kit's —
blocks are self-contained, ordered, and independently validated: ⟨verify⟩

```ston
#kits : [
    { #kit : 'PCKKit', #lintRules : [ 'PCKNoIsNilIfTrueRule' ] },
    { #kit : 'DKKit',  #docChecks : [ 'DKClassCommentCheck' ] } ]
```

Nothing about your kit runs anywhere until a project's file names it — shipping a kit
grants no enforcement, and a kit upgrade can never change an adopter's enforcement
without a visible diff in the adopter's own repo.

## 5 · What you ship

Five things make a complete kit: the check classes · the engines they need (your
packages only — engine vocabulary never crosses into the core) · the
`recommendedBlock` stanza · your block schema, strictly validated by you · a
bad/good fixture pair for every shipped check, with named tests (see Quickstart 2 §3).

---
*Spec citations: ch. 1 §1.3 (kit protocol row, `PGRRegistrationSpec`), §1.4 (kit
contract and duty, registry construction, spec-level validation), §1.1 (`#kits`
envelope) · ch. 0 §0.1 (component map, symmetry law, first-kit stance), §0.3
(kit-author SDK) · ch. 4 §4.4 (the layer edges). Ruling trail (log numbers, for
maintainers): D-51, D-53, D-54, D-56, D-57, D-59, D-60.*
