# E08 · Fix command and capability — chunk index (M1)

*Produced by Prompt 4 (fifth run). Entry check: Gate 3 closed and roadmap frozen
(D-62); both E08 dependencies are `accepted` in `plan/ledger.md` with frozen
interface digests — E02 (2026-07-24, head `5f2fc60`, the full SDK surface tabled
in `plan/04-epics/E02-sdk-vocabulary/chunks.md`) and E06 (2026-07-25, head
`0c4fb7b`, the kit surface tabled in `plan/04-epics/E06-coding-kit-lint/chunks.md`).
Owner notes for this cut: D-66/D-67 stand — every COMMIT section cites
`bash tools/precheck.sh` as its precondition check; **D-73 — this is the first
epic-qualified cut**: IDs are `E08-C##`, counter local to this epic, in ledger
rows, commit messages, and cross-references; work-order filenames stay
`C##-<slug>.md`. E08 runs `[P]` beside E07 and E05 (frozen roadmap): this epic's
ground is `Phi-Coding-Kit-Rules` and `Phi-Coding-Kit-Tests-Rules`; E07 owns
`-Behavioral`/`-Fixtures` and `PCKKit` — and although `PCKKitTest` lives in
`-Tests-Rules`, it is **E07's file to extend** (the E06 agent call): no E08
manifest touches it, ever.*

| ID | Title | Depends | [P] | LOC est. | Acceptance (one line) |
|---|---|---|---|---|---|
| E08-C01 | Trait-aware lint environment (the D-72 amendment) | — | yes | ~80 | `PCKLintRuleCheck` runs through the widened, class-side single-sourced environment; the D-71 probe scenario (scratch trait + using class, run scoped to the using package) yields a red verdict naming the plant; the four existing `PCKLintRuleCheckTest` tests stay green |
| E08-C02 | `PCKFixCommand`: construction and error paths | — | yes | ~90 | `rule:packages:` signals `PGRNotAutofixable` on a flag-only rule; `apply` before preview signals `PGRFixNotPreviewed` (P-FIX-PREVIEW leg 1); `changes` empty pre-preview; `PCKFixCommandTest` (3) green |
| E08-C03 | `PCKFixCommand`: `previewOn:` and `changes` | E08-C01, E08-C02 | no | ~100 | preview runs the rule through the D-72 environment, emits target + old + new source per pending change, answers the count; `changes` answers the change objects; preview mutates nothing; `PCKFixCommandTest` +3 green |
| E08-C04 | `PCKFixCommand`: `apply` and the staleness guard | E08-C03 | no | ~115 | apply re-reads targets and signals `PGRFixStale` applying nothing on drift (D-34.2); otherwise `change execute` per pending change, applied objects answered; second apply signals; saved-source `setUp`/`tearDown` discipline; `PCKFixCommandTest` +3 green (P-FIX-PREVIEW legs 2–3) |
| E08-C05 | The fix capability pair on `PCKLintRuleCheck` | E08-C01, E08-C04 | no | ~75 | `canFix` true for any recipe-carrying rule (catalog rule **and** the cruft built-in — D-74), false for a recipe-less built-in; `fixCommandOn:` answers a bound, working command; `testProvidesAutofix` green (**P-CAT-AUTOFIX**); the scheduled `testKindIsLint` deny-line removal executed |

