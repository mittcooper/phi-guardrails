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
