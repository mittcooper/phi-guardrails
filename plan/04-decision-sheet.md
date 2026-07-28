# Decision sheet 04 — Prompt-4 / execution-stage questions

*Numbering continues from sheet 02 (closed at Q-28). Agents recommend, humans rule;
a ruling becomes a numbered decision-log entry.*

## Q-29 · Publishing the repo: host coordinates, visibility, default branch — RULED (D-64)

The M0 checkpoint requires the minimal CI workflow "green on an actual CI run"
(roadmap §1, frozen at D-62), and the D-60.a probe needs real `github://` load
coordinates — but the repo currently has **no git remote**, and its local branch is
`master` while every spec placeholder (`github://<org>/phi-guardrails:main/src`,
§7.3) and the harness's main-branch setting assume `main`. Publishing is an
owner-facing act; the executor may not choose it.

**To rule:** (a) host owner/org and repo name; (b) visibility; (c) rename `master`
→ `main` before first push?

**Recommendation:** (a) `mittcooper/phi-guardrails` on github.com (the `gh` account
already authenticated); (b) **public** — a private repo makes the D-60.a hosted-load
probe need a token in the image and would defer that probe arm to E15 with extra
machinery; public keeps the M0 probe honest and matches the family's
open-development posture — owner's call if that posture is wrong; (c) **yes**,
rename before first push, so the committed spec placeholders' `:main` form is the
real form and no remote ever carries `master`.

**Status:** **RULED** (owner notice 2026-07-23, as recommended) → **D-64**:
`mittcooper/phi-guardrails` on github.com · public · `master` → `main` before first
push. C03's entry block is lifted.

## Q-30 · Write-boundary reading for build infrastructure (toolchain, scripts, `.gitignore`) — RULED (D-65)

Constitution §2's mutation discipline names `src/`, `plan/`, `docs/`, the four root
artifacts, and test scratch files — and forbids network calls. Read literally that
forbids the M0 toolchain download (D-31.a `curl`s it; CI fetches it every run) and
leaves `.gitignore` and any runner script homeless, yet the frozen roadmap requires
a "permanently installed" toolchain and a verify run "from a script".

**Reading proposed (agent-decided):** the boundary governs the *product* —
framework/kit/toy code and their tests at run time — not repo build infrastructure;
`.gitignore` is git metadata like `.git` itself; the network is touched only by
toolchain bootstrap and the CI service, never by product code (P-DETERMINISTIC's
reflective query continues to enforce the product-side rule at E09).

**To rule:** confirm this reading, or name the location the toolchain and scripts
should use instead.

**Status:** **RULED** (owner notice 2026-07-23) → **D-65**: the reading is
confirmed, with **amended locations** — committed harness scripts in `tools/` (repo
root); all uncommitted build state in the single git-ignored `.build/` (toolchain
`.build/pharo/`, work images `.build/work/`, probe scratch `.build/scratch/`).
Constitution §2 amended by the owner accordingly; the E01 papers are swept to the
ruled paths.

## Q-31 · The matcher-ambiguity error arm is unconstructible — implement dead code, or record it vacuous?

