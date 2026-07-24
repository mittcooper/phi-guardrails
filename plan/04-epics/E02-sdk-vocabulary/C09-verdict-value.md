# C09 · PGRVerdict value      [E02 · depends: C08 · parallel: no]

GOAL      Land `PGRVerdict` — one registration's outcome: five class-side
          constructors total over P6's states, the frozen caller readers, and the
          internal engine-stamping members the registration machinery (E04) will
          consume.

TRACE     spec ch. 1 §1.3 (`PGRVerdict` row) · §1.4 ("the registration stamps
          name/kind/duration") · §1.5 (missing is a verdict; the report shows what
          was missing *and why*) · glossary *verdict* / *green/red/missing/skipped*
          / *advisory* · D-21/D-32 (`skipped` is the fail-closed reserve,
          engine-only) · D-51 (`scope` removed) · D-53/D-54 (vocabulary; blessed
          data-crossing) · R-04 (boundary half).

## CONTEXT DIGEST

**What exists when this chunk starts:** C08 accepted — `PGRFinding` in
`Phi-Guardrails-SDK` with class-side `target:message:` / `target:message:rationale:`
and readers `target`/`message`/`rationale`. Both SDK packages are E01 stubs
otherwise; the baseline is **not** edited.

**The class — `PGRVerdict` in `Phi-Guardrails-SDK`, a «value» of the boundary
vocabulary.** Frozen surface (freezes at E02 acceptance; ch. 1 §1.3 verbatim):

- class side (check author — except where noted):
  `green` · `greenAdvisories:` · `redFindings:` · `missingReason:` ·
  `skipped` (**engine-only** — see below)
- instance side (caller, reading): `status` · `findings` · `advisories` ·
  `registrationName` · `kind` · `durationMillis` · `isGreen`

**Semantics per constructor** (statuses are the four Symbols
`#green` / `#red` / `#missing` / `#skipped`; `isGreen` ⇔ `status == #green`;
everything non-green fails the gate):

| Constructor | status | findings | advisories | notes |
|---|---|---|---|---|
| `green` | `#green` | empty | empty | ran, nothing to report |
| `greenAdvisories: aCollection` | `#green` | empty | the handed `PGRFinding`s | the sub-`#error` lint case (ch. 2 §2.3) and the layer-map `#unlayered` line — advisories are reported, never block; `isGreen` stays true |
| `redFindings: aCollection` | `#red` | the handed `PGRFinding`s | empty | ran with blocking findings (an erroring check also becomes red — that conversion is E04's, not this class's) |
| `missingReason: aString` | `#missing` | empty | empty | the registration could not resolve; the reason string is stored (see internal reader below) |
| `skipped` | `#skipped` | empty | empty | **engine-only** (D-21/D-32): check authors must never emit it; no v1 code path produces it in a completed run; it exists so the vocabulary stays total over P6's states — its only legitimate producer is report construction over a partially-run registry. It is deliberately absent from the Check-author SDK and both spec diagrams. The class comment must carry this note |

**Engine-stamping members (internal — specified for implementation, changeable
without notice, never on the frozen surface):** §1.4 says the *registration* stamps
name/kind/duration onto the verdict after `run`. Provide instance-side setters
`registrationName:` · `kind:` · `durationMillis:` in a browser protocol named
`'internal - engine stamping'` (agent call, veto-open, recorded in the chunk
index). Their readers (`registrationName`, `kind`, `durationMillis`) ARE frozen
caller surface; unstamped they answer `nil`.

**Internal `missingReason` reader (agent call, veto-open, recorded):** the frozen
caller surface lists no reason reader, yet §1.5 requires the report to show
"precisely what was missing and why" — so `missingReason:` stores its string and an
**internal** instance reader `missingReason` exposes it for report rendering (E05).
Internal = changeable without notice; it is not part of the freeze.

