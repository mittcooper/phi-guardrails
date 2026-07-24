#!/usr/bin/env bash
# tools/build-image.sh — C02: build the work image (D-60.a local form): copy the pristine
# C01 image, Metacello-load group 'CI' from the committed local Tonel (src/), save.
# Produces .build/work/phi.image (D-65 location); the load + save spelling as executed
# here is the row recorded in decision-log D-63.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PHARO="$ROOT/.build/pharo"
VM="$PHARO/vm/Pharo.app/Contents/MacOS/Pharo"
WORK="$ROOT/.build/work"
[ -x "$VM" ] || { echo "no VM at $VM (run tools/install.sh)" >&2; exit 1; }
IMAGE="$(ls "$PHARO"/Pharo13.0-*.image 2>/dev/null | head -n 1)"
[ -n "$IMAGE" ] || { echo "no Pharo13.0-*.image in $PHARO (run tools/install.sh)" >&2; exit 1; }
rm -rf "$WORK" && mkdir -p "$WORK"
cp "$IMAGE" "$WORK/phi.image"
cp "${IMAGE%.image}.changes" "$WORK/phi.changes"
for s in "$PHARO"/*.sources; do ln -sf "$s" "$WORK/"; done
"$VM" --headless "$WORK/phi.image" eval \
    "Metacello new baseline: 'PhiGuardrails'; repository: 'tonel://$ROOT/src'; load: 'CI'. Smalltalk snapshot: true andQuit: true"
echo "work image built: $WORK/phi.image (group 'CI' from tonel://$ROOT/src)"