Spec ch. 1 §1.1 (D-45 agent detail, ratified D-47) rules: a `#roles` matcher
string "that is both a group name and a package name is a configuration error."
The E03 probe pass (2026-07-25, D-31.a work image — record: E03 chunks.md
§probes) found **Metacello itself refuses the precondition**: declaring a group
named like a declared package raises "incompatible specs
(MetacelloGroupSpec/MetacelloPackageSpec)" when the version is built, so no real
baseline can ever present an ambiguous string to the resolution order, and the
ruled error arm would be a dead, untestable branch (a test that cannot fail —
constitution §2's defect).

**To rule:** (a) accept the arm as **vacuously satisfied** — the resolution order
(group-name-first with membership pre-check, else package name, else full-match
pattern) is total without it, C24 implements no dead branch, and ch. 1 §1.1's
sentence gains an erratum note at the owner's next spec pass; or (b) keep the
arm, which requires a synthetic (non-Metacello) version stub to test — machinery
the spec nowhere else needs.

**Recommendation:** (a). The ruling's intent — never a silent pick between two
readings — is met structurally: Metacello guarantees the two namespaces cannot
collide, so no pick ever happens. E03's C24 work order is written to this
recommendation, flagged veto-open; a veto returns the arm as its own amendment
chunk with the stub design.

**Status:** **RULED** (owner word 2026-07-25) → **D-70**: option (a) confirmed —
the arm is vacuously satisfied (Metacello refuses the precondition upstream); C24
stands as cut; ch. 1 §1.1 gains an erratum note at the owner's next spec pass.

## Q-32 · B-03 escape confirmed: where do trait-provided methods get linted?

The C12 probe (`plan/probes/b03-lint-env-trait-probe.st`, decision-log **D-71**,
2026-07-25) confirmed the B-03 hole live: the ch. 2 §2.3 package-scoped lint run
(`RBPackageEnvironment packageName:`) attributes a trait-provided method **only to
the trait's defining package** — the using class's package run returns zero
critiques. So a trait defined in an exempt-role package but used from a production
class escapes lint entirely, and the lint query disagrees with the architecture
walk, which judges trait methods at each using class (D-15.b). The lint chunks
C13–C18 land regardless (roadmap E06 risk row); this question gates only the
future amendment chunk.

**To rule:** where a trait-provided method must be linted — (a) at each **using
class's package**, by widening the per-package lint environment (e.g. the package
environment unioned with a selector environment of the package's classes'
trait-acquired methods), so the using package's role governs, matching the
architecture walk's attribution; (b) at the **trait's defining package only**
(current behavior), closing the hole by policy instead — a registry/gate check
that a package defining traits used from stricter-role packages may not carry an
exempt role; or (c) accept the hole, documented as a known limit in ch. 2 §2.3
and ch. 8.

