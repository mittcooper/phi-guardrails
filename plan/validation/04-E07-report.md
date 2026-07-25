All sweeps complete. Compiling the verdict.

---

# Gate-4 validation report — E07 (behavioral kind) chunk cut

**Verdict: PASS** — zero BLOCKING findings. Two MINORs ride as the punch list; two advisories recorded.

## Scripted sweeps (all on absolute paths, nonzero scanned-file counts asserted)

**Sweep 1 — mechanical** (`scratchpad/validate_e07.py`, scanned 6 work orders + ledger):
- Dependency chain: all `depends-on` targets exist; the strictly linear chain C01←C02←C03←C04←C05←C06 matches index and ledger exactly.
- `[P]`: no chunk claims parallel — matches the index's "no [P] anywhere, deliberately" and its stated structural reason (shared file pairs, consumed deliverables).
- LOC: targets 125+105+115+115+150+70 = **680**, equal to the index's claimed sum; all ceilings ≤ constitution's 300; 680/6 ≈ 113 avg sits inside the 50–150 band, consistent with the frozen roadmap's ~6-chunk row.
- Every work order has VERIFY and COMMIT sections (all citing `precheck.sh` per D-66/D-67 and epic-qualified commit IDs per D-73).
- Ledger rows E07-C01…C06 match work-order files one-to-one, depends-on identical, verify lines present.
- Floor arithmetic verified end-to-end: 88 accepted + 5/3/3/3/5/1 → floors 93/96/99/102/107/108, identical in work orders, ledger, and exit checkpoint; 20 new E07 tests total confirms the checkpoint's named suite (5+3+4+3+5).

**Sweep 2 — cross-epic manifest disjointness** (16 work orders across the three concurrent cuts E04/E07/E08): zero overlap in any pair. E07's 14-file manifest matches its declared package fence exactly (`-Behavioral`/`-Fixtures-Behavioral`/`-Tests-Behavioral` + `PCKKit.class.st` + `PCKKitTest.class.st`); no concurrent cut touches `Phi-Guardrails-Tests-SDK` (C03/C04's green-arm subject) or the `Phi-Coding-Kit` root package (C03's missing-arm subject).

## Judgment checks

**Self-containment** (sampled C05 — most complex — plus C03, C04, C01): every signature used is inlined and I verified each against the actual frozen ground, not just the digests: E02's digest (`PGRFinding target:message:[rationale:]`, `PGRVerdict green/redFindings:/missingReason:`, `PGRRegistrationSpec name:kind:check:`/`missing:kind:reason:`, check protocol) matches `plan/04-epics/E02-sdk-vocabulary/chunks.md` and the committed SDK sources — including the non-frozen internals the orders lean on, which really exist: `PGRCheck>>setPackages:` (private) and `PGRVerdict>>missingReason` (internal reader, explicitly documented as such in the class comment). E06's digest confirms the order law already names E07's insertion, and the "E07 extends the class in place" ruling exists in E06's papers (chunks.md:35, C16:112). C05's amendment table's "current assertion" column matches the committed `PCKKitTest.class.st` line-for-line (all 8 amended + 5 untouched = the 13 accepted methods; the untouched-set reasons check out against the source). No interface is used before its introducing chunk. The committed `PCKKit>>registrationsFrom:` matches C05's stated starting point exactly.

**Tests are real:** every skeleton is a given/when/then with concrete expected values that break if the behavior breaks — exact finding (target→message) sets, cache identity/non-identity assertions, the D-36 isolation regression, exact 4-spec ordered name arrays. C01's package-run arithmetic is correct (5 methods, runCount 4 with skip excluded, 1 each failure/error/skip/expectedDefect); C02's name-order inventory expectation is alphabetically correct. `Phi-Guardrails-Tests-SDK` really has 19 test methods, no `skip:`/`expectedFailures` (grep-verified), and its one non-test resident is a `PGRCheck` subclass the §5.2 filter excludes.

**Epic coverage:** ch. 5 fully mapped — §5.1→C05, §5.2→C02/C03, §5.3→C04(+C06 stanza registration), §5.4→C02/C05, §5.5→C01/C03/C04 (§5.5's R-44 end-to-end paragraph is E14's per the roadmap's R-44 placement — correctly not cut here). R-23/R-24(behavioral half)/R-25/R-37(both behavioral pairs) all traced. All four owed properties discharge by exactly the test names ch. 9 hardcodes (verified verbatim: P-GATE-SKIP both tests, P-SUITES-BEFORE-META, P-GATE-MISSING suite half in `PCKTestSuiteCheckTest`, P-STANZA-VALID). Exit checkpoint's named suite includes every chunk's tests. Baseline facts C01 asserts are true of the committed frozen baseline (fixtures group sole member; both packages under composite `Tests`; the D-57 regex genuinely non-matching the fixtures package).

## Findings

1. **MINOR** (checklist 1, arithmetic) — `C05-kit-behavioral-dispatch.md` VERIFY, line 167: "the 88 accepted E01/E02/E03/E06 tests **(7 of them in amended form)**" contradicts the same order's own enumeration of **8** amendments (and chunks.md's "8 in their C05-amended form"). Should read 8. The exhaustive table is the operative ground, so nothing downstream misacts.
2. **MINOR** (checklist 1, annotation) — `chunks.md` exit checkpoint line 88: "PCKKitTest at 18 (13 accepted E06 methods, **8 in their C05-amended form**, + 5 E07 methods)" undercounts the final amended state: C06 further amends two of the 13 (`testRecommendedBlockParsesAsKitBlock` is amended *only* by C06), so 9 distinct accepted methods end in amended form. The C06 row does say "with the 2 stanza pins amended", so the index is internally complete; only the checkpoint parenthetical is imprecise.
3. **ADVISORY** — C06 VERIFY contains "(see `chunks.md`)" pointing at the exit checkpoint; same pattern as every prior epic's closing chunk and orchestrator ground, not implementer context — noted, not acted on.
4. **ADVISORY** — the two §5.5 letter-bends (green-arm subject `Phi-Guardrails-Tests-SDK` in place of "the clean fixture class"; "scratch configuration" realized as baseline introspection) are handled via the recorded veto-open agent-call list, closing on the D-16 precedent at acceptance. Both are forced by frozen ground I verified independently: P-SDK-EDGE's letter covers *every* `Phi-Coding-Kit*` package (so a scratch `PGRConfiguration` in kit tests is illegal), and a clean-package subject would require editing the frozen E01 baseline. The mechanism matches four prior accepted cuts; the owner sees the list at Gate 4.

MINORs are a producer one-batch sweep, no re-validation required. Nothing was changed by this validation.

Key files: `/Users/mitt/dev/projects/phi-guardrails/plan/04-epics/E07-behavioral-kind/` (all seven papers), `/Users/mitt/dev/projects/phi-guardrails/plan/ledger.md`, validation script at `/private/tmp/claude-501/-Users-mitt-dev-projects-phi-guardrails/e17d7b62-ba9b-4294-9da6-8886bc3437ba/scratchpad/validate_e07.py`.
