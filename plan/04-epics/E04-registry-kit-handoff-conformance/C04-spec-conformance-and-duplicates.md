# E04-C04 · Spec-level conformance, kind agreement, duplicate names    [E04 · depends: E04-C03 · parallel: no]

GOAL      Registry construction validates every resolved spec's check instance
          — protocol conformance and kind agreement — and rejects duplicate
          registration names, all before any check runs.

TRACE     ch. 0 §0.4 (conformance invariant: on the specs kits answer, never on
          block contents) · ch. 1 §1.3 (duplicate names: configuration error,
          not a silent dedupe) · §1.4 step 2 (engine validation after the kit's
          answer) · D-53 (error names class + missing selector) · D-60 G-6/G-7
          (kind agreement; specs-never-blocks) · P-CONFORMANCE (both ch.-9-named
          tests land here) · P-CFG-STRICT, duplicate-name arm (E03's recorded
          cross-epic handoff — discharged here) · P-CANFIX-DEFAULT's
          `fixCommandOn:`-when-`canFix` clause ("checked by P-CONFORMANCE's
          machinery").

## CONTEXT DIGEST

**What exists.** E04-C03's `PGRRegistry class>>fromConfiguration:` hands each
block verbatim to its kit with the resolved role lists, wraps every answered
`PGRRegistrationSpec` into a `PGRRegistration` (E04-C02: `fromSpec:`, `name`,
`kind`, `isResolved`, `run`), concatenating in `#kits` array order.
`PGRRegistryTest` carries helpers `artifactWithKitsFragment:` /
`registryFromKitsFragment:` (canonical scratch envelope: baseline
`'BaselineOfPGRScratchGrouped'`, roles production `['scratch-prod']` / tests
`['scratch-tst']` / exempt `['scratch-ghost']`) and five green tests. Spec
readers (frozen E02): `name` · `kind` · `check` · `missingReason`.
`PGRConfigurationError` (frozen E02): direct `Error` subclass; the class is
API, wording is not — but D-53/D-60 fix what an error message must *name*.

**E04-C01 fixture cast used here (restated):** `PGRScratchGreenCheck` (fully
conforming, kind `#scratch`, plain `Object` lineage — subclasses nothing
framework-side) · `PGRScratchNonconformingCheck` (instantiable via `packages:`;
answers `kind`/`canFix`; **no `run`**) · `PGRScratchClaimsFixCheck` (`canFix`
true, **no `fixCommandOn:`**). A `#specs` entry is a map — `{ #name :
'scratch/G1', #kind : 'scratch', #check : 'PGRScratchGreenCheck' }` (resolved:
check instantiated via `packages: productionNames`) or `{ #name : …, #kind :
…, #missing : '<reason>' }` — and the kit sets the spec's kind from the
entry's `#kind` value, so a kind-mismatched spec is pure block data (e.g.
`#kind : 'architecture'` over the green check whose own `kind` is `#scratch`).

**This chunk appends the engine's validation pass to `fromConfiguration:`**
(spec ch. 1 §1.4 step 2, verbatim ground):

