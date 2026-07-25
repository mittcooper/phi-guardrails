# E04-C05 · Registry property tests: loading-inert and reg-fresh    [E04 · depends: E04-C04 · parallel: no]

GOAL      Discharge P-LOADING-INERT and land P-REG-FRESH's named test (registry
          + reflective arms) — nothing enters a registry by mere presence in
          the image, and runs share nothing.

TRACE     ch. 0 §0.4 ("runs share nothing"; "the configuration file is the
          complete statement of what runs") · ch. 9 §9.2 (P-LOADING-INERT:
          `PGRRegistryTest>>#testInstalledCheckClassRegistersNothing`;
          P-REG-FRESH: `PGRRegistryTest>>#testTwoRunsShareNothing`) · R-01 ·
          R-35 · R-41 · D-51.

## CONTEXT DIGEST

**What exists.** The full E04 registry: `PGRRegistry class>>fromConfiguration:`
(verbatim handoff, wrapping, order — E04-C03) with the complete validation pass
(conformance · kind agreement · duplicate names — E04-C04); `PGRRegistration`
(E04-C02); the E04-C01 scratch cast, of which this chunk uses
`PGRScratchSpecKit` — one spec per `#specs` entry, in order, an entry being
`{ #name : 'scratch/G1', #kind : 'scratch', #check : 'PGRScratchGreenCheck' }`
(resolved) or `{ #name : 'scratch/M1', #kind : 'scratch', #missing : 'engine
absent' }` (missing); `PGRRegistryTest` with helpers
`artifactWithKitsFragment:` / `registryFromKitsFragment:` (canonical scratch
envelope over `'BaselineOfPGRScratchGrouped'`) and 11 green tests. `PGRCheck` (frozen E02
`-SDK` skeleton): subclassing it yields a class whose instances would conform;
for this chunk only its *presence as a superclass* matters — the transient
class is never instantiated. E03's second baseline
`'BaselineOfPGRScratchPlain'` (same three real packages, no groups) is loaded
and available for a second, distinct artifact; with it, roles must be assigned
by package-name/pattern matchers, e.g. production
`[ 'Phi-Guardrails-SDK', 'Phi-Guardrails-Core' ]` · tests
`[ 'Phi-Guardrails-Tests-SDK' ]` (it declares no ghost package, so no exempt
role is needed).

**The two ch.-9-named property tests, their decidable assertions restated:**

- **P-LOADING-INERT** (R-41 — loading is not activation): build a registry
  from a scratch configuration; **install a fresh `PGRCheck` subclass named in
  no kit block; rebuild the registry from the same configuration** — both
  registries have identical registration names, and each name traces to a
  kit-block entry or a tests-role package (nothing enters by mere presence in
  the image; nothing enters from any shipped default — D-51). With the scratch
  spec kit, "traces to a kit-block entry" is assertable exactly: the name list
  equals the block's `#specs` names, in order. (The tests-role clause is the
  behavioral derivation's — kit-side, E07; no engine code derives suites, so
  here the trace target is block entries alone. Recorded in chunks.md as the
  property's within-E04 reading.)
- **P-REG-FRESH** (R-35 — no global state): two registries built from two
  artifacts in one image are independent — each carries exactly its own
  artifact's names; rebuilding from the *same* configuration answers a fresh
  registry (new registry object, new registration objects — nothing cached
  anywhere); and **no class-side state exists anywhere in `-Core`/`-Gate`**,
  asserted reflectively: every class in packages `Phi-Guardrails-Core` and
  `Phi-Guardrails-Gate` has no class variables and no class-side instance
  variables. (Ch. 9 phrases the property over "two gates … registries/
  reports"; `PGRGate`/`PGRReport` are E05 ground — this named test lands the
  registry + reflective arms now, and E05's gate tests complete the
  gate/report clause over the same reflective sweep. Cross-epic split recorded
  in chunks.md, the E03 P-CFG-STRICT precedent.)

**In-image mechanics, ⟨verify-in-image⟩ delegated to the implementer with
record-in-report duty (the E06 precedent — confirm each spelling in the work
image before use, record what was used):**

