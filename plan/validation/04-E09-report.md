All sweeps complete. Final report.

---

# E09 validation report — VERDICT: **PASS** (0 BLOCKING · 2 MINOR · 2 ADVISORY)

Inputs read byte-for-byte: `plan/04-epics/E09-self-host-m1-freeze/` (all six work orders + `chunks.md`), the E09 row and dependency rows in `plan/03-roadmap.md`, `plan/ledger.md`, `plan/00-constitution.md`, and the frozen digests of E05 (`70410b3`), E07 (`f569549`), E08 (`19beb68`) in their `chunks.md` files — all three heads match the entry-check citations.

## Checklist results

**1 · Mechanical (scripted — `mech_check.py`, output below): PASS.**
- 6 table rows scanned (nonzero asserted); every `depends-on` (C05→C04, C06→C05) exists in the cut; header depends match table depends match ledger depends.
- LOC targets 155+120+110+160+150+115 = **810** = the stated total; each work order's budget line matches its table row. The +1 over the roadmap's ~5 is the harness split the frozen row's own risk line anticipated — divergence recorded in `chunks.md`.
- Every chunk has a VERIFY and COMMIT section; ledger carries a verify-command row per chunk; ledger E09 rows are one-to-one with the work orders, all `todo`.
- `[P]` set {C01, C02, C03, C04}: 6 pairs checked, all manifests pairwise disjoint (four distinct packages + repo-root `guardrails.ston`).
- Floor arithmetic all correct: 174+6=180 (C01), +3=177 (C02), +6=180 (C03), +4=178 (C04), 179/194 (C05), 195=174+21 (C06); 21 = 6+3+6+4+1+1.

**2 · Self-containment (judgment; sampled C01, C03, C05 — C05 the most complex — plus C04's harness contract): PASS.**
- Every consumed signature is inlined: C05 inlines the full harness surface, the frozen report/verdict/spec readers, the scratch envelope verbatim, and the `BaselineOfPGRScratchGrouped` role expansions — which I verified against the committed fixture (`scratch-prod` = SDK+Core, `scratch-tst` = Tests-SDK, ghost exempt: exact match). C03 inlines the artifact byte-content, the baseline-introspection idiom as code, and PCKKit's exact expected spec-name order. C01 inlines the seven package names, ban lists, allowlist, and witness set. References to `chunks.md`/decision IDs are provenance annotations, not required lookups.
- No interface used before introduction: C05 consumes only C04's harness (declared dependency); C06 only C04+C05 ground; C01–C04 consume only frozen E02/E03/E05/E06/E07/E08 surfaces, each verified verbatim against the prerequisite digests.

**3 · Tests are real: PASS.** All six chunks' skeletons are given/when/then with failure modes: C01's sweeps carry nonzero-scan floors *and* known-banned witness assertions (a wrong predicate reds, never vacuously passes); C02's existence test is exactly what P-SURFACE-CONFORMS owes (D-54) and carries the ≥40-triple guard plus the four-audience manifest-gutting guard; C03's pins are decidable permanent facts (pattern non-match, exact group inventory, exact spec order, non-nil resolution) — explicitly "never `assert: true` placeholders"; C04's inventory pins fail on guide drift or parser bug; C05/C06 assert the guides' stated facts with named per-arm assertions.

**4 · Epic coverage: PASS.** Roadmap-assigned spec sections all land: ch. 7 §7.5 M1 form → C03; ch. 9 §9.1–§9.2 → C01/C02/C05/C06; ch. 0 §0.3 → C02; D-59/D-60 → C04–C06. Requirements R-04/R-05/R-15/R-38/R-47 all traced with scope annotations. All seven owed properties placed and stated, plus the recorded forms (P-FIX-GATE-WALL reflective, P-SELF-HOSTED M1); the P-SELF-HOSTED CI-form deferral to E15 is consistent with the frozen roadmap's E15 row and the §1 M1 checkpoint (which requires only the local runner leg) — divergence properly recorded. Exit checkpoint names all six suites, 21 tests, floor ≥195.

**5 · Amended surface (scripted): PASS — the "none" claim holds.** 207 tracked files at HEAD scanned, 53 accepted test files scanned (both nonzero asserted): **no manifest path exists at HEAD** — all six deliverable files plus `guardrails.ston` are new; no accepted test file appears in any manifest. C06's edit of `PGRQuickstartSamplesTest.class.st` is C05's same-epic file, scheduled with a byte-identity reviewer duty — not accepted ground. Diff against the cut's amendment claim: empty.

## Ground-truth corroboration (beyond the checklist, all scripted/grep-verified)

- **C02's 41-triple roster:** transcribed into `surface_check.py` and resolved against committed Tonel — **41/41 defined on the stated side**, 4 error classes chain to `Error`. The count matches both the work order's "41" and my independent count of ch. 0 §0.3.
- **C03's baseline facts:** committed `BaselineOfPhiGuardrails` groups = exactly the claimed 7/7/1/5 memberships; both stub packages (`Phi-Guardrails-Tests-Toy`, `Phi-Coding-Kit-Tests-Architecture`) confirmed classless — the forced move is genuinely forced (E07's frozen missing semantics × R-38); `PCKKit` source confirms the five-key schema, four-stage order, `'lint/'`/`'behavioral/'` spellings, and the three-key `recommendedBlock` — 2 lint + 7 behavioral + 1 meta = the claimed 10 registrations.
- **C04's guide pins:** fence scan gives guide 2 = `smalltalk smalltalk smalltalk ston smalltalk` (5), guide 3 = untagged + `smalltalk` + `ston` (2 samples) — exact match. Guide contents match every C05/C06 claim, including the elided `setPackages:` plumbing in guide-2 §2 (the F-1 resolution is genuine) and the Symbol/String `target` comparison risk at sample 3 (genuinely present at `docs/quickstarts/02-write-a-check.md:96`, correctly handled as a stop-and-report).
- **C01's walls hold on accepted ground today** (so no day-one stop-and-report): zero engine refs in SDK/Core, zero Toy refs in production, zero Core/Gate refs in kit packages, zero PCK refs in Gate, Transcript only in a class comment (invisible to a literals scan), Zinc exactly in `fromFile:` (`PGRConfiguration.class.st:65` — the B-15 pin is satisfiable), file-triad only in `PGRConfiguration`, zero extension-method files. Scan floors comfortably met by real counts: SDK+Core 94 ≥ 40, seven production 156 ≥ 100, Gate 17 ≥ 10, kit family 140 ≥ 60.

