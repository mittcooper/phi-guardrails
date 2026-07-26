# E05-C01 · B-15 hardening: `fromFile:` encoding wrap + empty exempt-patterns pin    [E05 · depends: — · parallel: yes]

GOAL      Close B-15's two recorded edges: an undecodable configuration file
          signals `PGRConfigurationError` (never a raw Zn encoding error), and
          the present-but-empty `#exemptNamePatterns : [ ]` behavior is pinned
          by tests in both directions.

TRACE     B-15 (`plan/backlog.md`, owner-scheduled to E05 — the placement
          annotation per D-61.a: this chunk is the backlog row's recorded
          landing, riding the E05 cut on the owner note of 2026-07-25) ·
          ch. 1 §1.1 (strict validation; family 7) · D-49 (callers catch
          configuration defects by class) · P-CFG-STRICT (additive arms).

## CONTEXT DIGEST

**What exists (accepted E03 ground, all in `Phi-Guardrails-Core` /
`Phi-Guardrails-Tests-Core`).** `PGRConfiguration class>>fromFile:` is frozen
caller surface whose stated contract is "signals `PGRConfigurationError` on
every defect of the §1.1 strict list". Its current body:

```smalltalk
PGRConfiguration class >> fromFile: aPathString
    | file contents |
    file := aPathString asFileReference.
    contents := [ file contents ]
        on: FileException
        do: [ :error | PGRConfigurationError new signal: 'Cannot read configuration file: ' , aPathString ].
    ^ self fromString: contents anchor: file parent
```

The C27 review observed (B-15): a file whose bytes are not valid UTF-8 makes
`file contents` raise a **Zn encoding error that is not a `FileException`**, so
it escapes `fromFile:` raw — a hole in the stated contract. The fix is to widen
the wrap, nothing else.

Stage 7 of the validation pipeline (`validateExemptNamePatterns:roles:`,
accepted at C26) reads: `#exemptNamePatterns` **absent** means no check at all;
**present**, direction 1 requires every exempt-role package to full-match at
least one pattern, direction 2 forbids any production- or tests-role package
from matching any. Consequence, faithful but untested: with the key present as
an **empty list** and a nonempty exempt role, direction 1 fires for every
exempt package. This chunk pins that behavior; **no stage-7 product change**.

**The accepted test class this chunk extends** (`PGRConfigurationTest`,
`Phi-Guardrails-Tests-Core`, 35 accepted tests): instVar `scratchDirectory`;
`setUp` creates `FileSystem workingDirectory / 'pgr-c27-scratch'`
(`ensureCreateDirectory`), `tearDown` runs `ensureDeleteAll`. Helpers this
chunk reuses verbatim:

- `validArtifactString` — the canonical green artifact:

  ```
  { #schemaVersion : 2, #project : 'Scratch',
    #baseline : 'BaselineOfPGRScratchGrouped',
    #roles : { #production : [ 'scratch-prod' ], #tests : [ 'scratch-tst' ],
               #exempt : [ 'scratch-ghost' ] },
    #kits : [ { #kit : 'PGRScratchKit' } ] }
  ```

  Under `BaselineOfPGRScratchGrouped`, group `scratch-ghost` expands to the one
  declared-but-unloaded package `'PGR-Scratch-Ghost'` (declaration is
  inventory; an absent exempt package is legal, D-25.a) — so the valid artifact
  has exactly one exempt-role package.
- `artifactWith: aKey value: aValue` — the valid artifact with one key
  added/replaced (goes through `artifactMap` / `STON toString:`).
- `artifactWithout: aKey` — the valid artifact with a key removed.
- `BaselineOfPGRScratchPlain` — the same three real packages
  (`Phi-Guardrails-SDK`, `Phi-Guardrails-Core`, `Phi-Guardrails-Tests-SDK`),
  **no groups**; with it roles are assigned by exact package-name matchers and
  no exempt role is declared, so the exempt-role expansion is empty.

**Amendment table (scheduled ground; enumerated by script over committed
sources — `grep -rn 'fromFile:' src/`, all hits accounted):**

| Consumer of the amended surface | Effect of this amendment |
|---|---|
| `PGRConfigurationTest>>#testFromFileMissingFileSignals` | none — a missing file still raises `FileException`, still wrapped, same message |
| `PGRConfigurationTest>>#testFromFileParsesAndAnchorsRelativeSrc` | none — a valid UTF-8 file never enters either wrap arm |
| (no production caller of `fromFile:` exists yet; `PGRGate` consumes it at E05-C05) | — |

