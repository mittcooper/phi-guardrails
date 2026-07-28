# E12 validation report — VERDICT: **PASS** (0 BLOCKING · 2 MINOR · 2 ADVISORY)

Validated: `/Users/mitt/dev/projects/phi-guardrails/plan/04-epics/E12-toy-client-init-tool/` (5 work orders + `chunks.md` + `probes.md`), E12's row in `plan/03-roadmap.md`, `plan/ledger.md`, `plan/00-constitution.md`, frozen digests of E03/E06/E07/E10 (their `chunks.md` exit checkpoints), spec ch. 0 §0.3 / ch. 1 §1.1+§1.3 / ch. 8 §8.1+§8.2, decision log entries D-26/D-45/D-49/D-57/D-82(Q-39), and the committed accepted sources.

## 1 · Mechanical (scripted — 5 work-order files + ledger scanned, nonzero asserted)
- Every `depends-on` chunk exists (C03→C01,C02 · C04→C01,C02 · C05→C01). **PASS**
- `[P]` pairs (C01∥C02; C03∥C04∥C05) all have disjoint deliverable manifests — script intersected every pair: empty. **PASS**
- LOC targets 110+100+140+90+170 = 610, matching chunks.md's stated ≈610; roadmap gives no LOC figure ("~7 chunks", cut as 5 with stated justification). **PASS**
- Every chunk has a VERIFY with `tools/build-image.sh && tools/verify.sh` plus the 12-registration gate regression leg; C02 additionally carries its unswept-pair eval arm. **PASS**
- Ledger rows one-to-one with work orders, deps matching, per-chunk verify entries present (ledger.md:81–85, 158–162). Floor arithmetic checked: 250+13 net swept = ≥263; per-chunk floors (252/250/257/254→259/256→263) all consistent with the serial pick order. **PASS**

## 2 · Self-containment (sampled C03, C05 — the most complex — plus C04)
Every signature the skeletons use is inlined in its digest (checker recipe, `rule:packages:`, the three-argument kit contract with the full block shape, `PGRRegistrationSpec`/`PGRVerdict`/`PGRFinding` readers, baseline-introspection spellings, envelope keys, the four amendment points spelled as triples). The only "see" is C05:224 referring to its own digest. No interface is used before its introducing chunk (C04 uses C02's rule and C01's baseline — both deps; C05 needs only C01: `fromString:` validation doesn't open kit blocks or require tests-role classes, so it is sound after C01 alone). Digest-cited spellings match the frozen E02/E06/E07/E10 digest texts exactly. **PASS**

## 3 · Tests are real + Q-39 probe evidence
All 15 skeletons are behavioral given/when/then with concrete expected values (package lists, entity identities, six names in order, counts) — none assert mere existence. `probes.md` discharges the D-82/Q-39 obligation at the recorded HEAD `bca7c9b`, which is the current HEAD; I re-ran **12 probe rows live** against `.build/work/phi.image` (P1, P4, P6, P9, P10, P11, P14, P16, P18, P24, P26, P27) — **all confirm**, including the load-bearing negatives (`redFindings:advisories:` absent, `BaselineOfToy` unbound, `'Toy-Tests'` outside the production pattern). I also live-probed the two frozen spellings probes.md has no row for (below): both true.

- **MINOR-1** (item 3 · `plan/04-epics/E12-toy-client-init-tool/probes.md`): C03's skeletons name `PCKKit registrationsFrom:productionPackages:testsPackages:` and the `PGRRegistrationSpec` readers `name`/`kind`/`check`/`missingReason`; the work order cites their frozen digests (Q-39's digest-check arm — both spellings are digest-exact in E02's frozen table), but probes.md's own preamble promises digest-checked *rows*, and neither has one. Record-completeness only — I verified both live-true and digest-exact.

## 4 · Epic coverage
Roadmap E12 spec assignments all land: ch. 8 §8.2 → C01/C02/C03/C04 · ch. 1 §1.1 example → C04 (I compared the work-order text against the spec example key-by-key: identical content, annotations stripped) · ch. 8 §8.1 step 1 → C05 · ch. 0 §0.3 → C05's mirror amendment. Requirements R-32 (fixture half), R-36, R-05, R-47, R-31 (draft half) all covered; the six-registration order matches E06/E07's frozen order law. Exit checkpoint leg 1 names every swept chunk suite (2+5+2+4 + amended pin); C02's pair rides leg 4's eval arm — consistent with the pinned D-57 unswept design, not a gap. E14-boundary claims verified: no committed test sends `run` at registry/gate level over toy configuration (C04 stops at `isResolved`; the six-red arm is the orchestrator-run leg 3). **PASS**

## 5 · Amended-surface completeness (scripted — **110 committed src files scanned, nonzero asserted**)
Exactly one accepted file amended (E12-C05): `src/Phi-Guardrails-Tests-SDK/PGRSurfaceConformanceTest.class.st`. My independent sweep for the manifest class, all four audience-method names, `PGRConfigurationDraft`, `draftFor:`, and the to-be-renamed test selector found **exactly one consumer — the amended file itself**; diff against the cut's amendment table: **EMPTY**. No other chunk manifest `modify`s an accepted file (C03/C04's modifies are in-epic creations). Both claimed schedules verified in ruled/accepted text: the committed class comment ("`PGRConfigurationDraft` is E12") + method comment ("E12's `draftFor:` cut amends this by schedule"), and the D-82 §0.3 erratum ("join this roster's conformance-test mirror at the next test-touching chunk"). Arithmetic verified against the committed file: 41 triples now, 4 audience methods, 3 test methods → 46/5 as claimed; the `>= 40` floor stays valid untouched. The accepted-ground safety sweeps (P29–P32) reproduce: no committed test asserts a toy package is classless (smoke test pins package *lists* only, re-checked). **PASS**

