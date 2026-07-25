# C25 · The scope law and loadedness   [E03 · depends: C24 · parallel: no]

GOAL      Enforce D-25's scope law over the expanded roles — pairwise disjoint,
          jointly total over the baseline's packages — plus the loadedness rule:
          production- and tests-role packages must be loaded, exempt need not be.

TRACE     spec ch. 1 §1.1 (strict list: disjointness · the scope law · the
          loaded-in-image arm · exempt-absent-is-fine) · D-25 (the scope law:
          the opt-in hole closed structurally) · D-45 (assignment moved to the
          config; the law survives the move) · R-02, R-24 (an unassigned package
          is loud) · properties P-SCOPE-TOTAL (all three named tests) and
          P-ROLES-FROM-CONFIG (second named test).

## CONTEXT DIGEST

**What exists:** `PGRConfiguration class>>fromString:` runs stages 1–5 (parse ·
shape · version · resolution · matcher expansion); readers `project`,
`kitBlocks`, `kitClasses`, `baselineClass`, `productionPackageNames`,
`testsPackageNames`, `exemptPackageNames`. `validArtifactString` on
`PGRConfigurationTest`: baseline `'BaselineOfPGRScratchGrouped'`, roles
production `['scratch-prod']` / tests `['scratch-tst']` / exempt
`['scratch-ghost']`, block `{ #kit : 'PGRScratchKit' }`, schemaVersion 2 — plus a
mutation helper. Fixture trees (the fixture contract, verbatim):

- `BaselineOfPGRScratchGrouped` — packages `Phi-Guardrails-SDK`,
  `Phi-Guardrails-Core`, `Phi-Guardrails-Tests-SDK`, `PGR-Scratch-Ghost`
  (**declared but not loaded**); groups `scratch-prod` = SDK+Core ·
  `scratch-tst` = Tests-SDK · `scratch-ghost` = Ghost · `scratch-overlap` = SDK ·
  `scratch-empty` = ∅ · `scratch-both` = composite of scratch-prod+scratch-ghost.
- `BaselineOfPGRScratchPlain` — packages SDK, Core, Tests-SDK; no groups.

**This chunk appends pipeline stage 6**, after expansion — three checks, each
signalling `PGRConfigurationError` with the offending package name(s) in the
message:

1. **Disjointness** — no package name in more than one expanded role.
2. **Coverage** — every name in `version packages` (the baseline's own packages;
   dependency projects are out of scope, §1.1) sits in some role. Together with
   (1): each package in **exactly one** role — the scope law. This is what makes
   an unassigned new package a loud failure instead of unguarded code (D-25 as
   amended by D-45: assignment from config, inventory from baseline).
3. **Loadedness** — every production- and tests-role package is loaded in the
   image: `PackageOrganizer default packageNamed: name ifAbsent: [nil]` (D-15
   verified spelling) answering nil → error naming the package. **An exempt-role
   package absent from the image is not an error** — no check ever targets it;
   role validation works on baseline introspection alone (D-25.a, §1.1).

Order within the stage: disjointness → coverage → loadedness (agent detail; keep
deterministic so error messages are stable).

**Constitution rules that bite here:** strict parsing — every violation loud with
the offender named (family 7, P-CFG-STRICT style); glossary exactly (*scope law*
— package coverage, distinct from the withdrawn *scope*; *group role*); no
global state; a test that cannot fail is a defect.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `tools/build-image.sh` load from the
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it
and asserts run count plus the 5 smoke tests.

## DELIVERABLES

- `src/Phi-Guardrails-Core/PGRConfiguration.class.st` — modify: stage 6.
- `src/Phi-Guardrails-Tests-Core/PGRConfigurationTest.class.st` — modify: the six
  tests below.
- LOC budget: target 140 / ceiling 240.

## TESTS FIRST

Test methods on `PGRConfigurationTest`:

- `testUnassignedPackageSignals` — **P-SCOPE-TOTAL** — given the valid artifact
  with the `#exempt` role removed entirely / then `PGRConfigurationError` whose
  message contains `'PGR-Scratch-Ghost'` (the uncovered package is named).
- `testOverlappingRoleGroupsSignals` — **P-SCOPE-TOTAL** — given tests
  `['scratch-tst', 'scratch-overlap']` (exempt back in place) / then
  `PGRConfigurationError` naming `'Phi-Guardrails-SDK'` (in production via
  `scratch-prod` and in tests via `scratch-overlap`).
- `testUnknownRoleGroupSignals` — **P-SCOPE-TOTAL** — given production
  `['scratch-prodd']` (a typo'd group name; tests/exempt as in the valid
  artifact) / then `PGRConfigurationError`. Mechanism, stated so the assertion is
  understood: the typo names no group, no package, and full-matches nothing, so
  it lawfully expands to zero (D-47) — and SDK + Core then sit in no role, which
  **the scope law catches** (the D-25.a silent-empty trap guarded by
  consequence; the error is the coverage arm's, and the test asserts the class
  plus that the message names an uncovered package).
- `testUnassignedPackageStillSignals` — **P-ROLES-FROM-CONFIG (second half)** —
  given baseline `'BaselineOfPGRScratchPlain'`, production
  `['Phi-Guardrails-SDK']`, tests `['Phi-Guardrails-Tests-SDK']`, no exempt /
  then `PGRConfigurationError` naming `'Phi-Guardrails-Core'` (the scope law
  survived the move to config-side assignment, D-45).
- `testUnloadedProductionPackageSignals` — given production
  `['scratch-prod', 'scratch-ghost']`, tests `['scratch-tst']`, no exempt (total
  and disjoint, but Ghost is production now) / then `PGRConfigurationError`
  naming `'PGR-Scratch-Ghost'` (a production-role package must be loaded).
- `testUnloadedExemptPackageIsLegal` — given the unmodified valid artifact (Ghost
  exempt, not loaded) / then it validates and `exemptPackageNames` includes
  `'PGR-Scratch-Ghost'` (baseline introspection alone suffices for exempt).

Fixtures: C20's; nothing new.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 6 new tests, the 21 prior
          `PGRConfigurationTest` methods, the 7 `PGRScratchFixturesTest` methods,
          the 19 accepted E02 SDK tests, and the 5 `PGRBaselineSmokeTest`
          methods (regression guard).

OUT OF SCOPE
- `#exemptNamePatterns` (C26) and `#src` (C27).
- Any behavioral-suite consequence of an empty tests role — that is run-time
  missing semantics (`behavioral/tests-role`, ch. 5 / E07), not parse-time law.
- Relaxing any C24 green test — they were built total-and-disjoint; if one turns
  red here, the implementation is wrong, not the test.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `C25: scope law and loadedness` before reporting for review; nothing
          left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
