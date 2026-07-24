# E02 · SDK vocabulary and skeletons — chunk index (M1)

*Produced by Prompt 4 (second run). Entry check: Gate 3 closed and roadmap frozen
(D-62); E02's only dependency E01 is `accepted` in `plan/ledger.md` (2026-07-23)
with its interface digest frozen (the 21-directory `src/` inventory + baseline
group tree, witnessed by `PGRBaselineSmokeTest`). Owner notes for this cut: D-66
(checksum-pinned install) and D-67 (commit hygiene) each rule one small build-infra
chunk into E02 alongside the roadmap scope — both verified in the decision log.*

| ID | Title | Depends | [P] | LOC est. | Acceptance (one line) |
|---|---|---|---|---|---|
| C05 | Checksum-pinned toolchain install (D-66) | — | yes | ~20 | `install.sh` verifies both zips by SHA-256 on every run; the tamper arm exits nonzero naming file + both checksums; double-run green |
| C06 | Commit-hygiene precheck (D-67) | — | yes | ~30 | `precheck.sh`: clean tree modulo `plan/ledger.md` → exit 0 + HEAD sha; any other dirt (incl. untracked) → exit 1 + listing |
| C07 | SDK error vocabulary | — | yes | ~60 | four direct-`Error` subclasses in `-SDK`, catchable by class, mutually disjoint; `PGRSdkErrorsTest` (3) green |
| C08 | `PGRFinding` value | — | yes | ~70 | both constructors + three readers; `rationale` nil-able; non-API `printOn:`; `PGRFindingTest` (3) green |
| C09 | `PGRVerdict` value | C08 | no | ~130 | five constructors total over P6's states; frozen caller readers; internal stamping + `missingReason`; `PGRVerdictTest` (7) green |
| C10 | `PGRRegistrationSpec` value | — | yes | ~70 | resolved/missing constructors + four readers, kind explicit on missing-specs; `PGRRegistrationSpecTest` (2) green |
| C11 | `PGRCheck` + `PGRKit` skeletons | C09 | no | ~110 | `packages:` constructor, `canFix` default false (**P-CANFIX-DEFAULT** by its ch.-9-named test), two-message kit contract; both skeleton suites (4) green |

Total ~490 LOC across 7 chunks (= the sum of the work-order targets; roadmap
estimate ~5 for the SDK scope — holds; the
two extra rows are the D-66/D-67 ruled build-infra chunks, owner-noted into this
cut). Size notes (constitution §3 band, on record for Gate 4): C05 (~20) and C06
(~30) sit below the 50 floor, deliberately — ruled single-purpose shell chunks
carry little code by nature (the E01 C03/C04 precedent).

`[P]` semantics: C05/C06 touch only `tools/`; C07/C08/C10 add disjoint class files
to the two SDK packages (no `package.st` or baseline edit — no shared mutable
surface). Under the D-67 discipline picks are sequential with a clean tree between
them; `[P]` records structural independence (worktree-parallel is safe), not a
scheduling requirement.

## Agent calls recorded (four confirmed at the Gate-4 spot-check — D-68; the rest veto-open, closing on the D-16 precedent at acceptance)

- **`PGRVerdict` internal `missingReason` reader** *(confirmed, D-68)*: the frozen
  caller surface (ch. 1 §1.3) lists no reason reader, yet §1.5 requires the report
  to show what was missing *and why* — the reason is stored and exposed
  **internal-only** for E05's report rendering.
- **Engine-stamping spellings** `registrationName:` / `kind:` / `durationMillis:`
  (internal protocol `'internal - engine stamping'`; E04 consumes).
