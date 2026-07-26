# E09-C04 · The quickstart sample harness    [E09 · depends: — · parallel: yes]

GOAL      Build the verbatim-sample execution machinery P-GUIDE-EXEC needs:
          markdown fence extraction from the committed guides, compilation
          of Smalltalk class/method samples into scratch packages, and
          guaranteed teardown — proven by its own pin tests against the
          real guide files.

TRACE     D-59, D-60, D-60.a · ch. 9 §9.2 P-GUIDE-EXEC (the harness half —
          the roadmap E09 risk line names this design as the chunk stage's)
          · P1 (the guides cannot rot) · R-47 (usable cold, D-45 ruling 5).

## CONTEXT DIGEST

**What P-GUIDE-EXEC demands (ch. 9, condensed):** every code and
configuration sample in `docs/quickstarts/*.md` is executed verbatim at its
guide's anchor milestone and must behave as the guide states — exit codes,
verdict names, and signalled error *classes*, never error wording. Guides
2–3 anchor at M1 (E09-C05/C06 write those tests **against this harness**);
guide 1 anchors at M4 (E15) — the harness must not choke on its file but
builds nothing for it now.

**The committed sample inventory (ground truth at cut time — the pin tests
below freeze it):**

- `docs/quickstarts/02-write-a-check.md` — five fenced blocks, in order:
  1. ```` ```smalltalk ```` — skeleton path: fluid class definition
     `PGRCheck << #AcmeClassCommentCheck package: 'Acme-Guardrails'` plus
     methods `kind` and `run` in listing form (`ClassName >> selector` +
     body lines).
  2. ```` ```smalltalk ```` — plain-class path: `Object << …` class
     definition, a class-side method (`AcmeClassCommentCheck class >>
     packages:`), and **one-line method definitions** (header and body on
     the same line, e.g. `AcmeClassCommentCheck >> kind      ^ #architecture`)
     including a comment-only body (`run       "as above"`).
  3. ```` ```smalltalk ```` — two SUnit test methods on
     `AcmeClassCommentCheckTest` (listing form).
  4. ```` ```ston ```` — a kit-block *fragment*:
     `#architectureChecks : [ 'PCKLayerMapCheck', 'AcmeClassCommentCheck' ]`.
  5. ```` ```smalltalk ```` — the fix-capability pair: `canFix` +
     `fixCommandOn:` (comment-only body) in listing form.
- `docs/quickstarts/03-build-a-kit.md` — three fenced blocks: one **plain
  (untagged)** fence (the naming tree — prose illustration, not a sample),
  one ```` ```smalltalk ```` (the `DKKit` class: fluid definition
  `PGRKit << #DKKit package: 'Demo-Kit'` + two **class-side** methods
  `DKKit class >> recommendedBlock` and `DKKit class >>
  registrationsFrom:productionPackages:testsPackages:`), one
  ```` ```ston ```` (a full `#kits : [ … ]` key–value fragment naming a
  `PCKKit` block and a `DKKit` block).

**Harness design (this work order's calls, recorded veto-open in
`chunks.md`):**

1. **Extraction.** `samplesIn: aGuideText` answers the ordered fenced
   blocks as (info, body) pairs: a fence opens at a line beginning
   ```` ``` ```` and closes at the next such line; info = the trimmed,
   lowercased remainder of the opening line. Blocks tagged `smalltalk` or
   `ston` are samples; untagged (or otherwise-tagged) fences are prose
   illustrations and are excluded. Order preserved.
2. **Guide access.** `guideNamed: aFileName` reads
   `docs/quickstarts/<aFileName>` as a string via the repo-root locator:
   walk upward (≤ 8 levels) from `FileSystem workingDirectory`, then — and
   only if that fails — probe a `SmalltalkCI`-provided project directory
   when that global exists (⟨verify⟩: smalltalkCI's in-image spelling for
   the checked-out project path; record what CI actually provides), then
   walk upward from `FileLocator imageDirectory`; all three failing is
   `self error:` — loud, never a skip. Locally the suite launches from the
   repo root and the work image sits two levels down (`.build/work/`).
   Tests may do file I/O — P-DETERMINISTIC binds production packages only.
3. **Class-sample compilation.** `install: aSmalltalkSampleBody` splits the
   body into segments at lines matching the listing header
   `Name >> selector…` or `Name class >> selector…` (a line whose first
   two tokens are an identifier and `>>`, or first three are identifier,
   `class`, `>>`). The pre-header segment, when it contains `<<`, is the
   fluid class definition: evaluate it **with `; install` appended as a
   cascade** — the verified idiom is the cascade shape
   `Object << #Name package: 'P'; install` (the D-71 probe's spelling;
   ⟨verify⟩ it holds for the guides' two-line form and record it). A body
   with **no** pre-header segment (listing-only) compiles its methods into
   the already-installed classes. The variant
   `install: aBody slots: slotNameArray` splices `slots: { … };` into the
   class-definition cascade before installing — the author's-own-storage
   input path C05's plain-class pass needs (plain `install:` ≡
   `slots: #()`). Each header segment compiles into the named class
   (instance side) or its metaclass (`class >>` form): the method source
   is the header line **minus** the `Name( class)? >> ` prefix, plus all
   following lines — this makes one-line definitions
   (`… >> kind      ^ #architecture`) and multi-line bodies compile
   identically, and a comment-only body (`run       "as above"`) compiles
   to a valid (self-returning) method, which is exactly verbatim execution.
