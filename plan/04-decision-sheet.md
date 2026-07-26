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
