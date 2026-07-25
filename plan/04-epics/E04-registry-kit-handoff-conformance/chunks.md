# E04 · Registry, kit handoff, conformance — chunk index (M1)

*Produced by Prompt 4 (fifth run, 2026-07-25). Entry check: roadmap approved and
frozen (D-62); E04's dependencies E02 and E03 are both `accepted` in
`plan/ledger.md` with interface digests frozen — E02 on head `5f2fc60`
(`plan/04-epics/E02-sdk-vocabulary/chunks.md`: the SDK vocabulary incl.
`PGRRegistrationSpec`, the check protocol, the two-message kit protocol, the
engine-stamping setters recorded for E04), E03 on head `e26fc9c`
(`plan/04-epics/E03-configuration-scope-law/chunks.md`: caller surface,
version-2 schema, and the eight specified-but-internal readers E04 consumes).
E06 is also `accepted` (head `0c4fb7b`) — its digest is citable fact, though no
E04 chunk touches kit packages. Owner notes honored: every COMMIT section cites
`bash tools/precheck.sh` (D-66/D-67); **IDs are epic-qualified `E04-C##` per
D-73** (ledger rows, commit messages, cross-references; filenames stay
`C##-<slug>.md`); every count assertion is named-suite membership plus a floor,
never an exact ceiling (the E03/E06 MINOR precedent, pre-empted — the accepted
sweep is 88 at cut time and parallel-track suites may join it).*

| ID | Title | Depends | [P] | LOC est. | Acceptance (one line) |
|---|---|---|---|---|---|
| E04-C01 | Scratch checks and the spec-answering kit | — | no | ~150 | the duck-typed check family + data-driven `PGRScratchSpecKit` land in `Phi-Guardrails-Tests-Core`; `PGRScratchCheckFixturesTest` (7) pins the fixture contract every later chunk cites |
| E04-C02 | `PGRRegistration`: wrapping and run semantics | E04-C01 | no | ~120 | `fromSpec:`/`name`/`kind`/`isResolved`/`run`: delegation + stamping, error→red (D-21), missing verdict (§1.5); `PGRRegistrationTest` (6) green incl. ch.-9-named `testErroringCheckYieldsRed` |
| E04-C03 | `PGRRegistry`: construction, verbatim handoff, order | E04-C02 | no | ~110 | `fromConfiguration:` hands each block verbatim + resolved role lists (never the configuration, D-53.5), wraps specs, concatenates in `#kits` order; `PGRRegistryTest` (5) green incl. the echo-roles handoff witness |
| E04-C04 | Spec-level conformance, kind agreement, duplicate names | E04-C03 | no | ~125 | the §0.4 invariant machine-true: conformance (class + missing selector), kind agreement (registration, both kinds, class), duplicate-name rejection; `PGRRegistryTest` +6 green — **P-CONFORMANCE** both named tests |
| E04-C05 | Registry property tests: loading-inert and reg-fresh | E04-C04 | no | ~90 | ch.-9-named `testInstalledCheckClassRegistersNothing` (**P-LOADING-INERT**) and `testTwoRunsShareNothing` (**P-REG-FRESH**, registry + reflective arms) green; no product code |

Total ~595 LOC across 5 chunks (= the sum of the work-order targets; the frozen
roadmap row estimates ~5 — holds). C01 sits at the band top deliberately: a
seven-file fixture-family chunk (the E03/C20 shape) whose count is class
definitions, not logic.

**No `[P]` anywhere, deliberately:** C02 consumes C01's fixtures; C03/C04/C05
all modify the same file pair (`PGRRegistry.class.st` +
`PGRRegistryTest.class.st`) — the engine is built up stage by stage, so the
chain is strictly linear (the E03 shape). No chunk touches `package.st`, the
baseline, any kit package, or any frozen E02/E03 file — E04 stays disjoint from
the kit-track cuts (E07/E08) running `[P]` beside it.

**Property placements, stated (cross-epic splits recorded so they are
statements, not drift — the E03 P-CFG-STRICT precedent):**

- **P-CONFORMANCE** — discharged in full here:
  `PGRRegistryTest>>#testNonconformingCheckClassSignals` +
  `>>#testSpecKindMismatchSignals` (E04-C04), with the positive duck-typed arm
  (`testDuckTypedConformingCheckRegisters`) and the missing-spec-skips arm
  beside them.
- **P-LOADING-INERT** — discharged here
  (`testInstalledCheckClassRegistersNothing`, E04-C05). Its "traces to a
  tests-role package" clause is vacuous at E04 by design: suite derivation is
  kit-side (E07); no engine path conjures a registration, which is exactly
  what the test proves.