Total ~460 LOC across 5 chunks. **Placement annotation (D-61.a):** the frozen
roadmap's E08 row estimated ~4 chunks covering `PCKFixCommand` and the
capability pair (R-11 fix half · R-12 invocation half · R-15 autofix — all
placed here and only here); **E08-C01 is the fifth, owner-scheduled beyond the
roadmap row** — the D-72 amendment to E06's frozen surface, carried by this cut
through the decision-sheet path (D-72's consequence line names "the next
kit-side Prompt-4 cut"; this is it). It cites D-72/D-71 in TRACE and carries
the regression test on the D-71 probe scenario.

`[P]` semantics (the E02/E06 precedent): E08-C01 and E08-C02 have disjoint
manifests (C01: `PCKLintRuleCheck.class.st` + `PCKLintRuleCheckTest.class.st`;
C02: `PCKFixCommand.class.st` + `PCKFixCommandTest.class.st` — both new) —
worktree-parallel is structurally safe; under the D-67 discipline picks are
sequential with a clean tree between them, so `[P]` records independence, not
a scheduling requirement. C03–C05 are strictly serial (shared files, stacked
state).

## Agent calls recorded (veto-open, closing on the D-16 precedent at acceptance)

- **`PCKLintRuleCheck class>>lintEnvironmentOver:`** — the D-72 environment
  law single-sourced class-side on the check, consumed by the fix command
  (E08-C03) so check and fix share one attribution story; name and placement
  are this cut's call, the widening itself is ruled ground (D-72).
- **Second `apply` signals `PGRFixNotPreviewed`** — §3.3 says re-running
  `apply` is an error but names no class; one preview authorizes one apply
  (the preview is consumed), and the E02-frozen SDK roster is exactly three
  fix errors, so no fourth class may be minted. Recorded, not ruled.
- **`changes` answers an empty `Array` before any preview** — "the
  pending/applied change objects" read as empty-when-none; no error state for
  the pre-preview read.
- **`PCKFixCommandTest` home `Phi-Coding-Kit-Tests-Rules`** — beside the
  machinery it tests (the E06 `PCKKitTest` residency precedent).
- **Runtime scratch trait fixture** for E08-C01's regression test — built and
  removed inside the test with the D-71 probe's verified fluid spellings
  (`plan/probes/b03-lint-env-trait-probe.st`), names `PCKScratchCruftTrait` /
  `PCKScratchCruftUser` in packages `PCKScratchB03-*` (matching no swept
  pattern); no committed cross-package fixture, no baseline edit. Removal is
  `ensure:`-guarded; the work image is rebuilt per verify run, bounding any
  leak to one run.
- **Exact-count assertions in C03–C05's fix tests** are deliberate and
  package-local: the only `isNil ifTrue:` send in `-Tests-Rules` is the
  declared plant, and the count guards `apply`'s blast radius (a second plant
  must redden the suite, never be silently rewritten). This is not the
  verify-sweep count law, which stays membership + floor.
