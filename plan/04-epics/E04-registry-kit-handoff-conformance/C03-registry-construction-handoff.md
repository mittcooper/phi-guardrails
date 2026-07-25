# E04-C03 · PGRRegistry: construction, verbatim handoff, order    [E04 · depends: E04-C02 · parallel: no]

GOAL      Land `PGRRegistry class>>fromConfiguration:` — per-block verbatim
          handoff to each kit with the resolved role lists, specs wrapped into
          registrations, concatenated in `#kits` array order.

TRACE     ch. 1 §1.4 steps 1–3 (hand the block verbatim + role lists — never
          the configuration object; wrap; concatenate in array order) · §1.3
          (`PGRRegistry` row: class `fromConfiguration:`; instance
          `registrations` (ordered), `size` — internal) · R-01 (one scope: the
          file) · R-08 (no interface for the checked agent to select or
          reorder — the artifact is the only input) · R-35 · R-40 (contract) ·
          R-42 · D-51 · D-53.5 · D-54.

## CONTEXT DIGEST

**What exists.**

- **E03 frozen ground (digest, `plan/04-epics/E03-configuration-scope-law/
  chunks.md`) — the specified-but-internal `PGRConfiguration` readers E04 was
  promised (changeable only via decision-sheet entry while E04 is in flight):
  `project` · `kitBlocks` (ordered, verbatim — opaque maps whose only common
  field is `#kit`) · `kitClasses` (resolved kit classes, ordered as the `#kits`
  array, **parallel to `kitBlocks`**) · `baselineClass` ·
  `productionPackageNames` · `testsPackageNames` · `exemptPackageNames` (all
  three expanded at validation time, answering fresh `Array` copies, expansion
  order: matcher order then baseline declaration order) · `srcPath`. Every kit
  class in `kitClasses` already conforms class-side to the two-message kit
  protocol — E03 stage 4 validated that at parse.
- **E02 frozen kit protocol (verbatim):** `registrationsFrom: aBlock
  productionPackages: productionNames testsPackages: testsNames` → ordered
  collection of `PGRRegistrationSpec` values · `recommendedBlock` → STON text.
- **E04-C02:** `PGRRegistration class>>fromSpec: aRegistrationSpec`; instance
  `name` · `kind` · `isResolved` · `run` → stamped `PGRVerdict`. An unresolved
  registration's `run` answers a `#missing` verdict whose **internal reader
  `missingReason`** (the E02-recorded agent call) carries the spec's reason —
  the echo test below reads it.
- **E04-C01 fixtures (restated):** `PGRScratchSpecKit` answers one
  `PGRRegistrationSpec` per `#specs` entry, in entry order. An entry is a map,
  three forms: `{ #name : 'scratch/G1', #kind : 'scratch', #check :
  'PGRScratchGreenCheck' }` → resolved spec, check instantiated via
  `packages: productionNames` · `{ #name : 'scratch/M1', #kind : 'scratch',
  #missing : 'engine absent' }` → missing spec with that reason · `{ #name :
  'scratch/R1', #kind : 'scratch', #echoRoles : true }` → missing spec whose
  reason is exactly
  `'production: <, -joined productionNames> | tests: <, -joined testsNames>'`.
  `PGRScratchKit` (E03/C20, untouched) answers an empty `OrderedCollection`.
- **E03 test ground reused (cite, never edit):** `PGRConfigurationTest>>
  validArtifactString` — schemaVersion 2, project `'Scratch'`, baseline
  `'BaselineOfPGRScratchGrouped'`, roles production `[ 'scratch-prod' ]` /
  tests `[ 'scratch-tst' ]` / exempt `[ 'scratch-ghost' ]`, kits
  `[ { #kit : 'PGRScratchKit' } ]`. Role expansions on this image (pinned by
  `PGRScratchFixturesTest`): production →
  `#('Phi-Guardrails-SDK' 'Phi-Guardrails-Core')`, tests →
  `#('Phi-Guardrails-Tests-SDK')`, exempt → `#('PGR-Scratch-Ghost')`.
  `PGRRegistryTest` carries its **own** artifact helpers (below) — nothing on
  `PGRConfigurationTest` is touched.

**The new class — `PGRRegistry`, package `Phi-Guardrails-Core`, internal:**

- `fromConfiguration: aPGRConfiguration` — for each (kitClass, block) pair,
  **in order** (`kitClasses` is parallel to `kitBlocks`): send
  `registrationsFrom: block productionPackages: aPGRConfiguration
  productionPackageNames testsPackages: aPGRConfiguration testsPackageNames`
  — the block **verbatim** (never copied, never filtered: opaque, D-51), the
  role lists resolved (never the configuration object — over-reach is
  impossible, not caught, D-53.5). Wrap each answered spec via
  `PGRRegistration fromSpec:` in answer order; concatenate across blocks in
  `#kits` array order (§1.4 step 3). Within a kit, the kit's answer order is
  normative — the engine never reorders.
