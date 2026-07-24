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
