# Gate-4 validation — E14 (the demonstration test)

*Two rounds. Round 1 (fresh validator subagent, byte-exact assembled prompt):
REJECT — 2 BLOCKING (one root cause: the plant-marker table collided with the
plants' own comments, which the fix command preserves), 3 MINOR, 1 ADVISORY.
Producer remediation: body-distinguishing markers for all six plants, C02
digest/skeleton corrected, remediation probe P8 run live and appended to
`probes.md`, owner-brief citations anchored to committed loci, "see" pointers
dropped. Round 2 (fresh validator subagent, same byte-exact prompt, never the
round-1 agent): PASS — zero BLOCKING, zero MINOR, 3 advisories. Both reports
verbatim below.*

---

## Round 1 — REJECT (validator report, verbatim)

# E14 cut validation — REJECT (2 BLOCKING)

Validator run 2026-07-28, HEAD `1f7c80f`, work image `/Users/mitt/dev/projects/phi-guardrails/.build/work/phi.image` (src byte-identical to `3333062` — script-verified).

## Verdict: **REJECT** — two BLOCKING findings, both from one root cause (the plant-marker table collides with the plants' own comments), plus three MINORs and one ADVISORY.

## Findings

**F1 · BLOCKING** — checklist 3 (tests are real / D-82-Q-39 probe obligation): **C02's skeleton step 4 is probed-false — the assertion as written fails.**
- Evidence: the committed `ToyOrder>>#totalOrZero` (`/Users/mitt/dev/projects/phi-guardrails/src/Toy-Core/ToyOrder.class.st` lines 58–63) carries the marker text **inside its comment** ("the \`isNil ifTrue:\`"). The fix command preserves the comment — the producer's **own P4 transcript** (`probes.md` line 76) shows the post-apply source still containing "the \`isNil ifTrue:\`". My live probe V5: `post-apply source contains marker 'isNil ifTrue:': true` → **C02-step-4 deny would: FAIL**. The digest sentence "(comment preserved, marker `'isNil ifTrue:'` gone)" (`C02-autofix-arm-restoration.md` lines 50–52) is self-contradictory with the P4 transcript quoted in the same cut — this exact assertion was never probed; the probe that exists contradicts it.
- Location: `/Users/mitt/dev/projects/phi-guardrails/plan/04-epics/E14-demonstration-test/C02-autofix-arm-restoration.md` — test skeleton step 4 (lines 119–120) and digest lines 50–52.
- Consequence: the implementer builds the ruled test, watches it fail for a non-behavioral reason, and must deviate mid-chunk — the next stage builds on wrong ground.

**F2 · BLOCKING** — checklist 2/6 (ruled ground D-43 item 2 contradicted): **the `setUp` guard as specified is blind to a leaked fix-arm mutation of plant #1.** The guard marker `'isNil ifTrue:'` (C01 table row 1, line 65) survives the fix inside the preserved comment (probe V5: `guard-marker still present post-fix: true`), so a failed restoration in exactly the autofix arm — the leak D-43 exists to catch — passes the guard silently. The stated rationale ("source shape is exactly the leak surface, and a failure names the leaked method directly" — C01 lines 81–88; `chunks.md` agent call 2) is false for this plant/path pair; a leak surfaces later as test 1's confusing count mismatch, precisely the failure mode D-43 item 2 rules out.
- Location: `/Users/mitt/dev/projects/phi-guardrails/plan/04-epics/E14-demonstration-test/C01-demo-scaffold-exact-six-red.md` (marker table + guard paragraph), `chunks.md` agent-judged call 2.
- Note: one sweep fixes both F1 and F2 — a body-distinguishing marker for plant 1 (e.g. `'items isNil ifTrue:'`, which I verified appears only in the planted body, not the comment or the fixed form).

**F3 · MINOR** — checklist 3: plant 5's marker spelling `'equals: 42'` carries no cut-time probe (the E12 digest row cited says only "(failing)"; no probes.md transcript names it). I verified it true live (probe V2, all six markers present) — annotation gap, nothing downstream acts wrongly.

**F4 · MINOR** — checklist 6: three citations of "the owner's E14 brief / carve-out" (`chunks.md` line 13, `probes.md` line 13, C01 line 124) point at an owner communication with no committed locus. Not producer-invented — every claim it backs carries a committed co-citation that independently supports it (§8.3's exact-count law, verified verbatim; the roadmap risk row) — but the uncommitted citation should be replaced or anchored.

**F5 · MINOR** — checklist 2: C03's VERIFY says "(see `chunks.md`)" (line 126); C01 line 125 similarly points at `chunks.md`. Both are non-load-bearing annotations (nothing an implementer needs), but the self-containment letter says no "see" pointers.

**A1 · ADVISORY** — the fix-under-nesting composition (C02 digest, `chunks.md` call 3) breaches §3.3's letter ("do not run a fix from inside a gate run" — verified verbatim at `plan/02-spec/03-rule-catalog.md` lines 126–127) under the self-hosted leg. The producer's compatibility argument is accurate on every cited fact and is correctly recorded veto-open per the D-16 precedent — flagged for the owner's eye, as the cut itself requests.

## Everything else — clean

- **Mechanical (scripted, 131 files scanned, nonzero asserted):** all `depends-on` chunks exist and match ledger (C01→C02→C03, statuses `todo`); no `[P]` chunks (disjointness vacuous — declared, with the shared-file reason stated); LOC 120+80+110 = 310 matches the claimed sum, all chunks within 50–150/300; every chunk carries both verify legs; ledger rows and per-chunk verify lines one-to-one with work orders. **MECHANICAL SWEEP CLEAN.**
- **Amended surface (scripted):** every manifest is exactly the one NEW file `src/Phi-Guardrails-Tests-Toy/ToyDemoTest.class.st` — not among the 125 git-tracked src files; zero accepted files in any manifest. The "Amended accepted surface: none" claim holds.
- **Frozen-digest conformance:** every inlined surface checked verbatim against E02/E05/E08/E12 digests (incl. `advisories`, `PCKFixCommand rule:packages:`/`previewOn:`/`apply`, the six-registration order, the plant inventory). All match.
- **Probe spot-checks (well beyond the required 3, all reproduced live):** P1/P2 (6 verdicts, frozen order, all red, per-plant targets) · P3 incl. the ensure-under-signal arm (post-unwind byte-identical restore: true) · P4 (preview 1 → apply 1 → fixed registration green, 5 blocking) · P5 (six fixed sources → `isClean` true, exit 0, exactly the one `architecture/PCKLayerMapCheck` advisory → all six restored byte-identical → 6 blocking again) · P6 (12 framework registrations incl. `behavioral/Phi-Guardrails-Tests-Toy`, exact list match).
- **Epic coverage:** §8.3's three ruled tests map one-to-one onto the three chunks; R-32/R-43/R-44 demo halves and P-GATE-RED all land; the exit checkpoint's ≥266 sweep names all three chunk tests; D-43's two protections split C01/C02 coherently.
- **Intent attribution (scripted sweep, 5 files, 15 normative hits):** every normative rationale traced to committed ground I spot-verified verbatim (§3.3 caution, D-43 both items, D-46 termination argument, D-80, D-82 carry-forwards 1–3, §8.1 residual caveat, §8.3 exact-count law, E07 cache law, E08 "one instance, one invocation") — except the F4 owner-brief anchoring above. The four agent-judged calls are all correctly channeled veto-open.

Scripts: `/private/tmp/claude-501/-Users-mitt-dev-projects-phi-guardrails/34a49cb8-c1a9-4051-848c-85c7fc8f51a2/scratchpad/` (`mech_check.py`, `probe1.st`–`probe5.st`); all probes ran headless without saving the image.

The cut is one small sweep from PASS: re-spell plant 1's marker to a body-only string, correct C02's digest sentence and step 4 accordingly, re-probe that one assertion, and anchor or drop the owner-brief citations. I changed nothing.

---

## Round 2 — PASS (fresh validator subagent, report verbatim)

# E14 cut validation — round 2 — VERDICT: **PASS** (zero BLOCKING, zero MINOR; 3 advisories)

Validated: `/Users/mitt/dev/projects/phi-guardrails/plan/04-epics/E14-demonstration-test/` (C01, C02, C03, `chunks.md`, `probes.md`) against `plan/03-roadmap.md` (E14 row + E12/E11/E08 deps), `plan/ledger.md`, `plan/00-constitution.md`, spec ch. 8 §8.3 / ch. 9 P-GATE-RED, decision log (D-06, D-26, D-42, D-43, D-45/D-46, D-57, D-80, D-82/Q-39), and the frozen digests of E02, E03, E05, E08, E11, E12.

## Checklist results

**1 · Mechanical (scripted — `mech_check.py`, output below): CLEAN.** Dependency chain C01→C02→C03 closed and matches ledger and index one-to-one; no `[P]` chunks (disjointness vacuous — correctly so, all three share the single manifest file and are declared strictly serial); LOC targets 120+80+110 = 310, matching the stated "Sum ≈ 310" and inside the roadmap's ~3-chunk band; every chunk carries both verify legs (sweep + self-hosted gate); ledger rows E14-C01..C03 and their verify-command entries match the work orders exactly, including the dep column. **130 files scanned (nonzero asserted).**

**2 · Self-containment (all three chunks reviewed — C01 the most complex): CLEAN.** Every frozen-surface signature used is inlined verbatim and matches its origin digest — `PGRConfiguration fromString:` (E03), `PGRGate forConfiguration:`/`run`, `PGRReport verdicts/isClean/exitCode/blockingVerdicts/advisories` (E05, checked at `plan/04-epics/E05-gate-report-invocation/chunks.md:154-171`), `PGRVerdict`/`PGRFinding` readers (E02), `PCKFixCommand rule:packages:/previewOn:/apply` (E08), `BaselineOfToy guardrailsSTON` + six-registration shape + plant inventory (E12). Zero "see"-references in any work order (scripted grep: no hits). No interface used before its introducing chunk: `restoringSourcesOf:during:` is introduced in C02 and consumed in C03; C02/C03 restate C01's helpers verbatim.

**3 · Tests are real + probe evidence: CLEAN.** All three skeletons are given/when/then with assertions that fail if behavior breaks (exact-6 count, order, per-verdict targets; preview=1/apply=1/green+5-blocking; isClean/exit-0/one-advisory; byte-identical restoration). Every frozen-surface/reflective assertion carries a P1–P8 citation. **I re-ran five probe groups live myself against `.build/work/phi.image`** (confirmed src-current: `git diff --stat 3333062 1f7c80f -- src/` empty):
- **Probe A (= P1/P2):** toy gate → `PGRReport`, 6 verdicts in the frozen order, all non-green, exit 1, each naming its planted target — byte-for-byte match with the producer's transcript.
- **Probe B (= P6/P7/P3 spellings):** framework registry = the 12 names incl. `behavioral/Phi-Guardrails-Tests-Toy`; all five selector spellings (`assert:description:`, `with:do:`, `includesSubstring:`, `protocolName`, `compile:classified:`) confirmed.
- **Probe C (= P8 + P3 round trip):** all six body-distinguishing markers present in committed bodies AND absent from plant comments; fix-shaped recompile removes the body marker while the naive `'isNil ifTrue:'` survives in the preserved comment; restore byte-identical; `protocolName` → `ByteSymbol`.
- **Probe D (= P5, the widest claim):** all six prescribed C03 fixed sources compiled → gate `isClean` true, exit 0, exactly one advisory targeting `'architecture/PCKLayerMapCheck'`; restore byte-identical all six; post-restore 6 blocking again. Matches P5 exactly. (Evals never save the image.)
- **Extra adversarial probe:** the Symbol/String comparison the skeletons lean on (`f target = <String literal>` where arch/behavioral targets render as Symbols) holds **in both directions** in the work image — the B-14 reliance is sound.

**4 · Epic coverage: CLEAN.** §8.3's three ruled tests map one-to-one onto C01/C02/C03; D-43's two protections land at C01 (`setUp` guard) and C02 (`ensure:`); R-32 (demo half), R-43 (demo half), R-44, and P-GATE-RED (ch. 9 row names `ToyDemoTest>>#testGateIsRedOnPlantedViolations` — the exact spelling cut) are all traced; the exit checkpoint's leg 1 sweeps all three named tests plus every accepted suite (floors 264/265/266 arithmetically consistent with 263 at cut).

**5 · Amended-surface (scripted): CLEAN — the no-amendments claim is asserted by script.** Union of all DELIVERABLES manifests is exactly `src/Phi-Guardrails-Tests-Toy/ToyDemoTest.class.st`; that file is **absent** from the 125 committed `git ls-files src/` files (new at C01); no `modify` target anywhere is a committed accepted file. Diff against the cut's "Amended accepted surface: none" claim: empty.

**6 · Intent attribution: CLEAN.** Every normative rationale spot-checked traces to real ground: the exact-count law is quoted **verbatim** from §8.3 (`plan/02-spec/08-client-onboarding.md:163-167`); the termination argument matches D-46/§8.3; the fix-gate caution matches D-42 and §3.3 (`03-rule-catalog.md:126-131`); the `ensure:`/`setUp` pair quotes D-43's ruled text; the D-80 advisory-on-clean-only claim matches D-80 **and** the committed `PCKLayerMapCheck>>unlayeredAdvisory` (target sentinel `'architecture/PCKLayerMapCheck'` confirmed in source); D-82 carry-forwards 1 and 3 verified (committed `ci.yml` runs smalltalkci only — no gate step; `PGRVerdict` has no red-with-advisories constructor, confirmed in `src/Phi-Guardrails-SDK/PGRVerdict.class.st`); "a test that cannot fail is a defect" is constitution verbatim; the E07 one-cache-per-registry-build law traces to E07's cut. The four judgment calls (class name, marker-based guard, fix-under-nesting, no third gate run) are all recorded **veto-open** in `chunks.md` per the D-16 precedent — none asserted as fact in prose without attribution.

## Advisories (recorded, not acted on)

1. C01 labels the §8.1 residual caveat "(law)" where §8.1 says the recursion is "no longer designed against, only advised against" — the caveat's own "do not invoke" instruction is normative and the work order restricts in the safe direction; no downstream effect.
2. `ToyDemoTest` (unprefixed) will sit beside four `PGRToy*Test` classes in the same package — a local naming asymmetry; ruled ground (§8.3 + frozen roadmap) supports the spelling and the producer already holds it veto-open (call 1).
3. `probes.md` transcripts show the mixed Symbol/String target rendering; the skeletons' reliance on cross-class `=` is probed here in both directions — worth one line in the eventual class comment.

## Script/probe outputs (condensed)

- `mech_check.py`: `depends-on: {C01: —, C02: E14-C01, C03: E14-C02}` · `[P]: none` · `LOC sum = 310` · `ledger rows: [E14-C01, E14-C02, E14-C03]` (rows + verify entries both one-to-one) · `manifest: {src/Phi-Guardrails-Tests-Toy/ToyDemoTest.class.st}` · `committed src files scanned: 125` · `total scanned-file count: 130` · **ALL MECHANICAL + AMENDED-SURFACE CHECKS CLEAN**
- Probe A: `verdict count: 6 · names in frozen order · all non-green: true · exitCode: 1 · blocking: 6 · six targets match the table`
- Probe B: `12 registrations · Tests-Toy present: true · all five spellings: true`
- Probe C: `6× marker-in-body: true · 6× absent-from-comment: true · post-fix marker gone: true · naive string survives: true · restored byte-identical: true`
- Probe D: `all-fixed isClean: true · exitCode: 0 · advisories: #('architecture/PCKLayerMapCheck') · restored all six: true · post-restore blocking: 6`

**Verdict: PASS** — zero BLOCKING findings; the cut is ready for the human gate. Nothing was changed; probe scripts live only in the session scratchpad.
