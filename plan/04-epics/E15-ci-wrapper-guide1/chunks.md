# E15 · CI two-step, wrapper guard, guide 1 — chunk index (M4's closing epic)

Cut by the twelfth committed Prompt-4 run (2026-07-28). Epic-qualified IDs per
D-73. **Owner cut notice on record (validator punch 1, the E10 precedent):**
the owner's E15 release notice of 2026-07-28 — the Prompt-4 message that
authorized this cut — is the "owner's cut notice"/"scope line" cited in these
papers; its operative lines as released: E14 accepted, E15 = CI two-step +
wrapper guard + guide 1 (~3 chunks), the wrapper self-test's arm is "a
deliberate non-gate failure" with B-23/B-25 collision hardening staying M5 out
of scope, shell-arm probes may run the actual scripts, the D-13 entry is a
REQUIRED question filed by design, E15 adds no registration, M4 closes at this
epic's acceptance, do not pre-build M5 ground. Entry check: roadmap approved
and frozen (D-62); **E14 owner-accepted
(2026-07-28)** — E15's one roadmap dependency — with its digest frozen @
`2f4cccb` (the demo contract: the three named `ToyDemoTest` tests, the
exact-six law red-test-enforced, the D-43 pair standing; D-83 confirmed the
nested fix-arm composition). Accepted verify sweep at cut time: **266 tests**
(head `181709f`, src byte-identical to the E14 checkpoint head `2f4cccb` —
probes.md P6); self-hosted gate **12 registrations GREEN**. Every count below
is named-suite membership plus a floor, never an exact ceiling. **E15 adds no
registration** — its new ground is CI infra, the shell self-test, and the
guide-1 sample test; the gate leg stays a 12-registration regression guard
throughout.

**The D-82/Q-39 cut-time probe obligation is discharged in `probes.md`** (this
directory): the wrapper/shell arms were probed by running the actual committed
scripts (they are D-65 infra, not image ground — the owner's cut notice names
this expressly), the guide-1 fence inputs were probed end-to-end against the
committed harness and gate in the work image, the Linux CI toolchain spellings
were fetched and checksummed, and every skeleton-named frozen-surface selector
was exercised live. Two probe discoveries shaped the cut: **(1)** guide 1's §2
Metacello fence is indented and therefore invisible to the harness (3 samples
seen, not 4) — the C02 reshape de-indents it; **(2)** a real VM with a
**nonexistent image file** exits 0 and the wrapper relays success — a
false-green hole outside D-75's ruled corrupt-image→1 limitation, filed as
**Q-40** (decision sheet, this cut; no chunk touches `guardrails.sh` unless
the owner rules it in).

Ruled ground in force: **D-82 carry-forward 1** — at cut time the committed
`.github/workflows/ci.yml` still runs CI step 1 only; **E15-C01 IS the
scheduled two-step upgrade**; until it lands no paper claims the gate step
exists, and after it lands the two-step contract is the committed fact (the
next regeneration retires the carry-forward line). **D-60.a** (the landing
condition C01 discharges, judged against the D-63 M0 hosted-load row and the
D-64 coordinates) · **D-76** (its consequence line binds the C02 pass:
illustrative-only fences are findings) · **D-77** (fence reshape, never
harness extension) · **D-75** (∉{0,1,2} erratum: an empty/corrupt image relays
1 — the self-test therefore uses the probed missing-VM arm, 127 → 3) ·
**D-13** (measure at M4, then rule — C03 files the REQUIRED question) ·
**D-66/D-67** (checksum pins; precheck discipline).

## Chunks