- **Transient class installation:** candidate fluid-builder form
  `PGRCheck << #PGRTransientLoadedCheck slots: {}; package:
  'Phi-Guardrails-Tests-Core'; install` (E03's probe verified the fluid
  builder for `BaselineOf` subclasses on this image; the legacy
  `subclass:instanceVariableNames:…` message is gone in Pharo 13). Removal:
  candidate `removeFromSystem` — **inside `ensure:`**, so a failing assertion
  can never leak the class into later tests or the exported image; the test
  must also guard against a leftover from a crashed prior run (remove-if-
  present in `setUp` or before install).
- **Reflective sweep:** candidates — package classes via
  `(PackageOrganizer default packageNamed: 'Phi-Guardrails-Core') definedClasses`
  (`packageNamed:ifAbsent:` is E03-probed ground; the `definedClasses`
  spelling needs the in-image check), class variables via `classVarNames`,
  class-side instance variables via `aClass class instVarNames`. The sweep
  must assert it saw a **nonzero class count** in `-Core` before claiming
  clean (a renamed package must fail loud, not pass vacuously).

**Constitution rules that bite here:** tests may create and delete scratch
state only if `setUp`/`tearDown`/`ensure:` restore it — the transient class is
exactly that; no `skip`/`expectedFailures`; a test that cannot fail is a
defect (hence the nonzero-count guard on the reflective sweep); the work-image
mutation never reaches committed `src/` (the D-65 boundary: `.build/` state is
disposable).

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export
to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present,
D-15); hand-writing class files is not allowed — the committed form must be what
the tooling emits. After export, a fresh `tools/build-image.sh` load from the
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Guardrails-Tests-Core/PGRRegistryTest.class.st` — modify: the two
  tests below (plus at most one private artifact helper for the plain-baseline
  variant). **No product code** — if either property cannot be discharged
  without touching `-Core`, stop and report (that is a finding, not a
  workaround).
- LOC budget: target 90 / ceiling 160.

## TESTS FIRST

Test methods on `PGRRegistryTest`:

- `testInstalledCheckClassRegistersNothing` — **ch.-9-named, P-LOADING-INERT**
  — given a registry built from a spec-kit artifact (specs `scratch/G1`,
  `scratch/M1`) whose registration names are recorded / when a fresh
  `PGRCheck` subclass named in no kit block is installed and the registry is
  rebuilt from the same configuration (removal guaranteed by `ensure:`) /
  then both name sequences are identical, and each equals exactly the block's
  `#specs` names in order — nothing entered by presence, nothing by default.
- `testTwoRunsShareNothing` — **ch.-9-named, P-REG-FRESH** — given one
  registry over the grouped-baseline artifact (specs `scratch/G1`,
  `scratch/M1`) and one over a plain-baseline artifact
  (`'BaselineOfPGRScratchPlain'`, roles by package-name matchers, spec
  `scratch/P1` only) / then each registry's names are exactly its own
  artifact's; **mutating one configuration object never affects the other
  run** (ch. 9's third clause): mutate the `Array` answered by the first
  configuration's `productionPackageNames` — its only reachable handle; the
  readers answer fresh copies — and assert the second registry and a rebuild
  from the first configuration still carry their original names; rebuilding
  from the first configuration answers a non-identical registry whose
  registrations are non-identical objects (fresh, uncached); and the
  reflective sweep over every class in `Phi-Guardrails-Core` and
  `Phi-Guardrails-Gate` (asserted nonzero for `-Core`) finds no class
  variables and no class-side instance variables.

Fixtures: E04-C01's cast; both E03 scratch baselines (loaded, untouched); the
transient class exists only inside the first test's `ensure:` window.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 13 `PGRRegistryTest` methods
          (11 prior + 2 new), the 6 `PGRRegistrationTest` methods, the 7
          `PGRScratchCheckFixturesTest` methods, **plus every previously
          accepted suite** — membership plus a floor (≥ 114 run), never an
          exact ceiling. This VERIFY is leg 1 of the E04 exit checkpoint
          (chunks.md §checkpoint).

OUT OF SCOPE
- Gate/report freshness and the P-REG-FRESH gate clause — E05 (recorded
  split).
- Mutating `PGRCheck`, any `-Core` product code, or any accepted E03 file.
- A committed fixture class for the transient check — it must be runtime-
  built and removed, or the property is not about *loading*.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `E04-C05: loading-inert and reg-fresh property tests` (D-73) before
          reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet · the verified class-builder, removal,
  and reflection spellings (P5 record duty).
