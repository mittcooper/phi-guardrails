# E09-C06 · `testBuildAKitSamples` — guide 3 executes verbatim    [E09 · depends: E09-C05 · parallel: no]

GOAL      Complete P-GUIDE-EXEC's M1 pair: every sample in
          `docs/quickstarts/03-build-a-kit.md` executed verbatim and
          asserted to behave as the guide states — the epic's closing
          chunk.

TRACE     ch. 9 §9.2 P-GUIDE-EXEC (build-a-kit leg — anchor M1 confirmed,
          D-62/roadmap §0) · D-51 (blocks self-contained, ordered,
          independently validated) · D-53/D-54 (two-message kit contract,
          specs cross the boundary) · D-60 (STON stanza; kit raises
          `PGRConfigurationError`; `self environment at:` idiom, D-60.a) ·
          roadmap §1 M1 checkpoint (the second sample leg).

## CONTEXT DIGEST

**This chunk extends C05's file** — `PGRQuickstartSamplesTest` in
`Phi-Guardrails-Tests-Gate` gains its second method; C05's
`testWriteACheckSamples` and helpers are accepted ground: **byte-identical
after this chunk** (the reviewer diffs; reusable helpers may be *called*,
never edited — if a helper needs generalizing, that is a deviation to
justify, not a silent edit).

**Harness surface (E09-C04):** `guideNamed: '03-build-a-kit.md'` ·
`samplesIn:` → 2 samples, tags `#(smalltalk ston)` (pinned by C04):
sample 1 = the `DKKit` class (fluid `PGRKit << #DKKit package: 'Demo-Kit'`
+ class-side `recommendedBlock` and
`registrationsFrom:productionPackages:testsPackages:` — the guide's full
working kit); sample 2 = the adopter's `#kits : [ … ]` fragment naming a
`PCKKit` block (`#lintRules : [ 'PCKNoIsNilIfTrueRule' ]`) and a `DKKit`
block (`#docChecks : [ 'DKClassCommentCheck' ]`). `install:` /
`removeInstalled` as in C05; `ensure:` + idempotent `tearDown`.

**What the sample kit's own code does (so the assertions are its stated
behavior, not invention):** `recommendedBlock` answers STON text
`'{ #kit : ''DKKit'', #docChecks : [ ''DKClassCommentCheck'' ] }'`;
`registrationsFrom:…` rejects any key outside `#(#kit #docChecks)` by
signalling `PGRConfigurationError`, then per `#docChecks` name answers a
missing spec (`missing: 'doc/…' kind: #doc`) when
`self environment at: name asSymbol` finds no class, else a live spec
(`name: 'doc/…' kind: #doc check: (cls packages: prodNames)`).

**Execution plan and the guide-stated facts to assert (ordering and the
one harness-supplied input are this work order's calls, recorded in
`chunks.md`):**

1. **Install sample 1.** Assert: `DKKit` exists, superclass `PGRKit`
   (skeleton path), both contract messages on the class side (the
   "two messages, both class-side" claim).
2. **Stanza arm.** `STON fromString: DKKit recommendedBlock` → a map whose
   `#kit` = `'DKKit'` and `#docChecks` = `#('DKClassCommentCheck')` — the
   guide's "parses cleanly as a kit block" (the framework-kit analog of
   P-STANZA-VALID, asserted at the sample kit's boundary).
3. **Strict-validation arm.** `DKKit registrationsFrom:` a Dictionary with
   keys `#kit → 'DKKit'` and `#zzz → #()` (scratch input),
   `productionPackages: #() testsPackages: #()` — expect
   `PGRConfigurationError` signalled (assert the class, never wording) —
   "an unknown key inside it is a `PGRConfigurationError` **you** raise."
4. **Missing arm.** `DKKit registrationsFrom:` its own parsed stanza,
   `productionPackages: #('P-One') testsPackages: #()` — one spec: `name`
   = `'doc/DKClassCommentCheck'`, `kind` = `#doc`, `check` isNil (the
   spec-reader surface is E02-frozen: `name`/`kind`/`check`/
   `missingReason`) — "or the reason it cannot run"; silence was not an
   option.
