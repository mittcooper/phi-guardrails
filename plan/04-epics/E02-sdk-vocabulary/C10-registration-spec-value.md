# C10 · PGRRegistrationSpec value      [E02 · depends: — · parallel: yes]

GOAL      Land `PGRRegistrationSpec` — what a kit answers across the boundary: two
          class-side constructors (resolved / missing) and four readers.

TRACE     spec ch. 1 §1.3 (`PGRRegistrationSpec` row) · §1.4 step 2 (kits answer
          specs; the engine wraps) · ch. 0 §0.1 ("the boundary carries information;
          the engine owns mechanism") · D-54.1 (the residency ruling that created
          this class) · D-60 rulings 4/7 (kind agreement is validated on specs;
          missing-specs keep their explicit kind) · R-04 (boundary half).

## CONTEXT DIGEST

**What exists (E01, frozen):** `src/Phi-Guardrails-SDK/` and
`src/Phi-Guardrails-Tests-SDK/` are package stubs in the frozen 21-directory
inventory; the baseline is **not** edited. This chunk needs no other E02 class: the
`check` slot holds *any* conforming instance and is not typed — tests use a plain
scratch object.

**The class — `PGRRegistrationSpec` in `Phi-Guardrails-SDK`, a «value» of the
boundary vocabulary.** Frozen surface (freezes at E02 acceptance; ch. 1 §1.3
verbatim):

- class side (kit author): `name:kind:check:` · `missing:kind:reason:`
- instance side: `name` · `kind` · `check` · `missingReason`

Meaning (class comment carries this): one entry of a kit's answer to
`registrationsFrom:productionPackages:testsPackages:` — a registration name
(`<kind>/<discriminator>`, e.g. `'lint/PCKNoIsNilIfTrueRule'`), a kind Symbol, and
**either** a live check instance bound to its targets **or** a missing-reason
string; never both. The engine (E04) validates every resolved spec's check —
protocol conformance plus kind agreement (the spec's kind must equal the check's
own `kind`) — and wraps it into its internal `PGRRegistration`; kits never see that
class. Missing-specs keep their explicit kind: no check exists to ask (D-60).
*The boundary carries information; the engine owns mechanism* (D-54).

**Field semantics:**

| Constructor | `name` | `kind` | `check` | `missingReason` |
|---|---|---|---|---|
| `name:kind:check:` | handed | handed | the handed instance | `nil` |
| `missing:kind:reason:` | handed (first arg) | handed | `nil` | handed |

**Design constraints:**
- Values are dumb: **no validation** here — conformance, kind agreement, duplicate
  names are all the engine's (E04); the spec never inspects its check.
- Class-side named constructors over `new`+setters; private setters in a
  private-marked protocol; contract methods in surface-named protocols.
- R-04: nothing in `-SDK` references SUnit/Renraku/RB classes.

**Constitution rules that bite here:** `PGR` prefix; glossary exactly (this is a
*spec* a kit answers — a *registration* is the engine's internal wrap, E04's class,
not built here); no global state; comments state constraints code cannot show;
SUnit, no `skip`/`expectedFailures`, a test that cannot fail is a defect.

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

- `src/Phi-Guardrails-SDK/PGRRegistrationSpec.class.st` — the value class as
  specified.
- `src/Phi-Guardrails-Tests-SDK/PGRRegistrationSpecTest.class.st` — its mirror
  test.
- LOC budget: target 70 / ceiling 120.

## TESTS FIRST

Test methods on `PGRRegistrationSpecTest`:

- `testResolvedSpecCarriesItsCheck` — given a scratch object as the check and
  `PGRRegistrationSpec name: 'lint/Scratch' kind: #lint check: scratch` / then
  `name`, `kind`, `check` answer exactly what was handed and `missingReason` is
  `nil`.
- `testMissingSpecCarriesReasonAndExplicitKind` — given
  `PGRRegistrationSpec missing: 'behavioral/tests-role' kind: #behavioral reason:
  'tests role expanded to zero packages'` / then `name`, `kind`, `missingReason`
  answer what was handed and `check` is `nil` — a missing-spec keeps its explicit
  kind (D-60: no check exists to ask).

Fixtures: none (`Object new` is the scratch check — the spec never inspects it).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 2 `PGRRegistrationSpecTest`
          methods and the 5 `PGRBaselineSmokeTest` methods (regression guard; plus
          any other accepted siblings').

OUT OF SCOPE
- Conformance/kind-agreement validation, duplicate-name rejection, wrapping into
  `PGRRegistration` — all E04.
- Any convenience predicate (`isMissing`/`isResolved`) — the surface is exactly the
  four readers; the engine asks `missingReason isNil` itself (minimal surface, ch. 0
  §0.3's law).
- Editing the baseline, any `package.st`, or anything outside the manifest.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md`
          (`bash tools/precheck.sh` once C06 is accepted; else by eye — D-67).
          Postcondition: exactly the manifest files, one commit
          `C10: PGRRegistrationSpec value` before reporting for review; nothing
          left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
