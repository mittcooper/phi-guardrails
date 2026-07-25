# E03 validation report — VERDICT: **PASS** (0 BLOCKING, 2 MINOR, 2 ADVISORY)

Validated the fourth Prompt-4 cut of E03 (C20–C27) against the frozen roadmap row, the ledger, the constitution, spec ch. 1 §1.1–§1.2 + ch. 9, and E02's frozen interface digest.

## Scripted sweeps (checklist item 1 — all run on absolute paths)

**Sweep 1** (`validate_e03.py`, scratchpad): `scanned files: 12 — MECHANICAL SWEEP CLEAN`
**Sweep 2** (acceptance-count cross-check): `scanned files: 9 — ACCEPTANCE-COUNT SWEEP CLEAN`

What they asserted and found clean:
- **Depends-on:** all 8 work orders exist; headers form the exact linear chain C20→…→C27; ledger `Depends-on` column matches one-to-one (C24's "(Q-31 recommendation)" annotation noted).
- **[P]:** every header says `parallel: no`, matching chunks.md's declared no-[P] structure (C21–C27 share one class-file pair; disjointness precondition structurally absent — correctly reasoned).
- **LOC:** targets 90+140+50+100+130+140+70+110 = **830** = chunks.md's stated total; index-table estimates equal work-order targets; all targets in the 50–150 band (C22 at floor, disclosed with the E02 C05/C06 precedent), all ceilings ≤ 240 < 300.
- **Verify commands:** every order carries `bash tools/build-image.sh && bash tools/verify.sh` plus a D-67 COMMIT section; ledger has a verify row per chunk. `tools/verify.sh` asserts run count dynamically (≥5), so parallel-track E06 landings can't break these commands.
- **Test arithmetic:** skeleton counts 7/7/3/5/6/6/3/5; no name reused across C21–C27 (one shared test class); cumulative counts in the ledger rows (7→10→15→21→27→30→35) exactly match; exit checkpoint's 42 = 7+35 and 66 = 42+19+5 both check out.
- **Properties:** all five ch.-9-named tests exist verbatim in the right chunks (P-CFG-STRICT/C21, P-SCHEMA-REFUSAL×2/C22, P-SCOPE-TOTAL×3/C25, P-ROLE-MISFILE/C26, P-ROLES-FROM-CONFIG split C24/C25); the duplicate-name arm's E04 discharge matches the frozen roadmap's E04 row and is recorded, not drifted. R-02/R-05/R-24/R-47 all appear in TRACE lines.

## Judgment checks (items 2–4)

**Self-containment** — sampled C21, C24, C25 (most complex), C27, plus C20: every signature used is inlined (E02 kit protocol reproduced in full in C20; `PGRConfigurationError`, STON spellings, `validArtifactString`, fixture trees restated verbatim in each successor digest); all `chunks.md §probes/§agent-calls` mentions are provenance citations with the content inlined; no interface used before its introducing chunk. I verified quoted ground against sources: `PGRKit`'s class comment carries the "duck-typed plain class… registers fine" sentence verbatim (`src/Phi-Guardrails-SDK/PGRKit.class.st`); `Phi-Guardrails-Tests-Core` holds `PGRBaselineSmokeTest` and `Phi-Guardrails-Core` is an empty stub, as C20/C21 claim; D-15's `matchesRegex:` full-match and D-25.a's `packagesForSpecNamed:` spellings are in the decision log; Q-31 exists in `plan/04-decision-sheet.md` with recommendation (a), which C24 follows and the ledger flags veto-open.

**Tests are real** — every one of the 42 skeletons asserts behavior (exact sets, error class + named offender in message, reader values); I traced each green-path artifact through all eight pipeline stages: `validArtifactString` and every C24 green case remain total, disjoint, and loadedness-clean under C25–C27's tightening — the "no green test turns red later" claim holds arithmetically.

**Coverage** — every §1.1 strict-list arm maps to a chunk (envelope/C21, version/C22, resolution/C23, matchers/C24, disjoint+total+loaded/C25, exempt-patterns/C26, src-anchor+fromFile/C27); duplicate-name → E04 (ruled by the frozen roadmap); ambiguity arm → Q-31 (probe-backed, decision-sheeted, never silent). The C23 conformance-not-ancestry reading is soundly grounded (D-53 + `PGRKit` comment + E04's duck-typed tests; constitution: decision log wins) and disclosed veto-open. Exit checkpoint includes both suites — all 42 tests.

## MINOR punch list (no re-validation needed)

1. **C21 · missing test arm:** §1.1's first strict arm is "top level is not a map **with Symbol keys**"; C21 tests only the non-map case (`testNonMapTopLevelSignals`). A String-keyed map (`{ 'schemaVersion' : 2, … }`) is constructible STON and only indirectly caught via the missing-core-key/unknown-key arms — worth one explicit case or a digest note. (P-CFG-STRICT's named cases don't require it, so not blocking.)
2. **C27 · VERIFY wording:** states "66 run" flatly; chunks.md's checkpoint and the ledger's C27 row both carry the "plus accepted parallel-track E06 suites" caveat, the work order doesn't — an implementer running after E06 landings would see >66 and could misread it.

## ADVISORY (recorded, not acted on)

1. §1.1's "group-named matcher names an absent group" error arm is realized as C24's membership pre-check plus D-47's consequence-catching (scope law fires), not a distinct parse-time error — the arm is vacuous under the spec's own resolution order, D-47's ratification text states the indirect-coverage mechanism verbatim, and ch. 9's P-SCOPE-TOTAL letter (signals `PGRConfigurationError`) is satisfied. Fully disclosed; consistent.
2. The C19 numbering gap and the concurrent-run near-miss are cleanly disclosed in both chunks.md and the ledger; stable-ID convention honored.

**Pass — zero blocking findings.** MINORs ride as the producer's one-batch sweep. Scripts at `/private/tmp/claude-501/-Users-mitt-dev-projects-phi-guardrails/95b0e482-7a1c-49cf-8b04-2949dcc28be9/scratchpad/validate_e03.py`; nothing in the repo was changed.

---

*Producer's note (appended after the verbatim report, per the MINOR-sweep protocol —
one batch, no re-validation): both MINORs swept 2026-07-25 — (1) C21's
`testNonMapTopLevelSignals` skeleton gained the String-keyed-map arm; (2) C27's
VERIFY line gained the parallel-track count caveat. Validation round count: 1
(pass on the first round).*
