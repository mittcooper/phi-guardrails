# E05-C06 · Escape arms: throwing kit, throwing stream, kit-raised config error    [E05 · depends: E05-C05 · parallel: no]

GOAL      Prove the top-level handler adversarially — P-NEVER-UNDECIDED
          discharged and the E04 validation ADVISORY (kit-raised
          `PGRConfigurationError` propagation) tested in both arms — with
          fixtures only, no product code.

TRACE     D-39 (rulings 2–3: the handler and its fixtures — "without these
          the arm is untested by construction, since nothing else in the
          suite crashes on purpose") · ch. 7 §7.3 · ch. 9
          (P-NEVER-UNDECIDED: `PGRGateTest>>#testEscapedExceptionExitsTwo`)
          · the E04 Gate-4 ADVISORY (recorded in E04 `chunks.md` addendum:
          kit-raised error propagation out of `fromConfiguration:` stated
          but untested — this cut's exit-2 tests are its recorded home;
          test the direct arm) · E04 digest (the propagation claim itself).

## CONTEXT DIGEST

**What exists.** `PGRGate class>>runHeadless:on:` (E05-C05) wraps the entire
run in the top-level handler: anything escaping → one error line naming the
exception → answers 2; the error-line write is itself guarded, so a broken
stream still gets its number. `PGRGate class>>forConfiguration:` builds the
registry **eagerly** via `PGRRegistry fromConfiguration:` (E04, internal),
whose frozen claim reads: *"a kit's `PGRConfigurationError` raised inside
`registrationsFrom:…` propagates out of `fromConfiguration:` unhandled (E05
maps it to exit 2)"* — stated, never yet tested (the E04 scratch kit is
deliberately obedient). `PGRGateTest` has 12 green tests, the
`artifactWithKitsFragment:` envelope helper, and the `scratchDirectory`
file discipline (E05-C05).

**The kit protocol a scratch kit must answer (frozen E02 surface):**
class-side `registrationsFrom: aBlock productionPackages: productionNames
testsPackages: testsNames` (answers ordered `PGRRegistrationSpec`s) ·
`recommendedBlock` (STON text). A kit that cannot resolve or validate its
own block raises `PGRConfigurationError` — the kit-author grant (D-60).

**New fixtures (this chunk's deliverable, residing in
`Phi-Guardrails-Tests-Gate` beside their tests — the E04-C01 residency rule
applied to this package; class-side only, stateless, none a `TestCase`):**

- `PGRScratchThrowingKit` — `registrationsFrom:productionPackages:testsPackages:`
  raises `Error new signal: 'scratch kit exploded'` (a plain `Error`, NOT a
  configuration error — the escape fixture D-39 ruling 3 demands);
  `recommendedBlock` answers `'{ #kit : ''PGRScratchThrowingKit'' }'`.
- `PGRScratchConfigErrorKit` — same protocol;  `registrationsFrom:…` raises
  `PGRConfigurationError new signal: 'scratch kit block defect'` (the
  kit-author grant exercised disobediently); `recommendedBlock` answers
  `'{ #kit : ''PGRScratchConfigErrorKit'' }'`.
- `PGRScratchThrowingWriteStream` — a write-stream stand-in whose every
  write raises `Error new signal: 'scratch stream exploded'`. Implement the
  smallest message set the C02 rendering and the C05 handler actually send
  (⟨verify-in-image⟩ delegated with record-in-report duty: enumerate the
  sends — candidates `nextPutAll:`, `nextPut:`, `lf`, `flush`, `<<` — and
  raise from each; a subclass of `Object`, not of `WriteStream`, so an
  unimplemented write is `doesNotUnderstand`, itself an `Error` the handler
  must survive — either way the number gets decided, which is the point).

**Kit resolution:** the envelope's `#kits` entries name kit classes by
string; `PGRConfiguration` resolves them via `Smalltalk classNamed:` with
class-side conformance (E03, accepted) — the new fixtures are resolvable as
soon as they are loaded; no registration anywhere else is needed
(P-LOADING-INERT: presence activates nothing — these classes enter runs
only when an artifact names them).

