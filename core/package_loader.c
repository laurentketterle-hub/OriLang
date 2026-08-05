// stub
#include "package_loader.h"
char* package_find_root(const char* s) { return NULL; }
int package_json_unescape(const char* i, char* o) { while(*i)*o++=*i++; *o=0; return 0; }
PackageManifest* package_load(const char* r, const char** e) { *e="stub"; return NULL; }
void package_free(PackageManifest* m) { (void)m; }
char* package_resolve_path(const char* r, const char* p) { return strdup(p); }
void package_print(const PackageManifest* m) { (void)m; }
