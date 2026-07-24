#!/usr/bin/env bash
# tools/verify.sh — C02: the pack §6 verify command against the work image, plus the
# D-15 zero-match guard: a regex matching zero packages exits 0, so the script also
# asserts the run count and that each of the 5 smoke tests actually ran. Output format
# pinned from the live runner: per-package "N run, N passes, 0 failures, 0 errors."
# summaries and one "Class>>#testSelector" line per test.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VM="$ROOT/.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo"
WORK="$ROOT/.build/work"
OUT="$WORK/verify.out"
[ -x "$VM" ] || { echo "no VM at $VM (run tools/install.sh)" >&2; exit 1; }
[ -f "$WORK/phi.image" ] || { echo "no work image (run tools/build-image.sh)" >&2; exit 1; }
"$VM" --headless "$WORK/phi.image" test --fail-on-failure \
    "(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*" > "$OUT" 2>&1
RC=$?
cat "$OUT"
RUNS=$(grep -Eo '[0-9]+ run,' "$OUT" | awk '{s += $1} END {print s + 0}')
FAILED=0
[ "$RC" -eq 0 ] || { echo "VERIFY FAIL: runner exit $RC"; FAILED=1; }
[ "$RUNS" -ge 5 ] || { echo "VERIFY FAIL: $RUNS tests run, expected >= 5 (D-15 zero-match trap)"; FAILED=1; }
for t in testBaselineClassIsLoadable testGroupTreeMatchesSpec \
         testRoleGroupsExpandExactlyAndDisjointly testCICompositeCoversEverything \
         testCompositeGroupsExpandExactly; do
    grep -q "PGRBaselineSmokeTest>>#$t" "$OUT" \
        || { echo "VERIFY FAIL: smoke test $t did not run"; FAILED=1; }
done
[ "$FAILED" -eq 0 ] && { echo "VERIFY PASS: exit 0, $RUNS run, all 5 smoke tests present"; exit 0; }
exit 1
