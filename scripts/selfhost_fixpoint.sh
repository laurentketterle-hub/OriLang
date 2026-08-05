#!/usr/bin/env sh
# Self-host compiler fixpoint check
# Rebuilds tools/oric.orb from tools/oric.ori using the current compiler
# and verifies byte identity (fixpoint property).
#
# Usage:  sh scripts/selfhost_fixpoint.sh
#
# Exit 0 if the rebuilt compiler is byte-identical to the committed one.
# Exit 1 on mismatch or build failure.

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CC=${CC:-cc}
NEW_ORB="$ROOT/tools/oric_new.orb"
ORIG_ORB="$ROOT/tools/oric.orb"

echo "[fixpoint] building core/orivm ..."
"$CC" -O2 -o "$ROOT/core/orivm" "$ROOT/core/orivm.c" -lm

echo "[fixpoint] rebuilding tools/oric.orb from tools/oric.ori ..."
ORI_HOME="$ROOT" ORI_WIN="" "$ROOT/core/orivm" "$ORIG_ORB" "$ROOT/tools/oric.ori" "$NEW_ORB"

if ! cmp -s "$ORIG_ORB" "$NEW_ORB"; then
    SIZE_ORIG=$(wc -c < "$ORIG_ORB" | tr -d ' ')
    SIZE_NEW=$(wc -c < "$NEW_ORB" | tr -d ' ')
    echo "[fixpoint] MISMATCH: original=${SIZE_ORIG} bytes, rebuilt=${SIZE_NEW} bytes"
    # For CI, output a small hex diff summary
    if command -v xxd >/dev/null 2>&1; then
        diff <(xxd "$ORIG_ORB") <(xxd "$NEW_ORB") | head -20
    elif command -v od >/dev/null 2>&1; then
        diff <(od -A x -t x1z "$ORIG_ORB") <(od -A x -t x1z "$NEW_ORB") | head -20
    fi
    rm -f "$NEW_ORB"
    exit 1
fi

echo "[fixpoint] PASS: rebuilt oric.orb is byte-identical"
rm -f "$NEW_ORB"
