# impl-12 — Self-host compiler fixpoint CI

## Summary

Issue #12 adds a CI workflow that verifies the Ori compiler (`oric.ori`) is at a
self-hosting **fixpoint**: the compiler, when asked to compile its own source,
produces a bytecode image (`oric1.orb`) that is byte-for-byte identical to the
image produced when *that* image recompiles the same source (`oric2.orb`).

## What "fixpoint" means

```
oric.ori ──[oric.orb]──► oric1.orb
oric.ori ──[oric1.orb]─► oric2.orb
                │
                cmp oric1.orb oric2.orb → must be identical
```

If `oric1.orb ≡ oric2.orb`, the compiler has reached a stable fixed point:
further self-compilation cycles produce the exact same bytecode. This is the
gold-standard proof that the self-hosting chain is **trustworthy**.

## CI workflow (`.github/workflows/ci-12.yml`)

| Step | What it does |
|------|-------------|
| 1. Build C VM | Compile `core/orivm.c` (the bytecode interpreter) |
| 2. Verify seed | Confirm `tools/oric.orb` (bootstrap compiler) exists |
| 3. Stage‑1 | `orivm oric.orb oric.ori oric1.orb` |
| 4. Stage‑2 | `orivm oric1.orb oric.ori oric2.orb` |
| 5. Fixpoint | `cmp -s oric1.orb oric2.orb` — fail if they differ |
| 6. Smoke | Compile a sample `.ori` file with the fixpoint compiler |

The workflow runs on every push/PR to `main` and on any `feat/**` branch.

## Why this matters

- **Trust**: Without a fixpoint test, a compiler bug could silently produce
  slightly different bytecode on each recompilation, eroding reproducibility.
- **Determinism**: Fixpoint == deterministic compilation. Two developers
  building from the same source always get identical `.orb` files.
- **Bootstrap integrity**: Ken Thompson's "Trusting Trust" attack is mitigated
  when the chain closes: source → compiler → bytecode → (same compiler) →
  identical bytecode.

## How to reproduce locally

```sh
sh build.sh                          # build VM + bootstrap ori CLI
cc -O2 -o core/orivm core/orivm.c -lm
core/orivm tools/oric.orb tools/oric.ori /tmp/oric1.orb
core/orivm /tmp/oric1.orb tools/oric.ori /tmp/oric2.orb
cmp /tmp/oric1.orb /tmp/oric2.orb && echo "✅ Fixpoint OK"
```

## References

- [oric.ori](../tools/oric.ori) — self-hosting compiler source
- [orivm.c](../core/orivm.c) — C bytecode VM
- [build.sh](../build.sh) — bootstrap build script
- [ci-12.yml](../.github/workflows/ci-12.yml) — this CI workflow

## Status

- [x] CI workflow created (`.github/workflows/ci-12.yml`)
- [x] Documentation written (`docs/impl-12.md`)
- [ ] PR merged into `ThanhTrucSolutions/OriLang:main`