| ID | Title | Depends-on | [P] | LOC est. | Acceptance (one line) |
|---|---|---|---|---|---|
| E15-C01 | CI to the two-step contract + wrapper-guard self-test | — | no | ~35 (YAML) | a real CI run `completed success` on the head with all six steps green — step-2 log `GATE: GREEN`/12 registrations, self-test exit-3 arm green; D-60.a discharged in the report; `.smalltalk.ston` confirmed final; local sweep ≥266 + gate leg 12 GREEN unchanged |
| E15-C02 | Guide 1 made real + `testAdoptAndRunSamples` | E15-C01 | no | ~140 | `testAdoptAndRunSamples` green in a ≥267 sweep (4-sample inventory pin, the four Acme registrations in order, draft/typo/no-role/defective-config arms by class); guide-1 ⟨verify⟩ count 9 → 0; accepted methods byte-identical; gate leg 12 GREEN; CI green on the head |
| E15-C03 | D-13 timings measured, Q-41 filed | E15-C01, E15-C02 | no | ~120 (papers) | measurements.md complete (CI steps · local ×3 · in-image ×2, raw outputs) and Q-41 on the decision sheet citing D-13/§7.6 with a recommendation; sweep ≥267 + gate leg + CI leg standing |

Sum ≈ 175 code/infra LOC + measurement papers — the roadmap's "~3 chunks" cut
as three: the infra amendment, the guide discharge, and the evidence filing
are three separately reviewable concerns. No `[P]`: C02's equivalence arm
reads the workflow C01 commits (guide ↔ workflow divergence must red, so the
workflow must exist first), and C03 measures the runs C01/C02 produce —
strictly serial picks C01 → C02 → C03 (verify floors stated against that
order).

## Scheduled ground riding this cut

- **The infra amendments are the roadmap-scheduled deliverable itself**
  (`ci.yml` to the two-step contract; `.smalltalk.ston` confirmed final —
  D-65-class committed infra, amended only by this scheduled epic). The
  scripted enumeration of every committed reference to the workflow's shape
  (136 committed code+docs+infra files scanned; table inlined in C01) found
  **no committed file pinning step-1-only as permanent** — checkpoint CI-leg
  wordings in `plan/` cite runs, not steps, and the seven `src/` "step" hits
  are spec-paragraph stages.
- **Guide 1's amendment is D-76-scheduled ground** (its consequence line names
  this pass); the guide has zero committed `src/` consumers (scripted — the
  harness test pins guides 2/3 only), so **amended accepted surface: none** —
  C02 adds to `PGRQuickstartSamplesTest` with every accepted method
  byte-identical (reviewer-diffed), and no chunk manifest names any other
  accepted test file.
- **B-24** (structured STON report, "E15-adjacent or M5") is **not** pulled
  in: the owner's E15 scope line does not name it; it stays backlog/M5.
  **B-17** (`*.fuel` gitignore) was already closed at the M2 opening infra
  act (D-78 ruling; the line is committed) — nothing to do here.

## Agent-judged calls at cut time (veto-open, D-16 precedent)

