# C24 · Role-matcher expansion         [E03 · depends: C23 · parallel: no]

GOAL      Expand the `#roles` matchers over the resolved baseline — group name
          first (membership pre-checked), else exact package name, else
          full-match pattern; zero-match legal — landing the three role-package
          readers.

TRACE     spec ch. 1 §1.1 (`#roles` row; matcher resolution order; expansion via
          the D-25.a spellings; zero-match-is-not-an-error) · D-45 (assignment
          from config, inventory from baseline) · D-47 ratification 2 (resolution
          order) · D-25.a (expansion API + unknown-group trap) · D-15
          (`matchesRegex:` full-match) · R-02 · properties P-ROLES-FROM-CONFIG
          (first named test) · Q-31 (the ambiguity arm — see below).

## CONTEXT DIGEST

**What exists:** `PGRConfiguration class>>fromString:` runs stages 1–4 (parse ·
shape · version {2} · kit/baseline resolution); readers `project`, `kitBlocks`,
`kitClasses`, `baselineClass`. `validArtifactString` on `PGRConfigurationTest`:
baseline `'BaselineOfPGRScratchGrouped'`, roles production `['scratch-prod']` /
tests `['scratch-tst']` / exempt `['scratch-ghost']`, block
`{ #kit : 'PGRScratchKit' }`, schemaVersion 2 — plus a mutation helper. C20's
fixture trees (the fixture contract, verbatim):

- `BaselineOfPGRScratchGrouped` — packages `Phi-Guardrails-SDK`,
  `Phi-Guardrails-Core`, `Phi-Guardrails-Tests-SDK`, `PGR-Scratch-Ghost`
  (unloaded); groups `scratch-prod` = SDK+Core · `scratch-tst` = Tests-SDK ·
  `scratch-ghost` = Ghost · `scratch-overlap` = SDK · `scratch-empty` = ∅ ·
  `scratch-both` = scratch-prod + scratch-ghost (composite).
- `BaselineOfPGRScratchPlain` — packages `Phi-Guardrails-SDK`,
  `Phi-Guardrails-Core`, `Phi-Guardrails-Tests-SDK`; **no groups**.

**This chunk appends pipeline stage 5**, after resolution. For each role in
`#production`, `#tests`, `#exempt` (absent `#exempt` = empty), expand each
matcher string over `baselineClass project version` (D-25.a verified API —
`version packages` / spec `name`, `version groups` / spec `name`, transitive
`version packagesForSpecNamed:`):

1. **Group name** — iff the matcher equals a name in `version groups` (the
   membership **pre-check**: an unknown group name silently expands to empty via
   `packagesForSpecNamed:`, the D-25.a trap — never call it unchecked) → the
   group's transitive package names.
2. **Else exact package name** — iff it equals a name in `version packages` →
   itself.
3. **Else full-match pattern** — the matcher as a regex, full-match semantics
   (`matchesRegex:`, D-15: `'XSUnit-Tests' matchesRegex: 'SUnit-.*'` is false),
   against every name in `version packages` → all full-matching names.
   **A matcher expanding to zero packages is not an error** (D-47: its
   consequences are what the machinery catches — C25's scope law, ch. 5's
   missing registration). Wrap the regex evaluation: a matcher the regex engine
   rejects (e.g. `'Toy-('`) signals `PGRConfigurationError` naming the matcher —
   malformed input is loud (family 7), and no engine exception may escape
   `fromString:` (agent call, veto-open — chunks.md §agent-calls).

**The ambiguity arm is not implemented — Q-31 (decision sheet), the
recommendation this order follows:** §1.1/D-47 make "a string that is both a
group name and a package name" a configuration error, but Metacello itself
refuses declaring that collision ("incompatible specs", probed 2026-07-25 —
chunks.md §probes), so the arm is unconstructible from any real baseline and its
branch would be dead, untestable code. Steps 1–3 above are total without it. If
the owner vetoes Q-31's recommendation, the arm returns as its own amendment
chunk — not silently here.

