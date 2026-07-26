# E09-C05 · `testWriteACheckSamples` — guide 2 executes verbatim    [E09 · depends: E09-C04 · parallel: no]

GOAL      Land `PGRQuickstartSamplesTest` with its first method: every
          sample in `docs/quickstarts/02-write-a-check.md` executed
          verbatim through the C04 harness and asserted to behave as the
          guide states.

TRACE     ch. 9 §9.2 P-GUIDE-EXEC (write-a-check leg — anchor M1 confirmed,
          D-62/roadmap §0) · D-59, D-60 (the `packages:` constructor and
          plain-class path the samples exercise) · D-41 (the lint sidebar's
          severity rule — prose, no sample) · R-47 (usable cold) · roadmap
          §1 M1 checkpoint (this named test is one of its two sample legs).

## CONTEXT DIGEST

**The property letter (ch. 9):** every code and configuration sample is
executed verbatim and behaves as its guide states — exit codes, verdict
names, signalled error *classes*; never error wording. D-59's recorded
test shape: **one method per guide** — this chunk is one test method (plus
private fixture-input helpers) on a new class `PGRQuickstartSamplesTest`
in `Phi-Guardrails-Tests-Gate` (the home C04's cut recorded).

**Harness surface you consume (E09-C04, in the same package):**
`PGRQuickstartSampleHarness new` — `guideNamed: '02-write-a-check.md'` →
text · `samplesIn:` → 5 ordered (info, body) pairs, tags
`#(smalltalk smalltalk smalltalk ston smalltalk)` (pinned by C04) ·
`install:` compiles a smalltalk sample (fluid class definition + listing
methods, one-liners included; a listing-only body compiles into the
already-installed classes) · `install:slots:` — same, with the given slot
names spliced into the class definition (the author's-own-storage input
path, C04's variant for exactly this chunk's step 1) · `removeInstalled`
tears down everything it created; wrap the whole body in `ensure:` and
also remove in `tearDown` (idempotent — the E08-C04 discipline).

**Sample-by-sample execution plan and the guide-stated facts to assert
(the guide's own sentences, made decidable — this ordering is the work
order's call, recorded in `chunks.md`; sample 2 redefines the same class
name as sample 1, so it runs in an isolated pass first):**

1. **Sample 2 (plain class) — isolated pass.** The sample deliberately
   elides the author's own plumbing: its `packages:` sends
   `self new setPackages: names` and its `run` is "as above" (which reads
   `self packages`), but the fence defines neither the setter nor any
   storage — D-60 recorded the setter spelling as "illustrative, the
   author's own class" (the guide shows the contract; the author owns the
   plumbing). Under the harness-supplied-inputs reading (extended to cover
   exactly this recorded elision — see `chunks.md`), the test plays the
   author's hand: install sample 2 via the harness's
   `install:slots: #(packages)` variant (the class-definition segment
   gains the slot), then compile the two input methods
   (`setPackages: a packages := a` — answers self by default, which
   `^ self new setPackages: names` relies on — and `packages ^ packages`)
   as harness-supplied input, then the sample's own methods stand
   verbatim on top. Guide claim: "the same check with no framework
   superclass registers identically." Assert: the class exists with
   superclass `Object`; `(AcmeClassCommentCheck packages: #('P-One'))`
   answers an instance whose `kind` = `#architecture`, `canFix` = false,
   and `packages` = `#('P-One')` (the sample's own constructor working —
   its `run` body is the verbatim comment-only placeholder, do **not**
   send `run`); then build a registry over the sample-4 splice (below)
   and assert the registration `architecture/AcmeClassCommentCheck` is
   resolved — conformance-not-ancestry, demonstrated at the engine.
   Remove installed classes.
2. **Samples 1 + 5 (skeleton path + fix capability).** Install sample 1
   (class definition + `kind` + the real `run`), then sample 5 onto the
   same class (`canFix` true + `fixCommandOn:`). Assert: superclass is
   `PGRCheck`; an instance answers `canFix` true (the guide's "declares
   it"); the class-side `packages:` is inherited from the skeleton (guide
   §1: "implements `packages:` for you").
