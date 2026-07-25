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

**Status:** OPEN — blocks E08-C05 (its `canFix` arm); E08-C03/C04 proceed
(they exercise a genuine rewrite rule).