- Instance: `registrations` — the wrapped registrations, ordered; answers a
  **fresh `Array` copy** per send (the E02/E03 handed-collections R-35
  convention; agent call, recorded in chunks.md) · `size`.
- A kit raising `PGRConfigurationError` inside `registrationsFrom:…`
  propagates out of `fromConfiguration:` untouched — the kit's stated duty
  (D-60); E05 maps it to exit 2. No handler here.
- Spec-level validation (conformance · kind agreement · duplicate names) is
  **E04-C04** — this chunk wraps trusting specs, exactly as E03 built its
  pipeline stage by stage.

**Constitution rules that bite here:** no global state — a registry is built
per run and holds only what construction gave it (R-35); class-side named
constructor `fromConfiguration:` over `new`+setters; no
`isKindOf:`/`class ==`; strict-parsing family 7 concerns stay in
`PGRConfiguration` (already frozen) — this class consumes, never re-validates
the envelope; R-04 — no SUnit/Renraku/RB in `-Core`; glossary exactly: the
*registry* is the registrations of one run; a *kit block* is the map; the
checked agent's only input is the artifact (R-08 — structural, no code to
write, no interface to add).

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export
to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present,
D-15); hand-writing class files is not allowed — the committed form must be what
the tooling emits. After export, a fresh `tools/build-image.sh` load from the
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Guardrails-Core/PGRRegistry.class.st` — create.
- `src/Phi-Guardrails-Tests-Core/PGRRegistryTest.class.st` — create: the five
  tests below **plus two fixture helpers**:
  `artifactWithKitsFragment: aStonKitsArrayString` — splices the given `#kits`
  array text into the canonical scratch envelope (schemaVersion 2, project
  `'Scratch'`, baseline `'BaselineOfPGRScratchGrouped'`, the three roles as in
  E03's `validArtifactString` above) and answers the artifact String;
  `registryFromKitsFragment:` — parses it via `PGRConfiguration fromString:`
  and answers `PGRRegistry fromConfiguration:` of it.
- LOC budget: target 110 / ceiling 190.

## TESTS FIRST

Test methods on `PGRRegistryTest`:

- `testRegistrationsWrapSpecsInOrder` — given one `PGRScratchSpecKit` block
  whose `#specs` name `scratch/G1` (green check) then `scratch/M1` (missing,
  reason `'engine absent'`) / when the registry is built / then `size` = 2;
  registration names in order = `'scratch/G1'`, `'scratch/M1'`; the first
  `isResolved` (and its `run` answers a green verdict stamped
  `'scratch/G1'`), the second not.
- `testKitsConcatenateInArrayOrder` — given three blocks in the `#kits` array:
  spec-kit ⟨`scratch/A1`, `scratch/A2`⟩ · `{ #kit : 'PGRScratchKit' }` (answers
  nothing) · spec-kit ⟨`scratch/B1`⟩ / then names in order =
  `'scratch/A1'`, `'scratch/A2'`, `'scratch/B1'` — array order across kits,
  answer order within one (§1.4 step 3).
- `testRoleListsHandedResolved` — **the D-53.5 handoff witness** — given one
  spec-kit block with a single `#echoRoles` entry named `scratch/R1` / then
  the single registration's `run` answers a missing verdict whose internal
  `missingReason` = `'production: Phi-Guardrails-SDK, Phi-Guardrails-Core |
  tests: Phi-Guardrails-Tests-SDK'` — the resolved role lists crossed the
  boundary, and nothing else did.
- `testEmptyKitAnswerYieldsEmptyRegistry` — given E03's `validArtifactString`
  envelope verbatim (its only kit is `PGRScratchKit`) / then `size` = 0 and
  `registrations` is empty — a kit may lawfully answer no registrations; what
  runs is exactly what the file names (D-51).
- `testRegistrationsAnswersFreshCopy` — given any built registry / then two
  sends of `registrations` answer equal name sequences but non-identical
  collections (`~~`), and the elements are the same registration objects
  (R-35: the collection is defensive, the members are the run's).

Fixtures: E04-C01's cast + E03's scratch baselines (loaded, untouched); all
artifacts are Strings built by this class's own helpers.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 5 new `PGRRegistryTest`
          methods, the 6 `PGRRegistrationTest` methods, the 7
          `PGRScratchCheckFixturesTest` methods, **plus every previously
          accepted suite** — membership plus a floor (≥ 106 run), never an
          exact ceiling.

OUT OF SCOPE
- Conformance, kind-agreement, duplicate-name validation — E04-C04.
- Running the whole registry / verdict aggregation / exit codes — E05
  (`PGRGate`).
- Any edit to `PGRConfiguration`, `PGRConfigurationTest`, `PGRScratchKit`, or
  the scratch baselines (frozen/accepted E03 ground).
- Behavioral-suite derivation (kit-side, E07) — the engine never conjures
  registrations.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `E04-C03: PGRRegistry construction and verbatim handoff` (D-73)
          before reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
