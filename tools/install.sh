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
