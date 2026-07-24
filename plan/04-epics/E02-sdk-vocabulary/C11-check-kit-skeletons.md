# C11 · PGRCheck and PGRKit skeletons      [E02 · depends: C09 · parallel: no]

GOAL      Land the two optional skeletons — `PGRCheck` (the `packages:`
          constructor, `canFix` default false, `subclassResponsibility` markers)
          and `PGRKit` (the two-message class-side kit contract) — with
          P-CANFIX-DEFAULT proven by its named test.

TRACE     spec ch. 1 §1.3 (`PGRCheck` / `PGRKit` rows) · ch. 0 §0.3 (check-author
          and kit-author SDKs) · glossary *check* / *kit* / *skeleton* /
          *capability* · D-53.2 (skeletons optional; conformance, not ancestry) ·
          D-54.2/.3 (capability pair; `recommendedBlock`) · D-60 rulings 3/7
          (two-message kit contract; `packages:` spelling, role-by-block-key,
          instance reader `packages`) · D-62 (Gate 3 closed the D-59/D-60
          veto-open spellings — settled ground, never re-litigated) ·
          P-CANFIX-DEFAULT (ch. 9 §9.1) · R-40 (i).

## CONTEXT DIGEST

**What exists when this chunk starts:** C09 accepted — `PGRVerdict` in
`Phi-Guardrails-SDK` with class-side `green` (among others); C08's `PGRFinding`
likewise. Both SDK packages otherwise as stubbed by E01; the baseline is **not**
edited.

**Skeleton stance (class comments must carry it):** the check and kit contracts are
*protocols* — message sets plus behavioral expectations; **conformance, not
ancestry, is what registration requires** (D-53). A duck-typed plain class
implementing the messages registers fine; these skeletons are a convenience —
documentation, `subclassResponsibility` markers, and the default implementations
below. Abstract classes, not traits (trait attribution is live backlog B-03).

**`PGRCheck` — in `Phi-Guardrails-SDK`.** The check protocol it documents and
partially implements (spellings are Gate-3-settled, D-62 — a change here is a
frozen-surface amendment, decision-sheet only):

| Member | Side | Skeleton implementation |
|---|---|---|
| `packages: aCollectionOfPackageNames` | class | **implemented**: answers a new instance storing the handed names (copied to `Array`; private setter `setPackages:` — the same spelling guide 2's plain-class sample uses for its own class). The kit that names a check instantiates it, handing its target package names at construction; the role handed is the one the block key implies (`#architectureChecks` → production-role, `#metaRules` → tests-role) |
| `packages` | instance | **implemented**: reader for subclasses — a check's `run` reads its targets here; `run` stays argument-less and a check never pulls context from anywhere: everything it knows, it was given (D-60) |
| `run` | instance | `self subclassResponsibility` — answers a `PGRVerdict` |
| `kind` | instance | `self subclassResponsibility` — answers a `Symbol`; must equal the kind its block key implies (kind agreement, D-60 — validated by the engine at E04, stated here in the method comment) |
| `canFix` | instance | **implemented**: `^ false` — fixing is opt-in (the P-CANFIX-DEFAULT subject) |
| `fixCommandOn: aCollectionOfPackageNames` | instance | `self subclassResponsibility` — required only when `canFix` is overridden true; answers an object conforming to the fix-invocation protocol (construct → `previewOn:` → `apply` → `changes`). A `canFix`-false check is never sent it; the marker is documentation, not obligation (agent call, veto-open: the ch. 0 diagram lists the member on the skeleton) |

**`PGRKit` — in `Phi-Guardrails-SDK`.** All class-side; kits are stateless. The
whole contract, **two messages** (D-54 as amended by D-60 — `kitName` dropped; the
class name is the identity):

| Member | Side | Skeleton implementation |
|---|---|---|
| `registrationsFrom: aBlock productionPackages: productionNames testsPackages: testsNames` | class | `self subclassResponsibility` — takes the kit's verbatim block (a `Dictionary` from the artifact's `#kits` array) plus the resolved role package-name lists — **never the configuration object** (D-53: over-reach is impossible, not caught); answers an ordered collection of `PGRRegistrationSpec` values, never fewer than the block names; validates its own block strictly (an unknown key inside it → `PGRConfigurationError`, raised by the kit) |
| `recommendedBlock` | class | `self subclassResponsibility` — the published stanza, single-sourced on the kit class, answering **STON text** (a String, D-60); the init tool composes it into drafts, docs quote it, P-STANZA-VALID (E06+) keeps it true |

The contract's substance above goes in the two method comments and the class
comment — the skeleton is where a kit author reads the rules (D-53's
documentation duty).

