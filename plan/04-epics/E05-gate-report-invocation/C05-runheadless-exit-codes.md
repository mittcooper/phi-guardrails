# E05-C05 · `runHeadless:`/`runHeadless:on:` — the invocation contract    [E05 · depends: E05-C04, E05-C01 · parallel: no]

GOAL      Land the headless entry: explicit path in, streamed report out,
          exit codes 0/1/2 decided by the top-level handler, flush before
          answering — P-GATE-HEADLESS, P-EXIT-CODES, P-NO-DEFAULT-PATH, and
          P-SAME-VERDICT discharged.

TRACE     R-07 · R-47 · R-06 (exit codes) · R-30 (P-SAME-VERDICT) · R-09
          (design note: the artifact read is the gate's only file access,
          §7.6) · ch. 7 §7.3 · D-39 (the gate never ends without deciding a
          number) · D-45 rulings 1/4 · D-63 (flush probe record — consumed,
          not re-derived) · ch. 9 (P-GATE-HEADLESS:
          `PGRGateTest>>#testRunHeadlessAnswersExitCode`; P-EXIT-CODES:
          `>>#testConfigurationErrorExitsTwo`; P-NO-DEFAULT-PATH:
          `>>#testNoDefaultPathIsConsulted`; P-SAME-VERDICT:
          `>>#testHeadlessAndInImageAgree`).

## CONTEXT DIGEST

**What exists.** `PGRGate` (`forConfiguration:` — eager registry build,
`onVerdict:`, `run` → `PGRReport`; E05-C03) with 8 green `PGRGateTest`
tests and helpers `artifactWithKitsFragment:` / `gateFromKitsFragment:` /
`plainBaselineArtifactString` (E05-C03/C04). `PGRReport` (E05-C02) with the
single-sourced rendering seam: class-side
`printHeaderProject:count:on:` · `printVerdict:on:`; instance
`printSummaryOn:` · `printOn:` · `exitCode` (0/1). `PGRConfiguration
class>>fromFile:` (frozen E03 surface, hardened at E05-C01): signals
`PGRConfigurationError` on every defect — missing file, undecodable file,
malformed STON, every §1.1 validation failure; a relative `#src` anchors to
the config file's own directory. Internal reader `project`.

**The contract (ch. 7 §7.3 — this section is THE way the gate runs; no
caller is privileged and none is required):**

```smalltalk
PGRGate class >> runHeadless: aPathString
    "Parse the artifact at the path, run, print the report to stdout (verdicts stream
     as they complete), answer the exit code. Configuration errors print one line and
     answer 2. Equivalent to runHeadless: aPathString on: Stdio stdout."

PGRGate class >> runHeadless: aPathString on: aWriteStream
    "Same, onto an explicit stream — the testable seam (property P-GATE-HEADLESS)."
```

- The gate reads the configuration at the **explicit path the caller
  passes** — no repo-root convention, no working-directory default (D-45
  ruling 1), no environment sniffing (D-45 ruling 4).
- Exit codes: `0` clean · `1` ≥1 non-green verdict · `2` configuration error
  **or any escaped exception** (D-39 — "no verdict produced"). The method
  **answers** the code; mapping it to a process exit
  (`Smalltalk exit:`) is the caller's line (E05-C07's runner).
- **Streaming:** the report renders incrementally — header first, one
  verdict line as each registration completes (an internal `onVerdict:` sink
  writing `PGRReport printVerdict: ... on: aWriteStream`), then the summary
  line. The format has one owner (the C02 seam); `runHeadless:on:` composes
  it, never re-renders it.
- **The top-level handler (D-39, both forms):** the entire run — parse,
  eager gate construction, streaming, rendering, summary — is wrapped;
  anything escaping is caught, **one error line naming the exception** is
  written to the stream, and the method answers **2**. The error-line write
  itself is guarded (`on: Error do:` around it, swallowing): if even the
  stream is broken, deciding the number still wins — no path through either
  form ends without answering 0, 1, or 2. Handler catch class: `Error` is
  the ruled minimum; whether the wrap must also name non-`Error` catchables
  (D-39's "a non-`Error` exception" — candidates `Error, Halt` as an
  `ExceptionSet`) is recorded as an agent call in `chunks.md` — implement
  the recorded recommendation (`on: Error, Halt do:`), record the verified
  spelling. For `PGRConfigurationError` the line carries its `messageText`;
  for anything else, the exception's class name and `description`. Exactly
  one line, one trailing `lf`.
- **Flush before answering:** both forms send `flush` to the stream before
  answering the code. The D-63 probe record is consumed here, not
  re-derived: an explicit flush is **not** required for correctness on this
  toolchain (stdout written immediately before `Smalltalk exit:` arrived
  intact in all four arms), and it is harmless — this is the recorded
  belt-and-braces. `WriteStream` and `Stdio stdout` both answer `flush`
  (D-63/D-15).
- `runHeadless:` delegates: `^ self runHeadless: aPathString on: Stdio
  stdout` — the only `Stdio` reference this chunk may add (P-DETERMINISTIC's
  E09 sweep will pin `runHeadless:` as one of the two ruled file/stream
  access sites, §7.6).

