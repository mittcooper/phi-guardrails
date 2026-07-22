# Spec ch. 1 — The check registry

*Satisfies: R-01, R-02, R-03 (pointer), R-04, R-05, R-06, R-08, R-35, R-40, R-41, R-42 ·
D-01, D-07, D-16, D-17, D-18, D-21.*

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
| `#kits` | an **ordered array of kit blocks** (D-51): each block is a map naming its kit (`#kit : 'PGRCodingKit'`) and carrying that kit's **entire** configuration. **`#kit` is the block's only common field** (D-53) — everything else is kit-custom; a new common field requires a ruling and a schema bump. Blocks are opaque to the core and validated strictly by their kits — an unknown key *inside* a block is a configuration error raised by the kit. Array order is registry order | yes, ≥1 |
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
an unknown group expands to empty silently, D-25.a trap) · **any matcher expands to zero
baseline packages** (silence never assigns) · roles are not pairwise disjoint
after matcher expansion · **the scope law fails: some package the baseline defines falls
in no role, or in more than one** (this is what makes an unassigned new package a loud
failure instead of unguarded code — assignment moved to the config, D-45, but the
*inventory* is still the baseline's, D-25) · a production- or tests-role package is not
loaded in the
image · `#exemptNamePatterns`, when present, is violated in either direction · two
registrations derive the same registration name · **a `#lintRules` entry names a rule
class that does not itself implement class-side `severity`** (D-41 — an inherited
severity is not a legal state for a registered rule; ch. 2 §2.2b) · **a named, loaded
check class does not conform to its protocol** (D-53 — the error names the class and
the missing selector; conformance, not ancestry, is what registration requires, and it
is decided here, before any check runs) · a relative `#src`
in a directory-less (`fromString:`) configuration (D-47 — the error message names the
fix: absolute path, or load via `fromFile:`).

Expansion uses the verified Metacello API (D-25.a): the baseline's own packages from
`version packages` (dependency projects, `version projects`, are out of scope — the
framework never sweeps a client's dependencies), group membership from `version groups`,
group-named matchers via `version packagesForSpecNamed:`; package-name and pattern
matchers match (full-match, D-15) against the names in `version packages`. Only production- and tests-role
packages must be loaded: an exempt-role package absent from the image is not an error —
no check ever targets it, and role validation works on baseline introspection alone
(D-25.a). A configuration error aborts the run before any check executes:
exit nonzero, no report (a broken artifact must never look like a green build).

**Complete example — the toy client's artifact** (normative for schema, and the actual
committed toy artifact — in-repo it lives as class-side STON text, §8.2):

```ston
{
    #schemaVersion : 2,
    #project : 'Phi-Guardrails-Toy',
    #baseline : 'BaselineOfPhiGuardrailsToy',
    #roles : {
        #production : [ 'Phi-Guardrails-Toy-(Core|UI|Persistence|Rules)' ],
        #tests      : [ 'Phi-Guardrails-Toy-Tests' ] },
        "assignment from the config (a full-match pattern and a package name, D-45);
         the baseline's own role groups would work too — they are a convenience"

    #kits : [ {
        #kit : 'PGRCodingKit',
        #lintRules : [ 'PGRNoIsNilIfTrueRule',           "recommended block…"
                       'ReCodeCruftLeftInMethodsRule',   "…drafted by the init command"
                       'PGRToyNoIsNilIfFalseRule' ],     "the toy's own rule"
        #architectureChecks : [ 'PGRLayerMapCheck' ],
        #layerMap : {
            #layers : {
                'ui'          : [ 'Phi-Guardrails-Toy-UI' ],
                'domain'      : [ 'Phi-Guardrails-Toy-Core' ],
                'persistence' : [ 'Phi-Guardrails-Toy-Persistence' ] },
            #allowed : [ [ 'ui', 'domain' ], [ 'domain', 'persistence' ] ],
            #unlayered : [ 'Phi-Guardrails-Toy-Rules' ] },   "declared, D-35"
        #metaRules : [ 'PGRNoSkippedTestsMetaRule' ] } ]
}
```

Every check the toy runs is **named here** (D-51): the recommended coding-kit block —
composed by the init command at authoring time — contributed the first two lint rules
and the meta-rule; nothing arrives by default, and deleting a line is the only, fully
diffable, way to not run a check.

(The toy ships its own `BaselineOfPhiGuardrailsToy` — ch. 8 §8.2. The baseline owns the
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
| `PGRConfiguration` | the parsed, validated artifact | class: `fromString:`, `fromFile:` · instance: `project`, `kitClasses`, `kitBlocks` (ordered, verbatim — D-51), `baselineClass`, `productionPackageNames`, `testsPackageNames`, `exemptPackageNames` (all three derived from the baseline at validation time, D-25) | caller (construction, D-49); kit author (role-package accessors); `project`/`kitClasses`/`kitBlocks` internal (blocks are *handed* to kits, §1.4, not looked up) |
| `PGRRegistry` | the registrations of one run | class: `fromConfiguration:` · instance: `registrations` (ordered), `size` | internal |
| `PGRRegistrationSpec` | what a kit answers («value», `-SDK` vocabulary, D-54): name, kind, and either a conforming check instance or a missing-reason — *the boundary carries information; the engine owns mechanism* | class: `name:kind:check:`, `missing:kind:reason:` · instance: `name`, `kind`, `check`, `missingReason` | kit author (constructors) |
| `PGRRegistration` | one registry member (`-Core`, **fully internal** — the engine wraps each spec into one of these; residency resolved by D-54) | class: `fromSpec:` · instance: `name`, `kind`, `isResolved`, `run` → `PGRVerdict` | internal |
| `PGRCheck` | **optional skeleton** of the check *protocol* (D-53 — conformance, not ancestry; `-SDK`) | `run` → `PGRVerdict`, `kind`, and the fix capability (D-54): `canFix` (skeleton default **false**) + `fixCommandOn:` (required when `canFix`; answers an object conforming to the fix-invocation protocol — spellings veto-open, shape ruled) | check author |
| `PGRVerdict` | one registration's outcome («value», `-SDK` vocabulary) | class: `green`, `greenAdvisories:` (the sub-`#error` lint case, §2.3), `redFindings:`, `missingReason:`, `skipped` · instance: `status`, `findings`, `advisories`, `registrationName`, `kind`, `durationMillis`, `isGreen` (`scope` removed, D-51) | check author (constructors); caller (reading, D-49) |
| `PGRFinding` | one violation / advisory («value», `-SDK` vocabulary) | class: `target:message:` , `target:message:rationale:` · instance: `target`, `message`, `rationale`, `printOn:` | check author (constructors); caller (reading, D-49) |
| `PGRKit` | **optional skeleton** of the kit *protocol* (all class-side; kits are stateless; `-SDK`) | `kitName` · `registrationsFrom:productionPackages:testsPackages:` (its verbatim block + the resolved role lists — **never the configuration object**, D-53) → ordered collection of `PGRRegistrationSpec` (D-54) · `recommendedBlock` (the published stanza, single-sourced on the class — the init tool composes from it, docs quote it, D-54; property P-STANZA-VALID) — the whole contract, three messages | kit author |
| `PGRConfigurationError` | artifact defect («value», `-SDK` vocabulary) | an `Error` subclass carrying a one-line reason | caller (catchable by class, D-49); its message *text* is human-facing, not an API |
| `PGRConfigurationDraft` | the init tool (authoring-time only; `-Core`; D-53 — `PGRConfiguration` is purely run-time) | class: `draftFor:` (a baseline name) → draft STON text composing the kits' published stanzas | config author |

`PGRGate` and `PGRReport` live in `Phi-Guardrails-Gate` and are specified in chapter 7.
The kit class `PGRCodingKit` lives in `Phi-Guardrails-Coding` (D-17).

**Registration names** are deterministic: `<kind>/<discriminator>`, where the
discriminator is the check class name for class-registered entries and the package name
for derived behavioral-suite registrations (D-25). Examples: `lint/PGRNoIsNilIfTrueRule`,
`architecture/PGRLayerMapCheck`, `behavioral/Phi-Guardrails-Toy-Tests`,
`behavioral/PGRNoSkippedTestsMetaRule`. Two identical names
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
2. Per block: **validate conformance first** (D-53) — every check class the block names
   that is loaded must respond to its protocol; a nonconforming class is a
   configuration error naming the class and the missing selector, before any check
   runs. Then hand the block **verbatim** to its kit —
   `registrationsFrom: block productionPackages: names testsPackages: names` (the
   resolved role lists the behavioral derivation needs, D-25; **kits never receive the
   configuration object** — over-reach is impossible, not caught, D-53). The kit
   validates its block strictly — an unknown key inside it is a configuration error the
   *kit* raises — and answers one **`PGRRegistrationSpec`** per entry (D-54): carrying
   a live check bound to its targets, or a missing-reason string; never fewer specs
   than its block names. **The engine wraps each spec into its internal
   `PGRRegistration`** — resolution state, `run`, verdict production stay engine-side,
   unreferenced by kits.
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
error description (D-21); the registration stamps name/kind/scope/duration. No v1 code
path emits a `skipped` verdict: a completed run never does (an erroring check is red, so
the run loop cannot abort), and v1 ships no partial-run reporter — the constructor exists
so the verdict vocabulary stays total over P6's states; its only legitimate producer is
report construction over a partially-run registry (D-21). The core never
interprets section contents — only kinds and verdicts. The agent under check has no
interface to select, weaken, or reorder any of this (R-08): the only input is the artifact,
and the artifact is diffable in git.

## 1.5 Missing semantics, per kind (R-06, R-24 via ch. 5)

| Kind | Registration source | **Missing** when |
|---|---|---|
| `#lint` | `#lintRules` class name | the name resolves to no loaded class, or the class is not a lint rule class (a descendant of the Renraku rule base, ch. 2 §2.2) |
| `#architecture` | `#architectureChecks` class name | the name resolves to no loaded class (a loaded but *nonconforming* class is a configuration error at construction instead, D-53); **or** its required `#layerMap` block key is absent (D-51: inside the kit's block); or the map names an unloaded package |
| `#behavioral` (suite) | one tests-role package (D-25) | the package contains zero test classes (§5.2); *an empty tests-role expansion yields one missing registration `behavioral/tests-role`* |
| `#behavioral` (meta) | `#metaRules` class name | the name resolves to no loaded class (nonconforming-when-loaded is a configuration error at construction, D-53; the tests role itself is mandatory at validation, §1.1 — a test-discipline check always has suites to judge or the run never starts) |

*The `#architecture` missing-condition encodes the v1 checks' parameter need
(`#layerMap`) rather than a generic required-keys protocol — a deliberate v1 trade
(D-32); a future check with different parameters amends its row.*

Missing is a verdict, not an exception: the run completes, the report shows precisely what
was missing and why, and the gate exits nonzero (P6).

## 1.6 Promotion, reworded (R-03 — v1-widen; D-07 as amended by D-51)

Promoting a client check means **inclusion in the kit's recommended block** — a
documented template, not a mechanism: move the class from the client's extension package
into the kit's shipped package, move its fixture pair into the kit's test package, and
add the entry to the kit's documented recommended block, so future adopters' init drafts
include it. Existing adopters see no change until they edit their own file — composition
over defaults (D-51). No tooling in v1.