**Recommendation:** (a). It matches the D-15.b precedent (the architecture walk
already judges trait methods at every using class — one attribution story across
both check kinds), keeps the role law meaningful ("the using package's role keeps
it in scope"), and needs no new policy machinery; the duplication when several
packages use one trait is the same accepted defense-in-depth D-15.b recorded.
(b) adds a second enforcement concept for one hole; (c) leaves a real escape in a
guardrails product. The exact environment-composition spelling is ⟨verify⟩ work
for the amendment chunk, not settled here.

**Status:** **RULED** (owner word 2026-07-25) → **D-72**: option (a) — trait
methods lint at each using class's package; the amendment chunk rides the next
kit-side Prompt-4 cut; ch. 2 §2.3 gains an erratum note at the next spec pass.

## Q-33 · The `isRewriteRule` guard does not capture catalog flag-only-ness

Filed by the orchestrator from the E08-C02 completion report (2026-07-25;
commit `44dee8a`). The frozen §3.3 constructor guard — and E08-C05's `canFix`,
specified as the same probe — is mechanical: `aRuleClass new isRewriteRule`
(instance-side; the P5-confirmed form, exactly two implementors in the live
image: `ReAbstractRule` false · `ReNodeRewriteRule` true). But ch. 3 §3.2b
classifies `ReCodeCruftLeftInMethodsRule` flag-only **by policy** ("the fix
deletes statements, which is never a safe automatic rewrite"), while
mechanically it *is* a `ReNodeRewriteRule` subclass answering `isRewriteRule`
true (probed live at E08-C02; the work order's red-arm fixture had to be
substituted — `ReEmptyExceptionHandlerRule` — for exactly this reason). So
`PCKFixCommand rule: ReCodeCruftLeftInMethodsRule packages: …` constructs
successfully, and E08-C05's check-side `canFix` would answer **true** for the
cruft check — the gate would advertise a fix capability the catalog forbids.

**To rule:** (a) accept the mechanical answer — `isRewriteRule` is the whole
truth, and §3.2b's "flag-only" becomes an erratum; (b) add a kit-side flag-only
classification (e.g. a catalog-owned deny-list or a per-rule `fixIsSafe`-style
hook) that the constructor guard and the `canFix` capability both consult on
top of the mechanical probe; or (c) amend the catalog entry so the cruft rule
is no longer classified flag-only.

**Recommendation (implementer's, orchestrator-relayed — E08-C05 is gated on
this ruling):** (b) — the catalog's safety judgment should be machine-enforced
(P1), not prose; (a) silently widens the fix surface past what §3.2b ruled
safe, and (c) reverses a safety call on convenience grounds.

**Status:** **RULED** (owner word 2026-07-25) → **D-74**: option (a),
owner-strengthened — no flag-only category exists; `canFix` is the mechanical
fact alone; per-application judgment lives at the mandatory preview. E08-C05
amended under the ruling and unblocked; §3.2b gains an erratum at the next
spec pass.

## Q-34 · The §7.3 wrapper mapping is unsound on this toolchain: an unloadable image exits 1, not ∉ {0,1,2}

Filed by the orchestrator from the E05-C07 completion report (2026-07-26;
commit `65bd022`), reproduced independently before filing. The frozen §7.3
contract script maps VM exit codes `0|1|2` straight through and treats
anything else as "gate did not run to a verdict" (exit 3). Its stated
assumption — "the image failing to load, the `PGRGate` class being absent, or
the VM dying must never read as success" — does not hold for this VM build:
feeding an empty/corrupt image file makes the VM itself exit **1**
(`[ERROR] … Invalid image format: detected version 0, expected version
68021`; reproduced twice by the implementer, once by the orchestrator, and
confirmed with the VM invoked directly without the wrapper). Exit 1 is inside
the wrapper's pass-through set, so a broken image reads as "RED — a check
failed" rather than exit 3, and CI would report a real-looking violation
verdict where no gate ever ran. Arms 1–3 are sound (0/1/2 exactly, verified);
the committed script is byte-identical to §7.3 modulo the recorded
`--headless` accommodation; the E05-C07 work order named exactly this
observation as a stop-and-report decision-sheet finding (E15's
P-WRAPPER-GUARD depends on the mapping's soundness). E05-C07 is `blocked` on
this ruling; it is the last E05 chunk, so the epic checkpoint (runner leg:
exit exactly 0/1/2/3) waits with it.

**To rule:** (a) accept the gap as a known limitation for v1 — arm 4's
expectation is amended to "documents the observed VM behavior" and
P-WRAPPER-GUARD (E15) owns the real defense (e.g. a sentinel probe run before
the gate run); (b) amend §7.3 so the image-side answer cannot collide with
raw VM exits — e.g. `Smalltalk exit:` a shifted code set (gate answers
0/1/2 → image exits 10/11/12, wrapper maps back, anything else → 3); or
(c) keep the mapping and have the wrapper distinguish by scanning the run's
output for the `GATE:`/error-line marker before honoring 0|1|2.

**Recommendation (orchestrator-relayed, implementer concurring):** (b) — it
makes the collision impossible by construction with a three-line wrapper
change and one amended eval string, stays fully deterministic (P2, no output
sniffing as in (c)), and keeps exit-code semantics the only contract; (a)
leaves CI able to report a phantom RED until E15 lands. Amending frozen §7.3
ground is precisely what the decision-sheet path is for.

**Status:** **RULED** (owner word 2026-07-26) → **D-75**: option (a) — the
script stays byte-identical to §7.3; the recommended exit-code remap was
rejected as unnecessary rule-making; arm 4 documents the observed behavior
(known v1 limitation); the hardening is widening scope (B-23, M5). C07
unblocks.

## Q-35 · Guide 2 sample 5 (`fixCommandOn:`) is a Pharo 13 syntax error — P-GUIDE-EXEC finding against a producer-owned guide

Filed by the orchestrator from the E09-C05 completion report (2026-07-26),
**verified independently before filing** (guide text read directly; the
syntax error reproduced in-image — a headless compile of the verbatim body
hangs on the resulting syntax-error debugger, corroborating the
implementer's caught `OCSyntaxErrorNotice`). E09-C05 (`testWriteACheckSamples`)
must execute every sample in `docs/quickstarts/02-write-a-check.md` verbatim
through the C04 harness (P-GUIDE-EXEC). Sample 5 (§5, "the fix capability")
does not compile:

```
AcmeClassCommentCheck >> fixCommandOn: packages
    ^ "an object conforming to the fix-invocation protocol"
```

`^` (caret return) followed only by a comment, with no expression, is a hard
Pharo 13 syntax error ("Variable or expression expected"). The harness
`install:` compiles the whole sample body, so the `fixCommandOn:` segment
aborts installation and sample 5 cannot be installed — the work order's step 2
(`canFix` true witnessed on the installed skeleton) is unreachable. Notably
the offending fence in the guide is preceded by a literal `⟨verify⟩` marker:
these spellings were flagged for in-image verification and never confirmed.

Every route around this is a forbidden move for the implementer — editing the
guide, splitting/patching the sample in the harness, or dropping the sample-5
install and the `canFix`-true assertion (OUT OF SCOPE: "Any edit to the
guides, the harness, or any accepted file"; "a sample the surface no longer
satisfies is a red test to report, not a document or product to patch"). This
is the P-GUIDE-EXEC property working exactly as designed: the executable-guide
check caught a real defect in an accepted, producer-owned file (D-59). The
implementer correctly stopped and reported rather than compensate.

**Everything else in the plan is verified green** (implementer probe against
the C04-loaded image, orchestrator has not re-run but the arms are
independent of sample 5): the named Symbol/String risk does **not** bite
(`#Object = 'Object'` → true on this image, so sample 3's `f target =
'AcmeUncommentedFixture'` holds); a commentless class's `comment` is `''`
(empty, not nil), so sample 1's `run` fires/silences the fixture pair
correctly; steps 1–4 (plain-class conformance + resolved registration,
skeleton superclass + inherited `packages:`, fixture pair 2/2 green, gate
report includes `architecture/AcmeClassCommentCheck`) all hold. Sample 5 is
the sole blocker.

**To rule:** the fix is a change to an accepted, producer-owned guide, which
only the owner may authorize — (a) correct sample 5's `fixCommandOn:` to a
compilable placeholder, recommended as the caret-free comment form matching
sample 2's own `run "as above"` idiom — `fixCommandOn: packages    "an object
conforming to the fix-invocation protocol"` (compiles; returns self, a lawful
placeholder that satisfies existence/arity validation, which is all the
sample-4 registration exercises) — or supply a real returnable placeholder
expression; then re-accept the guide, and E09-C05 lands unchanged as
specified. (b) Alternatively, if the guide is meant to show a non-compiling
illustrative sketch here, amend P-GUIDE-EXEC / the C05 work order to exclude
sample 5 from verbatim execution (a scope change to the property, not
recommended — it puts a hole in the executable-guide guarantee).

**Recommendation (orchestrator-relayed, implementer concurring):** (a), the
caret-free comment form. It is the smallest correct change, matches an idiom
the same guide already uses, keeps every sample verbatim-executable (the
whole point of P-GUIDE-EXEC), and leaves the C05 work order untouched. (b)
weakens the property to accommodate a typo.

**Impact / blocking:** E09-C05 is `blocked` on this ruling. E09-C06 depends on
C05 (`testBuildAKitSamples` is a scheduled addition to C05's same file), so it
is blocked transitively. E09's exit checkpoint — which **is** the M1 milestone
boundary — cannot close until both land. The rest of E09 (C01–C04) is accepted
and green; only the two sample legs wait on this one guide correction.

**Status:** **RULED** (owner word 2026-07-26) → **D-76**, owner-broadened: ALL
quickstart guides must be REAL — every fence genuine executable code doing the
actual lesson. Guide 2 §5 amended to a complete working fix object
(`AcmeCommentFix`); the realness requirement lands as Drydock law. E09-C05
unblocks.

## Q-36 · D-76's enriched guide-2 sample 5 outruns the accepted C04 harness parser — second class definition, mid-fence

Filed by the orchestrator from the E09-C05 re-pick completion report
(2026-07-26), **verified independently** (harness driven against the committed
guide in a rebuilt work image at `e4ad139`: installing sample 5 verbatim
raises a compile failure — `Syntax Error … 'Undeclared variable'` /
`OCUndeclaredVariableNotice` on `AcmeCommentFix`, matching the implementer's
caught `KeyNotFound: #AcmeCommentFix` and `NewUndeclaredWarning:
AcmeClassCommentCheck>>fixCommandOn: (AcmeCommentFix is Undeclared)`).

D-76 replaced sample 5's placeholder with a complete working fix object. The
fence now carries **two class definitions**: method listings on the
pre-existing `AcmeClassCommentCheck` (`canFix`, `fixCommandOn:`) **followed
by** a *second* fluid class definition `Object << #AcmeCommentFix …` **placed
mid-fence** (after those method listings), then five method listings on
`AcmeCommentFix`. The accepted E09-C04 harness (`PGRQuickstartSampleHarness`,
frozen at epic acceptance) installs a fluid class definition **only from the
pre-header segment** — the lines before the first listing header. Its
`isListingHeader:` matches only `Name >> sel` / `Name class >> sel`, so
`Object << #AcmeCommentFix` is not recognized as a definition boundary; those
lines are absorbed as body into the preceding `fixCommandOn:` segment,
`AcmeCommentFix` is never created, and the subsequent `AcmeCommentFix class >>
onPackages:` segment fails to resolve its target class. The harness's model is
**one class definition per sample, pre-header only**; D-76's sample introduces
a shape (two definitions, the second interior) that model does not cover.

This is again the P-GUIDE-EXEC verifier doing its job (D-76's own words: "this
very test is its verifier") — it caught that the enriched guide and the
accepted harness surface are not yet reconciled. The three routes to green are
all forbidden to the implementer: edit the guide (producer-owned, D-59), edit
the frozen C04 harness (accepted surface — needs its own chunk + decision-log
entry), or hand-parse sample 5 inside the test (executes *not through the
harness*, defeating P-GUIDE-EXEC and the "verbatim through the C04 harness"
letter). The implementer correctly stopped and reported.

**Everything else is verified in-image and ready** (implementer probe,
orchestrator-confirmed on the risk items): the Symbol/String risk does **not**
bite (`#AcmeUncommentedFixture = 'AcmeUncommentedFixture'` → true, `cls name`
is a `ByteSymbol`); an uncommented class answers `comment isNil` false /
`comment isEmpty` true, so sample 1's `run` fires/silences correctly. Only
sample 5's install shape blocks; the other four samples land per the work
order once sample 5 is installable.

**To rule** — pick how sample 5 is made installable verbatim (the orchestrator
recommends (a)):

- **(a) Reshape sample 5 in the guide so the `Object << #AcmeCommentFix`
  definition leads the fence** (pre-header), with every method listing — for
  both `AcmeClassCommentCheck` and `AcmeCommentFix` — following it. Installable
  by the current harness **unchanged**: the pre-header segment installs
  `AcmeCommentFix`; each following listing compiles into its named class
  (`AcmeClassCommentCheck` already exists from sample 1's install in step 2;
  `AcmeCommentFix` now exists). No accepted-surface change, no work-order
  change, fence inventory unchanged (still one `smalltalk` fence → C04's pin
  `#(smalltalk smalltalk smalltalk ston smalltalk)` holds). Cost: the guide's
  narration order shifts (introduce the fix object first, then wire it onto the
  check) — a producer/owner call on an accepted file. **Recommended** — minimal,
  keeps every sample verbatim-executable, touches only the guide.
- **(b) Extend the C04 harness** to recognize any `Super << #Name` line as a
  class-definition boundary (multiple definitions, interleaved with method
  listings), not only pre-header. A change to the frozen E09-C04 surface → a
  new chunk + decision-log entry; larger blast radius, and it generalizes the
  harness beyond what any current guide needs except this one.
- **(c) Split sample 5 into two fences** (the check's `canFix`/`fixCommandOn:`;
  and the `AcmeCommentFix` class). Changes guide 2's frozen fence inventory —
  `samplesIn:` would answer 6 samples, not 5 — reddening C04's two accepted
  inventory pin tests (`PGRQuickstartSampleHarnessTest`), so it drags an
  amendment to accepted E09-C04 ground along with it.

**Recommendation (orchestrator-relayed, implementer concurring):** (a). It
satisfies D-76's realness law (the fence stays genuinely executable, and this
test still verifies it), needs no change to any accepted code surface or work
order, and is the smallest edit. (b) reshapes an accepted interface for one
sample; (c) reddens accepted pins and amends E09-C04.

**Impact / blocking:** E09-C05 remains `blocked`. E09-C06 stays blocked
transitively (its `testBuildAKitSamples` is a scheduled addition to C05's
file; note guide 3's own §5-style samples should be checked for the same
two-definitions-per-fence shape before C06 runs). E09's exit checkpoint — the
M1 milestone boundary — waits on both. C01–C04 remain accepted and green.

**Status:** **RULED** (owner word 2026-07-26) → **D-77**: option (a) — fence 5
reshaped, definition leads, wiring last; advisor's drafting attributed on the
record; guide 3 scanned clean. E09-C05 re-picks.

## Q-37 · §4.2 step 4 vs frozen `PGRVerdict` — the `#unlayered` advisory can attach only to green verdicts

Pre-filed in the E10-C04 work order and restated here by the integrator at
E10-C04 acceptance (2026-07-27; commit `2b9791c`). **Owner-pre-ruled to the
conservative arm and NOT a blocker** — E10-C04 shipped green implementing it;
this entry records the open surface question for the owner's ruling, per the
work order's instruction (the implementer did not escalate).

Spec ch. 4 §4.2 step 4 reads that the layer-map check's verdict carries one
advisory restating the `#unlayered` packages "in **every** report". But the
frozen E02 `PGRVerdict` (D-15 inventory) offers **no `redFindings:advisories:`
constructor** — its constructors are `green` · `greenAdvisories:` ·
`redFindings:` · `missingReason:` · `skipped`, and `redFindings:` sets
advisories to `#()`. So a **red** verdict structurally cannot carry the
`#unlayered` advisory; only the green (clean) path can.

**Implemented (the conservative arm, no surface change):** `PCKLayerMapCheck>>run`
attaches the `#unlayered` advisory only on the green verdict
(`PGRVerdict greenAdvisories: { advisory }`); a red verdict carries findings
only (`PGRVerdict redFindings: findings`). Witnessed green by
`testUnlayeredReportedAsAdvisory` (green + advisory names the unlayered
package) and `testGreenWithNoUnlayeredHasNoAdvisory`. Amending `PGRVerdict` was
forbidden in E10-C04 (frozen E02 surface).

**To rule:** (a) **advisory-on-green-only** — accept the implemented behavior as
the permanent contract; amend §4.2 step 4's "every report" wording to "every
**clean** report" at the owner's next spec pass (a one-line erratum, the B-19
pattern). No code or surface change. **[implemented]** · (b) **amend the frozen
E02 `PGRVerdict`** with a `redFindings:advisories:` constructor (and have the
check carry the advisory on red verdicts too), so the advisory truly rides
every report as §4.2 step 4 literally reads — a decision-sheet amendment to a
frozen surface, a follow-on chunk, and a re-freeze.

**Recommendation (orchestrator-relayed, implementer concurring):** (a). The
`#unlayered` advisory is a *completeness* note — "these client packages sit
outside the map, unjudged"; on a red verdict the report already carries the
blocking findings, and the unjudged-packages note is strictly less urgent than
a live violation, so green-only loss is immaterial. (b) reopens a frozen E02
surface and adds a constructor the rest of the framework does not need, for a
note that only matters on the clean path. The `redFindings:advisories:` gap is
recorded either way.

**Impact / blocking:** none — E10-C04 is accepted and green with the
conservative arm; the epic proceeds. This is an owner-pending wording/surface
question, not a gate on any E10 chunk.

**Status:** **RULED — D-80, option (a)** (owner word 2026-07-27):
advisory-on-green-only is the permanent contract; §4.2 step 4 erratum landed
under D-80 ("every report" → "every clean report").

## Q-38 · The envelope-parameter seam: how `#src` (and the baseline inventory) reach the kit for `PCKSrcInventoryCheck`

**Filed by:** the E11 cut (Prompt 4, 2026-07-27) · **Status: RULED — D-81**
(owner words 2026-07-27): recommendation (a) **VETOED** — *"it means changing
api every time something needs something. We need a more generalized
solution"* — and the generalized shape ruled from the owner's queryable-config
probe: kits query a **read-only environment view with named readers** (a
defined API — `PGRKitEnvironment`, SDK), built by the core, landed additively
beside the frozen three-argument message with a one-time engine probe;
D-53.5 upheld; future published facts = one new reader each, never a new
selector. The option-(a) cut below is superseded (retired to
`.build/superseded/`); E11 re-cuts from D-81.

**The conflict (spec-internal, surfaced by the cut's entry analysis):** §1.5's
architecture row makes `architecture/PCKSrcInventoryCheck` **missing** when the
config declares no `#src` — "an envelope key, §1.1; D-45" — and §7.5's walk
judges directories against "a package the baseline defines." But the kit is the
only party that can answer that missing spec (blocks are opaque to the core,
D-51/D-60), and the frozen E02 kit contract hands kits exactly
`registrationsFrom: block productionPackages: names testsPackages: names` —
never the configuration object (D-53.5). Under the frozen three-argument
handoff the kit can see **neither** the resolved `#src` path **nor** the
baseline's full package inventory (the exempt role is absent). No ruling
settles the seam; `PGRConfiguration>>srcPath`'s accepted comment says only
"E11's src-inventory wiring consumes it."

**To rule:**

- **(a) — recommended, and what the E11 cut builds:** an **additive, opt-in
  extended kit message** beside the frozen contract:
  `registrationsFrom:productionPackages:testsPackages:exemptPackages:srcPath:`
  (the two role-family additions: the resolved exempt package-name list, and
  the resolved-absolute `#src` path String or nil). `PGRRegistry
  fromConfiguration:` probes each kit class with `respondsTo:` — the
  established D-53/D-60 reflective-conformance family, not the banned type
  predicate — and calls the extended form when answered, else the frozen
  three-argument form. `PCKKit` implements the extended form; its frozen
  three-argument message survives byte-compatible as a delegation with
  `exemptPackages: #() srcPath: nil` (identical behavior on every accepted
  input — no accepted block names `PCKSrcInventoryCheck`; scripted sweep in the
  E11 cut). Kits still never receive the configuration object (D-53.5 upheld);
  external kits that consume no envelope parameter implement nothing new (the
  frozen two-message contract remains complete for them). `#src` reaches the
  kit resolved per D-45 ruling 2; the baseline inventory reaches it as
  production ∪ tests ∪ exempt, which **equals** "the packages the baseline
  defines" by D-25's scope law (roles are pairwise disjoint and jointly total
  over the baseline inventory) — the check never asks Metacello at run time.
- **(b)** widen the frozen three-argument signature itself (every kit,
  including every accepted scratch kit, must change). Scripted enumeration:
  **19 committed files** send or implement
  `registrationsFrom:productionPackages:testsPackages:` — a breaking amendment
  with a 19-file consumer table, for a parameter only one kit consumes.
  Recommend against.
- **(c)** hand kits the configuration object. Overrules D-53.5's
  "over-reach is impossible, not caught." Recommend against.

**Consequences if (a) is ratified:** the E02 digest's "the whole contract, two
messages" gains a one-line erratum ("…plus one optional engine-probed extended
message for kits that consume envelope parameters"); guide 3
(`docs/quickstarts/03-build-a-kit.md`) earns a one-sentence completeness note
at the owner's next doc pass (no sample changes — its three-argument teaching
stays correct for kits that consume no envelope parameter); `PGRKit` (the
optional SDK skeleton) stays untouched in v1 — the extended form is documented
kit-author surface, skeleton support is a widening candidate. A future third
envelope parameter re-opens this entry (the D-32 v1-trade pattern: encode the
v1 checks' needs, not a generic protocol).

**Impact / blocking:** blocking for E11-C02/E11-C03 in the sense that a veto
reshapes their seam; not blocking for E11-C01 (the check class is
seam-agnostic) or E11-C04's artifact form (ruled ground, §7.5).
