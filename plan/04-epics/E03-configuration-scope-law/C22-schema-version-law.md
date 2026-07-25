# C22 · Schema-version law             [E03 · depends: C21 · parallel: no]

GOAL      Enforce the schema-version parse set — exactly {2} — with refusal
          messages that name both versions: the artifact's and the gate's own.

TRACE     spec ch. 1 §1.1 (`#schemaVersion` row: v1 writes 2; version 1 refused
          as unknown; a newer version refused, naming both) · D-45 ruling 3
          (refuse newer, never misinterpret) · D-49 (every schema change bumps —
          ch. 1 owns the policy) · D-51 detail 4 (version 1 = the never-shipped
          pre-D-51 draft; prior-shipped set empty at v1) · R-47 (the schema) ·
          property P-SCHEMA-REFUSAL (both named tests land here).

## CONTEXT DIGEST

**What exists:** C21's `PGRConfiguration class>>fromString:` runs pipeline stages
1–2: strict STON parse (`STONReaderError` → `PGRConfigurationError`) and the
envelope shape law — in particular `#schemaVersion` is already required and
already refused when not an Integer. C21's test class `PGRConfigurationTest`
carries `validArtifactString` (schemaVersion 2, project 'Scratch', baseline
'BaselineOfPGRScratchGrouped', roles production ['scratch-prod'] / tests
['scratch-tst'] / exempt ['scratch-ghost'], one kit block { #kit :
'PGRScratchKit' }) plus a mutation helper for defect arms.
`PGRConfigurationError` (frozen E02 export, `-SDK`): direct `Error` subclass,
signalled with a one-line reason; class is API, wording is not.

**This chunk appends pipeline stage 3**, after shape, before any resolution:

- The gate's own schema version is **2**, stated in exactly one place — a
  class-side method on `PGRConfiguration` (suggested spelling
  `currentSchemaVersion`, internal; agent detail, veto-open).
- The artifact's `#schemaVersion` must be **exactly 2**. The parse set is {2}
  because the prior-*shipped*-versions set is empty at v1: version 1 was the
  never-shipped pre-D-51 draft and is **refused as unknown**, exactly like any
  other non-2 value (D-51 detail 4). The older-shipped-versions arm of the D-49
  policy activates only with the first post-2 bump — v1 code has no "older
  versions" list, and must not grow one speculatively.
- Every refusal message names **both** versions — the artifact's value and the
  gate's own 2 (D-45 ruling 3: "a clear configuration error naming both
  versions"). E.g. `'artifact schema version 3; this gate reads version 2'` —
  wording free, both numbers mandatory.

**Constitution rules that bite here:** strict parsing (family 7) — refusal, never
best-effort reading of an unknown schema; comments state constraints the code
cannot show (the {2}-not-{1,2} fact and its D-51 reason belong in the method
comment); a test that cannot fail is a defect.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `tools/build-image.sh` load from the
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it
and asserts run count plus the 5 smoke tests.

## DELIVERABLES

- `src/Phi-Guardrails-Core/PGRConfiguration.class.st` — modify: add stage 3 and
  the version constant.
- `src/Phi-Guardrails-Tests-Core/PGRConfigurationTest.class.st` — modify: add the
  three tests below.
- LOC budget: target 50 / ceiling 100.

## TESTS FIRST

Test methods on `PGRConfigurationTest`:

- `testNewerSchemaVersionSignals` — **P-SCHEMA-REFUSAL** — given the valid
  artifact with `#schemaVersion : 3` / then `fromString:` signals
  `PGRConfigurationError` whose message contains both `'3'` and `'2'` (both
  versions named, D-45).
- `testNeverShippedVersionOneSignals` — **P-SCHEMA-REFUSAL** — given
  `#schemaVersion : 1` / then signals `PGRConfigurationError` naming both `'1'`
  and `'2'` (the pre-D-51 draft is unknown, not parsed).
- `testVersionTwoParses` — given the unmodified valid artifact / then an instance
  is answered (the green arm; guards against an over-eager refusal).

Fixtures: C21's `validArtifactString` + mutation helper; nothing new.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 3 new tests, the 7 prior
          `PGRConfigurationTest` methods, the 7 `PGRScratchFixturesTest` methods,
          the 19 accepted E02 SDK tests, and the 5 `PGRBaselineSmokeTest`
          methods (regression guard).

OUT OF SCOPE
- Any "read older shipped versions" machinery — the set is empty at v1 by ruling;
  building it now would be speculative generality.
- Non-integer `#schemaVersion` — already C21's shape arm; do not re-test here.
- Resolution, expansion, laws — C23 onward.
- Anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `C22: schema-version law` before reporting for review; nothing left
          uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