1. **Protocol conformance, per resolved spec, in answer order.** The validated
   instance protocol is the engine-consumed subset (agent call, veto-open —
   recorded in chunks.md): the check instance must respond to `run` · `kind` ·
   `canFix`; when `canFix` answers true it must also respond to
   `fixCommandOn:` (P-CANFIX-DEFAULT's clause). A failure signals
   `PGRConfigurationError` **naming the class and the missing selector**
   (D-53's error style — the same shape E03's kit-conformance arm used). The
   class-side `packages:` constructor is *not* re-checked here: by the time a
   spec exists the check is constructed — spec-level validation cannot see
   construction (D-60 G-7); the `packages` reader is a skeleton convenience
   the engine never sends.
2. **Kind agreement (D-60 G-6).** The spec's `kind` must equal the check's own
   `kind`; mismatch signals `PGRConfigurationError` **naming the registration
   (spec name), both kinds, and the check class**. **Missing-specs keep their
   explicit kind and are skipped by both passes** — no check exists to ask.
3. **Duplicate registration names.** Two registrations deriving the same name
   anywhere in the concatenated answer — within one kit or across kits — is a
   configuration error **naming the duplicated name**, never a silent dedupe
   (ch. 1 §1.3). Detection at wrap time, in answer order: the first name seen
   a second time signals (agent call: deterministic error precedence —
   per-spec conformance/kind as each spec is processed, duplicate on add).

All of stages 1–3 complete inside `fromConfiguration:` — **before any check
runs** (the §0.4 invariant; the gate's run loop is E05 and never sees an
unvalidated registry). Blocks are never opened by the engine: everything here
operates on specs, so the resident coding kit and an external kit share one
validation path (D-60 G-7).

**Constitution rules that bite here:** strict validation — malformed input
signals a configuration error, never a silent default (family 7); no
`isKindOf:`/`class ==` — conformance is `respondsTo:`, the *specified contract
check* (the ruled D-53 protocol test, not type dispatch); every offender named
in its error (the E03 message style); R-04 — no SUnit/Renraku/RB in `-Core`.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export
to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present,
D-15); hand-writing class files is not allowed — the committed form must be what
the tooling emits. After export, a fresh `tools/build-image.sh` load from the
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Guardrails-Core/PGRRegistry.class.st` — modify: the validation pass
  (private class-side methods beside the C03 construction machinery).
- `src/Phi-Guardrails-Tests-Core/PGRRegistryTest.class.st` — modify: the six
  tests below.
- LOC budget: target 125 / ceiling 220.

## TESTS FIRST

Test methods on `PGRRegistryTest`:

- `testNonconformingCheckClassSignals` — **ch.-9-named, P-CONFORMANCE** —
  given a spec-kit block whose entry names `'PGRScratchNonconformingCheck'` /
  when built / then `PGRConfigurationError` whose message includes
  `'PGRScratchNonconformingCheck'` and `'run'` (class + missing selector,
  D-53).
- `testSpecKindMismatchSignals` — **ch.-9-named, P-CONFORMANCE** — given an
  entry named `kindclash/X1` with `#kind : 'architecture'` over
  `'PGRScratchGreenCheck'` / then `PGRConfigurationError` whose message
  includes `'kindclash/X1'`, `'architecture'`, `'scratch'` (lowercase — the
  check's own kind; the name was chosen so no other message part contains that
  substring, keeping the clause falsifiable), and `'PGRScratchGreenCheck'`
  (registration, both kinds, check class — D-60 G-6).
- `testCanFixTrueWithoutFixCommandSignals` — given an entry naming
  `'PGRScratchClaimsFixCheck'` / then `PGRConfigurationError` whose message
  includes the class name and `'fixCommandOn:'` (P-CANFIX-DEFAULT's clause via
  this machinery).
- `testDuplicateRegistrationNameSignals` — **P-CFG-STRICT's duplicate-name
  arm, the E03-recorded handoff** — given two spec-kit blocks each answering a
  spec named `'scratch/G1'` / then `PGRConfigurationError` whose message
  includes `'scratch/G1'` — cross-kit, never a silent dedupe.
- `testDuckTypedConformingCheckRegisters` — **P-CONFORMANCE's positive arm** —
  given the green-check entry (a plain-`Object`-lineage duck type) / then the
  registry builds, the registration `isResolved`, and its `run` answers a
  green verdict — a conforming class that subclasses nothing registers
  normally.
- `testMissingSpecSkipsConformance` — given one missing entry (kind
  `'scratch'`, reason `'engine absent'`) beside no other / then no error: the
  registry builds with one unresolved registration whose `kind` = `#scratch`
  (missing-specs keep their explicit kind; no check exists to ask, D-60).

Fixtures: E04-C01's cast, driven through the C03 helpers — block data only, no
new classes.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 11 `PGRRegistryTest` methods
          (5 prior + 6 new), the 6 `PGRRegistrationTest` methods, the 7
          `PGRScratchCheckFixturesTest` methods, **plus every previously
          accepted suite** — membership plus a floor (≥ 112 run), never an
          exact ceiling.

OUT OF SCOPE
- Validating block contents, counting block entries, or any "never fewer specs
  than its block names" check — that duty is the kit's, stated not engine-
  enforced (D-60 G-7 keeps blocks opaque).
- Validating what `run` answers, or missing-spec reasons (dumb values).
- Re-validating class-side kit conformance (E03 stage 4 owns it) or the
  envelope.
- The registered-lint-severity rule (D-41) — kit-side, landed in E06.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `E04-C04: spec-level conformance, kind agreement, duplicate names`
          (D-73) before reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
