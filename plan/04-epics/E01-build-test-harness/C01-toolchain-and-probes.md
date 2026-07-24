# C01 · Permanent toolchain + M0 environment probes        [E01 · depends: — · parallel: no]

GOAL      Install the D-31.a Pharo 13 headless toolchain permanently at the D-65
          location (`.build/pharo/`, git-ignored) and execute the three environment
          probes that need no project code — D-58 collisions, D-61.b stream flush,
          D-57 regex dialect — recording every outcome as decision-log entry **D-63**.

TRACE     R-39 (probe discipline) · roadmap E01 probe list (D-57 · D-58 · D-61.b) ·
          D-31.a (toolchain) · D-15 (prior verified spellings) · D-65 (Q-30 ruled:
          committed harness scripts in `tools/`, uncommitted build state in `.build/`).

## CONTEXT DIGEST

**What exists:** the repo is planning-corpus only — `src/` is empty, there is no
toolchain, no `.gitignore`, no code. `plan/probes/` exists (one old probe file).
The decision log ends **D-63 (a one-line reservation stub) · D-64 · D-65**: the
stub reserves the number for the M0 probe record you create — replace nothing;
append your full **D-63** entry after D-65, citing the stub.

**Constitution rules that bite here:**
- *Probe discipline (P5/R-39):* no design or code statement rests on an unverified
  Pharo spelling; a probe's job is to execute the question and record what actually
  happened, including spellings that had to be adjusted to work.
- *Write boundary (constitution §2, as amended with D-65):* the boundary governs the
  product at run time, not repo build infrastructure. Committed harness scripts live
  in `tools/` (repo root); **all** uncommitted build state lives in the single
  git-ignored `.build/` — toolchain at `.build/pharo/` (version-free path), work
  images at `.build/work/`, probe scratch at `.build/scratch/`; `.gitignore` is git
  metadata. This chunk writes only `tools/`, `plan/probes/`, the decision-log
  append, `.gitignore`, and the ignored `.build/`.
- *Decisions:* anything a probe surfaces that the spec doesn't settle → recommend in
  the D-63 entry or file a numbered question on `plan/04-decision-sheet.md`; never
  rule silently.

**The D-31.a toolchain (install exactly this recipe, pinned — target directory per
D-65):**

```bash
mkdir -p .build/pharo && cd .build/pharo
curl -sSLo image.zip https://files.pharo.org/get-files/130/pharoImage-arm64.zip
curl -sSLo vm.zip https://files.pharo.org/get-files/130/pharo-vm-Darwin-arm64-stable.zip
unzip -oq image.zip && unzip -oq vm.zip -d vm && xattr -dr com.apple.quarantine vm
./vm/Pharo.app/Contents/MacOS/Pharo --headless Pharo13.0-*.image eval "3 + 4"   # → 7
# scripts:  ... st probe.st        · eval "expr"
# verify:   ... test --fail-on-failure "<regex>"   (green→0, red→1, zero-match→0!)
```

The probe sessions used image build `Pharo13.0-SNAPSHOT-64bit-4c3e4714cc` (2026-07-09).
If the download now serves a different build, record the actual build id in D-63 — the
D-15/D-25.a spelling inventory was verified on 4c3e4714cc, so a build drift is a noted
risk line, not a failure.

**Prior verified facts you rely on (D-15, do not re-probe):** `Smalltalk exit:` and
`Stdio stdout` exist; `test --fail-on-failure` exits 0 green / 1 red / **0 on a regex
matching zero packages** (the silence hole); `matchesRegex:` is full-match; zero
loaded classes start with `PGR` in the stock image. Scratch **class creation is not
in the verified inventory** — the one on-disk precedent (D-15.b's probe,
`plan/probes/trait-attribution-probe.st`) used the Pharo 13 fluid form
(`Object << #Name … package: '…'; install`, then `compile:` on the result); the
spelling probe 3 actually uses is itself probe output, recorded in its D-63 row.

**The three probes (outcomes go in D-63, each with the exact spelling that ran):**