- **P-REG-FRESH** — the ch.-9-named test `testTwoRunsShareNothing` lands here
  (E04-C05) with the registry-independence, rebuild-fresh,
  **configuration-mutation-isolation** (ch. 9's third clause: mutating one
  configuration object never affects the other run — asserted through the
  role readers' fresh-copy handles), and reflective no-class-side-state arms
  over `-Core` **and** `-Gate`; ch. 9's "two gates … reports" clause completes
  at E05 over the same reflective sweep. E04 claims the property as
  roadmap-owed; E05's gate tests inherit the finishing clause.
- **P-GATE-MISSING (core half)** — E04 delivers the machinery only: a missing
  spec wraps unresolved and `run` answers a `#missing` verdict carrying the
  reason (`PGRRegistrationTest>>#testMissingRunAnswersMissingVerdict`,
  E04-C02). The ch.-9-named property tests are E05's (`PGRGateTest`) and
  E07's (`PCKTestSuiteCheckTest`).
- **P-ERR-IS-RED (registration arm)** — the property is E05's roadmap row, but
  its first named test's subject class is E04's, so
  `PGRRegistrationTest>>#testErroringCheckYieldsRed` lands here (E04-C02);
  E05 adds `PGRGateTest>>#testRunContinuesAfterErroringCheck` to complete it.
- **P-CFG-STRICT (duplicate-name arm)** — E03's recorded handoff is discharged
  by `PGRRegistryTest>>#testDuplicateRegistrationNameSignals` (E04-C04).

**B-14 considered (owner note "remains open for E04"):** no E04 chunk opens a
kit block — the engine operates on specs only (D-60 G-7), and the one
block-reading class this cut adds is a test fixture modelling an obedient kit —
so neither B-14 arm (String-valued core keys; String/Symbol block-key
conflation) can bite this epic. The row stays open where filed, untouched;
first real biter remains the kit-side ground it was filed against.

## Agent calls recorded (veto-open, D-16 precedent; closing at acceptance unless vetoed)

- **The scratch kind `#scratch` (C01–C05):** the core treats `kind` as an
  opaque Symbol everywhere except the D-60 agreement law; a non-catalog kind
  is the cleanest witness that the engine interprets "only kinds and verdicts"
  (R-42) with no kind whitelist.
- **Validated instance protocol = the engine-consumed subset (C04):** `run` ·
  `kind` · `canFix`, plus `fixCommandOn:` when `canFix` is true. The
  class-side `packages:` constructor is spent before a spec exists (D-60 G-7 —
  validation cannot see construction), and the `packages` reader is a skeleton
  convenience the engine never sends — neither is conformance-checked.
- **Error→red finding shape (C02, D-21):** one `PGRFinding`, `target:` = the
  check's class name, `message:` = the error description.
- **Stamping totality (C02):** all three stamps (`registrationName:` ·
  `kind:` · `durationMillis:`) on every verdict `run` answers, missing
  verdicts included; the duration assertion is integer ≥ 0, never a magnitude.
- **`registrations` answers a fresh `Array` copy per send (C03)** — the
  E02/E03 handed-collections R-35 convention; the members are the run's own
  registration objects (defensive collection, shared elements).
- **Deterministic error precedence (C04):** per-spec conformance + kind
  agreement as each spec is processed in answer order; duplicate-name
  detection on add — the first name seen twice signals, naming it.
- **Fixture family naming and residency (C01):** `PGRScratchGreenCheck` /
  `-Red-` / `-Erroring-` / `-ClaimsFix-` / `-Nonconforming-` +
  `PGRScratchSpecKit`, suite `PGRScratchCheckFixturesTest` — the descriptive
  E01/E02/E03 precedent; all in `Phi-Guardrails-Tests-Core` beside their tests
  (ch. 9 §9.3), none a `TestCase`.
- **`PGRScratchSpecKit` validates nothing (C01):** it models an obedient kit;
  kit-side strictness is E06/E07 ground and block opacity to the core is the
  very thing the registry tests witness (D-51).
- **⟨verify-in-image⟩ items delegated to implementers with record-in-report
  duty (P5, the E06 precedent):** the duration spelling (candidate
  `Time millisecondsToRun:`, C02) · the fluid-builder install + removal of the
  transient check class (C05) · the package-class iteration and
  class-variable/class-side-slot reflection spellings (C05).

## Exit checkpoint (closes E04; no new frozen surface — see below)

E04 is provable by, on one head commit:

1. **Named suite:** `PGRScratchCheckFixturesTest` (7) + `PGRRegistrationTest`
   (6) + `PGRRegistryTest` (13) — 26 tests — green under
   `bash tools/build-image.sh && bash tools/verify.sh`, with **every
   previously accepted suite still green** (88 accepted at cut time → floor
   ≥ 114 run, 0 failures, 0 errors; parallel-track suites accepted meanwhile
   add to the count — membership plus floor, never an exact ceiling). Named
   properties discharged by their ch.-9-named tests: **P-CONFORMANCE** (both) ·
   **P-LOADING-INERT** · **P-REG-FRESH** (registry + reflective arms; gate
   clause completes at E05, recorded above) — plus the recorded arms:
   P-ERR-IS-RED (registration arm), P-GATE-MISSING (core-half machinery),
   P-CFG-STRICT (duplicate-name arm).
2. **Infra leg:** `bash tools/precheck.sh` green at every chunk pick (D-67
   standing discipline); commits carry D-73 qualified IDs (`E04-C##: <title>`).
3. **CI leg:** the committed `.github/workflows/ci.yml` (step 1) green on an
   actual CI run of the same commit — the new tests ride the existing
   smalltalkCI sweep.

**At acceptance (E04's interface digest):** the frozen roadmap rules **no new
frozen exports** — the engine is internal; the SDK contract it validates is
E02's. What E05 builds on is **specified-but-internal** (changeable only via a
decision-sheet entry while E05 is in flight — the E03 wording):

- `PGRRegistry` — class: `fromConfiguration:` (validates every resolved spec —
  conformance + kind agreement — and rejects duplicate names before
  answering); instance: `registrations` (ordered; fresh `Array` copy per
  send) · `size`.
- `PGRRegistration` — class: `fromSpec:`; instance: `name` · `kind` ·
  `isResolved` · `run` → a `PGRVerdict` stamped with
  registrationName/kind/durationMillis, total over resolved-green /
  resolved-red / erroring-red (D-21) / missing (§1.5); no `#skipped` producer.
- A kit's `PGRConfigurationError` raised inside `registrationsFrom:…`
  propagates out of `fromConfiguration:` unhandled (E05 maps it to exit 2).

Checkpoint result (filled at acceptance, 2026-07-25): **PASS — all three legs
green on head `9127e31`.** Leg 1: orchestrator-run
`bash tools/build-image.sh && bash tools/verify.sh` → exit 0, **114 run, 114
passes, 0 failures, 0 errors** — the 26-test named suite
(`PGRScratchCheckFixturesTest` 7 · `PGRRegistrationTest` 6 · `PGRRegistryTest`
13) listed by name with every previously accepted suite (floor ≥ 114 met
exactly; no parallel-track suite had landed). Named properties discharged:
P-CONFORMANCE (both ch.-9-named tests, C04) · P-LOADING-INERT (C05) ·
P-REG-FRESH registry + reflective arms (C05; gate clause → E05, recorded
split) · P-ERR-IS-RED registration arm (C02) · P-GATE-MISSING core-half
machinery (C02) · P-CFG-STRICT duplicate-name arm (C04). Leg 2:
`tools/precheck.sh` green at every pick (`38cbbbd` · `cda0e03` · `aa38715` ·
`890e9b0` · `a444cd6`); all five commits carry D-73 `E04-C##:` IDs. Leg 3: CI
run **30169997450** `completed success` on `9127e31`. One review round-trip
this epic (E04-C05 fix 1 — inert mutation arm made failable).

## Addendum — post-PASS punch list (swept 2026-07-25; one batch, no re-validation per the validation rules)

The Gate-4 validator passed this cut on round 1 (report:
`plan/validation/04-E04-report.md`, 0 BLOCKING · 2 MINOR · 1 ADVISORY). Both
MINORs applied the same day:

1. **P-REG-FRESH third clause assigned:** ch. 9's "mutating one configuration
   object never affects the other run" now lands as an explicit arm of
   `testTwoRunsShareNothing` (C05 skeleton amended; the split statement above
   names it) — the cross-epic split is exhaustive over the property's clauses.
2. **C01 `#echoRoles` arm completed:** the dispatch now states the missing
   spec's `kind:` comes from the entry's `#kind` like the other two arms — no
   implementer inference left.

The ADVISORY (kit-raised `PGRConfigurationError` propagation out of
`fromConfiguration:` is stated but untested in E04 — the scratch kit is
deliberately obedient) is recorded for the E05 cut: its exit-2 arm is the
natural test home.
