# Gate-4 validation report — E05 chunk cut (7 work orders, `plan/04-epics/E05-gate-report-invocation/`)

## Verdict: **PASS** — 0 BLOCKING · 1 MINOR · 3 ADVISORY

---

## 1 · Mechanical sweep (scripted — `e05_mech.py`, output below)

Script scanned **11 files** (nonzero asserted). All clean:

- **Dependency existence:** every `depends-on` target exists (C03→C02, C04→C03, C05→C04+C01, C06→C05, C07→C05); work-order headers, chunks.md table, and ledger rows agree three-way on IDs, deps, and [P] flags — 7 = 7 = 7, one-to-one.
- **[P] disjointness:** C01 (`PGRConfiguration` + `PGRConfigurationTest`) ∩ C02 (`PGRReport` + `PGRReportTest`) ∩ C07 (`guardrails.sh`) = ∅. C03–C06's shared `PGRGate`/`PGRGateTest` file pair is strictly serial as declared.
- **LOC:** 60+150+130+110+155+115+40 = **760** = chunks.md's stated total; all ceilings ≤ 260 < the 300 hard limit; the 7-vs-~6 chunk deviation is annotated as the owner-scheduled B-15 rider (D-61.a), verified against the backlog row (`plan/backlog.md` line 22, landing "E05").
- **Verify commands:** every work order has a VERIFY section; ledger has all 7 verify lines.
- **Count arithmetic:** 3+7+4+4+4+4 = 26 new tests; 148 accepted (confirmed: ledger E08-C05 row, "accepted @ 19beb68, 148 run") + 26 = 174 checkpoint floor; per-chunk floors 151/155/162/166/170/174 all consistent; `PGRGateTest` 4+4+4+4 = 16 ✓, `PGRConfigurationTest` 35+3 = 38 ✓ (35 accepted methods counted by script).

## 2 · Item 5 — amended accepted surface (scripted)