1. **D-58 · Collision probe.** In the *stock* image, confirm each is absent:
   classes/globals named with prefix `PCK`, prefix `Toy`, and the exact name
   `BaselineOfToy`. Expected: all collision-free (analogue of D-15's `PGR` survey).
   Suggested query shape (adjust freely, record what ran):
   `Smalltalk globals keys select: [:k | k beginsWith: 'PCK']` → empty ·
   same for `'Toy'` (note any hits and whether they are classes) ·
   `Smalltalk globals includesKey: #BaselineOfToy` → false.

2. **D-61.b · Stream flush before `Smalltalk exit:`.** The question E05 consumes:
   does stdout output written just before `Smalltalk exit:` reach the caller intact,
   and is an explicit `flush` required? Probe script `plan/probes/m0-flush.st`:

   ```smalltalk
   | payload |
   payload := String new: 100000 withAll: $x.
   Stdio stdout nextPutAll: payload; nextPutAll: 'END-OF-REPORT'; lf.
   "arm B adds:  Stdio stdout flush.  here"
   Smalltalk exit: 7
   ```

   Run **four arms** from the shell, each asserting (i) exit code is exactly 7 and
   (ii) captured stdout ends with `END-OF-REPORT`: arm A `st` without flush · arm B
   `st` with flush · arm C the same expression inline via `eval` without flush ·
   arm D `eval` with flush. The `eval` arms matter because `guardrails.sh` (§7.3)
   invokes via `eval`. Record per-arm results; if the no-flush arms lose output,
   D-63 states "flush is mandatory" — that sentence is what E05 builds on.

3. **D-57 · Verify-command alternation regex.** The question: does the test CLI's
   regex dialect honor `"(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*"` — both branches,
   full-match. Recipe: on a scratch *copy* of the stock image, create (in-image, via
   script `plan/probes/m0-regex-setup.st`) three trivial `TestCase` subclasses, one
   passing test method each — start from the D-15.b fluid form
   (`TestCase << #ProbeAlphaTest … package: '…'; install`, then `compile:` a
   `testTruth` asserting `3 + 4 = 7`); the class-creation spelling that works is
   part of this probe's D-63 record — in
   packages `Phi-Guardrails-Tests-ProbeAlpha`, `Phi-Coding-Kit-Tests-ProbeBeta`,
   and `XPhi-Guardrails-Tests-Gamma`; save the image (record the save spelling that
   worked, e.g. `Smalltalk saveAs:`/`saveSession`); then run

   ```
   <vm> <scratch-image> test --fail-on-failure "(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*"
   ```

   Expected: exit 0, and the runner's output shows **exactly 2 tests ran** — one per
   matching family, with the `XPhi-…` package excluded (full-match, D-15). Record the
   output line proving the count. If alternation is *not* honored, stop the probe,
   record the failing behavior and every alternative spelling tried (e.g. two
   separate runs) in D-63, and file a decision-sheet question — the pack's verify
   command itself is at stake; do not silently substitute a different command.

**The probe harness** `tools/probe-m0.sh`: one script that runs probes 1–3
end-to-end against the installed toolchain, asserts every expected outcome with plain
shell checks, and exits 0 only if all hold. Scratch images/outputs go under
`.build/scratch/` (git-ignored) — never under `plan/` or `src/`.

## DELIVERABLES

- `.gitignore` — new; one line, ignoring `.build/` (and nothing else yet — D-65).
- `tools/install.sh` — new; the pinned D-31.a install into `.build/pharo/`,
  **idempotent** (safe to re-run; skips downloads already present), ending with the
  `3 + 4` smoke eval and a printed VM/image inventory.
- `tools/probe-m0.sh` — new; the harness above.
- `plan/probes/m0-flush.st`, `plan/probes/m0-regex-setup.st` — new; probe sources.
- `plan/decision-log.md` — **append only**: new entry `## D-63 · M0 probe record
  (E01)` following the log's house format (`From:` E01/C01 execution · `Ruled by:`
  live-image evidence, recorded by the implementer · date), containing a results
  table for probes 1–3 (question · spelling as executed · outcome) and the actual
  image build id. Leave a stated stub line for the two rows later chunks append
  (C02: local load expression · C04: hosted load expression + real-family regex
  confirmation) and the note "entry completes at E01 acceptance".
- LOC budget: target 120 / ceiling 300 (shell + probe scripts; no product code).

## TESTS FIRST

No SUnit tests exist at M0-start; the probes **are** this chunk's tests, and
`probe-m0.sh` is their runner. Its named assertions (write these as labeled shell
checks; watch the harness fail before the toolchain/probes make it pass):

- `probe_collisions_pck_empty` — given the stock image / when scanning globals for
  prefix `PCK` / then zero hits.
- `probe_collisions_toy_empty` — same for prefix `Toy` and for `#BaselineOfToy`.
- `probe_flush_exit_code_preserved` — given each of arms A–D / when the snippet
  exits via `Smalltalk exit: 7` / then the shell sees exit 7.
- `probe_flush_output_complete` — given each arm / then captured stdout ends with
  `END-OF-REPORT` (record per-arm pass/fail; arms may legitimately differ — the
  *record* is the deliverable, the harness asserts only that the flush-bearing arms
  B and D are complete).
- `probe_regex_alternation_two_tests` — given the scratch image with the three probe
  packages / when running the verify command's exact regex / then exit 0 and exactly
  2 tests ran.

VERIFY    `bash tools/install.sh && bash tools/probe-m0.sh`
          exits 0 (run install.sh twice — second run must also exit 0, proving
          idempotence). No regression suite exists yet.

OUT OF SCOPE
- Anything under `src/` (C02's), `.smalltalk.ston` / CI workflow (C03's), any GitHub
  interaction (C03's, under D-64's ruled coordinates).
- Editing any existing decision-log entry, spec chapter, or the frozen roadmap.
- Linux/CI toolchain — this chunk installs the *local* (Darwin-arm64) harness only;
  CI fetches its own via smalltalkCI (C03).
- Probing anything already in D-15/D-25.a's verified inventory.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · harness assertion names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