1. **The wrapper self-test arm is the missing-VM arm (exec 127 → 3), not an
   "unloadable image".** Probed (P1): on this toolchain an empty/corrupt image
   makes the VM exit 1 (D-75's ruled limitation) and a missing image file
   makes it exit 0 (the Q-40 hole) — no image-shaped input reaches the
   ∉{0,1,2} branch. The owner's cut notice names the arm "a deliberate
   non-gate failure"; the ch. 9 P-WRAPPER-GUARD row's "unloadable image exits
   3" wording predates D-75 and is queued as a MINOR erratum for the owner's
   next spec pass. (A veto substitutes its own arm by chunk amendment.)
2. **The gate-image assembly is its own named workflow step** between §7.4's
   two steps — the §7.3 recipe's executable copy (D-60/D-60.a) made visible;
   the two contract steps keep their exact §7.4 meanings (smalltalkCI ·
   `./guardrails.sh guardrails.ston`).
3. **The guide-1 fence reshapes** (de-indent the §2 Metacello fence + D-64
   real coordinates; §3's path becomes the fence's one free variable; §3's
   defective-config fence — the guide's 4th sample — answers
   `err messageText`) — the D-77 species: reshape the guide,
   never extend the frozen harness; each reshape is probed (P3/P5) and
   red-test-enforced by the new inventory pin.
4. **The Metacello fence executes to the compile boundary in-image**
   (`OCParser parseExpression:`, faulty/`OCCodeError` both red) **plus a
   guide↔workflow textual-equivalence pin**, with live execution delegated to
   the workflow's hosted load on every CI run — the constitution's network ban
   at test run time leaves no in-image alternative; the CI leg is the fence's
   genuine executor (guide 1's own §2 sentence states exactly this division).
5. **The hosted load of `main` in CI step 2 is the commit under judgment** on
   every push run under D-64's main-only model; the race window (a second push
   landing mid-run) is recorded here as a known property, not defended against
   — revisit only if a PR flow ever starts.

## Cross-epic notes

- **After E15-C01 lands, the two-step contract is the committed fact** — the
  D-82 carry-forward's step-1-only line retires at the next regeneration.
- **Q-40 rides the cut veto-open:** if the owner rules the one-line
  missing-image guard into scope, it lands as its own amendment chunk against
  `guardrails.sh` (accepted E05 infra), never as a silent C01 edit.
- **The M4 milestone gate carries** (owner-side, none pre-built here): the
  mining sweep with the queued B-31/B-32 evidence, the D-13 budget ruling
  (from C03's Q-41), and the roadmap re-entry that cuts M5.

## Exit checkpoint (proves the epic; E15's acceptance IS the M4 milestone boundary)

E15 is provable by, on one head commit (the roadmap M4 exit criterion):

1. **CI leg (the criterion's core):** the committed `.github/workflows/ci.yml`
   green on a real run of the head — **the smalltalkCI step + the
   `./guardrails.sh guardrails.ston` step + the P-WRAPPER-GUARD shell
   self-test** all green in one run (six workflow steps in all: checkout ·
   setup · smalltalkCI · gate-image assembly · enforcement · self-test); the
   enforcement-step log shows
   `GATE: GREEN`, 12 registrations (P-SELF-HOSTED, CI form — the crashed-step
   hole closed by the self-test, P-WRAPPER-GUARD; D-60.a discharged on the
   record).
2. **Named suite (the verify command):** `bash tools/build-image.sh && bash
   tools/verify.sh` exit 0, 0 failures / 0 errors — all three
   `PGRQuickstartSamplesTest` methods by name (`testAdoptAndRunSamples` the M4
   anchor, P-GUIDE-EXEC complete across all three guides) **and** all three
   `ToyDemoTest` cases by name (the sweep driving red → fixed → green — the
   M4 criterion's demonstration clause, standing from E14) with every
   previously accepted suite, ≥267 run; membership + floor. Guide 1 carries
   zero ⟨verify⟩ markers.
3. **Self-hosted gate leg (regression):**
   `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
   → exit 0, **12 registrations unchanged**, `GATE: GREEN`.
4. **The D-13 filing:** `measurements.md` complete and **Q-41 on the decision
   sheet** — timings measured and filed for the budget ruling at the gate.
5. **Infra leg:** `bash tools/precheck.sh` green at every pick; D-73
   `E15-C##:` commit prefixes throughout (D-66/D-67).

**Frozen at acceptance (E15's interface digest):** the **committed two-step CI
contract** — `.github/workflows/ci.yml`'s six-step shape (checkout · setup ·
smalltalkCI step · gate-image assembly carrying the real §7.3 load form
`github://mittcooper/phi-guardrails:main/src` / `load: 'CI'` · enforcement
step · wrapper self-test) with the D-66 pins
(image `897668dd…`, Linux VM `b4b344a8…`), amendable only by scheduled epic
edits or decision-sheet entry; **guide 1's executable form** (4-sample
inventory, red-test-enforced by `testAdoptAndRunSamples`'s pin) joining guides
2/3 under the standing P-GUIDE-EXEC witness; `.smalltalk.ston` confirmed at
its §7.4 final form. Internal/unfrozen: the Acme scratch-world helper
spellings, the measurement record's layout. **The epic ends at the owner's
milestone gate** — M4 closes at this checkpoint's acceptance.

Checkpoint result (filled at epic close): —
