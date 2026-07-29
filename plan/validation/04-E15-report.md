# Validation report — E15 cut (Gate 4 pre-validation)

*Validator subagent output, written verbatim by the producing session (2026-07-28).
Round 1 of 1.*

---

## Validation report — E15 cut (`plan/04-epics/E15-ci-wrapper-guide1/`)

**Verdict: PASS — zero BLOCKING findings.** Four MINORs ride as the producer's punch list; two advisories recorded.

### Scripted sweeps (all on absolute paths, nonzero scanned-file counts asserted)

**Checklist 1 · Mechanical — PASS** (5 files scanned: 3 work orders + `chunks.md` + `ledger.md`):
- Every `depends-on` target exists (C02→C01; C03→C01,C02); no cycles, strictly serial as declared.
- Zero `[P]` chunks — disjointness vacuous; the no-`[P]` rationale (C02 reads C01's workflow; C03 measures C01/C02's runs) is sound.
- LOC: 35 + 140 + papers ≈ the stated ~175; roadmap gives "~3 chunks" and the cut is 3 — consistent; all under the 300 ceiling.
- Every chunk has a VERIFY section; ledger rows ↔ work-order files one-to-one, statuses `todo`, deps byte-matching; chunks.md table matches.

**Checklist 5 · Amended surfaces — PASS** (136 committed files scanned, matching the cut's own count):
- Workflow-shape sweep re-run: hits = `ci.yml`, `.smalltalk.ston`, guide 1 line 65, `PGRQuickstartSampleHarness` (runtime `SmalltalkCI` locator), and the src "step 1/2" stage comments — diff against C01's amendment table **empty** except one label (finding 3 below).
- Guide-1 consumers: zero committed `src/` references to `01-adopt-and-run`; the harness tests pin guides 2/3 only — "amended accepted surface: none" holds.
- The one accepted-test file in a manifest (`PGRQuickstartSamplesTest.class.st`, C02) is declared additive with byte-identical accepted methods and a reviewer-diff clause — the declared-amendment path, table provided, not a silent amendment.
- `.smalltalk.ston` inlined in C01 is **byte-identical** to the committed file, as claimed.

**Checklist 3 · Probe spot-checks — 5 run (≥3 required), all reproduce:**
- Wrapper arm A (missing VM): exit **3** + the one stderr line — exactly P1-A.
- Wrapper arm B (real VM, missing image): VM errors, exit **0** — the Q-40 false-green hole, independently reconfirmed; the missing-VM self-test arm choice is sound.
- Work image: committed guide 1 yields **3** samples (`#ston #smalltalk #smalltalk`) — C02 arm 1's tests-first red is real; `OCParser parseExpression:` discriminates (clean→`isFaulty` false, broken→`OCCodeError`) — P4 exact; `locateUpwardFrom:for:` finds `ci.yml`.
- `tools/install.sh` `IMAGE_SHA256` = `897668dd…` — the D-66 pin identity P2 claims.
- Bonus: self-hosted gate leg live — **12 registrations, GATE: GREEN, exit 0** — the baseline every verify floor cites. Harness selectors C02 names (`smalltalkCILocateFor:`, the three-stage chain, `install:`/`removeInstalled`, `newHarness`/`tearDown`) all exist in the accepted source.

**Checklists 2, 4, 6 (judgment):** C01 and C02 (the most complex) sampled fully — every signature is inlined, the complete target YAML and `.ston` are in-order, no "see another document" inside any work order, no interface used before introduction. Epic coverage complete: §7.4/P-WRAPPER-GUARD/P-SELF-HOSTED→C01, P-GUIDE-EXEC/D-59 M4 anchor→C02, §7.6/R-09/D-13→C03; `.smalltalk.ston` final-form confirmation→C01; exit checkpoint's five legs sweep every chunk's arms. Spec/decision citations spot-checked against ch. 7, ch. 9, D-13/40/45/49/59/60.a/63/64/65/66/75/76/77/82/83 — all support their claims verbatim (including the D-75-vs-ch.9-row conflict, correctly resolved decision-log-wins and queued as erratum). E14 digest @`2f4cccc`… (`2f4cccb`) matches the cut's summary; D-82 carry-forward 1 (step-1-only at cut) confirmed against the committed workflow.

### Findings (all MINOR — punch list, no re-validation needed)

1. **[item 6 · MINOR]** The "owner's cut notice" / "owner's E15 scope line" is cited five times (`chunks.md` lines 17–19, 75–76, 86–87; `C01` lines 46–47; `probes.md` line 8; plus the Q-40 entry) but is **recorded nowhere** — the only on-record owner word of 2026-07-28 for E15 is commit `181709f`'s two lines. Not blocking because every operative claim stands independently on recorded ground (B-23/M5: D-75's consequence line; B-25: its own backlog row; B-24 exclusion: the frozen roadmap E15 row omits it and B-24's schedule reads "E15-adjacent **or M5**"; probe sanction: D-82/Q-39 obligates it and D-65 places the scripts outside the product boundary). Punch: record the notice as an owner-note line at Gate 4 (the E10 precedent), or strip the attributions — per the D-82 carry-forward discipline, unrecorded owner words are precisely the recurrence shape it worries about.
2. **[item 1 · MINOR · arithmetic]** "All **five** steps green" / "five-step shape" (chunks.md acceptance row, exit checkpoint leg 1, frozen digest; C01 Arm 2 and VERIFY; ledger E15-C01 verify row) — the target YAML has **six** step entries, and the digest itself lists six items (checkout · setup · smalltalkCI · assembly · enforcement · self-test) under "five-step". A checkpoint verifier counting steps will trip loudly, not silently; fix the number in one sweep.
3. **[item 1/5 · MINOR · arithmetic]** C01's amendment table and P8 say the src "step 1/2" hits are "7 files"; scripted re-run: **7 hits across 6 files** (`PCKSuiteRunCache` carries two). All are stage comments as claimed; the untouched verdict is unaffected.
4. **[item 2 · MINOR · wording]** The defective-config handler fence (guide lines 129–135) sits in guide **§3**, but C02 (amendment 4, marker list, arm 7) and chunks.md call it "the §4 fence"; guide §4 contains no fence. Unambiguous in practice — the exact current text is quoted — but the label is wrong.

### Advisories (recorded, not acted on)

- The `on: [push, pull_request]` trigger vs. step-2's hosted load of `main`: on any non-main ref the gate judges `main`, not the head under test. The cut records this itself (agent-judged call 5) under D-64's main-only model; noting only that the `pull_request` trigger makes the mismatch reachable in principle.
- Q-40's arm-B false-green reproduced here independently; the recommendation-not-ruling posture and the "no chunk touches `guardrails.sh` unless ruled" fence are correctly maintained throughout the cut.

---

*Producer's punch-list sweep (same session, one batch, per the MINOR rule — no
re-validation): (1) the owner cut notice recorded as a dated owner-note line in
`chunks.md`; (2) five→six step count fixed in chunks.md, C01, and the ledger
verify row; (3) "7 files"→"7 hits across 6 files" in C01 and probes.md P8;
(4) the defective-config fence relabeled §3 (sample 4) in C02 and chunks.md.*