5. **Resolved arm (harness-supplied input — the C05-recorded reading:
   referenced-but-undefined classes are inputs, the sample stays the code
   under test).** Install a minimal conforming `DKClassCommentCheck`
   (subclass `PGRCheck`, package `Demo-Kit-Checks`, `kind ^ #doc`,
   `run ^ PGRVerdict green`; register for teardown). Re-run arm 4's call:
   now one live spec whose `check` is a `DKClassCommentCheck` with
   `packages` = `#('P-One')` — the promised-constructor handoff
   ("instantiate a class you don't own via its promised `packages:`
   constructor").
6. **Sample 2 (the adopter's file).** Build the artifact as the canonical
   scratch envelope (C05's recorded splice shape over
   `'BaselineOfPGRScratchGrouped'`, project `'Scratch'`, roles
   `scratch-prod`/`scratch-tst`/`scratch-ghost`) whose `#kits` key–value
   is **sample 2 verbatim**. With `DKClassCommentCheck` still installed,
   run `(PGRGate forConfiguration: (PGRConfiguration fromString: …)) run`
   and assert the guide's composition claims: the report's verdict names
   include `'lint/PCKNoIsNilIfTrueRule'` and `'doc/DKClassCommentCheck'`,
   and every PCK-block verdict precedes every DK-block verdict ("blocks
   are self-contained, **ordered**, and independently validated" — D-51;
   the PCK block also derives `behavioral/Phi-Guardrails-Tests-SDK` from
   the scratch tests role — count it among PCK's, assert membership, never
   an exact verdict list). The nested suite run terminates (D-46).
7. Teardown: `removeInstalled` (DKKit, DKClassCommentCheck, `Demo-Kit*`
   packages), `ensure:`-guarded.

**Frozen reader spellings you consume (E02/E05 digests):** a report answers
`verdicts` (ordered); each verdict answers `registrationName` / `status` /
`isGreen` — "the report's verdict names" is
`report verdicts collect: [ :v | v registrationName ]`. A
`PGRRegistrationSpec` answers `name` / `kind` / `check` / `missingReason`;
a check instance answers `packages` (the skeleton reader).

**Why the engine accepts the DK kit:** kit resolution validates class-side
conformance to the two-message contract (E03's `resolveKitClassNamed:`);
spec-level validation then checks the resolved `DKClassCommentCheck`
instance (protocol + kind agreement `#doc` = `#doc`). Kinds are opaque
labels to the core — `#doc` needs no registration anywhere (guide §3).

**Constitution rules that bite here:** scratch classes/packages created
and deleted by the test; assert error classes and stated names, never
wording; no accepted file changes — C05's method byte-identical.

**Epic-close duty (orchestrator-facing, restated from `chunks.md`):** this
is E09's last chunk; its acceptance triggers the E09 exit checkpoint = the
**M1 milestone boundary** (verify sweep + `./guardrails.sh guardrails.ston`
exit 0 + both sample tests green + CI leg, one head commit) and the formal
M1 mining pass.

## DELIVERABLES

- `src/Phi-Guardrails-Tests-Gate/PGRQuickstartSamplesTest.class.st` —
  modified (C05's file): add `testBuildAKitSamples` + its private helpers;
  C05's accepted methods byte-identical.
- LOC budget: target 115 / ceiling 300.

## TESTS FIRST

- `testBuildAKitSamples` — given the committed guide 3 and the C04
  harness; when both samples execute per the plan above; then every
  guide-stated fact holds: the two-message class-side contract; the stanza
  parses to the kit block; the unknown key signals `PGRConfigurationError`;
  the unresolved name answers a `doc/`-named `#doc` missing spec; the
  resolved name is instantiated via `packages:` with the handed list; and
  the composed adopter artifact yields both kits' registrations in block
  order. One method (the D-59 shape), arms failing individually with named
  assertions.

Fixtures: the committed guide file; scratch DK classes/packages built and
removed in-test; `BaselineOfPGRScratchGrouped` by name inside the artifact
string.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists `testBuildAKitSamples` and
          `testWriteACheckSamples` **plus every previously accepted
          suite** — membership plus a floor (≥ 195 run = 174 + the 21 E09
          tests, all prior chunks accepted by this point in the serial
          chain), never an exact ceiling. Then the epic exit checkpoint
          (chunks.md §checkpoint) runs on this chunk's accepted head.

OUT OF SCOPE
- Any edit to C05's methods, the harness, the guides, or any accepted
  file.
- Asserting exact verdict lists, exit codes, report wording, or error
  wording for the composed run — the guide states none of them.
- A committed `DKClassCommentCheck` or any committed sample class — all
  scratch, all removed.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest file, one commit
          `E09-C06: guide-3 samples execute verbatim` (D-73) before
          reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output
  (including the byte-identity statement for C05's methods) ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