Exactly one chunk (E05-C01) touches committed files, matching the tabled claim. Scripted consumer enumeration: `grep -rn 'fromFile:' src/` → 9 hits, of which **2 call sites**, resolving to `PGRConfigurationTest>>#testFromFileMissingFileSignals` and `#testFromFileParsesAndAnchorsRelativeSrc` — **diff against the C01 amendment table: empty**. Zero production callers, as tabled. No other manifest contains an accepted file (C02/C03 create new files — verified absent from `git ls-files`; C04–C06 modify only files C02/C03 introduce this epic; C07's `guardrails.sh` verified absent at root).

## 3 · Self-containment (judgment — sampled C05 [most complex], C02, C06 fully; C01, C03 checked against sources)

Every signature the digests inline was verified against committed sources, byte-for-byte where quoted:

- C01's `fromFile:` body quote matches `src/Phi-Guardrails-Core/PGRConfiguration.class.st:60-68` exactly; its stage-7 claim (empty `#exemptNamePatterns` + nonempty exempt role ⇒ direction 1 fires naming `'PGR-Scratch-Ghost'`) verified against the accepted `validateExemptNamePatterns:roles:` — empty pattern loop ⇒ empty `matchedExempt` ⇒ signal naming the unmatched package; the plain-baseline third arm is genuinely vacuous (empty exempt role). The helpers (`validArtifactString`, `artifactWith:value:`, `artifactWithout:`, `pgr-c27-scratch` discipline) all exist as described.
- C02's `PGRVerdict`/`PGRFinding` inventories match `src/Phi-Guardrails-SDK/` exactly (incl. the D-68.1 `missingReason` reader and the stamping setters); "no baseline edit" verified — both Gate packages are in the baseline and role groups since E01.
- C03/C06's E04 digest quotes match the frozen tabled surface in E04 `chunks.md` §checkpoint verbatim, including the propagation sentence; the E04 Gate-4 ADVISORY (kit-raised error untested) is quoted correctly from the E04 addendum and both its arms land in C06.
- Scratch cast verified: `PGRScratchSpecKit` arms, `PGRScratchErroringCheck` (`Error 'scratch check exploded'`), `PGRScratchRedCheck` (target/message as quoted), both scratch baselines' package/group trees.
- Cross-epic completions are all real: `PGRRegistrationTest>>#testErroringCheckYieldsRed` ✓, `PCKTestSuiteCheckTest>>#testMissingOnEmptyTestsRole` ✓, and `PGRRegistryTest>>#testTwoRunsShareNothing`'s reflective sweep does iterate `#('Phi-Guardrails-Core' 'Phi-Guardrails-Gate')` — the "covers the gate classes without amendment" claim holds.
- C07's `--headless` accommodation claim verified: every `tools/*.sh` VM invocation carries it; the D-63 probe record says exactly what C05/C07 consume (flush not required, harmless belt-and-braces; exit code preserved under `eval`). The §7.3 script text in C07 is byte-identical to spec ch. 7. `guardrails.sh` is named in the constitution's write boundary.
- No chunk says "see" another document for a needed interface; no interface is used before its introducing chunk (C03 uses only C02+accepted; C05 only C01–C04+accepted).

## 4 · Tests are real / epic coverage (judgment)

Every skeleton is given/when/then with a failure mode (fresh-copy identity assertions, mid-registry continuation, exact name-order arrays, exit-code assertions, one-line/`lf` counts); C07's four shell arms demand exact exit codes 0/1/2/3 with a stop-and-report clause if the VM's unloadable-image code lands in {0,1,2}. Property-name/test-name pairs all match ch. 9 rows exactly (checked all 14 named tests). Roadmap coverage: §7.1 (C02/C04), §7.2 (C02/C03), §7.3 (C05/C06/C07), §7.6 (design honored at C05; sweep explicitly recorded as E09's — a stated split, not drift); all 10 roadmap properties discharged in-epic, the four cross-epic completions recorded as statements. The exit checkpoint sums every chunk's tests (26 named + C07's shell leg) and its frozen-surface list matches ch. 0 §0.3's gate-caller SDK row exactly.

## Findings

1. **MINOR — item 1, floor arithmetic conditionality.** C03's and C04's ledger verify lines state floors ≥162/≥166 unconditionally, but those floors include E05-C01's 3 tests, and the dependency graph permits C01 ([P], no dependent until C05) to land after C03/C04 — the sweep would then run 159/163 and the ledger floor would read as a failure. The work orders themselves carry the saving condition ("when stacked after E05-C01–C02") and chunks.md serializes the [P] chunks, so nothing builds on wrong ground. Sweep: `plan/ledger.md` lines 111–112 vs `C03…md` VERIFY, `C04…md` VERIFY.
2. **ADVISORY — C01 amendment-table caption.** "`grep -rn 'fromFile:' src/` … all hits accounted" — the grep yields 9 hits; the table accounts the 2 call-site consumers (correctly and completely), while 7 comment/error-message-text hits (incl. accepted `testRelativeSrcWithoutAnchorSignals`, which asserts the substring `'fromFile:'` in a `fromString:` error message and is unaffected) go unmentioned. The consumer enumeration is complete; the caption overstates the table's coverage.
3. **ADVISORY — C05 decoy vs constitution wording.** The `guardrails.ston` decoy is created/deleted inside the test body under `ensure:`, not in `setUp`/`tearDown` as the constitution's scratch-file clause is worded; the order guards pre-existing files and `guardrails.ston` is a sanctioned root artifact, so the boundary itself is honored.
4. **ADVISORY — C02 `[SKIPPED]` rendering arm.** The rendering handles `#skipped` but no producer exists (per the E04 digest) and no C02 skeleton exercises that arm; it is reachable only via direct `PGRVerdict class>>skipped` construction. Observation only.

**Pass** — MINORs ride as the producer's one-batch punch list, no re-validation. I changed nothing; the scripted sweep and its full output are reproducible at `/private/tmp/claude-501/-Users-mitt-dev-projects-phi-guardrails/7d560071-f5f2-4eaf-bfd1-07595ad30c62/scratchpad/e05_mech.py` (run output: 7/7/7 row agreement, [P] disjoint, LOC 760, consumer diff empty, 11 files scanned, "CLEAN — no mechanical findings").
