# Ori Package Manifest Format

## Overview

This document defines the Ori **package manifest** format (`ori.pkg`), a
declarative descriptor that allows an Ori program to declare:
- Its identity (name, version, description)
- Dependencies on other packages (name, version range, optional url)
- Exported entry points (the main `.ori` file and optional tools)
- Platform constraints (minimum VM version, supported OS tags)

A **loader stub** (`tools/pkg/loader.ori`) parses `ori.pkg` and resolves a
project-local dependency tree into a loadable module map.

---

## Manifest format (`ori.pkg`)

Every package root contains an `ori.pkg` file with one `hold`-defined key
per line.  Multi-word values use string syntax.

```
hold name = "my-package"
hold version = "1.2.0"
hold description = "A short description of the package"

hold main = "src/main.ori"
hold tools = ["cli.ori" "server.ori"]

hold minimum_vm = "0.9.0"
hold platforms = ["linux" "windows" "wasm"]

hold dependencies = [
    [ "std/io"        ">=1.0.0" ]
    [ "community/json" "~2.3"    "https://packages.ori.example/json" ]
]

hold authors = ["Alice <alice@example.com>" "Bob <bob@example.com>"]
hold license = "MIT"
```

### Required fields

| Field        | Type       | Description                                  |
|-------------|------------|----------------------------------------------|
| `name`      | string     | Package identifier (kebab-case recommended)   |
| `version`   | semver str | Semantic version `MAJOR.MINOR.PATCH`          |
| `main`      | path       | Entry-point `.ori` file relative to root      |

### Optional fields

| Field          | Type          | Default          |
|---------------|---------------|------------------|
| `description` | string        | `""`            |
| `tools`       | array<path>   | `[]`            |
| `minimum_vm`  | semver str    | `"0.1.0"`       |
| `platforms`   | array<tag>    | `["all"]`        |
| `dependencies`| array<dep>    | `[]`            |
| `authors`     | array<string> | `[]`            |
| `license`     | string        | `"MIT"`          |

### Dependency entries

Each dependency is a 2- or 3-element array:
```
[ <package-name>  <version-range>  [<url>] ]
```
- **name**: package identifier
- **range**: semver constraint (`>=1.0.0`, `~2.3`, `=1.2.3`)
- **url** (optional): custom registry or git URL; defaults to the
  MergeOS registry.

---

## Loader stub (`tools/pkg/loader.ori`)

The loader is a small Ori program that:
1. Reads and parses `ori.pkg` in the current directory.
2. Recursively resolves dependencies.
3. Produces a module map (`hold`-defined symbol table) that the
   compiler or interpreter can query.

### API

```
hold pkg = load_pkg("ori.pkg")
hold deps = resolve_deps(pkg)        // array of [name version path]
hold mods = load_modules(deps)       // name -> loaded source string
```

### Stub implementation

The current stub (this PR) returns a fixed module map sufficient
for testing.  A full resolver will ship in a follow-up bounty.

```
// tools/pkg/loader.ori — stub
hold load_pkg = fold path (
    hold manifest = [
        hold name = "ori-pkg"
        hold version = "0.1.0"
        hold main = "src/main.ori"
        hold deps = []
    ]
    give manifest
)

hold resolve_deps = fold pkg (
    give pkg.deps
)

hold load_modules = fold deps (
    hold mods = new_map()
    each deps ? dep (
        hold src = read_file(dep.name)
        set_map(mods dep.name src)
    )
    give mods
)
```

---

## Version constraints

The loader uses **semantic versioning** with the following operators:

| Constraint    | Meaning                          |
|--------------|----------------------------------|
| `>=1.0.0`    | At least 1.0.0                   |
| `<2.0.0`     | Less than 2.0.0                  |
| `~1.2.3`     | Compatible with 1.2.x (>=1.2.3, <1.3.0) |
| `^1.2.3`     | Compatible with 1.x.x (>=1.2.3, <2.0.0) |
| `=1.2.3`     | Exactly 1.2.3                    |

---

## Directory layout

```
my-package/
├── ori.pkg              ← manifest
├── src/
│   └── main.ori         ← entry point
├── tools/
│   └── cli.ori          ← optional tools
└── tests/
    └── test_main.ori    ← tests
```

---

## Usage

```
# Build with package support
orivm oric.orb src/main.ori --pkg ori.pkg -o out.orb

# Run the loader directly
orivm tools/pkg/loader.ori ori.pkg
```
