# Package Manifest Format — Design Proposal (Issue #36)

> **Status:** Proposal / Stub  
> **Related issue:** [#36](https://github.com/thanhtrucsolutions/orilang/issues/36)

## 1. Motivation

OriLang currently supports single-entry-point projects via a loose `.meta` file
(see `docs/TOOLCHAIN.md`). As the language grows, projects need **multi-file
packages** with explicit source-file lists, versioned dependencies, and a
well-defined directory layout. This document proposes a **JSON manifest format**
(`manifest.json`) as a structured replacement for `.meta`, and describes how a
new C stub loader (`core/package_loader.c`) will parse it.

## 2. Proposed manifest format (`manifest.json`)

A package root contains a single `manifest.json`. Example:

```json
{
  "name": "my-package",
  "version": "1.2.0",
  "description": "An example multi-file OriLang package",
  "entry": "ori/main.ori",
  "platform": "windows",
  "ui": "window",
  "authors": ["Alice <alice@example.com>"],
  "license": "MIT",
  "sources": [
    "ori/main.ori",
    "ori/utils.ori",
    "ori/math.ori",
    "ori/http.ori"
  ],
  "dependencies": {
    "json-lib": "^2.0.0",
    "http-helpers": ">=1.0.0 <3.0.0"
  },
  "build": {
    "output": "build/app.orb",
    "flags": ["-O2"]
  },
  "scripts": {
    "test": "orivm build/test_runner.orb"
  }
}
```

### 2.1 Fields

| Field          | Type            | Required | Description |
|----------------|-----------------|----------|-------------|
| `name`         | `string`        | yes      | Package identifier (kebab-case, max 64 chars) |
| `version`      | `string`        | yes      | SemVer 2.0 (MAJOR.MINOR.PATCH) |
| `description`  | `string`        | no       | Short human-readable summary |
| `entry`        | `string`        | yes      | Path (relative to package root) of the main .ori file |
| `platform`     | `string`        | no       | Target platform: windows, web, android, linux, macos, ios, etc. |
| `ui`           | `string`        | no       | UI mode: console, window, widget |
| `authors`      | `string[]`      | no       | List of author strings |
| `license`      | `string`        | no       | SPDX identifier (MIT, Apache-2.0, etc.) |
| `sources`      | `string[]`      | yes      | Ordered list of .ori source files (relative paths) |
| `dependencies` | `object`        | no       | Map of package-name to version-spec |
| `build`        | `object`        | no       | Build configuration (output path, compiler flags) |
| `scripts`      | `object`        | no       | Named command scripts (test, lint, etc.) |

### 2.2 Version specification for dependencies

The loader stub supports a minimal version parser:

- **Exact:** `"1.2.3"` -- exact match
- **Caret:** `"^1.2.3"` -- compatible with >=1.2.3 <2.0.0
- **Tilde:** `"~1.2.3"` -- approximately >=1.2.3 <1.3.0
- **GTE:** `">=1.2.3"` -- greater than or equal
- **Range:** `">=1.0.0 <3.0.0"` -- explicit range

## 3. Directory layout for multi-file packages

```
my-package/                    <- package root (contains manifest.json)
├── manifest.json              <- the manifest
├── README.md
├── ori/                       <- OriLang source files
│   ├── main.ori               <- entry point
│   ├── utils.ori
│   ├── math.ori
│   └── http.ori
├── build/                     <- build artifacts (generated)
│   └── app.orb
├── tests/                     <- test files (optional)
│   ├── test_utils.ori
│   └── test_runner.ori
├── assets/                    <- static assets (web/mobile)
│   ├── index.html
│   └── style.css
└── deps/                      <- resolved dependency cache (generated)
    └── packages/
        ├── json-lib/
        │   ├── manifest.json
        │   └── ori/
        └── http-helpers/
            └── ...
```

### 3.1 Conventions

- **`ori/`** is the canonical source directory. All `.ori` files referenced in
  `sources` live here (or in subdirectories of `ori/`).
- **`build/`** is the default output directory (configurable via `build.output`).
- **`deps/`** is the local dependency cache, populated by the future package
  manager (`ori install`). The loader only resolves and validates paths; it
  does not fetch dependencies.
- **`tests/`** contains test `.ori` files.

## 4. Loader stub design (`core/package_loader.c`)

### 4.1 Responsibilities

The loader stub is a **pure C library** (no external JSON parser) that:

1. **Discovers** the package root by walking up from a given file path until it
   finds `manifest.json`.
2. **Parses** the JSON manifest into a C struct (`PackageManifest`).
3. **Resolves** the `sources` array into absolute file paths.
4. **Validates** that all listed source files exist on disk.
5. **Returns** a validated `PackageManifest` struct (or an error).

The stub does **NOT**:
- Execute or compile any code
- Fetch or install dependencies
- Validate version constraints (implementation deferred)

### 4.2 API (see `core/package_loader.h`)

```c
typedef struct {
    char* name;
    char* version;
    char* description;
    char* entry;
    char* platform;
    char* ui;
    int   source_count;
    char** sources;       // resolved absolute paths
    int   dep_count;
    struct { char* name; char* version_spec; }* deps;
    char* build_output;
    char* root_dir;       // absolute path to package root
} PackageManifest;

char* package_find_root(const char* start_path);
PackageManifest* package_load(const char* root_dir, char** err_msg);
void package_free(PackageManifest* m);
char* package_resolve_path(const char* root_dir, const char* relative_path);
void package_print(const PackageManifest* m);
```

### 4.3 JSON parser

The stub includes a **minimal, recursive-descent JSON parser** written from
scratch in C (no external dependencies). It handles:

- Objects, arrays, strings, numbers, booleans (true/false), null
- Unicode escape sequences in strings
- Nested structures up to a configurable depth (default: 32)

The parser is intentionally minimal and does **not** support:
- Streaming/SAX-style parsing
- Duplicate key detection (last key wins)
- Comments (JSON5 / JSONC)

### 4.4 Error handling

- Functions returning pointers return `NULL` on error.
- The `err_msg` out-parameter receives a static string (caller must NOT free it).
- The loader does not call `exit()` -- it returns errors to the caller.

### 4.5 Memory management

- `package_load()` allocates a `PackageManifest` and all its strings/arrays.
- `package_free()` recursively frees everything.
- The caller owns the returned struct.

## 5. Integration with the existing build system

### 5.1 `build.sh` / `build.cmd`

The package loader compiles alongside `orivm.c`:

```sh
cc -O2 -c core/package_loader.c -o core/package_loader.o
cc -O2 -o core/orivm core/orivm.c core/package_loader.o -lm
```

### 5.2 `CMakeLists.txt`

```cmake
add_library(package_loader core/package_loader.c)
target_link_libraries(orivm package_loader)
```

## 6. Future work

- **Dependency resolution:** The `deps/` cache and version-constraint solver.
- **`ori install` command:** Fetch dependencies from a registry.
- **Lock file:** `manifest.lock` recording exact resolved versions.
- **Workspace support:** Root `workspace.json` for monorepos.

## 7. Backward compatibility

The existing `.meta` format remains supported. When `manifest.json` is present,
it takes precedence over `.meta`.

---

*Design document -- v1.0 -- August 2026*
