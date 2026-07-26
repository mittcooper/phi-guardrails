#!/usr/bin/env bash
# guardrails.sh <config-path> — the headless gate; exit 0 = every registered check ran green
"$PHARO_VM" --headless "$IMAGE" eval "Smalltalk exit: (PGRGate runHeadless: '$1')"
code=$?
case "$code" in
  0|1|2) exit "$code" ;;
  *) echo "guardrails: gate did not run to a verdict (exit $code)" >&2; exit 3 ;;
esac
