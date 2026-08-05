#!/usr/bin/env sh
# OriLang Linux Platform Smoke Test
# Validates: orivm, ori toolchain, sample compilation and execution
set -eu

ok(){ printf 'PASS %s
' "$1"; }
fail(){ printf 'FAIL %s
' "$1"; exit 1; }

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ORI_HOME=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
export ORI_HOME

echo '=== OriLang Linux Smoke Test ==='
echo "ORI_HOME=$ORI_HOME"

[ -x "$ORI_HOME/core/orivm" ] && ok 'orivm binary found' || fail 'orivm binary missing'

[ -f "$ORI_HOME/tools/ori.orb" ] && ok 'ori.orb found' || fail 'ori.orb missing'
[ -f "$ORI_HOME/tools/oric.orb" ] && ok 'oric.orb found' || fail 'oric.orb missing'

if [ ! -x "$ORI_HOME/ori" ]; then
    echo '  Building ori CLI...'
    (cd "$ORI_HOME" && sh build.sh) || fail 'build.sh failed'
fi
[ -x "$ORI_HOME/ori" ] && ok 'ori CLI built' || fail 'ori CLI not built'

"$ORI_HOME/ori" doctor && ok 'ori doctor runs' || fail 'ori doctor failed'

SAMPLE="$ORI_HOME/samples/beginner_01_hello.ori"
[ -f "$SAMPLE" ] || fail 'hello sample not found'
"$ORI_HOME/ori" build "$SAMPLE" && ok 'ori build hello.ori' || fail 'ori build hello.ori failed'

OUT=$( "$ORI_HOME/ori" run "$SAMPLE" ) && ok 'ori run hello.ori' || fail 'ori run hello.ori failed'
echo "  Output: $OUT"

FIB="$ORI_HOME/samples/beginner_40_multiply_table.ori"
[ -f "$FIB" ] && "$ORI_HOME/ori" run "$FIB" && ok 'ori run multiply_table.ori' || fail 'ori run multiply_table.ori failed'

echo ''
echo 'All smoke tests passed!'
