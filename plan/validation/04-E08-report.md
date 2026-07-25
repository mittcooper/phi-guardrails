## Validation report — E08 (fix command and capability), fifth Prompt-4 cut

**VERDICT: PASS** — zero BLOCKING findings. Two MINORs and two ADVISORYs ride as the punch list.

### Scripted sweep results (absolute paths, scanned-file count asserted)

Script run over `/Users/mitt/dev/projects/phi-guardrails/plan/04-epics/E08-fix-command/` — asserted 5 work orders scanned (nonzero) before any clean claim. Output:

- **Depends-on existence:** all edges resolve within the cut — C03←{C01,C02}, C04←C03, C05←{C01,C04}. Work-order headers, index table, and ledger rows agree three ways.
- **[P] disjointness:** E08-C01 manifest (`PCKLintRuleCheck.class.st` + `PCKLintRuleCheckTest.class.st`) ∩ E08-C02 manifest (`PCKFixCommand.class.st` + `PCKFixCommandTest.class.st`) = ∅. Only the two `[P]` rows exist; C03–C05 are declared serial and do share files, correctly.
- **LOC:** 80+90+100+115+75 = 460 = the index's "~460"; every ceiling ≤300-per-chunk band (max 250). The fifth chunk beyond the roadmap's ~4 estimate is properly placement-annotated as the owner-scheduled D-72 amendment (D-61.a satisfied; D-72's consequence line names "the next kit-side Prompt-4 cut" and this is it).
- **Verify commands:** all five present in work orders and mirrored one-to-one in `plan/ledger.md` (E08-C01…E08-C05, no extras, no gaps).
- **Count arithmetic:** 1+3+3+3+(3+1) = 14; floors 89/91/95/98/102 = 88 cut-time accepted (E03 checkpoint's 88/88) + cumulative deltas; checkpoint suite math (9+8+3, 8 = 4+1+3, 3 = 2+1) all reconcile, and every count is membership + floor (the E06 punch-list law), never a ceiling.

### Verbatim-quote and ground checks (against committed src and record)

- C01's quoted `run` body matches `src/Phi-Coding-Kit-Rules/PCKLintRuleCheck.class.st` byte-for-byte; the four existing `PCKLintRuleCheckTest` names match; `testKindIsLint` really ends `self deny: check canFix` with the deferral comment C05 quotes — the scheduled amendment is real scheduled ground (E06 C15 line 53: "the capability pair on the catalog rule is E08's, not yours").
- C03/C04's plant quote matches `PCKLintBadFixture>>withIsNilIfTrue`; C05's `runRuleCritiques` helper and `entity ==` selection exist as described in `PCKNoIsNilIfTrueRuleTest`.
- C03's exact-count safety claim verified by grep: the plant is the only `isNil ifTrue:` **send** in `Phi-Coding-Kit-Tests-Rules` (the two stub-rule hits are pattern-string literals, as the order states); the epic's own new tests add only literals.
- C01's scratch spellings match `plan/probes/b03-lint-env-trait-probe.st` exactly; the D-71 raw output quote matches the decision log; scratch package names match neither the verify regex nor `.smalltalk.ston`'s patterns (checked both).
- D-72/D-71/D-73 read in full: the cut implements option (a) as ruled, routes the E06 frozen-surface amendment through the decision-sheet path, and uses epic-qualified IDs everywhere required.
- Frozen-digest conformance: every E02 surface used (verdict/finding readers, the three fix errors — no fourth minted, `canFix`/`fixCommandOn:` rows, `subclassResponsibility` marker per D-68) and every E06 surface used (`rule:packages:`, `rule` reader, D-03 mapping) is inlined in the consuming digest; no chunk uses an interface before the chunk introducing it (the `lintEnvironmentOver:`/preview-state handoffs follow the dependency edges). Tests are all real given/when/then — C01's would fail today on the D-71 evidence (0 critiques → green), the fix tests fail without the state machine.
- Epic coverage: §3.3 → C02/C03/C04, §1.3 capability rows → C05; R-11/R-12/R-15 halves all annotated; P-FIX-PREVIEW's three ch.-9-named tests and P-CAT-AUTOFIX's land verbatim; the exit checkpoint includes every chunk's tests plus the CI leg.
- Cross-track: no E08 manifest touches `PCKKitTest`; swept all E07 manifests — fully disjoint from E08's five files.

### Findings (punch list — no re-validation needed)

1. **[item 2 · MINOR]** C01's behavioral contract clauses (i) and (iii) latently contradict over extension methods: `RBPackageEnvironment` also covers methods a target package defines on classes elsewhere, which both candidate compositions (built from `definedClasses`) exclude — so "(i) every method the old package environment covered stays covered" overclaims, and the four-test regression guard cannot detect the drop. Currently vacuous (zero `*.extension.st` under `src/` — verified) and extension-method attribution is B-05, deferred on record. Reword (i) to "every defined-class method…" or add the B-05 pointer. — `plan/04-epics/E08-fix-command/C01-trait-lint-environment.md` (behavioral-contract paragraph).
2. **[item 2 · MINOR]** C02 says "lay down only what this chunk uses" yet its ivar list names `pendingChanges`, while C03's start-state asserts C02 landed it; a minimal-reading C02 implementer (e.g. `changes ^ Array new`) makes C03's "what exists" wrong by one ivar. Harmless (C03 owns the file next) but the two papers should agree — either drop `pendingChanges` from C02's list or drop the "only what this chunk uses" qualifier. — `C02-fix-command-errors.md` state-machine paragraph vs `C03-fix-preview.md` context digest.
3. **[item 1 · ADVISORY]** Mid-validation, the concurrent E07 cut landed its papers and ledger rows (the ledger changed between my first read and a later grep). The ledger's E08 block's "(E04, E07 — papers on disk)" was forward-dated when written but is now true; all E08 mechanical checks were re-verified against the current file. Recorded for the orchestrator as a race observation, not acted on.
4. **[item 3 · ADVISORY]** C04's `testStaleApplySignals` specifies a "*still-bad*" replacement body without saying why still-badness matters (staleness triggers on any drift). If it is deliberate (keeping the mutated state also rule-visible), one clause would show the constraint; as written an implementer may treat it as arbitrary. Style only.

**No BLOCKING findings.** The next stage may proceed on this cut as ground; MINORs 1–2 sweep in one producer batch without re-validation. I changed nothing.
