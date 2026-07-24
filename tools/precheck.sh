#!/usr/bin/env bash
# tools/precheck.sh — chunk-boundary commit-hygiene precondition (D-67, C06).
# Passes only when the working tree is clean modulo plan/ledger.md (the
# orchestrator's one mutable file). Untracked files count as dirt (B-12):
# `git status --porcelain` lists them as `?? path`, so they fail like any other.
# Prints the HEAD short sha on pass so each pick is recorded against a commit.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

STATUS="$(git -C "$ROOT" status --porcelain)" \
    || { echo "PRECHECK FAIL — git status failed" >&2; exit 1; }

# Porcelain v1: two-char XY status, one space, then the path — the path field
# starts at column 4. Exempt exactly plan/ledger.md, whatever its XY status.
DIRT="$(printf '%s\n' "$STATUS" | awk 'NF && substr($0, 4) != "plan/ledger.md"')"

if [ -z "$DIRT" ]; then
    echo "PRECHECK PASS @ $(git -C "$ROOT" rev-parse --short HEAD)"
    exit 0
else
    echo "PRECHECK FAIL — uncommitted state:"
    printf '%s\n' "$DIRT"
    exit 1
fi