- **In-image ⟨verify⟩ items delegated to implementers** with record-in-report
  duty (P5): the widened-environment spelling (C01 — per D-72 explicitly the
  implementer's), scratch-removal spellings (C01), the `isRewriteRule` side
  (C02; C05 reuses the record), the change→current-source accessor chain,
  staleness comparison form, and fixture recompile spelling (C04).
- **The scheduled `testKindIsLint` amendment (C05)** — removing the
  `deny: check canFix` placeholder E06's own papers deferred to E08; the
  E06-frozen surface (constructor, `kind`, `rule`, verdict mapping) is
  untouched.

## Exit checkpoint (freezes E08's interfaces)

E08 is provable by, on one head commit:

1. **Named suite:** `PCKFixCommandTest` (9) · `PCKLintRuleCheckTest` (8 = the
   4 E06-accepted + C01's 1 + C05's 3) · `PCKNoIsNilIfTrueRuleTest` (3 = the
   2 E06-accepted + C05's 1) — all green under `bash tools/build-image.sh &&
   bash tools/verify.sh`, within a sweep of **≥102 run, 0 failures, 0 errors**
   (the 88 tests accepted at cut time + this epic's 14; accepted
   parallel-track (E05/E07) suites add to the count — membership plus that
   floor, never an exact ceiling).
   `PCKFixCommandTest>>#testApplyWithoutPreviewSignals` +
   `>>#testPreviewThenApplyRewrites` + `>>#testStaleApplySignals` are
   **P-FIX-PREVIEW**; `PCKNoIsNilIfTrueRuleTest>>#testProvidesAutofix` is
   **P-CAT-AUTOFIX** — the two properties this epic owes.
   `PCKLintRuleCheckTest>>#testTraitProvidedMethodLintedAtUsingClassPackage`
   is the **D-72 amendment's witness** (the D-71 escape closed).
2. **CI leg:** the committed `.github/workflows/ci.yml` (step 1) green on an
   actual CI run of the same commit — the new tests ride the existing
   smalltalkCI sweep.

**Frozen at acceptance (E08's interface digest — later epics build on these;
amendments need a decision-sheet entry):**

- **The coding kit's fix-invocation implementation** (the generic protocol
  shape is E02's): `PCKFixCommand` class-side `rule:packages:` (signals
  `PGRNotAutofixable` unless the rule class answers `isRewriteRule` true);
  instance `previewOn:` (emits target/old/new per pending change, answers the
  pending count, mandatory first step), `apply` (staleness re-read against
  `oldVersionTextToDisplay`, `PGRFixStale` + apply-nothing on drift,
  `change execute` otherwise, answers applied changes; second apply signals
  `PGRFixNotPreviewed`), `changes` (pending/applied change objects; empty
  `Array` pre-preview). One instance, one invocation.
- **The capability pair on `PCKLintRuleCheck`:** `canFix` ⇔ the wrapped rule
  is a rewrite rule; `fixCommandOn: packages` → a `PCKFixCommand` bound to the
  wrapped rule and the handed target.
- **The D-72 environment law as implemented:** `PCKLintRuleCheck`'s lint run
  covers, per target package, every class defined there including its
  trait-provided methods (single-sourced in the class-side helper the fix
  command shares). This realizes the E06-digest amendment authorized by
  D-72/Q-32 — recorded here as the decision-sheet-path amendment, never a
  silent edit.

Checkpoint result (filled at acceptance): —

E08 `accepted` when all five rows are `accepted` in `plan/ledger.md` and the
checkpoint above is filled in — at which point E08's interface digest freezes
and E09's entry check (E05 + E07 + E08) can count this epic satisfied.

## Addendum — post-PASS punch list (swept 2026-07-25; one batch, no re-validation per the validation rules)

The Gate-4 validator passed this cut (report: `plan/validation/04-E08-report.md`,
one round) with two MINORs, both applied the same day:

1. **C01 contract clause (i) scoped to defined-class methods**, with the B-05
   pointer inlined — extension methods a package defines on classes elsewhere
   are outside the widening's contract either way (deferred ground; `src/`
   currently carries none).
2. **C02/C03 ivar handoff aligned:** C02 now explicitly lands `pendingChanges`
   (initialized empty, read by `changes`); the previewed/applied flags are
   named as C03/C04's to add — the two papers' state descriptions agree.

The validator's two ADVISORYs (the mid-run E07 ledger race observation; the
"still-bad" clause in C04's stale test) are recorded in the report, not acted
on, per the severity rules.

## Addendum 2 — the D-74 amendment (2026-07-25, owner-ruled)

E08-C02's execution probed the cut's "flag-only counterparty" premise false:
`ReCodeCruftLeftInMethodsRule` **is** mechanically a `ReNodeRewriteRule` (its
recipe deletes the matched statement). Q-33 (filed by the orchestrator, commit
`44dee8a`) was ruled **D-74**: no flag-only category exists — `canFix` is the
mechanical fact alone; per-application judgment lives at the mandatory preview
(guidance: appliers run the suite after apply; deletion diffs warrant reading
the surrounding method). E08-C05's work order is amended under that ruling:
the cruft check answers `canFix` true; the false-arm subject is the
recipe-less `ReEmptyExceptionHandlerRule`
(`testCanFixFalseForRecipelessRule`); TRACE cites D-74. C02–C04 stand
untouched; the frozen-digest line "`canFix` ⇔ the wrapped rule is a rewrite
rule" was already the mechanical reading and stands verbatim. §3.2b's
erratum rides the owner's next spec pass.