**Test fixture — `PGRMinimalCheckFixture` in `Phi-Guardrails-Tests-SDK`:** a
`PGRCheck` subclass overriding **only** `kind` (`^ #lint`) and `run`
(`^ PGRVerdict green`) — deliberately *not* `canFix`; it is the "minimal conforming
check" P-CANFIX-DEFAULT speaks of. Fixture classes without red tests sit beside
their tests in the mirroring tests-role package (ch. 9 §9.3); it is not a
`TestCase`, so behavioral runs never execute it.

**Guide alignment (why the spellings are immovable):**
`docs/quickstarts/02-write-a-check.md` and `03-build-a-kit.md` already carry
executable samples using exactly `packages:`, `self packages`, `canFix`,
`fixCommandOn:`, and the two kit messages; E09's `PGRQuickstartSamplesTest`
executes them verbatim against this chunk's classes.

**Constitution rules that bite here:** `PGR` prefix; glossary exactly
(gate-runnable things are *checks*, never "tests"); class-side named constructors
over `new`+setters; no global state (kits stateless — no class-side variables
anywhere); comments state constraints code cannot show; R-04 — nothing in `-SDK`
references SUnit/Renraku/RB classes; SUnit tests, no `skip`/`expectedFailures`, a
test that cannot fail is a defect.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits (see `src/Phi-Guardrails-Tests-Core/PGRBaselineSmokeTest.class.st`).
After export, a fresh `tools/build-image.sh` load from the committed `src/` is the
proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it
and asserts run count plus the 5 smoke tests.

## DELIVERABLES

- `src/Phi-Guardrails-SDK/PGRCheck.class.st`
- `src/Phi-Guardrails-SDK/PGRKit.class.st`
- `src/Phi-Guardrails-Tests-SDK/PGRMinimalCheckFixture.class.st`
- `src/Phi-Guardrails-Tests-SDK/PGRCheckSkeletonTest.class.st`
- `src/Phi-Guardrails-Tests-SDK/PGRKitSkeletonTest.class.st`
- LOC budget: target 110 / ceiling 200.

## TESTS FIRST

Test methods on `PGRCheckSkeletonTest`:

- `testCanFixDefaultsFalse` — given `PGRMinimalCheckFixture packages: #()` (a
  subclass overriding only `kind` and `run`) / when `canFix` / then false without
  the subclass ever writing it — **P-CANFIX-DEFAULT, the property this epic owes;
  the method name is fixed by ch. 9**.
- `testPackagesConstructorStoresNames` — given
  `PGRMinimalCheckFixture packages: #('Pkg-A' 'Pkg-B')` / then `packages` answers
  exactly those names and `run` answers a verdict with `isGreen` true (the
  handed-at-construction contract end to end).
- `testBareSkeletonMarksItsContract` — given `PGRCheck packages: #()` / when
  sending `run`, `kind`, and `fixCommandOn: #()` / then each signals
  `SubclassResponsibility` — the skeleton documents, it never silently answers.

Test methods on `PGRKitSkeletonTest`:

- `testKitContractIsTwoClassSideMessages` — given `PGRKit class` / when taking its
  locally-defined selector set (`PGRKit class selectors asSet` — metaclass
  selectors, local definitions only) / then it **equals exactly**
  `#(#registrationsFrom:productionPackages:testsPackages: #recommendedBlock)
  asSet`, and each of the two signals `SubclassResponsibility` when sent to the
  bare skeleton — set equality is the anti-drift mechanism: a third class-side
  message drifting in fails as an extra element, and a contract message vanishing
  locally (satisfied only by an inherited impostor up the hierarchy) fails as a
  missing one; a change to the two-message contract (D-60) must come through a
  ruling, never drift.

Fixtures: `PGRMinimalCheckFixture` (this chunk's own deliverable, above).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 3 `PGRCheckSkeletonTest` methods,
          the 1 `PGRKitSkeletonTest` method, and the 5 `PGRBaselineSmokeTest`
          methods (regression guard; plus all accepted siblings' tests).

OUT OF SCOPE
- Conformance validation machinery (E04), any concrete check or kit (`PCKKit` is
  E06), the fix-invocation implementation (E08).
- Helper methods beyond the tabled members — each SDK is complete *and minimal*
  (ch. 0 §0.3's law); convenience creep here is a review rejection.
- Editing the baseline, any `package.st`, or anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md`
          (`bash tools/precheck.sh` once C06 is accepted; else by eye — D-67).
          Postcondition: exactly the manifest files, one commit
          `C11: PGRCheck and PGRKit skeletons` before reporting for review;
          nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