- **`setPackages:` private setter** on the check skeleton — mirrors guide 2's
  plain-class sample spelling (D-60's recorded veto-open rider).
- **`fixCommandOn:` present on the skeleton as a `subclassResponsibility` marker**
  *(confirmed, D-68)*: the ch. 0 object diagram lists the member on `PGRCheck`;
  `canFix`-false checks are never sent it, so the marker is documentation, not
  obligation.
- **Single test home `PGRSdkErrorsTest`** *(confirmed, D-68)* for the four
  near-empty error classes — the descriptive `PGR*Test` precedent (E01's
  `PGRBaselineSmokeTest` call) over four one-assertion `<Subject>Test` classes.
- **`PGRMinimalCheckFixture`** name and residency (`Phi-Guardrails-Tests-SDK`,
  beside its test — ch. 9 §9.3's fixtures-without-red-tests rule).
- **Handed collections copied to `Array`** at value construction (no shared
  mutable state — R-35's spirit applied to the vocabulary).
- **No `isMissing`/`isResolved` convenience on `PGRRegistrationSpec`** — the
  surface is exactly ch. 1 §1.3's four readers (complete *and minimal*).
- **D-67's work-order-template amendment realized:** every E02 work order carries
  a `COMMIT` section (precondition: clean tree modulo the ledger; postcondition:
  one commit `C##: <title>`, nothing uncommitted). From E02 on this section is part
  of the Prompt-4 format. *(The clause-(b) subsumption reading inside C06 is
  confirmed as the final, one-check form — D-68; no stronger-check backlog item is
  filed.)*

## Exit checkpoint (freezes E02's interfaces)

E02 is provable by, on one head commit:

1. **Named suite:** the six `Phi-Guardrails-Tests-SDK` test classes —
   `PGRSdkErrorsTest` · `PGRFindingTest` · `PGRVerdictTest` ·
   `PGRRegistrationSpecTest` · `PGRCheckSkeletonTest` · `PGRKitSkeletonTest`
   (19 tests) — green under `bash tools/build-image.sh && bash tools/verify.sh`,
   with the 5 `PGRBaselineSmokeTest` smoke tests still green (24 run, 0 failures,
   0 errors) — this suite is the machine witness of the frozen export below.
   `PGRCheckSkeletonTest>>#testCanFixDefaultsFalse` is **P-CANFIX-DEFAULT**
   (ch. 9), the property this epic owes.
2. **Infra legs (ruled riders):** `tools/install.sh` double-run green with
   checksum-verified lines and the tamper arm exiting nonzero (D-66);
   `tools/precheck.sh` four arms behaving as C06 specifies (D-67).
3. **CI leg:** the committed `.github/workflows/ci.yml` (step 1) green on an actual
   CI run of the same commit — the new SDK tests ride the existing smalltalkCI
   sweep.

**Frozen at acceptance (E02's interface digest — later epics build on these;
amendments need a decision-sheet entry):**

- `PGRVerdict` — class: `green` · `greenAdvisories:` · `redFindings:` ·
  `missingReason:` · `skipped` (engine-only, D-21/D-32); instance: `status` ·
  `findings` · `advisories` · `registrationName` · `kind` · `durationMillis` ·
  `isGreen`.
- `PGRFinding` — class: `target:message:` · `target:message:rationale:`;
  instance: `target` · `message` · `rationale`.
- `PGRRegistrationSpec` — class: `name:kind:check:` · `missing:kind:reason:`;
  instance: `name` · `kind` · `check` · `missingReason`.
- Errors, catchable by class, mutually disjoint: `PGRConfigurationError` ·
  `PGRNotAutofixable` · `PGRFixNotPreviewed` · `PGRFixStale`.
- The **check protocol** — class: `packages:`; instance: `run` · `kind` ·
  `canFix` (skeleton default false) · `fixCommandOn:` · reader `packages`
  (conformance, not ancestry — `PGRCheck` optional).
- The **kit protocol** (class-side, two messages) —
  `registrationsFrom:productionPackages:testsPackages:` (answers ordered
  `PGRRegistrationSpec`s; never the configuration object) · `recommendedBlock`
  (STON text). (`PGRKit` optional.)

Checkpoint result (filled at acceptance): —

## Addendum — post-PASS punch list (owner notice, 2026-07-23; one batch, no ruling content, no D-number)

Three items accepted as found and applied the same day:

1. **C07 LOC aligned:** the index figure (~70) matched neither the order's target
   (60) — index row set to ~60 and the total restated as ~490, now equal to the
   work-order target sum (20+30+60+70+130+70+110) by construction.
2. **C11 kit-contract test re-mechanized:** `testKitContractIsTwoClassSideMessages`
   now asserts the locally-defined class-side selector set (metaclass `selectors`)
   **equals exactly** the two-message pair — `respondsTo:` presence removed; a third
   drifted-in class-side message or an inherited impostor standing in for a locally
   vanished contract message is a red test.
3. **C11 TRACE restated** to "R-40 (i)" per the frozen roadmap's E02 row — the
   former parenthetical belonged to E04's R-40 label and is struck from all E02
   papers (worded here without the literal string so mechanical sweeps stay clean).
