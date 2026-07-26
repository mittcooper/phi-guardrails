# E05-C03 · `PGRGate`: `forConfiguration:`, `onVerdict:`, `run`    [E05 · depends: E05-C02 · parallel: no]

GOAL      Land the in-image gate object: eager registry construction, one
          verdict per registration in registry order, caller-supplied sink
          streaming (none by default), report answered — P-GATE-COMPLETE,
          P-STREAM, and P-JUDGE-CONVICTS discharged.

TRACE     R-30 (one engine, two modes — this is the in-image mode) · R-45 as
          amended by D-55 (no default sink) · ch. 7 §7.2 · ch. 9
          (P-GATE-COMPLETE: `PGRGateTest>>#testOneVerdictPerRegistration`;
          P-STREAM: `>>#testVerdictsStreamInOrder` +
          `>>#testNoSinkMeansNoStreaming`; P-JUDGE-CONVICTS:
          `>>#testDeliberatelyRedRegistrationIsReported`, D-40) · D-53.5.

## CONTEXT DIGEST

**Package and residency.** `PGRGate` joins `PGRReport` (E05-C02) in
`Phi-Guardrails-Gate`; `PGRGateTest` joins `PGRReportTest` in
`Phi-Guardrails-Tests-Gate`. Gate may depend on `-Core` and `-SDK` (ch. 0
§0.1); it must never reference a kit class (P-FIX-GATE-WALL).

**The specified-but-internal E04 surface this chunk consumes (verbatim from
the E04 digest — changeable only via decision-sheet entry while E05 is in
flight):**

- `PGRRegistry class>>fromConfiguration: aPGRConfiguration` — builds the
  run's registry; validates every resolved spec (conformance + kind
  agreement) and rejects duplicate names **before answering**; a kit-raised
  `PGRConfigurationError` propagates out unhandled.
- `PGRRegistry>>registrations` (ordered; fresh `Array` copy per send) ·
  `size`.
- `PGRRegistration>>name` · `kind` · `isResolved` · `run` → a `PGRVerdict`
  stamped with registrationName/kind/durationMillis, total over
  resolved-green / resolved-red / erroring-red (D-21) / missing (§1.5); no
  `#skipped` producer.

**The E03 frozen caller surface:** `PGRConfiguration class>>fromString:`
(signals `PGRConfigurationError` on any defect). Specified-but-internal
reader used here: `project` (the artifact's `#project` string).

**The E05-C02 report (accepted by the time this runs):**
`PGRReport class>>project: aProjectString verdicts: aVerdictArray` (internal
constructor); instance `verdicts` · `isClean` · `exitCode` ·
`blockingVerdicts` · `advisories`.

**Gate protocol (ch. 7 §7.2, frozen at epic acceptance):**

```smalltalk
gate := PGRGate forConfiguration: aPGRConfiguration.
gate onVerdict: [ :verdict | ... ].   "optional; sets the verdict sink — none by default (D-55)"
report := gate run.                    "→ PGRReport"
```

- `forConfiguration:` — named constructor; builds the registry **eagerly**
  (inside the constructor), so configuration errors surface before anything
  runs; captures the configuration's `project` string for the report. The
  gate holds `project`, `registry`, `sink` (nil by default) — nothing else,
  and never the configuration object itself beyond construction.
- `onVerdict: aOneArgBlock` — sets the sink. There is **no default sink**:
  given none, verdicts accumulate in the report and nothing streams.
  Framework production code never references `Transcript` — not as default,
  not as fallback, not via `Smalltalk at: #Transcript` (D-55).
- `run` — runs every registration in registry order via
  `PGRRegistration>>run`; when a sink is set, passes each verdict to it **as
  it completes, before `run` returns**; answers
  `PGRReport project: project verdicts: <all verdicts, in order>`. `run`
  itself adds **no exception handling** — per-registration errors are
  already red verdicts inside `PGRRegistration>>run` (D-21), and the
  top-level handler is `runHeadless:`'s alone (D-39; E05-C05): an in-image
  caller sees raw exceptions from anything outside a check's `run`.

**Scratch fixtures this chunk's tests drive (accepted E04-C01 ground, in
`Phi-Guardrails-Tests-Core` — loaded in the work image; gate tests reference
them by name inside STON artifact strings):** `PGRScratchSpecKit` — the
data-driven obedient kit: one spec per `#specs` entry, in order; entry arms
`{ #name : 'scratch/G1', #kind : 'scratch', #check : 'PGRScratchGreenCheck' }`
(resolved — instantiates the named class via `packages:` with the production
names) and `{ #name : 'scratch/M1', #kind : 'scratch', #missing : 'engine
absent' }` (missing, with reason). Check cast: `PGRScratchGreenCheck` (always
green) · `PGRScratchRedCheck` (one planted finding, target
`'PGRScratchRedCheck'`, message `'planted scratch violation'`) ·
`PGRScratchErroringCheck` (its `run` raises `Error 'scratch check
exploded'`).

