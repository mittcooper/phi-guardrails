# Spec ch. 1 — The check registry

*Satisfies: R-01, R-02, R-03 (pointer), R-04, R-05, R-06, R-08, R-35, R-40, R-41, R-42,
R-47 · D-01, D-07, D-16, D-17, D-21, D-45, D-47, D-49, D-51, D-53, D-54 (D-18 was
superseded in full by D-51 — §8.2 cites it only as technique provenance).*

## 1.1 The configuration artifact

A client declares everything the framework enforces in **one** file: `guardrails.ston`
(D-16, D-07, as amended by D-45). **The file lives wherever the caller says:**
`fromFile:` and `runHeadless:` take an explicit path — there is no repo-root convention
and no working-directory default — and the config need not live in the target repo at
all (checking a repo you don't control is a supported case). In-repo at the root remains
the *recommended* default for projects that own their config: it versions with the code.
It is pure-data STON: one map with `Symbol` keys; values are strings, integers, lists,
and nested maps — no class-tagged STON objects.

**Core-owned keys** (present in every project artifact). **Inventory from the baseline,
assignment from the configuration** (D-25 as amended by D-45): the baseline remains the
product's only package *inventory* — no matcher can conjure a package the baseline does
not define — while the artifact assigns each package its *role* directly; role groups in
the client's baseline are an optional convenience, never a requirement.

| Key | Value | Required |
|---|---|---|
| `#schemaVersion` | the artifact schema version (Integer; v1 writes `2` — the per-kit-blocks ruling D-51 was the schema's first breaking change under the D-49 policy; version 1 was the never-shipped pre-D-51 draft and is refused as unknown). The gate reads its own version **and older shipped ones**; a *newer* version is refused with a clear configuration error rather than misinterpreted — tool and target repos version independently (D-45). **Versioning policy (D-49 — this chapter owns it):** *every* schema change bumps the version — under strict validation there is no "compatible" change (an unknown key is already an error, so even an addition breaks older gates) | yes |
| `#project` | the project's display name (String) | yes |
| `#kits` | an **ordered array of kit blocks** (D-51): each block is a map naming its kit (`#kit : 'PCKKit'`) and carrying that kit's **entire** configuration. **`#kit` is the block's only common field** (D-53) — everything else is kit-custom; a new common field requires a ruling and a schema bump. Blocks are opaque to the core and validated strictly by their kits — an unknown key *inside* a block is a configuration error raised by the kit. Array order is registry order | yes, ≥1 |
| `#baseline` | the name of the client's loaded `BaselineOf` subclass — the package inventory checks run against | yes |
| `#roles` | map: role → list of **matchers**. Each matcher is a baseline group name, a package name, or a full-match regex over the baseline's packages (resolution order: baseline group name first, else package name / pattern; a string that is both a group name and a package name is a configuration error — D-45, agent-detail veto-open). Exactly the roles `#production` (checked by lint and architecture), `#tests` (behavioral suites), and optionally `#exempt` (never targeted by any check — demo clients, red fixtures) | yes (`#production` and `#tests` mandatory) |
| `#src` | the source root the dead-src check walks (String path), interpreted **relative to the config file's own directory** (D-45 ruling 2). A **relative** `#src` in a configuration with no anchoring directory (`fromString:`) is a **configuration error naming the fix** — use an absolute path, or load via `fromFile:` (D-47); absence never falls back to the working directory | optional — required only by a registered check that consumes it (the §1.5 parameter pattern) |
| `#exemptNamePatterns` | regex list, **full-match** against package names (`matchesRegex:` semantics, D-15; D-25 residual 1): every exempt-role package name must match one; no production/tests-role package name may match any | optional |

There are **no other top-level keys** (D-51): each kit's entire configuration lives
inside its `#kits` block, and an unknown top-level key is a configuration error — the
core owns the whole envelope. The framework never names a client:
nothing in core or kit code refers to any project (R-05); the artifact is the only place
the client is known (R-02).

**Strict validation** (D-16 as amended by D-25; family 7). `PGRConfiguration
class>>fromString:` / `fromFile:` signal `PGRConfigurationError` when: the top level is
not a map with Symbol keys · **the `#schemaVersion` is newer than the gate's own**
(refused with a message naming both versions, D-45) · a core key is absent or of the
wrong shape · an unknown top-level key (the core owns the whole envelope, D-51) · a
block's `#kit` does not resolve to a loaded `PGRKit` subclass · the
`#baseline` name does not resolve to a loaded `BaselineOf` subclass · a group-named
matcher names a group absent from the baseline's `groups` (checked *before* expansion —
an unknown group expands to empty silently, D-25.a trap) · roles are not pairwise disjoint
after matcher expansion · **the scope law fails: some package the baseline defines falls
in no role, or in more than one** (this is what makes an unassigned new package a loud
failure instead of unguarded code — assignment moved to the config, D-45, but the
*inventory* is still the baseline's, D-25) · a production- or tests-role package is not
loaded in the
image · `#exemptNamePatterns`, when present, is violated in either direction · two
registrations derive the same registration name · a relative `#src`
in a directory-less (`fromString:`) configuration (D-47 — the error message names the
fix: absolute path, or load via `fromFile:`).

Expansion uses the verified Metacello API (D-25.a): the baseline's own packages from
`version packages` (dependency projects, `version projects`, are out of scope — the
framework never sweeps a client's dependencies), group membership from `version groups`,
group-named matchers via `version packagesForSpecNamed:`; package-name and pattern
matchers match (full-match, D-15) against the names in `version packages`. **A matcher
expanding to zero packages is not itself an error** (D-47, D-25.a): its consequences are
what the machinery catches — packages a typo'd pattern *meant* to cover sit in no role
and the scope law fires, and an empty tests-role expansion fails at run time as the
missing registration `behavioral/tests-role` (R-24, §1.5, ch. 5 §5.1). An empty group is
a legal baseline fact (D-25.a — `BaselineOfPCKFixture`'s empty `production` group
depends on it, ch. 5 §5.5). Only production- and tests-role
packages must be loaded: an exempt-role package absent from the image is not an error —
no check ever targets it, and role validation works on baseline introspection alone
(D-25.a). A configuration error aborts the run before any check executes:
exit nonzero, no report (a broken artifact must never look like a green build).

**Two validation stages, one entry point (D-41 × D-51 × D-53 × D-60, reconciled):**
the list above is the **envelope** — validated by `fromString:`/`fromFile:`, which
never open kit blocks (opaque to the core, D-51). **Blocks are opened exactly once, at
registry construction** (`PGRRegistry fromConfiguration:`, reached through
`PGRGate class>>forConfiguration:` — so still "before any check runs", D-41's letter):
each kit strictly validates its own block there (unknown key → configuration error,
raised by the kit) and resolves the names inside it, answering missing-specs or
raising `PGRConfigurationError`; the construction machinery then validates **every
resolved spec's check instance** — protocol conformance plus kind agreement — never
block contents (D-60; the error names the registration and the class, with the
missing selector or both kinds); and the coding kit enforces D-41 in the same pass — a
`#lintRules` entry naming a rule class without its own class-side `severity` is a
configuration error the *kit* raises (ch. 2 §2.2b). Both stages complete before any
check executes.

**Complete example — the toy client's artifact** (normative for schema, and the actual
committed toy artifact — in-repo it lives as class-side STON text, §8.2):

```ston
{
    #schemaVersion : 2,
    #project : 'Toy',
    #baseline : 'BaselineOfToy',
    #roles : {
        #production : [ 'Toy-(Core|UI|Persistence|Rules)' ],
        #tests      : [ 'Toy-Tests' ] },
        "assignment from the config (a full-match pattern and a package name, D-45);
         the baseline's own role groups would work too — they are a convenience"

    #kits : [ {
        #kit : 'PCKKit',
        #lintRules : [ 'PCKNoIsNilIfTrueRule',           "recommended block…"
                       'ReCodeCruftLeftInMethodsRule',   "…drafted by the init command"
                       'ToyNoIsNilIfFalseRule' ],     "the toy's own rule"
        #architectureChecks : [ 'PCKLayerMapCheck' ],
        #layerMap : {
            #layers : {
                'ui'          : [ 'Toy-UI' ],
                'domain'      : [ 'Toy-Core' ],
                'persistence' : [ 'Toy-Persistence' ] },
            #allowed : [ [ 'ui', 'domain' ], [ 'domain', 'persistence' ] ],
            #unlayered : [ 'Toy-Rules' ] },   "declared, D-35"
        #metaRules : [ 'PCKNoSkippedTestsMetaRule' ] } ]
}
```

Every check the toy runs is **named here** (D-51): the recommended coding-kit block —
composed by the init command at authoring time — contributed the first two lint rules
and the meta-rule; nothing arrives by default, and deleting a line is the only, fully
diffable, way to not run a check. The quoted annotations in this rendering are for the
reader only: **the committed `guardrailsSTON` text carries no comments** — STON's
comment support is unverified, and nothing may depend on it (P5).

(The toy ships its own `BaselineOfToy` — ch. 8 §8.2. The baseline owns the
*inventory* (D-25): the matchers above can only assign roles to packages the baseline
defines, and any baseline package they miss is a loud configuration error.)

## 1.2 One scope: the file (D-51 — supersedes the two-scope model)

Every check kind accepts registrations from exactly one place: the project's
`guardrails.ston` (R-01 as amended by D-51). **The file is the complete, diffable
statement of what runs.** Kits ship no catalog, the core performs no merge, and a
framework upgrade cannot change a project's enforcement without a visible diff in that
project's own repo — P6 strengthened. A "default check set" is a **recommended block**:
the kit's documented, pre-written block template, composed into the file at authoring
time by hand or by the init command (§8.1); once composed it is ordinary project
configuration, owned like every other line. Exclusion needs no mechanism (D-24 is
moot): a check not written runs not — and the trade is stated honestly: a hand-written
minimal config is minimally checked.

## 1.3 The core object model

Split across two packages since D-53: **`Phi-Guardrails-SDK`** holds the published
boundary (protocol declarations, the two optional skeletons, the frozen vocabulary);
**`Phi-Guardrails-Core`** holds the engine. No global state anywhere: each object is
constructed per run, passed explicitly, inspectable (R-35).

| Class | Role | Protocol (the M1 freeze binds **public-surface** members, ch. 0 §0.3/D-48; the rest is *specified but internal* — changeable without notice) | Surface (D-48) |
|---|---|---|---|
| `PGRConfiguration` | the parsed, validated artifact | class: `fromString:`, `fromFile:` · instance: `project`, `kitClasses`, `kitBlocks` (ordered, verbatim — D-51), `baselineClass`, `productionPackageNames`, `testsPackageNames`, `exemptPackageNames` (all three derived from the baseline at validation time, D-25) | caller (construction, D-49); **everything else internal** — the role-package accessors left the kit-author surface with D-54 (role lists are handed to kits as `registrationsFrom:productionPackages:testsPackages:` arguments; kits never see this object), and blocks are *handed* to kits (§1.4), not looked up |
| `PGRRegistry` | the registrations of one run | class: `fromConfiguration:` · instance: `registrations` (ordered), `size` | internal |
| `PGRRegistrationSpec` | what a kit answers («value», `-SDK` vocabulary, D-54): name, kind, and either a conforming check instance or a missing-reason — *the boundary carries information; the engine owns mechanism* | class: `name:kind:check:`, `missing:kind:reason:` · instance: `name`, `kind`, `check`, `missingReason` | kit author (constructors) |
| `PGRRegistration` | one registry member (`-Core`, **fully internal** — the engine wraps each spec into one of these; residency resolved by D-54) | class: `fromSpec:` · instance: `name`, `kind`, `isResolved`, `run` → `PGRVerdict` | internal |
| `PGRCheck` | **optional skeleton** of the check *protocol* (D-53 — conformance, not ancestry; `-SDK`) | class: **`packages:`** (D-60, spelling veto-open) — the promised constructor: the kit that names a check instantiates it, handing the target package names at construction; `run` stays argument-less and a check never pulls context — everything it knows, it was given; the skeleton stores the list and exposes it to subclasses (instance reader `packages`, an agent detail) · instance: `run` → `PGRVerdict`, `kind`, and the fix capability (D-54): `canFix` (skeleton default **false**) + `fixCommandOn:` (required when `canFix`; takes the fix target — packages, the same target language as ch. 3 §3.3 — and answers an object conforming to the fix-invocation protocol; spellings veto-open, shape ruled) | check author |
| `PGRVerdict` | one registration's outcome («value», `-SDK` vocabulary) | class: `green`, `greenAdvisories:` (the sub-`#error` lint case, §2.3), `redFindings:`, `missingReason:`, `skipped` · instance: `status`, `findings`, `advisories`, `registrationName`, `kind`, `durationMillis`, `isGreen` (`scope` removed, D-51) | check author (constructors — **except `skipped`: engine-only**, partial-run report construction, D-21/D-32; deliberately absent from the Check-author SDK and both diagrams); caller (reading, D-49) |
| `PGRFinding` | one violation / advisory («value», `-SDK` vocabulary) | class: `target:message:` , `target:message:rationale:` · instance: `target`, `message`, `rationale`, `printOn:` (rendering — human-facing text, explicitly not an API and on no surface, D-48; the freeze does not bind it) | check author (constructors); caller (reading, D-49 — `printOn:` excluded) |
| `PGRKit` | **optional skeleton** of the kit *protocol* (all class-side; kits are stateless; `-SDK`) | `registrationsFrom:productionPackages:testsPackages:` (its verbatim block + the resolved role lists — **never the configuration object**, D-53) → ordered collection of `PGRRegistrationSpec` (D-54) · `recommendedBlock` (the published stanza, single-sourced on the class, answering **STON text** — the init tool composes that text into the draft, docs quote it, D-54/D-60; property P-STANZA-VALID) — the whole contract, **two messages** (`kitName` dropped by D-60: no consumer existed; the class name is the identity, and block resolution already uses it) | kit author |
| `PGRConfigurationError` | artifact defect («value», `-SDK` vocabulary) | an `Error` subclass carrying a one-line reason | caller (catchable by class, D-49); kit author and check author (signalling side, D-60 — a kit that cannot resolve or validate its own block, and a check whose construction-time parameters are invalid, raise it); its message *text* is human-facing, not an API |
| `PGRConfigurationDraft` | the init tool (authoring-time only; `-Core`; D-53 — `PGRConfiguration` is purely run-time) | class: `draftFor:` (a baseline name) → draft STON text composing the kits' published stanzas | config author |

`PGRGate` and `PGRReport` live in `Phi-Guardrails-Gate` and are specified in chapter 7.
The kit class `PCKKit` lives in `Phi-Coding-Kit` (D-17).

**Registration names** are deterministic: `<kind>/<discriminator>`, where the
discriminator is the check class name for class-registered entries and the package name
for derived behavioral-suite registrations (D-25). Examples: `lint/PCKNoIsNilIfTrueRule`,
`architecture/PCKLayerMapCheck`, `behavioral/Toy-Tests`,
`behavioral/PCKNoSkippedTestsMetaRule`. Two identical names
in one configuration (the same rule listed twice) are a
configuration error, not a silent dedupe.

## 1.4 The kit contract and the run flow (R-40, R-42)

A kit supplies, per R-40 (as amended by D-51): (i) check classes implementing
`PGRCheck`'s contract; (ii) the engines they drive (kit packages only — engine classes
never appear in core, R-04); (iii) its **recommended block** — the documented template
the init command drafts from (a template, not a mechanism: once composed it is ordinary
project configuration, §1.2); (iv) its **block schema** — the keys its block accepts,
validated strictly by the kit itself; (v) fixture pairs for every shipped check.

**Loading is not activation** (R-41): loading kit packages registers nothing. A check
runs only because the project's own file names it. **Registry construction**
(`PGRRegistry fromConfiguration:`):

1. For each block in the artifact's `#kits` array, resolve the block's `#kit` class
   (failure → configuration error).
2. Per block: hand the block **verbatim** to its kit —
   `registrationsFrom: block productionPackages: names testsPackages: names` (the
   resolved role lists the behavioral derivation needs, D-25; **kits never receive the
   configuration object** — over-reach is impossible, not caught, D-53). **The kit's
   stated duty (D-60):** validate its block strictly — an unknown key inside it is a
   configuration error the *kit* raises — and resolve every name inside its own
   block, answering missing-specs for what cannot run or raising
   `PGRConfigurationError` for what is malformed. The kit instantiates the checks it
   names: its own classes however it likes (the parameterized v1 checks take their
   block parameter keys, §1.5); a named class it does not own via the **promised
   constructor** `packages:` (D-60), handing the role list its block key implies
   (`#architectureChecks` → production-role, `#metaRules` → tests-role); a named
   class answering neither path is a configuration error the kit raises. It answers
   one **`PGRRegistrationSpec`** per entry (D-54): carrying a live check bound to its
   targets, or a missing-reason string; never fewer specs than its block names.
   **The engine then validates every resolved spec's check instance** — protocol
   conformance (D-53: the error names the class and the missing selector) and **kind
   agreement** (D-60: the spec's kind must equal the check's own `kind`; mismatch is
   a configuration error naming the registration, both kinds, and the check class;
   missing-specs keep their explicit kind — no check exists to ask) — **on specs,
   never on block contents**, so blocks stay opaque and resident and external kits
   share one validation path. **The engine wraps each validated spec into its
   internal `PGRRegistration`** — resolution state, `run`, verdict production stay
   engine-side, unreferenced by kits.
3. Concatenate registrations in `#kits` array order; within a kit, in the kit's
   canonical order. Reject duplicate names.

A kit's *registration order* is normative. The coding kit's block schema is,
canonically: `#kit` · `#lintRules` · `#architectureChecks` · `#layerMap` · `#metaRules`
(behavioral suites have no block key — their targets are the configuration's tests-role
packages, D-25). The kit emits registrations in run order:
lint → architecture → **behavioral suites (one per tests-role package)** → meta-rules;
the suites-before-meta-rules order keeps duration attribution and report reading
honest — correctness no longer rests on it (the run cache pulls per package, §5.3/§5.4,
D-36).

**Run flow** (R-42): the gate iterates the registry in order; each registration's `run`
answers its verdict — a missing registration answers a missing verdict; a resolved one
delegates to its check, converting an unhandled exception into a red verdict carrying the
error description (D-21); the registration stamps name/kind/duration (the `scope` field
left with the two-scope model, D-51). No v1 code
path emits a `skipped` verdict: a completed run never does (an erroring check is red, so
the run loop cannot abort), and v1 ships no partial-run reporter — the constructor exists
so the verdict vocabulary stays total over P6's states; its only legitimate producer is
report construction over a partially-run registry (D-21). The core never
interprets block contents — only kinds and verdicts. The agent under check has no
interface to select, weaken, or reorder any of this (R-08): the only input is the artifact,
and the artifact is diffable in git.

## 1.5 Missing semantics, per kind (R-06, R-24 via ch. 5)

| Kind | Registration source | **Missing** when |
|---|---|---|
| `#lint` | `#lintRules` class name | the name resolves to no loaded class (a loaded class that is *not* a lint rule class — no Renraku descent, ch. 2 §2.2 — is a configuration error at construction instead, the same D-53 regime as the other kinds, checked in the same kit pass as D-41's severity rule) |
| `#architecture` | `#architectureChecks` class name | the name resolves to no loaded class (a loaded but *nonconforming* class is a configuration error at construction instead, D-53); **or** a parameter the named check requires is absent — `#layerMap` for `PCKLayerMapCheck` (D-51: inside the kit's block), `#src` for `PCKSrcInventoryCheck` (an envelope key, §1.1; D-45) — or the map names an unloaded package |
| `#behavioral` (suite) | one tests-role package (D-25) | the package contains zero test classes (§5.2); *an empty tests-role expansion yields one missing registration `behavioral/tests-role`* |
| `#behavioral` (meta) | `#metaRules` class name | the name resolves to no loaded class (nonconforming-when-loaded is a configuration error at construction, D-53; the tests role itself is mandatory at validation, §1.1 — a test-discipline check always has suites to judge or the run never starts) |

*The `#architecture` missing-conditions encode the v1 checks' parameter needs
(`#layerMap`, `#src`) rather than a generic required-keys protocol — a deliberate v1
trade (D-32; the row was amended once already when D-45's inventory check arrived); a
future check with different parameters amends it again.*

Missing is a verdict, not an exception: the run completes, the report shows precisely what
was missing and why, and the gate exits nonzero (P6).

## 1.6 Promotion, reworded (R-03 — v1-widen; D-07 as amended by D-51)

Promoting a client check means **inclusion in the kit's recommended block** — a
documented template, not a mechanism: move the class from the client's extension package
into the kit's shipped package, move its fixture pair into the kit's test package, and
add the entry to the kit's documented recommended block, so future adopters' init drafts
include it. Existing adopters see no change until they edit their own file — composition
over defaults (D-51). No tooling in v1.
