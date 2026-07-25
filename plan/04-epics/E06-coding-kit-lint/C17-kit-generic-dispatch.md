# C17 · PCKKit: generic paths for the remaining keys      [E06 · depends: C16 · parallel: no]

GOAL      Complete E06's dispatch: `#architectureChecks` and `#metaRules` names
          resolve via the promised `packages:` constructor with role-by-block-key,
          unresolved names answer missing-specs, `#layerMap` is a recognized
          no-registration parameter key, and the answered order is lint →
          architecture → meta.

TRACE     ch. 1 §1.4 (promised constructor, role-by-block-key, canonical order,
          "never fewer specs than its block names") · §1.5 (`#architecture` and
          `#behavioral`-meta missing rows) · §1.3 (names `architecture/<Class>`,
          `behavioral/<Class>`) · D-60 · roadmap §2 preamble ("dispatch laid
          down complete in E06; E07 and E10 each fill exactly one kind-specific
          builder").

## CONTEXT DIGEST

**What exists when this chunk starts:** C16 accepted — `PCKKit` (package
`Phi-Coding-Kit`, all class-side) whose
`registrationsFrom:productionPackages:testsPackages:` validates the block
envelope (five keys recognized: `#kit` · `#lintRules` · `#architectureChecks` ·
`#layerMap` · `#metaRules`; unknown key → `PGRConfigurationError`) and answers
the `#lintRules` specs. C15's `PCKLintRuleCheck`. The E02-frozen SDK (below).

**The two list keys, generic path** (ch. 1 §1.4): the kit instantiates its own
classes however it likes — but at E06 the kit owns no architecture or behavioral
check classes (`PCKLayerMapCheck` is E10's, `PCKTestSuiteCheck` /
`PCKNoSkippedTestsMetaRule` are E07's). Every resolved name therefore takes the
**promised-constructor path**: "a named class it does not own via the promised
constructor `packages:` (D-60), handing the role list its block key implies
(`#architectureChecks` → production-role, `#metaRules` → tests-role); a named
class answering neither path is a configuration error the kit raises."

Per name, in block order:

- **`#architectureChecks`**: unresolved → `PGRRegistrationSpec missing:
  'architecture/' , name kind: #architecture reason:` (one line naming the
  name). Resolved and its class side answers `packages:` — detection: `cls
  respondsTo: #packages:` (a *class* receiving `respondsTo:` asks its
  metaclass, inherited implementations included — inheriting from `PGRCheck` is
  the normal case) → spec `name: 'architecture/' , name kind: #architecture
  check: (cls packages: productionNames)`. Resolved but no class-side
  `packages:` → `PGRConfigurationError` naming the class (the neither-path
  arm). This reflective conformance probe on a configuration-named class is the
  same validation family the engine uses (D-53/D-60) — it is not the
  constitution's banned type-predicate dispatch; say so in a method comment.
- **`#metaRules`**: identical pipeline with `testsNames` as the handed role,
  names `'behavioral/' , name`, kind `#behavioral` (§1.3's example:
  `behavioral/PCKNoSkippedTestsMetaRule`).
- Shape rule from C16 extends: each present list key must be a collection of
  strings, else `PGRConfigurationError` naming the key.

**Kind-specific builders are deliberately absent here** (roadmap: E07 fills
behavioral — suite derivation from tests-role packages plus any meta-rule
special-casing; E10 fills architecture — the `#layerMap` parameter and §1.5's
parameter-missing row). Do not implement §1.5's "`#layerMap` absent →
`PCKLayerMapCheck` missing" logic — that arrives with the class it describes.

**`#layerMap`**: recognized (C16 already tolerates the key); produces no
registrations and no error at this epic — a present map is simply carried,
unread. Its shape validation and consumption are E10's.

**Order law** (ch. 1 §1.4, frozen at E06 acceptance): the answered collection is
all lint specs, then all architecture specs, then all meta specs — in-key block
order preserved. E07 inserts the derived behavioral-suite registrations between
architecture and meta (lint → architecture → behavioral suites → meta-rules;
P-SUITES-BEFORE-META is E07's test). From this chunk on the kit satisfies
"never fewer specs than its block names" (§1.4) for all three list keys.

**Kind agreement is not yours:** the spec's kind comes from the block key; the
engine validates spec-kind = check-kind at E04 (D-60). The kit never sends
`kind` to instantiated checks.

**Frozen signatures used** (verbatim, E02 digest):

```smalltalk
PGRCheck class >> packages: aCollectionOfPackageNames
    "answers a new instance storing the handed names (copied to Array)"
PGRCheck >> packages      "reader"
PGRRegistrationSpec class >> name: aNameString kind: aKindSymbol check: aCheck
PGRRegistrationSpec class >> missing: aNameString kind: aKindSymbol reason: aReasonString
"spec readers: name · kind · check (nil on missing) · missingReason (nil on resolved)"
PGRVerdict class >> green
```

**Scratch fixtures** (in `Phi-Coding-Kit-Tests-Rules`, beside their tests —
ch. 9 §9.3's fixtures-without-red-tests rule; plain `PGRCheck` subclasses, not
`TestCase`s, inert to behavioral runs; class comments say they are test
fixtures):

- `PCKArchStubCheck` — `PGRCheck` subclass overriding only `kind` (`^
  #architecture`) and `run` (`^ PGRVerdict green`); inherits `packages:` /
  `packages` from the skeleton.
- `PCKMetaStubCheck` — likewise with `kind` `^ #behavioral`.

**Constitution rules that bite here:** strict parsing, never a silent default
(family 7); no global state (class-side methods only, no class-side variables);
glossary exactly; comments state constraints the code cannot show; no
`skip`/`expectedFailures`; a test that cannot fail is a defect.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export
to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present,
D-15); hand-writing class files is not allowed — the committed form must be what
the tooling emits. After export, a fresh `bash tools/build-image.sh` load from
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Coding-Kit/PCKKit.class.st` (modify — the dispatch grows)
- `src/Phi-Coding-Kit-Tests-Rules/PCKArchStubCheck.class.st`
- `src/Phi-Coding-Kit-Tests-Rules/PCKMetaStubCheck.class.st`
- `src/Phi-Coding-Kit-Tests-Rules/PCKKitTest.class.st` (modify — methods added)
- LOC budget: target 120 / ceiling 250.

## TESTS FIRST

Test methods added to `PCKKitTest` (blocks are `Dictionary`s with Symbol keys,
handed directly to the kit contract):

- `testArchitectureCheckResolvedViaPackagesConstructor` — given
  `#architectureChecks → #('PCKArchStubCheck')`, production `#('P-One'
  'P-Two')`, tests `#()` / then one spec named
  `'architecture/PCKArchStubCheck'`, kind `#architecture`, whose `check` is a
  `PCKArchStubCheck` with `packages` = `#('P-One' 'P-Two')` — role-by-block-key:
  the production list, not the tests list.
- `testMetaRuleResolvedWithTestsRole` — given `#metaRules →
  #('PCKMetaStubCheck')`, production `#('P-One')`, tests `#('T-One')` / then
  one spec `'behavioral/PCKMetaStubCheck'`, kind `#behavioral`, whose `check`
  has `packages` = `#('T-One')` — the tests list, not the production list.
- `testUnresolvedArchitectureAndMetaAnswerMissingSpecs` — given both lists
  naming `'PCKNoSuchCheck'` / then two missing specs:
  `'architecture/PCKNoSuchCheck'` kind `#architecture` and
  `'behavioral/PCKNoSuchCheck'` kind `#behavioral`, `check` nil, each
  `missingReason` naming the class (§1.5: a missing spec keeps its explicit
  kind — no check exists to ask).
- `testClassAnsweringNeitherPathSignals` — given `#architectureChecks →
  #('PGRFinding')` (loaded; its class side has no `packages:`) / then
  `PGRConfigurationError` naming the class.
- `testLayerMapKeyProducesNoRegistrationsAndNoError` — given a block with
  `#lintRules → #('PCKNoIsNilIfTrueRule')` **and** `#layerMap → {#layers → a
  Dictionary}` / then exactly the one lint spec is answered — the map is
  carried, unread, unerrored at this epic.
- `testRegistrationOrderIsLintThenArchitectureThenMeta` — given a block naming
  one of each (`#lintRules → #('PCKNoIsNilIfTrueRule')`, `#architectureChecks →
  #('PCKArchStubCheck')`, `#metaRules → #('PCKMetaStubCheck')`) / then the
  answered names are exactly `#('lint/PCKNoIsNilIfTrueRule'
  'architecture/PCKArchStubCheck' 'behavioral/PCKMetaStubCheck')` in that order
  — the frozen order law.

Fixtures: `PCKArchStubCheck` / `PCKMetaStubCheck` (this chunk's own
deliverables) · C13's rule (accepted).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 6 new `PCKKitTest` methods
          plus every previously accepted suite — the 24 E01/E02 tests (19 SDK
          + 5 smoke), all accepted E06 siblings, and any accepted
          parallel-track (E03) suites (regression guard; membership + floor,
          never an exact ceiling).

OUT OF SCOPE
- `recommendedBlock` (C18); behavioral-suite derivation and meta-rule
  special-casing (E07); the `#layerMap` builder, its shape validation, and the
  parameter-missing row (E10).
- Engine-side validation — conformance beyond the promised-constructor probe,
  kind agreement, duplicate names (E04).
- Touching `package.st` files, the baseline, or anything outside the manifest.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files,
          one commit `C17: PCKKit generic dispatch for remaining keys` before
          reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) · new
  questions for the decision sheet.