**The property, restated decidably (P-NEVER-UNDECIDED, D-39.2):** with a kit
that throws during registry construction (and, separately, a sink/stream
that throws), `runHeadless:on:` answers **2**, wrote one error line naming
the exception (where the stream permits writing at all), and **did not
raise** — no path through either `runHeadless:` form ends without answering
0, 1, or 2.

**Constitution rules that bite here:** fixtures exist to be caught —
deliberately-broken behavior lives in fixture classes, never in test logic;
no product-code change (if the handler cannot survive an arm, stop and
report — that is a C05 defect finding, not this chunk's to patch); tests
assert behavior.

**Authoring rule (E01 precedent, verbatim):** author in-image and export to
`src/` with the image's Tonel tooling; hand-writing class files is not
allowed. After export, a fresh `tools/build-image.sh` load from committed
`src/` proves the round trip.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Guardrails-Tests-Gate/PGRScratchThrowingKit.class.st` — new.
- `src/Phi-Guardrails-Tests-Gate/PGRScratchConfigErrorKit.class.st` — new.
- `src/Phi-Guardrails-Tests-Gate/PGRScratchThrowingWriteStream.class.st` —
  new.
- `src/Phi-Guardrails-Tests-Gate/PGRGateTest.class.st` — modify: the four
  tests below. **No product code.**
- LOC budget: target 115 / ceiling 200.

## TESTS FIRST

Test methods on `PGRGateTest` (artifact files written under the existing
`scratchDirectory`; `#kits : [ { #kit : 'PGRScratchThrowingKit' } ]` etc.):

- `testEscapedExceptionExitsTwo` — **ch.-9-named, P-NEVER-UNDECIDED (kit
  arm)** — given an artifact file naming `PGRScratchThrowingKit` / when
  `runHeadless:on:` a String write stream / then it answers 2, did not
  raise, and the stream holds exactly one line whose text includes
  `'scratch kit exploded'` — the escape was caught, named, and numbered.
- `testThrowingStreamStillAnswersTwo` — **P-NEVER-UNDECIDED (stream arm —
  ch. 9's "and, separately, a sink that throws")** — given a *clean*
  artifact file and a `PGRScratchThrowingWriteStream` / when
  `runHeadless:on:` it / then it answers 2 and did not raise — even the
  error line's own failure is swallowed; deciding the number wins.
- `testKitRaisedConfigurationErrorExitsTwo` — **the E04 ADVISORY, headless
  arm** — given an artifact file naming `PGRScratchConfigErrorKit` / when
  `runHeadless:on:` a String write stream / then it answers 2 and wrote
  exactly one line including `'scratch kit block defect'` — the kit-author
  grant lands as a configuration error, code 2, before any check runs.
- `testKitConfigurationErrorPropagatesFromConstruction` — **the E04
  ADVISORY, direct arm** — given the same artifact as a string / when
  `PGRGate forConfiguration:` (in-image, no handler) / then
  `PGRConfigurationError` is raised with `'scratch kit block defect'` in
  its message — the frozen E04 claim ("propagates out of
  `fromConfiguration:` unhandled") witnessed through the gate's eager
  build.

Fixtures: the three new scratch classes above; the accepted E04-C01 cast
untouched.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 16 `PGRGateTest` methods
          (12 prior + 4 new) and the 7 `PGRReportTest` methods **plus every
          previously accepted suite** — membership plus a floor (≥ 174 run
          when stacked after E05-C01–C05), never an exact ceiling; the three
          fixture classes appear in no test-run line (none is a
          `TestCase`).

OUT OF SCOPE
- Any product-code change to `PGRGate`/`PGRReport`/`PGRRegistry` — a
  surviving-handler failure is a stop-and-report finding.
- Amending any accepted test anywhere.
- `guardrails.sh` — E05-C07.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `E05-C06: escape arms and throwing fixtures` (D-73) before
          reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet · the enumerated write-message set
  the throwing stream implements (P5 record duty).
