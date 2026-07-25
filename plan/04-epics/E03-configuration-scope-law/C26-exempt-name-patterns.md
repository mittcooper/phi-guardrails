# C26 · Exempt-name patterns           [E03 · depends: C25 · parallel: no]

GOAL      Enforce `#exemptNamePatterns` in both directions — every exempt-role
          package full-matches some pattern; no production- or tests-role package
          full-matches any.

TRACE     spec ch. 1 §1.1 (`#exemptNamePatterns` row + strict-list arm "violated
          in either direction") · D-25 residual 1 (misfiling, machine-closed) ·
          D-15 (`matchesRegex:` full-match) · R-24 (validation half) · property
          P-ROLE-MISFILE (its named test lands here).

## CONTEXT DIGEST

**What exists:** `PGRConfiguration class>>fromString:` runs stages 1–6 (parse ·
shape · version · resolution · expansion · scope law + loadedness); role readers
`productionPackageNames` / `testsPackageNames` / `exemptPackageNames` answer the
expanded, law-checked roles. `validArtifactString` on `PGRConfigurationTest`
(baseline `'BaselineOfPGRScratchGrouped'`, production `['scratch-prod']` →
SDK+Core, tests `['scratch-tst']` → Tests-SDK, exempt `['scratch-ghost']` →
`PGR-Scratch-Ghost`, block `{ #kit : 'PGRScratchKit' }`, schemaVersion 2) plus a
mutation helper. C21 already enforces the *shape*: `#exemptNamePatterns`, when
present, is an Array of Strings. `PGRConfigurationError`: frozen E02 `-SDK`
export; class is API, wording is not.

**This chunk appends pipeline stage 7**, after the scope law. When
`#exemptNamePatterns` is present (absent = no check at all, §1.1 "optional"):

- **Direction 1:** every name in `exemptPackageNames` must full-match at least
  one pattern (`matchesRegex:` — full-match semantics, D-15) → a non-matching
  exempt package is a `PGRConfigurationError` naming that package.
- **Direction 2:** no name in `productionPackageNames` or `testsPackageNames`
  may full-match any pattern → a match is a `PGRConfigurationError` naming that
  package (a production/tests package wearing an exempt-looking name is filed
  wrong somewhere — D-25 residual 1: misfiling is loud).
- A pattern the regex engine rejects → `PGRConfigurationError` naming it — same
  regex-wrap rule as C24's matchers (family 7; no engine exception escapes
  `fromString:`).

**Constitution rules that bite here:** strict parsing, offender named (family 7);
glossary exactly (`#exemptNamePatterns` regexes are always named in full — never
bare "pattern", which is reserved for the AST sense); a test that cannot fail is
a defect.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `tools/build-image.sh` load from the
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it
and asserts run count plus the 5 smoke tests.

## DELIVERABLES

- `src/Phi-Guardrails-Core/PGRConfiguration.class.st` — modify: stage 7.
- `src/Phi-Guardrails-Tests-Core/PGRConfigurationTest.class.st` — modify: the
  three tests below.
- LOC budget: target 70 / ceiling 130.

## TESTS FIRST

Test methods on `PGRConfigurationTest`:

- `testExemptNamePatternMismatchSignals` — **P-ROLE-MISFILE** — given the valid
  artifact plus `#exemptNamePatterns : [ 'Toy-.*' ]` / then
  `PGRConfigurationError` naming `'PGR-Scratch-Ghost'` (exempt, matches no
  pattern — direction 1).
- `testProductionMatchingExemptPatternSignals` — given `#exemptNamePatterns :
  [ 'PGR-Scratch-.*', 'Phi-Guardrails-SDK' ]` / then `PGRConfigurationError`
  naming `'Phi-Guardrails-SDK'` (a production-role package full-matches a
  pattern — direction 2).
- `testExemptNamePatternsGreenPath` — given `#exemptNamePatterns :
  [ 'PGR-Scratch-.*' ]` / then the configuration validates (Ghost matches;
  no production/tests name does — both directions hold; also witnesses that
  `'PGR-Scratch-.*'` does **not** full-match any `Phi-Guardrails-*` name).

Fixtures: C20's; nothing new.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 3 new tests, the 27 prior
          `PGRConfigurationTest` methods, the 7 `PGRScratchFixturesTest` methods,
          the 19 accepted E02 SDK tests, and the 5 `PGRBaselineSmokeTest`
          methods (regression guard).

OUT OF SCOPE
- Setting the *framework's own* exempt-name patterns — that belongs to the
  framework's `guardrails.ston` (E09/§7.5), not to this parser.
- `#src` (C27).
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `C26: exempt-name patterns` before reporting for review; nothing left
          uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