**Design constraints:**
- Handed collections are copied to `Array` at construction (value semantics — a
  caller mutating its own collection afterwards must not reach into the verdict; no
  shared mutable state, R-35's spirit).
- `findings` and `advisories` always answer a collection — empty by default, never
  `nil`.
- Values are dumb: no validation in constructors (strictness is the engine's).
- Class-side named constructors over `new`+setters; private setters in a
  private-marked protocol; contract methods in surface-named protocols
  (`'instance creation'`, `'accessing'`, `'testing'` for `isGreen`).
- R-04: nothing in `-SDK` references SUnit/Renraku/RB classes.

**Constitution rules that bite here:** `PGR` prefix; glossary exactly (verdict
statuses are green/red/missing/skipped — never "passed/failed"; non-blocking items
are *advisories*); no global state, no class-side caches; comments state
constraints code cannot show; SUnit, no `skip`/`expectedFailures`, a test that
cannot fail is a defect.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits (see `src/Phi-Guardrails-Tests-Core/PGRBaselineSmokeTest.class.st`).
After export, a fresh `tools/build-image.sh` load from the committed `src/` is the
proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it
and asserts run count plus the 5 smoke tests.

## DELIVERABLES

- `src/Phi-Guardrails-SDK/PGRVerdict.class.st` — the value class as specified.
- `src/Phi-Guardrails-Tests-SDK/PGRVerdictTest.class.st` — its mirror test.
- LOC budget: target 130 / ceiling 200.

## TESTS FIRST

Test methods on `PGRVerdictTest`:

- `testGreenVerdict` — given `PGRVerdict green` / then `status` is `#green`,
  `isGreen` is true, `findings` and `advisories` are empty collections (not `nil`).
- `testGreenWithAdvisoriesStaysGreen` — given `greenAdvisories:` with one
  `PGRFinding` / then `status` `#green`, `isGreen` true, `advisories` carries
  exactly the handed finding, `findings` empty — advisories never block.
- `testRedFindingsVerdict` — given `redFindings:` with one `PGRFinding` / then
  `status` `#red`, `isGreen` false, `findings` carries exactly it, `advisories`
  empty.
- `testMissingVerdictCarriesReason` — given `missingReason: 'class not loaded'` /
  then `status` `#missing`, `isGreen` false, `missingReason` answers the string,
  `findings` and `advisories` empty.
- `testSkippedVerdictIsNotGreen` — given `PGRVerdict skipped` / then `status`
  `#skipped` and `isGreen` false (the engine-only reserve is constructible and
  non-green; the engine-only rule is contract, not mechanism).
- `testEngineStampingReadBack` — given a green verdict stamped via the three
  internal setters (`registrationName: 'lint/X'`, `kind: #lint`,
  `durationMillis: 12`) / then the three frozen readers answer exactly those values
  (and answer `nil` before stamping).
- `testHandedCollectionsAreCopied` — given an `OrderedCollection` handed to
  `redFindings:` / when the caller adds another finding to its own collection
  afterwards / then the verdict's `findings` still holds only the original one.

Fixtures: none (findings constructed inline via C08's frozen constructors).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 7 `PGRVerdictTest` methods, the
          3 `PGRFindingTest` methods, and the 5 `PGRBaselineSmokeTest` methods
          (regression guard; plus any other accepted siblings').

OUT OF SCOPE
- The error→red conversion, duration measurement, and stamping *invocation* — all
  E04 (`PGRRegistration>>run`); this chunk only makes stamping possible.
- Report aggregation/rendering (E05), any `printOn:` on the verdict (the report
  owns rendering; nothing here is promised).
- `PGRRegistrationSpec` (C10), the skeletons (C11).
- Editing the baseline, any `package.st`, or anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md`
          (`bash tools/precheck.sh` once C06 is accepted; else by eye — D-67).
          Postcondition: exactly the manifest files, one commit
          `C09: PGRVerdict value` before reporting for review; nothing left
          uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