**Test mechanics.** `PGRGateTest` gains a scratch-directory discipline (the
accepted `PGRConfigurationTest` shape): instVar `scratchDirectory`; `setUp`
creates `FileSystem workingDirectory / 'pgr-e05-scratch'`
(`ensureCreateDirectory`); `tearDown` runs `ensureDeleteAll`. Artifact files
are written with `writeStreamDo:` + `nextPutAll:` and passed by `fullName`.
The artifact texts reuse `artifactWithKitsFragment:` (E05-C03's helper on
this same class) with these `#kits` fragments — clean:
`[ { #kit : 'PGRScratchSpecKit', #specs : [ { #name : 'scratch/G1', #kind :
'scratch', #check : 'PGRScratchGreenCheck' } ] } ]`; red: the same with
`#name : 'scratch/R1'` and `#check : 'PGRScratchRedCheck'`; malformed: the
literal `'not ston {'` (no helper).

For **P-NO-DEFAULT-PATH**, the decoy discipline (constitution: scratch files
a test creates and deletes in `setUp`/`tearDown`; the repo's own
`guardrails.ston` does not exist until E09, but the test must survive its
later arrival): the test computes `FileSystem workingDirectory /
'guardrails.ston'`; **only if absent**, writes a decoy (any valid green
scratch artifact) and remembers it created it; the assertion then calls
`runHeadless:on:` with an explicit path to a **red** artifact in
`scratchDirectory` and asserts the answer is that artifact's verdict (1) —
the working-directory file was never consulted; a second arm passes an
explicit path to a nonexistent file and asserts 2 with one error line, no
fallback. Cleanup deletes the decoy **only if the test created it**, inside
`ensure:` — a pre-existing file is never touched, never deleted.

**Constitution rules that bite here:** no environment sniffing, no default
path — loud failure over inference; no `Transcript` (D-55); nothing in this
repo writes files outside the sanctioned roots except scratch files a test
creates and deletes in `setUp`/`tearDown` (the decoy and artifacts above);
class-side named constructors; comments state constraints code cannot show.

**Authoring rule (E01 precedent, verbatim):** author in-image and export to
`src/` with the image's Tonel tooling; hand-writing class files is not
allowed. After export, a fresh `tools/build-image.sh` load from committed
`src/` proves the round trip.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Guardrails-Gate/PGRGate.class.st` — modify: add class-side
  `runHeadless:` and `runHeadless:on:` exactly as contracted above (the
  full top-level handler included). No instance-side changes.
- `src/Phi-Guardrails-Tests-Gate/PGRGateTest.class.st` — modify: add
  `scratchDirectory` + `setUp`/`tearDown`, at most two private
  artifact-file helpers, and the four tests below.
- LOC budget: target 155 / ceiling 260.

## TESTS FIRST

Test methods on `PGRGateTest` (every path explicit, every stream a
`WriteStream on: String new` unless stated):

- `testRunHeadlessAnswersExitCode` — **ch.-9-named, P-GATE-HEADLESS** —
  given a clean artifact file at an explicit scratch path / when
  `runHeadless:on:` / then it answers 0; given a red artifact file / then it
  answers 1; and in both arms the stream's contents at return include the
  header line and the final `'GATE:'` summary line — the **full** report
  text, including its last line, reached the stream before the exit code
  was answered (the §7.3 flush requirement, machine-stated).
- `testConfigurationErrorExitsTwo` — **ch.-9-named, P-EXIT-CODES** — given
  a malformed artifact file (`'not ston {'`) / when `runHeadless:on:` /
  then it answers 2, did not raise, and wrote **exactly one line** (one
  `lf`) that names the defect (its `PGRConfigurationError` messageText
  substring). (The clean→0 / red→1 arms of P-EXIT-CODES are the previous
  test's; the escaped-exception arm of code 2 is P-NEVER-UNDECIDED,
  E05-C06.)
- `testNoDefaultPathIsConsulted` — **ch.-9-named, P-NO-DEFAULT-PATH** —
  given a valid `guardrails.ston` present in the process working directory
  (the decoy discipline above) / when `runHeadless:on:` an explicit path to
  a *different*, red artifact / then it answers 1 — that artifact's
  verdict, the working-directory file never consulted; and a nonexistent
  explicit path answers 2 with one error line — no fallback.
- `testHeadlessAndInImageAgree` — **ch.-9-named, P-SAME-VERDICT** — given
  the same artifact text both written to a scratch file and held as a
  string / then `runHeadless:on:`'s answer equals
  `(PGRGate forConfiguration: (PGRConfiguration fromString: text)) run
  exitCode` — asserted for a clean and a red artifact (0 and 1) — one
  engine, two modes, identical verdicts.

Fixtures: the E04-C01 cast (untouched); scratch artifact files under
`scratchDirectory`; the conditional decoy.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 12 `PGRGateTest` methods
          (8 prior + 4 new) and the 7 `PGRReportTest` methods **plus every
          previously accepted suite** — membership plus a floor (≥ 170 run
          when stacked after E05-C01–C04), never an exact ceiling.

OUT OF SCOPE
- The adversarial escape fixtures and arms (throwing kit, throwing stream,
  kit-raised `PGRConfigurationError`) — E05-C06 proves the handler; this
  chunk builds it and proves the config-error arm.
- `guardrails.sh` — E05-C07.
- Any change to `PGRReport`'s rendering seam beyond *calling* it; any change
  to `fromFile:`.
- A default path, an implicit sink, any `Transcript` reference.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `E05-C05: runHeadless and the exit-code contract` (D-73) before
          reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet · the verified handler catch-class
  spelling (`Error, Halt` ExceptionSet) and `Stdio stdout` delegation
  (P5 record duty).