## Findings

1. **MINOR** · checklist 3 · `C01-arch-self-test.md` TESTS FIRST — skeletons 5 (`testNoProductionMethodReferencesTranscript`) and 6 (`testNoNetworkOrStrayFileReferences`) omit the explicit numeric scan floor that skeletons 1–4 carry ("given every method in the seven production packages" with no "≥ N"). The sweep-design rule ("each test asserts its sweep visited a nonzero method count") still binds them, so no wrong build results — but stating ≥ 100 on both would remove the asymmetry.
2. **MINOR** · checklist 2 · `C01-arch-self-test.md` — the file-triad allowlist entries `PGRGate class>>#runHeadless:`/`runHeadless:on:` are dead against today's committed source (only `PGRConfiguration` references the triad); the Zinc entry gets a liveness pin (the B-15 assertion) but the two gate entries get none, so a future removal of their (currently nonexistent) triad use is invisible. Harmless slack mirroring the ch. 9 letter; a one-line note in the work order would do.
3. **ADVISORY** · `C04-quickstart-sample-harness.md` — "must not choke on guide 1's file" is stated but no pin test exercises guide 1 at E09 (its execution is E15's); the claim is untested until M4. Recorded, consistent with the out-of-scope list.
4. **ADVISORY** · `chunks.md` — the P-DETERMINISTIC Zinc-arm reconciliation is a recorded divergence from the ch. 9 letter (which allowlists no Zinc reference); the cut's handling (same allowlist + pin + the owner's ch. 9 erratum ride) is the right shape, but the erratum should not be forgotten at the next spec pass.

**Verdict: PASS** — zero BLOCKING findings; the two MINORs ride as a punch list for the producer's single batch sweep, no re-validation needed. Scripts run on absolute paths under `/private/tmp/claude-501/.../scratchpad/` (`mech_check.py`, `surface_check.py`); both asserted nonzero scanned-file counts (6 table rows, 6 work orders, 207 tracked files, 53 accepted test files, 41 triples) before claiming clean, and both exited 0.