3. **Fixture inputs (harness-supplied — inputs the samples reference but
   do not define; the recorded reading: fixture classes are *inputs*, the
   samples are the code under test).** Create scratch packages
   `Acme-Guardrails-Fixtures` holding class `AcmeUncommentedFixture`
   **without** a class comment, and `Acme-Guardrails-GoodFixtures` holding
   `AcmeCommentedFixture` **with** one (any one-sentence comment; ⟨verify⟩
   how an absent comment reads on this image — `comment` nil vs empty —
   sample 1's `run` accepts either). Register both for teardown.
4. **Sample 3 (the fixture pair).** Create scratch class
   `AcmeClassCommentCheckTest` (subclass `TestCase`, package
   `Acme-Guardrails-Tests` — matches no swept pattern) and compile the
   sample's two test methods into it verbatim via the harness. Run
   `AcmeClassCommentCheckTest suite run`. Assert: 2 run, 2 passes, 0
   failures, 0 errors — the guide's bad-fixture-fires / good-fixture-silent
   pair holds against the sample check.
5. **Sample 4 (the registration line).** Splice the fragment verbatim into
   the canonical scratch envelope's coding-kit block (the accepted
   E05-C03 `PGRGateTest` shape — duplicate the helper locally, deliberate
   self-containment):

   ```
   { #schemaVersion : 2, #project : 'Scratch',
     #baseline : 'BaselineOfPGRScratchGrouped',
     #roles : { #production : [ 'scratch-prod' ], #tests : [ 'scratch-tst' ],
                #exempt : [ 'scratch-ghost' ] },
     #kits : [ { #kit : 'PCKKit', <sample-4 text verbatim> } ] }
   ```

   (`BaselineOfPGRScratchGrouped` — accepted E03 fixture, referenced by
   name inside the artifact string, the E05-recorded cross-package idiom;
   its roles expand to `scratch-prod` = SDK + Core, `scratch-tst` =
   `Phi-Guardrails-Tests-SDK`, ghost exempt.) With the skeleton check
   installed (step 2), run
   `(PGRGate forConfiguration: (PGRConfiguration fromString: envelope)) run`
   and assert the guide's stated fact: the report's verdict names include
   `'architecture/AcmeClassCommentCheck'` ("the registration appears in
   every report as…"). Do not assert the run's exit code or the
   `PCKLayerMapCheck` entry's state — the guide states neither (that name
   resolves to no loaded class at M1 and yields a missing verdict; it is
   *someone else's* row). The nested gate run derives
   `behavioral/Phi-Guardrails-Tests-SDK` and runs that suite — nests and
   terminates (D-46).

   For step 1's isolated pass, the same splice is built into a
   **registry**, not a gate run:
   `(PGRRegistry fromConfiguration: …) registrations` — assert the
   registration named `architecture/AcmeClassCommentCheck` answers
   `isResolved` true (`PGRRegistry`/`PGRRegistration` are
   specified-but-internal E04 surface; PGR tests may consume them — the
   accepted `PGRRegistryTest` precedent).

**Frozen reader spellings you consume (E02/E05 digests):** a report answers
`verdicts` (ordered); each verdict answers `registrationName` / `status` /
`isGreen` / `findings`; each finding answers `target` / `message` — so "the
report's verdict names" is
`report verdicts collect: [ :v | v registrationName ]`. A registration
(E04's specified-but-internal surface) answers `name` / `isResolved`.

**One named risk, handled in advance:** the sample check builds findings
with `target: cls name`, and `cls name` answers a **Symbol** on this image,
while sample 3 compares `f target = 'AcmeUncommentedFixture'` (a String).
⟨verify⟩ in-image whether that comparison holds under the live
Symbol/String equality semantics. If the committed sample text fails on it,
that is a **P-GUIDE-EXEC finding against the guide itself** — the property
working as designed: **stop and report** (the guides are producer-owned,
D-59); never patch the guide, the harness, or the assertion to compensate.

**Why the engine accepts the sample check both times:** `PCKKit`'s
promised-constructor path instantiates via `cls packages: roleNames` —
which works in the plain-class pass only because step 1 supplied the
elided storage (without it, `self new setPackages:` is a
`MessageNotUnderstood` before any validation runs) and in the skeleton
pass because `PGRCheck` implements it. Registry construction then
validates conformance on the spec's check instance —
`run`/`kind`/`canFix` present (and `fixCommandOn:` once `canFix` is true,
step 2) — and kind agreement (`#architectureChecks` → spec kind
`#architecture` = the sample's own `kind`). The comment-only bodies
satisfy existence/arity validation; nothing invokes them.

**Constitution rules that bite here:** every scratch class/package is
created and deleted by the test (`ensure:` + `tearDown`); no
`skip`/`expectedFailures`; assert error *classes* and stated names, never
message wording; nothing here touches the guides or any accepted file.

## DELIVERABLES

- `src/Phi-Guardrails-Tests-Gate/PGRQuickstartSamplesTest.class.st` — new;
  class `PGRQuickstartSamplesTest` (subclass `TestCase`, package
  `Phi-Guardrails-Tests-Gate`): `testWriteACheckSamples` plus private
  helpers (fixture-input builders, the envelope splice, teardown wiring).
  `testBuildAKitSamples` is **C06's scheduled addition to this same file**
  — do not stub it (an empty test body is a forbidden move).
- LOC budget: target 150 / ceiling 300.

## TESTS FIRST

- `testWriteACheckSamples` — given the committed guide 2 and the C04
  harness; when the five samples execute per the plan above; then every
  guide-stated fact holds: (§2) the plain class conforms and registers
  resolved; (§1/§5) the skeleton class carries `kind`/`run`/`canFix`
  true/`fixCommandOn:`; (§3) the sample fixture-pair tests run 2/2 green
  against the sample check; (§4) the gate report's verdict names include
  `architecture/AcmeClassCommentCheck`. One method — the D-59 shape; its
  internal arms fail individually with named assertions.

Fixtures: the committed guide file (ground truth); scratch Acme
classes/packages built and removed in-test; the accepted
`BaselineOfPGRScratchGrouped` by name inside the artifact string.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists `testWriteACheckSamples`
          **plus every previously accepted suite** — membership plus a
          floor (≥ 179 run = 174 + C04's 4 + this 1; ≥ 194 once C01–C03
          have also landed per the listed serial pick order), never an
          exact ceiling.
          Regression guard: the four `PGRQuickstartSampleHarnessTest`
          methods stay green (same file family, same run).

OUT OF SCOPE
- `testBuildAKitSamples` and every guide-3 concern (C06).
- Any edit to the guides, the harness, or any accepted file — a sample the
  surface no longer satisfies is a red test to **report**, not a document
  or product to patch (P-GUIDE-EXEC's whole point).
- Asserting report wording, error wording, or the `PCKLayerMapCheck` row's
  state.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest file, one commit
          `E09-C05: guide-2 samples execute verbatim` (D-73) before
          reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  the recorded ⟨verify⟩ spellings (scratch class-comment behavior,
  class/package creation-removal forms actually used) ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
