# C12 · B-03 probe: lint-environment trait attribution      [E06 · depends: — · parallel: yes]

GOAL      Answer B-03 — does §2.3's `RBPackageEnvironment`-scoped lint run see
          trait-provided methods in the *using* class's package, or only in the
          trait's defining package? — and record the outcome as a decision-log
          entry (next free D-number; D-70 if still free at commit time).

TRACE     backlog B-03 · D-15.b agent note (⟨verify at M1⟩) · roadmap E06 goal +
          risk row · P5 (verify the spellings) · constitution §3 (decisions:
          agents recommend, humans rule).

## CONTEXT DIGEST

**The question, self-contained.** D-15.b (probed live, 2026-07-13) established
two facts: (a) trait-provided methods surface in each *using* class's `methods`
with working `referencedClasses` — so the architecture walk judges them at every
using class; (b) `CompiledMethod>>package` answers the **trait's defining
package** (and `origin` the trait). The lint run is a different, *package-filtered*
query: `ReSmalllintChecker new rule: {r}; environment: (RBPackageEnvironment
packageName: 'X'); run; criticsOf: r` (verified spelling, D-15). Unknown: whether
that environment attributes a trait-provided method to the using class's package
(no hole — the role law keeps it in scope) or to the trait's defining package (the
B-03 hole: a trait defined in an exempt-role package but used from a production
class **escapes lint**).

**Probe design** — model on the committed `plan/probes/trait-attribution-probe.st`
(same fluid-definition style; that file's header comment doubles as its results
record — copy the convention). Scratch fixture, built in a throwaway copy of the
work image, never saved:

```smalltalk
Trait << #TCruftProbe
    package: 'ProbeB-Traits';
    install.
TCruftProbe compile: 'probeCruft self flag: #probe'.

Object << #ProbeBUser
    traits: { TCruftProbe };
    package: 'ProbeB-User';
    install.
```

Rule under test: the shipped `ReCodeCruftLeftInMethodsRule` (fires on `self flag:`
— verified live, D-28), so the probe needs no code of ours. Run the checker twice
and print both observations:

1. environment `(RBPackageEnvironment packageName: 'ProbeB-User')` — does
   `criticsOf:` contain a critique of `probeCruft`?
2. environment `(RBPackageEnvironment packageName: 'ProbeB-Traits')` — same
   question.

**Outcome handling:**

- Critique appears in the `ProbeB-User` run → **no escape**: the lint environment
  attributes trait methods to each using class's package. Record the decision-log
  entry: "B-03 closed — lint sees trait-provided methods at each using class",
  with setup, raw printed output, and the one-line consequence (ch. 2 §2.3 needs
  no amendment; backlog B-03 row is dispositioned by the entry).
- Critique appears **only** in the `ProbeB-Traits` run → **escape confirmed**:
  record the decision-log entry with the evidence, and **append a numbered
  decision-sheet entry** (next free Q-number in `plan/04-decision-sheet.md`,
  matching that file's format: context · to-rule · recommendation · status open)
  recommending where trait methods get linted — recommend, never rule. The lint
  chunks C13–C18 land regardless (roadmap E06 risk row: the entry rides; it does
  not block).
- Any third behavior (e.g. critique in both runs) → record exactly what was
  observed; same decision-sheet duty if it leaves a hole.

**Toolchain.** `bash tools/build-image.sh` builds the work image under `.build/`
from committed `src/`; run the probe headless against a scratch **copy** of that
image using the same VM-invocation pattern `tools/probe-m0.sh` uses (read that
committed script for the exact form). Never `install`-probe in the canonical work
image; never save any image. Probe packages exist only inside the scratch run.

**Constitution rules that bite here:** probe scratch lives under git-ignored
`.build/` (D-65); `plan/` is append-or-frozen — the decision log and decision
sheet take appends only, never edits to existing entries; nothing under `src/`
changes in this chunk; no network beyond what the committed toolchain scripts
already do.

## DELIVERABLES

- `plan/probes/b03-lint-env-trait-probe.st` — the self-contained probe script;
  after the run, its header comment records the results verbatim (the
  `trait-attribution-probe.st` convention)
- `plan/decision-log.md` — **one appended entry** (next free D-number; expected
  D-70): question, setup, raw observations, consequence
- `plan/04-decision-sheet.md` — one appended Q-entry **iff** the escape (or any
  residual hole) is confirmed
- LOC budget: ~30 script lines; **no product code** (probe chunk — the E01
  C01/C04 precedent; script LOC is outside the product budget)

## TESTS FIRST

None — a probe chunk delivers recorded evidence, not product code (E01
precedent). The acceptance instrument is the script's printed observations,
committed verbatim in its header comment and in the decision-log entry.

VERIFY    the probe script runs headless, exit 0, printing both observations;
          `bash tools/build-image.sh && bash tools/verify.sh` stays green —
          0 failures, 0 errors, run count unchanged from the pick-time accepted
          set (24 when no `[P]` sibling or parallel-track E03 suite has landed
          yet; no product change — regression guard).

OUT OF SCOPE
- Any code change responding to the outcome (a future chunk under a future
  ruling), including amending ch. 2 §2.3.
- Ruling on the escape — the decision-sheet entry recommends only.
- Touching `plan/probes/trait-attribution-probe.st` (history) or anything under
  `src/`.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files, one
          commit `C12: B-03 probe — lint-environment trait attribution` before
          reporting for review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · probe output verbatim + the recorded
  D-number · deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
