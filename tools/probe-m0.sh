#!/usr/bin/env bash
# tools/probe-m0.sh — M0 environment probes (E01/C01): D-58 collisions · D-61.b stream
# flush before exit · D-57 verify-regex alternation. Outcomes are recorded in decision-log
# D-63; this harness asserts every expected outcome and exits 0 only if all hold.
# Scratch lives under .build/scratch/ only (D-65).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PHARO="$ROOT/.build/pharo"
VM="$PHARO/vm/Pharo.app/Contents/MacOS/Pharo"
SCRATCH="$ROOT/.build/scratch"
FAILURES=0
pass() { echo "PASS  $1${2:+ $2}"; }
fail() { echo "FAIL  $1${2:+ — $2}"; FAILURES=$((FAILURES + 1)); }

[ -x "$VM" ] || { fail toolchain_present "no VM at $VM (run tools/install.sh)"; exit 1; }
IMAGE="$(ls "$PHARO"/Pharo13.0-*.image 2>/dev/null | head -n 1)"
[ -n "$IMAGE" ] || { fail toolchain_present "no Pharo13.0-*.image in $PHARO"; exit 1; }
rm -rf "$SCRATCH" && mkdir -p "$SCRATCH"
ev() { "$VM" --headless "$IMAGE" eval "$1"; }

echo "== probe 1 · D-58 collisions (stock image) =="
PCK="$(ev "(Smalltalk globals keys select: [:k | k beginsWith: 'PCK']) asSortedCollection asArray")"
TOY="$(ev "(Smalltalk globals keys select: [:k | k beginsWith: 'Toy']) asSortedCollection asArray")"
BOT="$(ev "Smalltalk globals includesKey: #BaselineOfToy")"
echo "PCK -> $PCK · Toy -> $TOY · BaselineOfToy -> $BOT"
[ "$PCK" = "#()" ] && pass probe_collisions_pck_empty || fail probe_collisions_pck_empty "$PCK"
{ [ "$TOY" = "#()" ] && [ "$BOT" = "false" ]; } \
    && pass probe_collisions_toy_empty || fail probe_collisions_toy_empty "Toy=$TOY BaselineOfToy=$BOT"

echo "== probe 2 · D-61.b flush before Smalltalk exit: (arms A-D) =="
sed 's/^Smalltalk exit: 7/Stdio stdout flush. Smalltalk exit: 7/' \
    "$ROOT/plan/probes/m0-flush.st" > "$SCRATCH/m0-flush-flushed.st"
run_arm() { # $1 label · $2 st|eval · $3 script · $4 note
    local out="$SCRATCH/arm-$1.out"
    if [ "$2" = "st" ]; then
        "$VM" --headless "$IMAGE" st "$3" > "$out" 2> "$SCRATCH/arm-$1.err"
    else
        "$VM" --headless "$IMAGE" eval "$(cat "$3")" > "$out" 2> "$SCRATCH/arm-$1.err"
    fi
    ARM_RC=$?
    ARM_BYTES=$(wc -c < "$out" | tr -d ' ')
    ARM_COMPLETE=no
    tail -c 64 "$out" | tr -d '\r\n' | grep -q 'END-OF-REPORT$' \
        && [ "$ARM_BYTES" -ge 100013 ] && ARM_COMPLETE=yes
    echo "arm $1 ($2, $4): exit=$ARM_RC bytes=$ARM_BYTES complete=$ARM_COMPLETE"
}
run_arm A st   "$ROOT/plan/probes/m0-flush.st"  "no flush"; RC_A=$ARM_RC; C_A=$ARM_COMPLETE
run_arm B st   "$SCRATCH/m0-flush-flushed.st"   "flush";    RC_B=$ARM_RC; C_B=$ARM_COMPLETE
run_arm C eval "$ROOT/plan/probes/m0-flush.st"  "no flush"; RC_C=$ARM_RC; C_C=$ARM_COMPLETE
run_arm D eval "$SCRATCH/m0-flush-flushed.st"   "flush";    RC_D=$ARM_RC; C_D=$ARM_COMPLETE
[ "$RC_A$RC_B$RC_C$RC_D" = "7777" ] && pass probe_flush_exit_code_preserved \
    || fail probe_flush_exit_code_preserved "A=$RC_A B=$RC_B C=$RC_C D=$RC_D"
{ [ "$C_B" = "yes" ] && [ "$C_D" = "yes" ]; } \
    && pass probe_flush_output_complete "(record: A=$C_A C=$C_C; B/D asserted)" \
    || fail probe_flush_output_complete "B=$C_B D=$C_D"

echo "== probe 3 · D-57 verify-regex alternation (scratch image copy) =="
cp "$IMAGE" "$SCRATCH/probe.image"
cp "${IMAGE%.image}.changes" "$SCRATCH/probe.changes"
for s in "$PHARO"/*.sources; do ln -sf "$s" "$SCRATCH/"; done
"$VM" --headless "$SCRATCH/probe.image" st "$ROOT/plan/probes/m0-regex-setup.st" \
    > "$SCRATCH/regex-setup.out" 2>&1
SETUP_RC=$?
"$VM" --headless "$SCRATCH/probe.image" test --fail-on-failure \
    "(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*" > "$SCRATCH/regex-run.out" 2>&1
RUN_RC=$?
RUNS=$(grep -Eo '[0-9]+ run' "$SCRATCH/regex-run.out" | awk '{s += $1} END {print s + 0}')
echo "setup exit=$SETUP_RC · test exit=$RUN_RC · total tests run=$RUNS"
sed 's/^/  | /' "$SCRATCH/regex-run.out"
{ [ "$RUN_RC" -eq 0 ] && [ "$RUNS" -eq 2 ] && ! grep -q "Gamma" "$SCRATCH/regex-run.out"; } \
    && pass probe_regex_alternation_two_tests \
    || fail probe_regex_alternation_two_tests "setup=$SETUP_RC exit=$RUN_RC runs=$RUNS"

echo "----"
[ "$FAILURES" -eq 0 ] && { echo "M0 probes: ALL PASS"; exit 0; }
echo "M0 probes: $FAILURES FAILURE(S)"; exit 1
