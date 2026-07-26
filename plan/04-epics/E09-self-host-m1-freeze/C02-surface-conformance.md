# E09-C02 · `PGRSurfaceConformanceTest` — the machine-witnessed freeze    [E09 · depends: — · parallel: yes]

GOAL      Freeze the published surfaces by machine: a class-side manifest
          mirroring ch. 0 §0.3's audience surfaces, and a test asserting
          every promised (class, side, selector) exists as promised — a
          renamed or dropped member is a red test, not a client surprise.

TRACE     R-04 (machine half) · ch. 0 §0.3 · ch. 9 §9.1 P-SURFACE-CONFORMS
          · D-48, D-49, D-53, D-54, D-60 · roadmap §2 ("From E09 the freeze
          is machine-witnessed").

## CONTEXT DIGEST

**The ch. 9 letter:** for every (class, selector) pair in the audience
surfaces — mirrored as the test's class-side manifest, kept in sync with
ch. 0 §0.3 — the class exists and implements **or inherits** the selector
on the stated side with matching arity. Since a selector's arity is
intrinsic to its spelling, asserting successful lookup of the exact
selector *is* the arity assertion (record this reading in the class
comment). Lookup: class side via `cls class canUnderstand: sel` (or
`respondsTo:` on the class object — either includes inheritance), instance
side via `cls canUnderstand: sel`.

**The complete M1 manifest — inline it verbatim as class-side data, one
audience per method or one keyed structure (triples: class name · #class |
#instance · selector).** This roster is ch. 0 §0.3 checked against the
accepted E02/E03/E05/E08 sources; every row below exists today — a failing
row at implementation time means a transcription slip on your side, not a
product defect:

*Gate-caller SDK (read-only by construction):*
- `PGRGate` class: `runHeadless:` · `runHeadless:on:` · `forConfiguration:`
- `PGRGate` instance: `run` · `onVerdict:`
- `PGRConfiguration` class: `fromFile:` · `fromString:`
- `PGRReport` instance: `verdicts` · `isClean` · `exitCode` ·
  `blockingVerdicts` · `advisories`
- `PGRVerdict` instance: `status` · `isGreen` · `registrationName` ·
  `kind` · `durationMillis` · `findings` · `advisories`
- `PGRFinding` instance: `target` · `message` · `rationale`

*Check-author SDK:*
- `PGRCheck` class: `packages:` — instance: `run` · `kind` · `canFix` ·
  `fixCommandOn:` (the skeleton implements all four; implements-or-inherits
  is the assertion, `subclassResponsibility` bodies count as implemented)
- `PGRVerdict` class: `green` · `greenAdvisories:` · `redFindings:` ·
  `missingReason:`
- `PGRFinding` class: `target:message:` · `target:message:rationale:`

*Kit-author SDK (beyond the check-author rows):*
- `PGRKit` class: `registrationsFrom:productionPackages:testsPackages:` ·
  `recommendedBlock`
- `PGRRegistrationSpec` class: `name:kind:check:` · `missing:kind:reason:`

*Fix-invoker SDK:*
- `PCKFixCommand` class: `rule:packages:` — instance: `previewOn:` ·
  `apply` · `changes`

*Error vocabulary (catchable/signallable by class):*
`PGRConfigurationError` · `PGRNotAutofixable` · `PGRFixNotPreviewed` ·
`PGRFixStale` — each exists and inherits from `Error`.

**Deliberate M1 exclusions (agent calls, recorded veto-open in
`chunks.md`; do not add them):** the config-author audience has **no code
member at M1** — `PGRConfigurationDraft class>>draftFor:` is E12's and
joins the manifest by that epic's scheduled edit (the manifest grows like
the artifact, constitution §3). `PGRVerdict class>>skipped` exists but is
deliberately off every surface (D-21/D-32 — check authors must never emit
it). `PGRCheck` instance `packages` and `setPackages:` are agent-detail
internals (D-60), not surface. `PGRReport class>>project:verdicts:`, the
rendering seam, and all `PGRConfiguration` instance readers are internal
(E05/E03 digests).

**Constitution rules that bite here:** test methods assert behavior — the
manifest-driven test fails when any row stops resolving, and the guard
test fails if the manifest is gutted; no global state (the manifest is a
class-side *method* answering fresh data, never a class-side variable).

## DELIVERABLES

- `src/Phi-Guardrails-Tests-SDK/PGRSurfaceConformanceTest.class.st` — new;
  class `PGRSurfaceConformanceTest` (subclass of `TestCase`, package
  `Phi-Guardrails-Tests-SDK`): the class-side manifest (grouped by the
  audiences above) and the three test methods. Nothing else.
- LOC budget: target 120 / ceiling 300. (The manifest is data-shaped but
  lives in methods; count it.)

## TESTS FIRST

- `testEverySurfaceSelectorExistsWithRightArity` — the ch.-9-named test.
  Given the full manifest; when every triple is resolved against
  `Smalltalk globals`; then every named class exists and
  implements-or-inherits its selector on the stated side, with **every
  failing row named in the failure description** (class · side ·
  selector); and the sweep visited ≥ 40 triples (the nonzero-scan guard —
  the M1 roster is 41).
- `testErrorSurfaceClassesAreCatchableByClass` — given the four error
  class names; then each resolves and `inheritsFrom: Error` (the
  catch-by-class promise, D-49).
- `testManifestSpansTheFourCodeSurfacesAtM1` — given the manifest's
  audience grouping; then exactly the four code audiences are present
  (check-author, kit-author, gate-caller, fix-invoker), each non-empty —
  and the config-author audience has no code member yet (the M1-form pin;
  E12's cut amends this test by schedule when `draftFor:` lands).

Fixtures: none — the subject is the loaded surface itself.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 3
          `PGRSurfaceConformanceTest` methods **plus every previously
          accepted suite** — membership plus a floor (≥ 177 run = 174 + 3;
          parallel-landed E09 chunks add to the count), never an exact
          ceiling.

OUT OF SCOPE
- Adding, renaming, or "fixing" any surface member anywhere in `src/` — a
  manifest row that will not resolve means transcription error here or a
  genuine frozen-surface defect: **stop and report**, never patch product.
- `PGRConfigurationDraft` in any form (E12).
- Behavioral assertions about what the members *do* (other suites own
  that) — this chunk asserts existence/side/arity only (D-54: complete-
  and-minimal is judgment-tier; P-SURFACE-CONFORMS covers existence/arity).
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest file, one commit
          `E09-C02: PGRSurfaceConformanceTest machine freeze` (D-73)
          before reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
