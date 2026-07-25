# E06 · Coding kit and the lint kind — chunk index (M1)

*Produced by Prompt 4 (third run). Entry check: Gate 3 closed and roadmap frozen
(D-62); E06's only dependency E02 is `accepted` in `plan/ledger.md` (2026-07-24)
with its interface digest frozen at head `5f2fc60` (the full SDK surface tabled in
`plan/04-epics/E02-sdk-vocabulary/chunks.md`). Owner notes for this cut: D-66/D-67
delivered — every COMMIT section cites `bash tools/precheck.sh` as its
precondition check. E06 runs `[P]` beside E03/E04/E05 (kit packages vs framework
packages — disjoint; baseline pre-stubbed in E01).*

| ID | Title | Depends | [P] | LOC est. | Acceptance (one line) |
|---|---|---|---|---|---|
| C12 | B-03 probe: lint-environment trait attribution | — | yes | ~30 (script; no product code) | probe runs headless exit 0 with both observations printed; outcome recorded as a decision-log entry (D-70 expected); decision-sheet entry appended iff a hole is confirmed |
| C13 | `PCKNoIsNilIfTrueRule` with fixture pair | — | yes | ~110 | the canonical §2.2 rule lands; `PCKNoIsNilIfTrueRuleTest` (2) green — fires on the named plant, silent on the good twin (P-CAT-FIXTURES, lint) |
| C14 | Built-in cruft rule pinned: match set + severity | — | yes | ~100 | `PCKCodeCruftBuiltInTest` (3) green — one asserted critique per claimed form (D-55.4), good-fixture silence, `severity == #error` pin (P-BUILTIN-PINNED) |
| C15 | `PCKLintRuleCheck` | C13 | no | ~140 | `rule:packages:` constructor, kind `#lint`, D-03 verdict mapping (red findings / green advisories / green); `PCKLintRuleCheckTest` (4) green |
| C16 | `PCKKit`: block envelope + lint dispatch (D-41) | C15 | no | ~150 | five schema keys recognized, unknown key errors; `#lintRules` pipeline complete (missing spec · non-rule error · D-41 severity error · `PCKLintRuleCheck` construction); `PCKKitTest` (5) green incl. **P-SEVERITY-EXPLICIT** |
| C17 | `PCKKit`: generic paths for the remaining keys | C16 | no | ~120 | `#architectureChecks`/`#metaRules` resolve via the promised `packages:` constructor with role-by-block-key, missing-specs for unresolved names, `#layerMap` carried unread, order lint → architecture → meta; `PCKKitTest` +6 green |
| C18 | `recommendedBlock`: the published stanza (M1-partial) | C17 | no | ~60 | stanza parses as a kit block naming exactly the two catalog rules, and registers cleanly through the kit's own dispatch; `PCKKitTest` +2 green |

Total ~680 product-adjacent LOC across 7 chunks (C12's ~30 script lines sit
outside the product budget — probe chunk, the E01 C01/C04 precedent); roadmap
estimate ~7 chunks — holds. All manifests of the three `[P]` chunks are disjoint
(C12: `plan/` only; C13/C14: disjoint class files in two kit packages; no
`package.st` or baseline edit anywhere in the epic). Under the D-67 discipline
picks are sequential with a clean tree between them; `[P]` records structural
independence (worktree-parallel is safe), not a scheduling requirement.

## Agent calls recorded (veto-open, closing on the D-16 precedent at acceptance)

- **`PCKKitTest` home = `Phi-Coding-Kit-Tests-Rules`.** The frozen E01 naming
  tree has no root kit tests package and creating one would edit the frozen
  baseline (decision-sheet-only); ch. 9 names `PCKKitTest` without a home;
  `-Tests-Rules` is where the kit's E06 (lint-kind) behavior is exercised. E07
  extends the class in place.
- **`PCKLintRuleCheck class>>rule:packages:`** constructor spelling — mirrors
  ch. 3 §3.3's `PCKFixCommand rule:packages:`; one target language.
- **Stub fixture names** `PCKWarningSeverityStubRule` ·
  `PCKInheritedSeverityStubRule` · `PCKArchStubCheck` · `PCKMetaStubCheck` —
  `-Tests-Rules` residents beside their tests (ch. 9 §9.3's
  fixtures-without-red-tests rule; none is a `TestCase`).
- **Class-by-name lookup** `Smalltalk globals at: name asSymbol ifAbsent:` — a
  read (the constitution bans only `at:put:` writes); confirmed in-image per P5
  before first use (C16).
- **The E06 stanza omits `#metaRules` deliberately** — the roadmap's E07 row
  owns "stanza completion (meta-rule line) + P-STANZA-VALID"; the later edit is
  scheduled ground, not a frozen-surface amendment.
- **In-image ⟨verify⟩ items delegated to implementers** with record-in-report
  duty (P5): the critique→critiqued-method accessor (C13/C14/C15), the
  multi-package `RBPackageEnvironment` constructor (C15), the `CompiledMethod`
  precise print form (C15), the class-lookup spelling (C16).
- **C12's D-number is "next free at commit time"** (D-70 expected) — E03/E04/E05
  may run `[P]` beside this epic and append decisions; the number is claimed at
  the probe chunk's commit, never reserved here.

