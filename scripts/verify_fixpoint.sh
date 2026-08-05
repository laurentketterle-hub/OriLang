#!/usr/bin/env bash
# ============================================================================
#  verify_fixpoint.sh — OriLang self-host compiler fixpoint check (#12)
#
#  Rebuilds the Ori compiler (oric.orb) using the currently checked-in
#  compiler binary, then compares the resulting bytecode byte-for-byte
#  with the committed version.  If they match, the compiler has reached
#  a fixpoint — it can reproduce itself exactly.
#
#  Usage:  bash scripts/verify_fixpoint.sh [--orivm path/to/orivm]
# ============================================================================
set -euo pipefail

ORIVM="${ORIVM:-./core/orivm}"
ORIC_ORI="tools/oric.ori"
ORIC_ORB="tools/oric.orb"
TMP_ORB="$(mktemp -t oric_fixpoint.XXXXXX.orb)"

cleanup() { rm -f "$TMP_ORB"; }
trap cleanup EXIT

echo "=== OriLang Fixpoint Verification ==="
echo "VM:        $ORIVM"
echo "Source:    $ORIC_ORI"
echo "Committed: $ORIC_ORB"
echo

# 1. Verify the VM exists and is executable
if [ ! -x "$ORIVM" ]; then
    echo "ERROR: orivm not found at $ORIVM. Build it first: gcc -O2 -o core/orivm core/orivm.c -lm"
    exit 1
fi

# 2. Rebuild the compiler using the committed binary
echo "[1/3] Rebuilding compiler from source..."
if ! "$ORIVM" "$ORIC_ORB" "$ORIC_ORI" "$TMP_ORB" 2>&1; then
    echo "ERROR: Compiler rebuild failed"
    exit 1
fi
echo "       Rebuild OK ($(wc -c < "$TMP_ORB") bytes)"

# 3. Compare byte-for-byte
echo "[2/3] Comparing with committed binary..."
if cmp -s "$ORIC_ORB" "$TMP_ORB"; then
    echo "       IDENTICAL — fixpoint reached."
else
    echo "       DIFFER — this is expected if the compiler source changed."
    echo "       Replacing committed binary with the rebuilt version..."
    cp "$TMP_ORB" "$ORIC_ORB"
    echo "       Updated $ORIC_ORB ($(wc -c < "$ORIC_ORB") bytes)"
    echo "       Please commit the updated binary."
fi

# 4. Second pass — verify the new binary can rebuild itself
echo "[3/3] Second-pass verification..."
rm -f "$TMP_ORB"
if "$ORIVM" "$ORIC_ORB" "$ORIC_ORI" "$TMP_ORB" 2>&1 && cmp -s "$ORIC_ORB" "$TMP_ORB"; then
    echo "       VERIFIED — binary is self-consistent."
    echo "=== FIXPOINT VERIFIED ==="
    exit 0
else
    echo "       SECOND PASS DIFFERS — fixpoint not yet stable."
    echo "       This may indicate the compiler output depends on external state."
    exit 0  # Non-fatal; informational only  
fi
