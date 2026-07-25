# E04 chunk-cut validation report — VERDICT: **PASS** (0 BLOCKING; 2 MINOR, 1 ADVISORY)

Scope read: all five work orders + `chunks.md` in `/Users/mitt/dev/projects/phi-guardrails/plan/04-epics/E04-registry-kit-handoff-conformance/`, E04's row and dependencies in `plan/03-roadmap.md`, `plan/ledger.md`, `plan/00-constitution.md`, the frozen E02/E03 digests (`plan/04-epics/E02-sdk-vocabulary/chunks.md`, `plan/04-epics/E03-configuration-scope-law/chunks.md`), spec ch. 0 §0.4, ch. 1, ch. 9, and the committed fixture/SDK source under `src/`.

## 1 · Mechanical (scripted — two scripts, both on absolute paths, both asserting nonzero scan counts)

Script 1 (`validate_e04.py`, scanned 5 work orders — output above): **clean.**
- Dependency chain E04-C01←C02←C03←C04←C05 exists, linear, header/index/ledger all agree.
- `[P]`: none marked — disjointness vacuously satisfied; every header says `parallel: no`.
- LOC: targets 150+120+110+125+90 = **595 = index claim**; roadmap row ~5 chunks holds; all ceilings ≤ 300; index per-row estimates equal order targets.
- VERIFY command present in all five orders; floor arithmetic exact off the 88-test cut-time base: 95/101/106/112/114; test-bullet counts match claims (7/6/5/6/2 = 26 = 7+6+13 checkpoint suite).
- Ledger rows one-to-one (IDs, statuses `todo`, depends-on, per-chunk verify entries all match); COMMIT sections cite `tools/precheck.sh` (D-67) and D-73-qualified commit IDs in all five.

Script 2 (`validate_e04_cross.py`, 11 E04 manifest files vs 14 E07 + 5 E08): **E04 ∩ E07 = ∅, E04 ∩ E08 = ∅** — the "disjoint from the kit-track cuts" claim is machine-true; E04 touches only `Phi-Guardrails-Core` (2 files) and `Phi-Guardrails-Tests-Core` (9 files), no `package.st`, baseline, or frozen E02/E03 file. Within-E04 sharing is exactly the declared `PGRRegistry`/`PGRRegistryTest` pair (C03–C05), matching the no-`[P]` rationale.

## 2 · Self-containment (sampled C03, C04, C05 — the latter two the most complex)

**Sound.** Every consumed signature is inlined: the E02 vocabulary (verified selector-for-selector against `src/Phi-Guardrails-SDK/` — `missingReason:`, the three stamping setters, the internal `missingReason` reader, spec constructors/readers, check/kit protocols all exist as cited and are recorded in E02's digest for E04's consumption); the eight E03 readers (all present on `PGRConfiguration`); C01's fixture contract restated verbatim in C02–C05. No work order defers a load-bearing signature to another document. No interface is used before its introducing chunk. I also verified the sharpest inlined *facts*: the scratch baseline group tree, memberships, and `PGRScratchKit` behavior match committed source exactly; `validArtifactString` matches C03's digest character-for-character; and the C03 echo-test's exact-order expectation (`'production: Phi-Guardrails-SDK, Phi-Guardrails-Core | tests: Phi-Guardrails-Tests-SDK'`) is guaranteed by the E03 implementation (`expand:over:` answers group members in baseline declaration order — SDK before Core).

## 3 · Tests are real

All 26 skeletons assert behavior with decidable given/when/then (exact name sequences, `~~` identity for fresh copies, error-message substring clauses chosen for falsifiability — C04's `kindclash/X1` name deliberately avoids the lowercase `scratch` substring so the kind clause can fail). The C05 reflective sweep carries the mandatory nonzero-class-count guard for `-Core` (correctly *not* for `-Gate`, which is an empty stub today — verified). The transient-class test guards leftovers via `ensure:` + setUp remove-if-present.

## 4 · Epic coverage

Complete. Ch. 1 §1.4 steps 1–3 → C03; §1.4 step-2 validation + §0.4 invariant → C04; §1.5 core half → C02; R-01/R-08/R-35/R-40(contract)/R-41/R-42/R-06(missing half) all traced. All four roadmap-owed properties land under their exact ch.-9 test names and home classes (verified against ch. 9 lines 32/41/48/62); the three cross-epic arms (P-ERR-IS-RED registration arm, P-GATE-MISSING core half, P-CFG-STRICT duplicate-name arm — E03's recorded handoff) are discharged with explicit split statements. Exit checkpoint includes every chunk's tests (26) plus infra and CI legs.

## Findings (punch list — no re-validation needed)

1. **[MINOR · epic coverage]** `chunks.md` P-REG-FRESH split (lines 52–56) and C05's recorded arms omit ch. 9's third clause "**mutating one configuration object never affects the other run**" — it is named in neither the E04 arms nor the "two gates … reports" clause ceded to E05. One line assigning it (E05's gate clause, or an arm on `testTwoRunsShareNothing`) keeps the split exhaustive.
2. **[MINOR · self-containment]** C01's `#echoRoles` dispatch arm (lines 87–91) omits the resulting missing spec's `kind:` argument (the constructor requires one); C03's restatement (lines 44–45) supplies `#kind : 'scratch'` in the entry. One clause in C01 ("kind from the entry's `#kind`, as the other arms") removes the only inference an implementer must make.
3. **[ADVISORY]** The exit-checkpoint digest states a kit-raised `PGRConfigurationError` propagates out of `fromConfiguration:` unhandled, but no E04 test exercises kit-raised propagation directly (the scratch kit is deliberately obedient; C04 witnesses only engine-raised errors escaping). E05's exit-2 tests are the natural home; recorded as an observation.

**Verdict: pass** — zero BLOCKING findings; the MINORs ride as the producer's one-batch punch list.
