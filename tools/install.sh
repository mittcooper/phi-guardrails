#!/usr/bin/env bash
# tools/install.sh — pinned D-31.a Pharo 13 headless toolchain into .build/pharo/ (D-65).
# Idempotent: downloads and extractions already present are skipped; safe to re-run.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$ROOT/.build/pharo"
mkdir -p "$DIR"
cd "$DIR"

# D-66: SHA-256 pins for the verified toolchain build 4f7563dfe5
# (Pharo-13.1.0+SNAPSHOT.build.745, D-63's toolchain record). Drift fails loudly.
IMAGE_SHA256="897668dd548864f74730065de3fa2b1f4b5d3636d4c7d14f91945f0a5ce22590"
VM_SHA256="6f1aa1577615c42205c395b4f39793e97a4402b133e39ca6ad2668c37d492e71"

verify_sha256() { # $1 = file, $2 = expected checksum
    local actual
    actual="$(shasum -a 256 "$1" | awk '{print $1}')"
    if [ "$actual" != "$2" ]; then
        echo "FAIL checksum mismatch (D-66): $1" >&2
        echo "  expected: $2" >&2
        echo "  actual:   $actual" >&2
        echo "  drifted zip left in place for inspection; nothing extracted." >&2
        exit 1
    fi
    echo "checksum verified (D-66): $1"
}

[ -f image.zip ] || curl -sSLo image.zip https://files.pharo.org/get-files/130/pharoImage-arm64.zip
[ -f vm.zip ]    || curl -sSLo vm.zip    https://files.pharo.org/get-files/130/pharo-vm-Darwin-arm64-stable.zip
verify_sha256 image.zip "$IMAGE_SHA256"
verify_sha256 vm.zip    "$VM_SHA256"
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
