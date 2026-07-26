# E05-C02 · `PGRReport`: the value and its rendering    [E05 · depends: — · parallel: yes]

GOAL      Land `PGRReport` — the gate run's aggregate: frozen caller readers
          (`verdicts` · `isClean` · `exitCode` · `blockingVerdicts` ·
          `advisories`) plus the single-sourced §7.2 rendering the headless
          entry will stream from.

TRACE     R-06 (verdict half — the fail/pass decision) · ch. 7 §7.2 (the
          report protocol and verdict-line format) · ch. 0 §0.3 (gate-caller
          SDK rows) · D-03 (advisories never block) · D-68.1 (`missingReason`
          internal reader serves report rendering).

## CONTEXT DIGEST

**Package and residency.** `PGRReport` is the first class in
`Phi-Guardrails-Gate` (package stub and baseline role group exist since E01 —
no baseline edit). Its mirror test `PGRReportTest` is the first class in
`Phi-Guardrails-Tests-Gate`. The gate package may depend on `-Core` and
`-SDK` only (ch. 0 §0.1); this chunk needs only `-SDK` vocabulary.

**The frozen E02 vocabulary this chunk consumes (verbatim from the E02
digest):**

- `PGRVerdict` — class: `green` · `greenAdvisories:` · `redFindings:` ·
  `missingReason:` · `skipped` (engine-only); instance: `status` (one of
  `#green #red #missing #skipped`) · `findings` · `advisories` ·
  `registrationName` · `kind` · `durationMillis` · `isGreen`. The
  engine-stamping setters `registrationName:` · `kind:` · `durationMillis:`
  are recorded internals (E02 digest) — this chunk's tests use them to build
  stamped verdicts directly, without the engine. `missingReason` is an
  internal reader put there for exactly this chunk's rendering (D-68.1).
  Unstamped readers answer nil.
- `PGRFinding` — class: `target:message:` · `target:message:rationale:`;
  instance: `target` · `message` · `rationale` (nil when absent).

**Report semantics (ch. 7 §7.1–§7.2, condensed to the decidable statements):**

- `verdicts` — the run's verdicts, ordered; answer a **fresh `Array` copy per
  send** (the R-35 handed-collections convention, E02/E03/E04 precedent);
  members are the run's own verdict objects.
- `isClean` — true iff every verdict `isGreen`.
- `exitCode` — `0` iff clean, else `1`. (Code 2 is `runHeadless:`'s — a
  configuration error produces no report at all.)
- `blockingVerdicts` — exactly the non-green verdicts, in verdict order,
  fresh `Array` per send. All non-green statuses block: `#red`, `#missing`,
  `#skipped` — silence never passes (P6).
- `advisories` — the concatenation of every verdict's `advisories`, in
  verdict order, fresh `Array` per send. Advisories are reported, never
  block: a report whose verdicts are green-with-advisories is clean, exit 0
  (D-03).
- The report also carries the **project name** (for the header line) — an
  internal construction argument, not a frozen reader.

**Construction (internal — the gate builds reports, nobody else):** class-side
`project: aProjectString verdicts: aVerdictArray`, copying the handed
collection to `Array` at construction. Not part of any frozen surface.

**Rendering (§7.2 — the format is human-facing and explicitly NOT an API; the
verdict-line format is owned here and nowhere else).** Reference example:

```
PGR gate · Toy · 6 registrations
[ GREEN ] lint/PCKNoIsNilIfTrueRule (34ms)
[ RED   ] architecture/PCKLayerMapCheck (12ms)
          ToyWidget>>#render references ToyDatabase — layer 'ui' → 'persistence' is not allowed
[MISSING] behavioral/Toy-Tests — tests-role package contains no tests
GATE: RED — 2 blocking of 6 · exit 1
```

Rendering is **single-sourced and split for streaming reuse** (E05-C05 streams
the same lines incrementally — the format must have exactly one owner):

- class-side `printHeaderProject: aProjectString count: anInteger on: aStream`
  — the `PGR gate · <project> · <N> registrations` line.
- class-side `printVerdict: aPGRVerdict on: aStream` — one status-tagged line
  (`[ GREEN ]` / `[ RED   ]` / `[MISSING]` / `[SKIPPED]`), the registration
  name, and for green/red the `(<durationMillis>ms)` suffix when stamped; a
  missing verdict carries ` — <missingReason>` on the same line; then one
  indented line per finding (target, space, message), a `rationale: <text>`
  indented line beneath any finding whose `rationale` is non-nil, and
  advisories rendered the same indented way.
