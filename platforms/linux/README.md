# Ori Linux Platform

This folder contains the Linux bundle host files for Ori apps.

`ori build <project>` for `platform: linux` emits:

```text
build/linux/<name>/
  app.orb
  orivm
  run.sh
```

When built on Linux, `orivm` is the native VM from the current toolchain. When
packaged from another host, `core/orivm` must already be a Linux binary.

## Smoke Test

Run the automated smoke test to verify your Linux OriLang installation:

```bash
sh platforms/linux/smoke_test.sh
```

The smoke test validates:
- VM binary (core/orivm) exists and is executable
- Toolchain images (tools/ori.orb, tools/oric.orb) are present
- ori CLI builds successfully
- ori doctor runs without errors
- Sample compilation (ori build) works
- Sample execution (ori run) produces output