## Exit checkpoint (freezes E06's interfaces)

E06 is provable by, on one head commit:

1. **Named suite:** the four `Phi-Coding-Kit-Tests-Rules` test classes —
   `PCKNoIsNilIfTrueRuleTest` (2) · `PCKCodeCruftBuiltInTest` (3) ·
   `PCKLintRuleCheckTest` (4) · `PCKKitTest` (13) — 22 kit tests green under
   `bash tools/build-image.sh && bash tools/verify.sh`, with the 24 accepted
   E01/E02 tests still green (≥46 run, 0 failures, 0 errors — exactly 46 when
   no parallel-track (E03) suite has landed yet; accepted E03 suites add to the
   count, and the assertion is named-suite membership plus that floor, never an
   exact ceiling).
   `PCKKitTest>>#testRuleWithoutOwnSeveritySignals` is **P-SEVERITY-EXPLICIT**;
   `PCKCodeCruftBuiltInTest>>#testSeverityStillBlocks` is **P-BUILTIN-PINNED**;
   the four fixture-pair tests (C13's 2, C14's first 2) are **P-CAT-FIXTURES
   (lint)** — the three properties this epic owes.
2. **Probe leg:** the B-03 outcome recorded as a decision-log entry (D-70
   expected), the probe script committed with its results header; the
   decision-sheet entry exists iff the entry says a hole was confirmed.
3. **CI leg:** the committed `.github/workflows/ci.yml` (step 1) green on an
   actual CI run of the same commit — the new kit tests ride the existing
   smalltalkCI sweep.

**Frozen at acceptance (E06's interface digest — later epics build on these;
amendments need a decision-sheet entry):**

- **The coding kit's block schema:** keys exactly `#kit` · `#lintRules` ·
  `#architectureChecks` · `#layerMap` · `#metaRules`; an unknown key inside the
  block is a `PGRConfigurationError` the kit raises; role-by-block-key —
  `#lintRules`/`#architectureChecks` hand the production-role list, `#metaRules`
  the tests-role list.
- **Registration naming and order:** `lint/<Class>` · `architecture/<Class>` ·
  `behavioral/<Class>`; answered order lint → architecture → (behavioral
  suites, E07) → meta-rules.
- **`PCKKit`** (class name D-56; package `Phi-Coding-Kit`) implementing the
  frozen two-message kit contract; `recommendedBlock` in its M1-partial
  two-rule form (completed at E07 by roadmap schedule).
- **`PCKLintRuleCheck`** — class-side `rule:packages:`; instance `kind` `#lint`,
  internal reader `rule`; the D-03 verdict mapping (`#error` critiques → red
  findings; sub-`#error` → green advisories; none → green).
- **The two catalog registrations:** `lint/PCKNoIsNilIfTrueRule` (severity
  `#error`, D-20) and `lint/ReCodeCruftLeftInMethodsRule` (shipped `#error`,
  pinned by test, D-34) — with their fixture classes' names.
- **The D-41 enforcement point:** the kit's block-opening pass — a `#lintRules`
  entry naming a rule class without its own class-side `severity` is a
  configuration error raised by the kit.

Checkpoint result (filled at acceptance): **2026-07-25, all three legs green on head
`0c4fb7b`** (orchestrator-run at epic acceptance) · leg 1: `tools/build-image.sh &&
tools/verify.sh` exit 0 — `74 run, 74 passes, 0 failures, 0 errors.` with all 22 kit
tests listed by name (`PCKNoIsNilIfTrueRuleTest` 2 · `PCKCodeCruftBuiltInTest` 3 ·
`PCKLintRuleCheckTest` 4 · `PCKKitTest` 13) plus the 24 E01/E02 tests and the accepted
E03 suites (≥46 floor met at 74); P-SEVERITY-EXPLICIT, P-BUILTIN-PINNED, and
P-CAT-FIXTURES (lint) all discharged by their named tests · leg 2: B-03 recorded as
**D-71** (not D-70 — taken; owner notice of 2026-07-25 superseded the "D-70 expected"
phrasing), probe script committed with results header, and decision-sheet **Q-32**
exists (the escape was confirmed) · leg 3: CI run 30155928234 on `0c4fb7b` —
`completed success`.

## Addendum — post-PASS punch list (swept 2026-07-25; one batch, no re-validation per the validation rules)

The Gate-4 validator passed this cut (report:
`plan/validation/04-E06-report.md`) with two MINORs, both applied the same day:

1. **Cross-track count contingency:** every count assertion (exit-checkpoint
   leg 1, all seven VERIFY sections, the ledger's C12–C18 verify lines) now
   asserts **named-suite membership plus a floor**, never an exact ceiling —
   E06 runs `[P]` beside E03 (C20–C27), whose accepted suites join the same
   verify sweep, so "exactly 46" holds only while no E03 suite has landed.
2. **C12's regression guard** reworded sibling-aware: run count unchanged from
   the pick-time accepted set, rather than the literal "24/24".

The validator's mid-run incident note (the transient E03/E06 chunk-ID
collision, resolved by the E03 run renumbering to C20–C27 with C19 a
documented gap) is recorded in the report; E06's papers needed no change.