4. **Teardown registry.** The harness records every class and package it
   creates (`Acme-*`, `Demo-Kit*`, and the scratch homes C05/C06 choose)
   and `removeInstalled` removes them (class removal + package removal
   spellings ⟨verify⟩, record them); callers wrap use in `ensure:`. Scratch
   package names must match **no** swept pattern
   (`Phi-Guardrails-Tests-.*` / `Phi-Coding-Kit-Tests-.*`) and no role of
   the framework's own artifact — `Acme-*` / `Demo-Kit*` / `PGR-Scratch-*`
   satisfy this (D-59 chose the sample namespaces disjoint from
   `PGR`/`PCK`/`Toy`). A teardown failure leaks at worst into one run —
   the work image is rebuilt per verify run (the E08-C01 bounding
   argument).
5. **Residency.** The harness is a plain class (not a TestCase) named
   `PGRQuickstartSampleHarness` in `Phi-Guardrails-Tests-Gate`, beside the
   sample tests that will drive gates (C05/C06) — D-59's veto-open home,
   closed by this cut: the samples drive the gate only on scratch
   configurations, which nests and terminates (the D-46 argument).
   Instance-side state: the teardown registry only — fresh per instance,
   no class-side state (R-35).

**Constitution rules that bite here:** no global state (the registry is
instance state); tests-first with failing skeletons; a test that cannot
fail is a defect — the pin tests below fail against a wrong parser or a
drifted guide; scratch classes/packages are created and deleted by the
tests (`setUp`/`tearDown`/`ensure:` — the sanctioned scratch pattern).

## DELIVERABLES

- `src/Phi-Guardrails-Tests-Gate/PGRQuickstartSampleHarness.class.st` —
  new: the extraction, locator, compilation, and teardown machinery above.
- `src/Phi-Guardrails-Tests-Gate/PGRQuickstartSampleHarnessTest.class.st`
  — new: the four pin tests.
- Nothing else — `PGRQuickstartSamplesTest` itself is C05's file; the
  guides are producer-owned and are **not** edited.
- LOC budget: target 160 / ceiling 300.

## TESTS FIRST

- `testGuideTwoSampleInventory` — given the committed
  `02-write-a-check.md`; when `samplesIn:` runs; then it answers exactly
  5 samples with info tags, in order, `#(smalltalk smalltalk smalltalk
  ston smalltalk)` — the freeze that makes a guide edit a visible test
  event, not silent drift.
- `testGuideThreeSampleInventory` — given the committed
  `03-build-a-kit.md`; then exactly 2 samples, tags `#(smalltalk ston)` —
  the untagged naming-tree fence was excluded.
- `testClassSampleInstallsAndRemoves` — given an inline mini-sample string
  (`Object << #PGRScratchGuideProbe package: 'PGR-Scratch-Guide'` plus a
  one-line method `PGRScratchGuideProbe >> answer ^ #probed`); when
  installed via `install: … slots: #(probeSlot)` plus a listing-only
  second call compiling a setter/reader pair for the slot; then the class
  exists, `new answer` = `#probed`, and slot state round-trips through the
  pair (the C05 storage-input path proven here); after `removeInstalled`,
  the class is gone from `Smalltalk globals` (run under `ensure:`).
- `testListingHeaderSplitsClassSideAndOneLiners` — given an inline sample
  with a fluid definition, a `class >>` method, and a one-line
  instance-side method; when installed; then the class-side selector is on
  the metaclass, the instance-side one-liner compiles and answers — the
  §2/§3 listing forms of the guides are all parseable (run under
  `ensure:`, then removed).

Fixtures: the two committed guide files (read-only ground truth); inline
sample strings for the round-trip arms — no committed scratch classes.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 4
          `PGRQuickstartSampleHarnessTest` methods **plus every previously
          accepted suite** — membership plus a floor (≥ 178 run = 174 + 4;
          parallel-landed E09 chunks add to the count), never an exact
          ceiling.

OUT OF SCOPE
- `PGRQuickstartSamplesTest` and any assertion about what the samples *do*
  (C05/C06).
- Editing any guide file — a guide whose committed text defeats the parser
  is a **stop and report** (the guides are producer-owned, D-59).
- Guide 1 execution machinery beyond not-choking (M4/E15).
- Generic markdown parsing beyond the fence rules above.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `E09-C04: quickstart sample harness` (D-73) before reporting for
          review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  the recorded ⟨verify⟩ spellings (fluid-install form, class/package
  removal, the CI project-directory probe) ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
