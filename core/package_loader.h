// ============================================================================
//  package_loader.h — OriLang package manifest loader (Issue #36 stub)
//
//  Parses manifest.json at the root of an OriLang package, resolves relative
//  source paths, and exposes the package structure to the VM / CLI.
//
//  This is a STUB — it does NOT execute or compile code, only parse + resolve.
// ============================================================================
#ifndef PACKAGE_LOADER_H
#define PACKAGE_LOADER_H

#ifdef __cplusplus
extern "C" {
#endif

// ---------------------------------------------------------------------------
//  Package manifest structure
// ---------------------------------------------------------------------------
typedef struct {
    char* name;              // Package name (from manifest)
    char* version;           // SemVer string (e.g. "1.2.3")
    char* description;       // Human-readable description (may be NULL)
    char* entry;             // Relative path to entry point (e.g. "ori/main.ori")
    char* platform;          // Target platform (may be NULL)
    char* ui;                // UI mode: "console", "window", "widget" (may be NULL)
    int   source_count;      // Number of source files
    char** sources;          // Resolved absolute paths to .ori source files
    int   dep_count;         // Number of dependencies
    struct {
        char* name;          // Dependency package name
        char* version_spec;  // Version constraint string (e.g. "^1.0.0")
    }* deps;
    char* build_output;      // Build output path (may be NULL)
    char* root_dir;          // Absolute path to package root directory
} PackageManifest;

// ---------------------------------------------------------------------------
//  API
// ---------------------------------------------------------------------------

// Walk up from `start_path` until a directory containing `manifest.json`
// is found. Returns the absolute path to that directory (caller frees),
// or NULL if no package root was found within 32 parent traversals.
char* package_find_root(const char* start_path);

// Load and parse manifest.json from the given `root_dir`.
// On success, returns a heap-allocated PackageManifest (caller must free
// with package_free). On error, returns NULL and sets *err_msg (if non-NULL)
// to a static error description (do NOT free).
PackageManifest* package_load(const char* root_dir, const char** err_msg);

// Free all memory owned by a PackageManifest (including itself).
void package_free(PackageManifest* m);

// Resolve a relative path (from the manifest) against the package root.
// Returns an absolute path string (caller frees), or NULL on error.
// Handles both forward-slash and backslash separators.
char* package_resolve_path(const char* root_dir, const char* relative_path);

// Print a human-readable summary of the manifest to stdout.
// Useful for debugging and `ori doctor` output.
void package_print(const PackageManifest* m);

// ---------------------------------------------------------------------------
//  Lower-level JSON helpers (exposed for testing)
// ---------------------------------------------------------------------------

// Minimal JSON string unescape. Writes the decoded string to `out`
// (which must be at least strlen(in)+1 bytes). Returns 0 on success,
// non-zero on parse error.
int package_json_unescape(const char* in, char* out);

#ifdef __cplusplus
}
#endif

#endif // PACKAGE_LOADER_H