**The canonical scratch artifact envelope** (the E04 `PGRRegistryTest` shape —
author the same two helpers on `PGRGateTest`; helper duplication across test
classes is deliberate self-containment, the E04 precedent):

```smalltalk
PGRGateTest >> artifactWithKitsFragment: aStonKitsArrayString
    ^ '{
    #schemaVersion : 2,
    #project : ''Scratch'',
    #baseline : ''BaselineOfPGRScratchGrouped'',
    #roles : {
        #production : [ ''scratch-prod'' ],
        #tests : [ ''scratch-tst'' ],
        #exempt : [ ''scratch-ghost'' ] },
    #kits : ' , aStonKitsArrayString , '
}'

PGRGateTest >> gateFromKitsFragment: aStonKitsArrayString
    ^ PGRGate forConfiguration:
        (PGRConfiguration fromString: (self artifactWithKitsFragment: aStonKitsArrayString))
```

**Constitution rules that bite here:** no global state — the gate holds only
what construction gave it (R-35); class-side named constructors over
`new`+setters; no `Transcript` (D-55); dispatch polymorphically — no
`isKindOf:`/`class ==`; a test that cannot fail is a defect.

**Authoring rule (E01 precedent, verbatim):** author in-image and export to
`src/` with the image's Tonel tooling; hand-writing class files is not
allowed. After export, a fresh `tools/build-image.sh` load from committed
`src/` proves the round trip.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Guardrails-Gate/PGRGate.class.st` — new: instVars `project`,
  `registry`, `sink`; class-side `forConfiguration:`; instance `onVerdict:`,
  `run`, private setter(s). (`runHeadless:` forms are E05-C05 — not here.)
- `src/Phi-Guardrails-Tests-Gate/PGRGateTest.class.st` — new: the two
  fixture helpers above and the four tests below.
- LOC budget: target 130 / ceiling 220.

## TESTS FIRST

Test methods on `PGRGateTest` (each names its specs `scratch/…` and drives a
gate built by `gateFromKitsFragment:`):

- `testOneVerdictPerRegistration` — **ch.-9-named, P-GATE-COMPLETE** — given
  a three-spec artifact (green `scratch/G1`, red `scratch/R1`, missing
  `scratch/M1`) / when `run` / then the report's verdict
  `registrationName`s equal exactly `#('scratch/G1' 'scratch/R1'
  'scratch/M1')` in order — report verdict names = registry registration
  names, exactly.
- `testVerdictsStreamInOrder` — **ch.-9-named, P-STREAM (sink arm)** — given
  the same three-spec gate with `onVerdict:` collecting into an
  `OrderedCollection` / when `run` / then the collection holds one verdict
  per registration, in registry order, its members identical (`==`) to the
  report's verdicts — every one delivered before `run` returned.
- `testNoSinkMeansNoStreaming` — **ch.-9-named, P-STREAM (no-sink arm)** —
  given the same gate with **no** sink / when `run` / then it answers
  normally and the report still carries every verdict — nothing needs a
  sink, and no default exists to receive one (D-55).
- `testDeliberatelyRedRegistrationIsReported` — **ch.-9-named,
  P-JUDGE-CONVICTS (D-40)** — given a gate whose artifact registers
  `PGRScratchRedCheck` / when `run` / then the report is not clean,
  `blockingVerdicts` names `scratch/R1`, and `exitCode` = 1 — the judge can
  convict.

Fixtures: the E04-C01 cast (untouched); the two helpers above.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 4 `PGRGateTest` methods and
          the 7 `PGRReportTest` methods **plus every previously accepted
          suite** — membership plus a floor (≥ 162 run when stacked after
          E05-C01/C02), never an exact ceiling.

OUT OF SCOPE
- `runHeadless:`/`runHeadless:on:`, exit codes, streams, the top-level
  handler — E05-C05/C06.
- Error/missing/purity/freshness gate tests — E05-C04.
- Touching `PGRRegistry`, `PGRRegistration`, `PGRConfiguration`, or any kit
  package.
- A default sink of any kind (D-55 forbids it).
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `E05-C03: PGRGate object, run, streaming` (D-73) before reporting
          for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
