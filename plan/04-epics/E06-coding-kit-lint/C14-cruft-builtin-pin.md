# C14 · Built-in cruft rule pinned: match set + severity      [E06 · depends: — · parallel: yes]

GOAL      Pin the registered built-in `ReCodeCruftLeftInMethodsRule`: a bad
          fixture containing each send form the catalog claims it catches, one
          asserted critique per form (D-55 item 4), the good-fixture silence arm
          (R-37), and the severity pin `severity == #error` (P-BUILTIN-PINNED,
          D-34).

TRACE     ch. 3 §3.2b (the catalog entry) · D-28 (built-in selected, spellings
          verified) · D-34.1 (severity pin) · D-55.4 (match-set pin) · R-37 ·
          P-CAT-FIXTURES, P-BUILTIN-PINNED.

## CONTEXT DIGEST

**The subject.** `ReCodeCruftLeftInMethodsRule` ships with Pharo (verified live,
D-28): it fires on `self halt`, `self haltIf:`, `Transcript show:`, `self flag:`;
its shipped class-side `severity` is `#error`; its shipped rationale reads
"Breakpoints, logging statements, etc. should not be left in production code."
We own none of its code — this chunk's product is **tests and fixtures only**.

**Why the pin exists (D-34/D-55, condensed).** The rule's blocking status is
inherited from the image, not declared by our code — a Pharo upgrade demoting it
to `#warning` would silently stop the gate blocking on debug cruft (severity is
the only tiering: `#error` blocks, the rest inform — D-03). So a third test
beside the fixture pair asserts `severity == #error`, turning drift into a red
test. And the bad fixture **pins the match set**: it contains each send form the
catalog entry claims, one asserted critique per form, so "what does this built-in
actually catch" is a permanent regression guard, not a one-time probe.

**If a claimed form turns out NOT to be matched** (the D-55 P5 gap, anticipated):
that is a fixture fact, not a failure of this chunk — drop the unmatched form
from the bad fixture and its assertion, report the discrepancy as a deviation in
the completion report, and append a decision-sheet entry recommending the catalog
row's amendment (the ch. 3 §3.2b claim table is owner-visible ground; agents
recommend, humans rule).

**Fixtures** — in `Phi-Coding-Kit-Tests-Rules` (tests-role: lint reads
production-role packages only, D-25/D-33, so bad fixtures are safe here; plain
`Object` subclasses, not `TestCase`s, so behavioral runs never execute them).
Class comments must state they are declared bad/good fixtures — the sanctioned
exception (R-37/D-26) to the constitution's halt/Transcript/flag ban. The
methods are **never executed** by any test — they exist to be read by the rule
(so `self halt` never actually halts anything).

- `PCKCruftBadFixture` — four methods, one per claimed form:

  ```smalltalk
  withHalt            self halt
  withHaltIf          self haltIf: false
  withTranscriptShow  Transcript show: 'cruft'
  withFlag            self flag: #cruft
  ```

- `PCKCruftGoodFixture` — one clean method (e.g. `cleanMethod ^ 42`).

**Verified headless run recipe** (D-15, verbatim):
`ReSmalllintChecker new rule: {r}; environment: (RBPackageEnvironment
packageName: 'Phi-Coding-Kit-Tests-Rules'); run; criticsOf: r` — where `r` is
`ReCodeCruftLeftInMethodsRule new`.

**⟨verify-in-image⟩ (P5):** the accessor from a critique to its critiqued method
is not yet a recorded spelling — probe it live (candidates: `critique entity` ·
`critique sourceAnchor entity`) before writing assertions and record the
confirmed form in the completion report. (C13 carries the same instruction; the
two chunks are parallel-eligible, so neither depends on the other's report —
whichever lands second simply confirms the same spelling.)

**Filter every assertion by critiqued class/method** — the package holds other
fixture classes (C13's lint pair, later stubs); package-wide counts would be
brittle across siblings.

**Constitution rules that bite here:** glossary (*checks*/*advisories*, AST
*pattern*); no `skip`/`expectedFailures`; a test that cannot fail is a defect;
comments state constraints the code cannot show; `PCK` prefix (D-56); tests named
`<Subject>Test` — the subject here is the built-in's catalog entry, test class
`PCKCodeCruftBuiltInTest` (name fixed by ch. 3 §3.2b).

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export
to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present,
D-15); hand-writing class files is not allowed — the committed form must be what
the tooling emits. After export, a fresh `bash tools/build-image.sh` load from
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against
it.

## DELIVERABLES

- `src/Phi-Coding-Kit-Tests-Rules/PCKCruftBadFixture.class.st`
- `src/Phi-Coding-Kit-Tests-Rules/PCKCruftGoodFixture.class.st`
- `src/Phi-Coding-Kit-Tests-Rules/PCKCodeCruftBuiltInTest.class.st`
- LOC budget: target 100 / ceiling 200.

## TESTS FIRST

Test methods on `PCKCodeCruftBuiltInTest` (first two names fixed by ch. 3 §3.2b's
fixture-pair row; third by D-34/ch. 9):

- `testFiresOnBadFixture` — given the D-15 checker recipe over
  `'Phi-Coding-Kit-Tests-Rules'` / when collecting the rule's critiques / then
  **for each of the four bad-fixture methods** (`withHalt`, `withHaltIf`,
  `withTranscriptShow`, `withFlag`) at least one critique targets it — four
  separate named assertions, the match-set pin: a form silently un-matched by a
  future Pharo is a red test.
- `testSilentOnGoodFixture` — same run / then zero critiques whose critiqued
  method belongs to `PCKCruftGoodFixture`.
- `testSeverityStillBlocks` — given the class / then
  `ReCodeCruftLeftInMethodsRule severity == #error` — **P-BUILTIN-PINNED**; a
  Pharo upgrade demoting it is a red test, never a silent unblocking.

Fixtures: `PCKCruftBadFixture` / `PCKCruftGoodFixture` (this chunk's own
deliverables, above).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 3 `PCKCodeCruftBuiltInTest`
          methods plus every previously accepted suite — the 24 E01/E02 tests
          (19 SDK + 5 smoke), any accepted E06 siblings, and any accepted
          parallel-track (E03) suites (regression guard; membership + floor,
          never an exact ceiling).

OUT OF SCOPE
- Registering the built-in (C16's dispatch; the recommended-block line is C18).
- Any wrapper or subclass of the built-in rule — we own no code of it.
- Touching `package.st` files, the baseline, or anything outside the manifest.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files, one
          commit `C14: built-in cruft rule pinned — match set and severity`
          before reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · the
  confirmed critique→method accessor spelling · match-set discrepancies if any ·
  deviations from the work order (each with one-line justification) · new
  questions for the decision sheet.
