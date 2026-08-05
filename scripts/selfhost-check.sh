#!/usr/bin/env bash
# =============================================================================
#  selfhost-check.sh — OriLang compiler fixpoint verification
#
#  Validates that the Ori compiler (oric.orb) is truly self-hosting by
#  compiling itself twice and checking that the output is byte-identical
#  (fixpoint reached).
#
#  Usage:   bash scripts/selfhost-check.sh
#  Env vars: CC          C compiler (default: cc or gcc)
#            VERBOSE=1   print extra diagnostics
# =============================================================================
set -euo pipefail

# ---- resolve project root ------------------------------------------------
ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd -P)"
cd "$ROOT"

# ---- tooling --------------------------------------------------------------
CC="${CC:-cc}"
# Prefer gcc if cc not available
if ! command -v "$CC" &>/dev/null; then
  if command -v gcc &>/dev/null; then CC=gcc; fi
fi

VM_EXE="$ROOT/core/orivm"
COMPILER_SRC="$ROOT/tools/oric.ori"
COMPILER_ORB="$ROOT/tools/oric.orb"

TMPDIR="${TMPDIR:-/tmp}"
BOOTSTRAP_ORB="$TMPDIR/oric.orb.bootstrap.$$"
FIXPOINT_ORB="$TMPDIR/oric.orb.fixpoint.$$"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[selfhost-check]${NC} $*"; }
warn()  { echo -e "${YELLOW}[selfhost-check]${NC} $*"; }
fail()  { echo -e "${RED}[selfhost-check] FAIL:${NC} $*"; }

cleanup() {
  rm -f "$BOOTSTRAP_ORB" "$FIXPOINT_ORB"
}
trap cleanup EXIT

# ---- step 1: build the C VM -----------------------------------------------
info "Building core/orivm from C sources..."
if ! command -v "$CC" &>/dev/null; then
  fail "C compiler '$CC' not found in PATH."
  fail "Install gcc/clang or set CC=... to your compiler."
  exit 1
fi

"$CC" -O2 -o "$VM_EXE" "$ROOT/core/orivm.c" -lm
info "VM built: $VM_EXE"

# ---- step 2: bootstrap — compile oric.ori with the existing oric.orb ------
info "Bootstrap: compiling oric.ori → oric.orb.bootstrap (using existing oric.orb)"
ORI_HOME="$ROOT" ORI_WIN="" "$VM_EXE" "$COMPILER_ORB" "$COMPILER_SRC" "$BOOTSTRAP_ORB"

if [[ ! -f "$BOOTSTRAP_ORB" ]]; then
  fail "Bootstrap compilation failed — no output file produced."
  exit 1
fi
BSIZE=$(wc -c < "$BOOTSTRAP_ORB")
info "Bootstrap produced: $BOOTSTRAP_ORB (${BSIZE} bytes)"

# ---- step 3: fixpoint — compile oric.ori with the bootstrap compiler ------
info "Fixpoint : compiling oric.ori → oric.orb.fixpoint (using bootstrap compiler)"
ORI_HOME="$ROOT" ORI_WIN="" "$VM_EXE" "$BOOTSTRAP_ORB" "$COMPILER_SRC" "$FIXPOINT_ORB"

if [[ ! -f "$FIXPOINT_ORB" ]]; then
  fail "Fixpoint compilation failed — no output file produced."
  exit 1
fi
FSIZE=$(wc -c < "$FIXPOINT_ORB")
info "Fixpoint produced: $FIXPOINT_ORB (${FSIZE} bytes)"

# ---- step 4: compare byte-by-byte -----------------------------------------
info "Comparing bootstrap ↔ fixpoint byte-by-byte..."

if cmp -s "$BOOTSTRAP_ORB" "$FIXPOINT_ORB"; then
  echo ""
  echo "  ╔══════════════════════════════════════════════════╗"
  echo "  ║  ✅  SELHOST FIXPOINT REACHED!                  ║"
  echo "  ║                                                  ║"
  printf "  ║  bootstrap == fixpoint  (%d bytes)             ║\n" "$BSIZE"
  echo "  ║  The compiler compiles itself identically.      ║"
  echo "  ╚══════════════════════════════════════════════════╝"
  echo ""
  exit 0
fi

# ---- differences found — document them ------------------------------------
fail "Bootstrap and fixpoint differ!"
echo ""

# Show sizes
echo "  bootstrap size : $BSIZE bytes"
echo "  fixpoint  size : $FSIZE bytes"
echo ""

# Show first differing byte offset
DIFF_BYTE=$(cmp -l "$BOOTSTRAP_ORB" "$FIXPOINT_ORB" | head -1 || true)
if [[ -n "$DIFF_BYTE" ]]; then
  echo "  First differing byte:"
  echo "  $DIFF_BYTE"
  echo "  (format: byte_offset  bootstrap_octal  fixpoint_octal)"
  echo ""
fi

# Count differing bytes
DIFF_COUNT=$(cmp -l "$BOOTSTRAP_ORB" "$FIXPOINT_ORB" 2>/dev/null | wc -l || echo "?")
echo "  Total differing bytes: $DIFF_COUNT"
echo ""

# Optional verbose hex dump of first few differences
if [[ "${VERBOSE:-0}" = "1" ]]; then
  echo "  First 20 differing bytes (offset: bootstrap → fixpoint):"
  cmp -l "$BOOTSTRAP_ORB" "$FIXPOINT_ORB" 2>/dev/null | head -20 | while read -r off b1 b2; do
    printf "    offset %6d : %3o → %3o\n" "$off" "$b1" "$b2"
  done
  echo ""
fi

echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║  ❌  SELHOST FIXPOINT NOT REACHED               ║"
echo "  ║                                                  ║"
echo "  ║  The compiler is NOT byte-identical after        ║"
echo "  ║  recompilation — the self-hosting loop has       ║"
echo "  ║  not converged.                                  ║"
echo "  ║  See details above.                              ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
exit 1