**Result state:** the expanded role name-sets, stored per role and exposed by the
three specified-but-internal readers (ch. 1 §1.3: "derived from the baseline at
validation time"): `productionPackageNames`, `testsPackageNames`,
`exemptPackageNames` — each an ordered `Array` of package-name Strings (handed
collections copied, the E02 R-35 convention; expansion order: matcher order, then
baseline declaration order within a group/pattern; dedup within one role). The
scope law (disjointness across roles, coverage, loadedness) is **not** enforced
until C25 — every green test below already satisfies it, so C25 tightens nothing
these tests exercise.

**Constitution rules that bite here:** no global state (expansion happens at
validation, results live on the instance); strict parsing (family 7); glossary
exactly (*group role*, *scope law* — distinct terms; *matcher* language per
§1.1); a test that cannot fail is a defect.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `tools/build-image.sh` load from the
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it
and asserts run count plus the 5 smoke tests.

## DELIVERABLES

- `src/Phi-Guardrails-Core/PGRConfiguration.class.st` — modify: stage 5 + the
  three role readers.
- `src/Phi-Guardrails-Tests-Core/PGRConfigurationTest.class.st` — modify: the six
  tests below.
- LOC budget: target 130 / ceiling 230.

## TESTS FIRST

Test methods on `PGRConfigurationTest`:

- `testGroupMatcherExpandsToRoleReaders` — given the valid artifact / then
  `productionPackageNames` = exactly `#('Phi-Guardrails-SDK'
  'Phi-Guardrails-Core')`, `testsPackageNames` = `#('Phi-Guardrails-Tests-SDK')`,
  `exemptPackageNames` = `#('PGR-Scratch-Ghost')`.
- `testRolesByPatternWithoutBaselineGroups` — **P-ROLES-FROM-CONFIG (first
  half)** — given baseline `'BaselineOfPGRScratchPlain'` with roles production
  `['Phi-Guardrails-(SDK|Core)']` (pattern), tests
  `['Phi-Guardrails-Tests-SDK']` (package name), no exempt / then it validates
  cleanly and the readers answer SDK+Core and Tests-SDK — a baseline with no role
  groups needs none (D-45).
- `testSubstringMatchDoesNotCount` — given the valid artifact with exempt
  `['scratch-ghost', 'Guardrails-Tests-SDK']` / then `exemptPackageNames` is
  still exactly `#('PGR-Scratch-Ghost')` — the second matcher substring-matches
  `Phi-Guardrails-Tests-SDK` but does not full-match, so it adds nothing (D-15
  semantics witnessed).
- `testZeroMatchMatcherIsLegal` — given exempt
  `['scratch-ghost', 'PGR-Nothing-.*']` / then the configuration validates and
  the extra matcher contributed nothing (D-47: zero-match is not itself an
  error).
- `testEmptyGroupMatcherIsLegal` — given exempt
  `['scratch-ghost', 'scratch-empty']` / then valid, `exemptPackageNames` still
  `#('PGR-Scratch-Ghost')` (an empty group is a legal baseline fact, D-25.a
  addendum).
- `testInvalidPatternMatcherSignals` — given exempt `['Toy-(']` / then
  `PGRConfigurationError` naming `'Toy-('` (a matcher the regex engine rejects is
  loud, never an escaped engine exception).

Fixtures: C20's; nothing new.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 6 new tests, the 15 prior
          `PGRConfigurationTest` methods, the 7 `PGRScratchFixturesTest` methods,
          the 19 accepted E02 SDK tests, and the 5 `PGRBaselineSmokeTest`
          methods (regression guard).

OUT OF SCOPE
- The scope law (disjointness · coverage · loadedness) — C25; do not pre-enforce
  any of it, and do not write green tests here that C25 would turn red (every
  green case above is total and disjoint by construction).
- The ambiguity arm — Q-31's ruling, never a silent implementation.
- `#exemptNamePatterns` semantics — C26. `#src` — C27.
- Composite-group expansion assertions — already pinned by C20's
  `testCompositeGroupExpandsTransitively` on the Metacello API itself.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `C24: role-matcher expansion` before reporting for review; nothing
          left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