- instance `printSummaryOn: aStream` — the
  `GATE: <RED|GREEN> — <b> blocking of <n> · exit <code>` line.
- instance `printOn: aStream` — header, then every verdict via
  `printVerdict:on:`, then the summary. Line separator: `lf` (the D-63 probe's
  spelling).

Exact wording/spacing beyond the example is the implementer's (the format is
not an API); **tests assert substrings, never byte-exact renderings.**

**Constitution rules that bite here:** no global state (a report holds only
what construction gave it); class-side named constructors over `new`+setters;
comments state constraints the code cannot show; framework production code
never references `Transcript` (D-55) — rendering targets the handed stream
only.

**Authoring rule (E01 precedent, verbatim):** author in-image and export to
`src/` with the image's Tonel tooling; hand-writing class files is not
allowed. After export, a fresh `tools/build-image.sh` load from committed
`src/` proves the round trip.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Guardrails-Gate/PGRReport.class.st` — new: instVars `project`,
  `verdicts`; class-side `project:verdicts:`,
  `printHeaderProject:count:on:`, `printVerdict:on:`; instance `verdicts`,
  `isClean`, `exitCode`, `blockingVerdicts`, `advisories`,
  `printSummaryOn:`, `printOn:`, private setter.
- `src/Phi-Guardrails-Tests-Gate/PGRReportTest.class.st` — new: the seven
  tests below.
- LOC budget: target 150 / ceiling 250.

## TESTS FIRST

Test methods on `PGRReportTest` (build verdicts via the `PGRVerdict`
constructors, stamping `registrationName:`/`kind:`/`durationMillis:` directly
— no engine involved):

- `testCleanReportAnswersExitZero` — given a report over two green verdicts /
  when read / then `isClean` is true, `exitCode` = 0, `blockingVerdicts`
  is empty.
- `testAnyNonGreenVerdictAnswersExitOne` — given green + red / then `isClean`
  false, `exitCode` = 1.
- `testMissingVerdictBlocks` — given green + `missingReason:` verdict / then
  `isClean` false, `exitCode` = 1, `blockingVerdicts` includes the missing
  one — silence never passes (P6).
- `testBlockingVerdictsAreExactlyNonGreenInOrder` — given green, red,
  missing, green / then `blockingVerdicts` collects registrationNames = the
  red and missing names, in that order.
- `testAdvisoriesAggregateAcrossVerdictsAndNeverBlock` — given two
  `greenAdvisories:` verdicts with distinct advisory findings / then
  `advisories` is their concatenation in verdict order, `isClean` true,
  `exitCode` = 0 (D-03).
- `testVerdictsAnswersFreshCopyPerSend` — given any report / then `verdicts`
  answers non-identical (fresh) collections on two sends whose elements are
  identical objects (R-35 convention).
- `testPrintOnRendersHeaderVerdictLinesAndSummary` — given a report (project
  `'Scratch'`) over a green stamped verdict, a red verdict with one finding
  carrying a rationale, and a missing verdict with a reason / when
  `printString` / then it includes the header substring (`'PGR gate'`,
  `'Scratch'`, the count), `'[ GREEN ]'`, `'[ RED'`, `'[MISSING]'`, each
  registration name, the finding's target and message, `'rationale:'` plus
  the rationale text, the missing reason, and a final `'GATE:'` line naming
  the blocking count and `'exit 1'` — substrings only, never byte-exact.

Fixtures: none beyond in-test verdict construction.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 7 `PGRReportTest` methods
          **plus every previously accepted suite** — membership plus a floor
          (≥ 155 run = 148 + 7; E05-C01's 3 tests add to the count when
          already landed), never an exact ceiling.

OUT OF SCOPE
- `PGRGate` in any form (E05-C03); `runHeadless:` (E05-C05).
- Any new reader on `PGRVerdict`/`PGRFinding` — the E02 freeze is not
  amended; `missingReason` already exists (D-68.1).
- Rendering options, colors, formats beyond §7.2's one shape.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `E05-C02: PGRReport value and rendering` (D-73) before reporting
          for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
