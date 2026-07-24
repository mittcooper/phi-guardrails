# C05 · Checksum-pinned toolchain install (D-66)      [E02 · depends: — · parallel: yes]

GOAL      Pin `tools/install.sh`'s two toolchain downloads by SHA-256 so a drifted
          build fails loudly at install time — never a silent install of a build the
          spelling inventory was not verified on.

TRACE     D-66 (B-10 ruled — the binding ruling this chunk implements) · D-63
          (toolchain record: the pin target build) · D-31.a/D-65 (install recipe,
          `tools/` + `.build/` locations) · constitution §2 mutation discipline
          (repo build infrastructure sits outside the product write boundary — Q-30
          ruling; this chunk touches `tools/` only).

## CONTEXT DIGEST

**The ruling (D-66, verbatim substance):** pin the D-31.a toolchain downloads by
checksum. The pin target is the build actually installed and re-verified green —
**`4f7563dfe5`** (`Pharo-13.1.0+SNAPSHOT.build.745`, D-63's toolchain record) — and
`tools/install.sh` must **fail loudly on mismatch**, never silently install a drifted
build. (An archived copy of the artifacts remains open as a stronger later form — not
ruled, not this chunk.)

**Why (D-63's risk line):** the `get-files/130` download channel demonstrably drifts —
it served `4f7563dfe5`, a 13.1-series snapshot under the Pharo13.0 name, not the
`4c3e4714cc` build the D-15/D-25.a spelling inventory was first verified on. Every
spelling was re-executed green on `4f7563dfe5`, so *that* build is the pin target;
any future drift must be a loud stop, not a quiet re-verification burden.

**The current script (committed at `tools/install.sh`), verbatim:**

```bash
#!/usr/bin/env bash
# tools/install.sh — pinned D-31.a Pharo 13 headless toolchain into .build/pharo/ (D-65).
# Idempotent: downloads and extractions already present are skipped; safe to re-run.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$ROOT/.build/pharo"
mkdir -p "$DIR"
cd "$DIR"

[ -f image.zip ] || curl -sSLo image.zip https://files.pharo.org/get-files/130/pharoImage-arm64.zip
[ -f vm.zip ]    || curl -sSLo vm.zip    https://files.pharo.org/get-files/130/pharo-vm-Darwin-arm64-stable.zip
ls Pharo13.0-*.image >/dev/null 2>&1 || unzip -oq image.zip
if [ ! -x vm/Pharo.app/Contents/MacOS/Pharo ]; then
    unzip -oq vm.zip -d vm
    xattr -dr com.apple.quarantine vm || true
fi

VM="$DIR/vm/Pharo.app/Contents/MacOS/Pharo"
IMAGE="$(ls "$DIR"/Pharo13.0-*.image | head -n 1)"
SMOKE="$("$VM" --headless "$IMAGE" eval "3 + 4")"
[ "$SMOKE" = "7" ] || { echo "FAIL smoke eval: got '$SMOKE', expected 7" >&2; exit 1; }
echo "smoke eval: 3 + 4 -> $SMOKE"
echo "-- toolchain inventory ($DIR) --"
echo "vm:      $VM"
echo "image:   $(basename "$IMAGE")"
echo "version: $("$VM" --headless "$IMAGE" eval "SystemVersion current")"
ls "$DIR"
```

**Required behavior after this chunk:**

1. Two pinned SHA-256 constants live at the top of the script (one per zip), each
   with a comment citing D-66 and the pin-target build `4f7563dfe5`.
2. **Every run verifies both checksums** — a fresh download and an already-present
   file alike (the idempotent re-run re-verifies; "present" is no longer "trusted").
3. On mismatch: print the file name, the expected checksum, and the actual checksum,
   and exit 1 **before any extraction** — the drifted zip is left in place for
   inspection, never unpacked.
4. On match: one line per zip confirming verification, then the existing flow
   unchanged (extraction guards, smoke eval, inventory print).

**Obtaining the pin values (do this first, it is the chunk's ground truth):** the
zips already at `.build/pharo/` are the verified build. Confirm before pinning:
`bash tools/install.sh` must print a `version:` line containing `4f7563dfe5`. Then
`shasum -a 256 .build/pharo/image.zip .build/pharo/vm.zip` — those two hex values are
the constants. If either zip is absent or the version line does not carry
`4f7563dfe5`, **stop and report** (that is live drift — D-63's suspect-drift-first
recommendation; a decision-sheet question, not your call).

**Tooling constraint:** `shasum -a 256` (present on macOS/darwin, this repo's
platform) — no new dependency (constitution §3 forbids adding one).

## DELIVERABLES

- `tools/install.sh` — modified in place. **Nothing else** (no product code, no other
  scripts, no `plan/` edits).
- LOC budget: target 20 changed / ceiling 40. Shell only — no SUnit tests; the
  VERIFY arms below are this chunk's test.

## TESTS FIRST

Shell arms, run in order (this chunk's contract skeletons — run arm 2 first with the
constants deliberately wrong to watch it "fail", i.e. catch the mismatch, then set
the real constants and run all arms):

- **arm-idempotent-green** — given the verified zips in place / when
  `bash tools/install.sh` runs twice / then both runs exit 0 and both print the two
  checksum-verified lines (present files are re-verified, not skipped).
- **arm-tamper-fails-loudly** — given a corrupted `image.zip` (append bytes to a
  backed-up copy) / when the script runs / then it exits nonzero, names `image.zip`,
  prints expected and actual checksums, and has extracted nothing new.
- **arm-restore-green** — given the original zip restored / when the script runs /
  then exit 0, `version:` line still contains `4f7563dfe5`.

## VERIFY

```
bash tools/install.sh && bash tools/install.sh          # arm 1: both exit 0, checksum lines printed
cp .build/pharo/image.zip .build/pharo/image.zip.bak
printf 'drift' >> .build/pharo/image.zip
if bash tools/install.sh; then echo "TAMPER ARM FAILED"; exit 1; fi   # arm 2: nonzero, names file + both sums
mv .build/pharo/image.zip.bak .build/pharo/image.zip
bash tools/install.sh                                   # arm 3: green again
bash tools/build-image.sh && bash tools/verify.sh       # regression guard: exit 0, 5 smoke tests run
```

Expected: arms 1 and 3 exit 0; arm 2 exits nonzero with the loud message; the verify
sweep stays green (`5 run, 5 passes, 0 failures, 0 errors.` from
`PGRBaselineSmokeTest` — or more tests if SDK chunks have landed first).

OUT OF SCOPE
- Archiving the artifacts elsewhere (D-66 leaves it open — not ruled, do not build it).
- Pinning image *filenames*, changing download URLs, or touching
  `tools/build-image.sh` / `tools/verify.sh` / `tools/probe-m0.sh`.
- Any `src/` or `plan/` change; any new tool or dependency.

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` (D-67; check
          `git status --porcelain` by eye until C06's `tools/precheck.sh` exists).
          Postcondition: exactly `tools/install.sh`, committed as one commit
          `C05: checksum-pinned toolchain install (D-66)` before reporting for
          review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · the two pinned checksums + the `version:` line
  proving the pin target · arm outputs (1–3 + regression) ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