**Accepted tests amended: none.** This chunk is additive on
`PGRConfigurationTest` — all 35 accepted test methods stay byte-identical; the
reviewer diffs the file to confirm.

**Constitution rules that bite here:** strict parsing — malformed or unknown
input raises a configuration error, never a silent default (family 7); tests
assert behavior (each new test must fail if the wrap or the stage-7 behavior
broke); scratch files live and die inside `setUp`/`tearDown` (the existing
`scratchDirectory` discipline).

**⟨verify-in-image⟩ delegated to the implementer with record-in-report duty
(P5, the E04/E06 precedent):** the exact Zn error class `file contents` raises
on invalid UTF-8 — candidates `ZnCharacterEncodingError` (likely root),
`ZnInvalidUTF8` — confirm by raising it in the work image and wrap the
confirmed root (an `ExceptionSet`: `on: FileException, ZnCharacterEncodingError
do:`); and the binary-write spelling for the bad fixture file — candidate
`(scratchDirectory / 'bad.ston') binaryWriteStreamDo: [ :s | s nextPutAll:
#[255 254 200 155] ]`.

**Authoring rule (E01 precedent, verbatim):** author in-image and export to
`src/` with the image's Tonel tooling; hand-writing class files is not allowed.
After export, a fresh `tools/build-image.sh` load from committed `src/` proves
the round trip.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Guardrails-Core/PGRConfiguration.class.st` — modify: widen
  `fromFile:`'s wrap to the confirmed encoding-error class beside
  `FileException`; error message unchanged in shape (`'Cannot read
  configuration file: ' , aPathString`). No other method changes.
- `src/Phi-Guardrails-Tests-Core/PGRConfigurationTest.class.st` — modify:
  add the three tests below; all accepted methods byte-identical.
- LOC budget: target 60 / ceiling 120.

## TESTS FIRST

Test methods on `PGRConfigurationTest`:

- `testUndecodableFileSignalsConfigurationError` — given a scratch file whose
  bytes are not valid UTF-8 (written binary in the test) / when
  `PGRConfiguration fromFile:` its full path / then `PGRConfigurationError` is
  signalled and its message includes the path — the raw Zn error never
  escapes (B-15 arm 1).
- `testEmptyExemptNamePatternsSignalsForExemptPackage` — given the valid
  grouped-baseline artifact with `#exemptNamePatterns` present as `#()` (via
  `artifactWith: #exemptNamePatterns value: #()`) / when `fromString:` / then
  `PGRConfigurationError` is signalled naming `'PGR-Scratch-Ghost'` —
  direction 1 fires for every exempt package under an empty pattern list
  (B-15 arm 2, behavior pinned).
- `testEmptyExemptNamePatternsLegalWithoutExemptPackages` — given a
  plain-baseline artifact (`BaselineOfPGRScratchPlain`, roles by exact
  package-name matchers: production `[ 'Phi-Guardrails-SDK',
  'Phi-Guardrails-Core' ]`, tests `[ 'Phi-Guardrails-Tests-SDK' ]`, no exempt
  role) carrying `#exemptNamePatterns : [ ]` / when `fromString:` / then it
  parses clean — an empty list is legal input, not a shape defect; both
  directions are vacuous over an empty exempt role.

Fixtures: the existing `scratchDirectory` discipline and the two accepted
scratch baselines; the plain-baseline artifact string is authored inline in
the third test (or one private helper).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 38 `PGRConfigurationTest`
          methods (35 prior + 3 new) **plus every previously accepted suite**
          — membership plus a floor (≥ 151 run), never an exact ceiling.

OUT OF SCOPE
- Any stage-7 product change — the empty-list arms pin existing behavior.
- Any other `fromFile:`/`fromString:` behavior change; the frozen caller
  surface's shape is untouched (this is a wrap-widening inside the stated
  contract, owner-scheduled via B-15).
- Touching `PGRGate`/`PGRReport` (later chunks) or anything outside the
  manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `E05-C01: fromFile: encoding wrap + empty exempt-patterns pin`
          (D-73) before reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet · the confirmed Zn error class and
  binary-write spelling (P5 record duty).
