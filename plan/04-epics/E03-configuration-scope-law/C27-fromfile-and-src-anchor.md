# C27 · fromFile: and the #src anchor  [E03 · depends: C26 · parallel: no]

GOAL      Land `fromFile:` — the second frozen constructor — and the `#src`
          anchor rules: relative `#src` resolves against the config file's own
          directory, and a directory-less (`fromString:`) relative `#src` is a
          configuration error naming the fix.

TRACE     spec ch. 1 §1.1 (`#src` row; strict-list anchor arm; "the file lives
          wherever the caller says") · D-45 rulings 1–2 (explicit path, no
          default location; paths relative to the config file's directory) ·
          D-47 flag 2 (the `fromString:` anchor edge: error names the fix) ·
          R-47 · property P-DETERMINISTIC (allows `FileReference` exactly here —
          context, discharged at E09).

## CONTEXT DIGEST

**What exists:** `PGRConfiguration class>>fromString:` runs the full pipeline
stages 1–7 (parse · shape · version · resolution · expansion · scope law +
loadedness · exempt-name patterns); C21's shape stage already requires `#src`,
when present, to be a String. `validArtifactString` on `PGRConfigurationTest`
(baseline `'BaselineOfPGRScratchGrouped'`, production `['scratch-prod']`, tests
`['scratch-tst']`, exempt `['scratch-ghost']`, block `{ #kit : 'PGRScratchKit' }`,
schemaVersion 2 — **no `#src`**) plus a mutation helper. `PGRConfigurationError`:
frozen E02 `-SDK` export; class is API, wording is not.

**This chunk delivers two things:**

**1 · `fromFile: aPathString`** (class-side; joins `fromString:` on the frozen
caller surface at E03 acceptance):

- `aPathString asFileReference`; a missing/unreadable file →
  `PGRConfigurationError` naming the path (the raw
  `FileDoesNotExistException` must never escape — a caller catches
  configuration defects by class, D-49; `runHeadless:`'s exit-2 mapping, E05,
  builds on exactly this).
- Read `contents`, run the identical `fromString:` pipeline (one validation
  path, two entries), remembering the file's directory (`parent`) as the
  **anchoring directory** for stage 8. There is no repo-root convention and no
  working-directory default — the explicit path is all there is (D-45 ruling 1).

**2 · Pipeline stage 8 — the `#src` anchor rules** (runs in both entries):

- `#src` absent → nothing to do (optional; a consuming check goes *missing* at
  run time, the §1.5 parameter pattern — E11's business, not the parser's).
- `#src` present and **absolute** → record as-is (both entries).
- `#src` present and **relative**:
  - via `fromFile:` → resolve against the anchoring directory (`parent / src`);
    record the resolved absolute path.
  - via `fromString:` (no anchoring directory exists) → `PGRConfigurationError`
    **whose message names the fix**: use an absolute path, or load via
    `fromFile:` (D-47 flag 2, verbatim requirement).
- Record on a specified-but-internal reader `srcPath` (String, absolute when
  anchored; nil when absent — agent call, veto-open, chunks.md §agent-calls;
  E11's `PCKSrcInventoryCheck` wiring consumes it). Existence of the directory
  is **not** checked — the walk that consumes it judges that at run time.

**Verified spellings (probed 2026-07-25, D-31.a work image — record: E03
chunks.md §probes; P5):** `asFileReference` → `FileReference`;
`writeStreamDo:`/`contents` round-trip a file; `contents` on a missing path
signals `FileDoesNotExistException`; `parent` answers the containing directory;
`parent / 'sub'` composes paths (`/` on `FileReference`); `fullName` renders the
absolute path; `isAbsolute` — `'/tmp/x' asFileReference isAbsolute` true,
`'src' asFileReference isAbsolute` false (the relative/absolute test).

**Test scratch files:** the constitution's write boundary allows "scratch files a
test creates and deletes in `setUp`/`tearDown`" — the `fromFile:` tests write the
artifact into a scratch directory under the image's working directory (D-15's
`FileSystem workingDirectory`, e.g. `FileSystem workingDirectory /
'pgr-c27-scratch'`), created in `setUp`, deleted (`ensureDeleteAll` or
equivalent recursive delete — spelling free) in `tearDown`, red or green.

**Constitution rules that bite here:** the mutation/write boundary above; strict
parsing — never a working-directory fallback (family 7 / D-45); glossary exactly
(*source root*, *caller*); no global state.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `tools/build-image.sh` load from the
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it
and asserts run count plus the 5 smoke tests.

## DELIVERABLES

- `src/Phi-Guardrails-Core/PGRConfiguration.class.st` — modify: `fromFile:`,
  stage 8, reader `srcPath`.
- `src/Phi-Guardrails-Tests-Core/PGRConfigurationTest.class.st` — modify:
  `setUp`/`tearDown` scratch-directory handling + the five tests below.
- LOC budget: target 110 / ceiling 200.

## TESTS FIRST

Test methods on `PGRConfigurationTest`:

- `testFromFileParsesAndAnchorsRelativeSrc` — given the valid artifact text plus
  `#src : 'src'` written to `<scratch-dir>/guardrails.ston` / when
  `PGRConfiguration fromFile:` that path / then an instance is answered whose
  `project` = `'Scratch'` and whose `srcPath` = the absolute
  `<scratch-dir>/src` (`fullName` form) — relative `#src` anchored to the
  config file's own directory, never the working directory.
- `testFromFileMissingFileSignals` — given a path in the scratch dir where no
  file exists / then `fromFile:` signals `PGRConfigurationError` (assert the
  class — the raw file exception must not escape) naming the path.
- `testRelativeSrcWithoutAnchorSignals` — given the valid artifact plus
  `#src : 'src'` via `fromString:` / then `PGRConfigurationError` whose message
  names the fix — contains `'fromFile:'` and `'absolute'` (D-47's ruled minimum;
  the wording around them stays free).
- `testAbsoluteSrcFromStringIsLegal` — given `#src : '/tmp/pgr-elsewhere'` via
  `fromString:` / then valid, `srcPath` = `'/tmp/pgr-elsewhere'` (no anchor
  needed; existence deliberately unchecked at parse time).
- `testAbsentSrcIsLegal` — given the unmodified valid artifact via `fromString:`
  / then valid and `srcPath` is nil (optional key, §1.5 pattern honored by
  absence).

Fixtures: C20's; plus the setUp/tearDown scratch directory described above.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 5 new tests, the 30 prior
          `PGRConfigurationTest` methods, the 7 `PGRScratchFixturesTest` methods,
          the 19 accepted E02 SDK tests, and the 5 `PGRBaselineSmokeTest`
          methods (regression guard). This is also the epic's exit-checkpoint
          suite head: 42 E03 tests + 24 accepted = 66 run — plus whatever
          accepted parallel-track E06 suites the sweep also matches by then
          (a count above 66 with all E03/E02 suites listed is still a pass;
          the E03 claim is the 42 + 24, all green).

OUT OF SCOPE
- `runHeadless:` and exit codes — E05 (it consumes `fromFile:`'s error contract).
- Checking that `srcPath` exists or walking it — `PCKSrcInventoryCheck`, E11.
- Any default path, environment sniffing, or working-directory fallback — ruled
  out (D-45); the temptation to "helpfully" try `./guardrails.ston` is a
  review-rejection.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `C27: fromFile: and the src anchor` before reporting for review;
          nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
