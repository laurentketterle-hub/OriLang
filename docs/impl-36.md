# Ori Package Manifest — Proposal (#36)

This proposal defines a **package manifest format** (`ori.pkg`) and a **loader stub**
(`tools/pkg/loader.ori`) so Ori projects can declare identity, dependencies, and
entry points in a standard way.

## Manifest format (`ori.pkg`)

A plain-text manifest at the package root. One `hold`-defined key per line.
Multi-word values use string syntax. Lines starting with `//` are comments.

### Required fields

| Field     | Type   | Description                     |
|-----------|--------|---------------------------------|
| `name`    | string | Package identifier (kebab-case) |
| `version` | semver | MAJOR.MINOR.PATCH               |
| `main`    | path   | Entry-point `.ori` from root    |

### Optional fields

| Field          | Type         | Default   |
|----------------|--------------|-----------|
| `description`  | string       | `""`      |
| `tools`        | array\<path\>| `[]`      |
| `minimum_vm`   | semver       | `"0.1.0"` |
| `platforms`    | array\<tag\> | `["all"]` |
| `dependencies` | list\<dep\>  | `[]`      |
| `authors`      | array\<str\> | `[]`      |
| `license`      | string       | `"MIT"`   |

### Dependency entries

Each is a 2- or 3-element list: `[<name> <version-range> [<url>]]`.
- **name**: package identifier
- **range**: semver constraint (`>=1.0.0`, `~2.3`, `=1.2.3`)
- **url** (optional): registry or git URL; defaults to MergeOS registry.

### Version constraints

| Operator  | Meaning                          |
|-----------|----------------------------------|
| `>=1.0.0` | At least 1.0.0                   |
| `<2.0`    | Less than 2.0                    |
| `~1.2.3`  | Compatible with 1.2.x            |
| `^1.2.3`  | Compatible with 1.x.x            |
| `=1.2.3`  | Exactly 1.2.3                    |

## Loader stub (`tools/pkg/loader.ori`)

Reads `ori.pkg`, parses it, resolves dependencies, returns a module map.

```
hold pkg  = load_pkg("ori.pkg")
hold deps = resolve_deps(pkg)
hold mods = load_modules(deps)
```

### Current scope

- Parse `name`, `version`, `main`, `description`, `authors`, `license`.
- Dependency resolution: stub (empty list); full registry in follow-up bounty.
- Module loading: stub map.

## Directory layout

```
my-package/
├── ori.pkg
├── src/main.ori
├── tools/
└── tests/
```

## Usage

```sh
orivm tools/pkg/loader.ori ori.pkg
```