## 6 · Intent attribution (scripted sweep over 7 files + spot-checked citations)
Keyword sweep (`never/must/by policy/forbidden/...`) produced 3 uncited-context hits, all false positives (a plant description, a constitution-section line, a floor-phrasing line). Spot-checked citations all support their claims: D-26 (committed-red + exempt-role guard), D-45 ("generation may guess, the run-time gate may never infer" — verbatim in the entry; the "ruling 4" numbering follows the spec's own §8.1 citation), D-82/Q-39 (probe obligation as described), D-57, §8.2 (in-package groupless baseline, plant table, class-side STON embodiment — all verbatim sources of the digests), §1.3 (`PGRConfigurationDraft` row), R-05/31/32/36/37/43/44/47 all exist as cited. The C05 discovery anchor and sort order are framed as guesses under D-45's granted ground with probe evidence (P4/P6) — attributed, not invented. **No producer-invented intent found.**

## Remaining findings (punch list — no re-validation needed)
- **MINOR-2** (item 6 wording/arithmetic · `C04-toy-artifact.md:36`): "minus its three annotation strings" — the §1.1 rendering carries **five** quoted annotation strings (four annotation sites). Harmless: the exact text to commit is inlined and was probe-parsed (P33), so no implementer acts on the count.
- **ADVISORY-1** (`C05-configuration-draft-mirror.md:169`): LOC target ~170 exceeds the constitution's 50–150 target band (ceiling 300 respected; the cut states its no-split rationale in chunks.md).
- **ADVISORY-2** (C04/chunks.md): "§1.1's example **verbatim**" is content-verbatim, not byte-verbatim (indentation/alignment differ from the spec rendering once annotations are stripped). The pin tests assert structure, not bytes; no downstream effect — but the frozen-digest wording could say "content-identical" to forestall a byte-diff dispute at E14.

**Verdict: PASS** — zero BLOCKING findings; the two MINORs and two ADVISORYs ride as the producer's one-batch punch list.

---

*Producer's record (appended by the task-writing session, outside the verbatim report
above): validation round 1 of 1 — PASS on the first round, fresh validator subagent,
byte-exact assembled brief ({{PACK}} + validation body + EPIC = E12, nothing else).
The two MINORs were swept in one batch after this report was filed (probes.md gains
the two digest-checked rows; C04's annotation-count wording corrected); the two
ADVISORYs are recorded, not acted on, per the validation rules.*
