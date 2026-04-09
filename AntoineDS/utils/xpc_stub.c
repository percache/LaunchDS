// xpc function stubs for linking
// These are only used by XPF's offset dictionary functionality
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

typedef void *xpc_object_t;
typedef const void *xpc_type_t;

xpc_object_t xpc_dictionary_create_empty(void) { return NULL; }
void xpc_dictionary_set_uint64(xpc_object_t dict, const char *key, uint64_t val) { (void)dict; (void)key; (void)val; }
int64_t xpc_dictionary_get_int64(xpc_object_t dict, const char *key) { (void)dict; (void)key; return 0; }
void xpc_release(xpc_object_t obj) { (void)obj; }

typedef bool (^xpc_dictionary_applier_t)(const char *key, xpc_object_t value);
bool xpc_dictionary_apply(xpc_object_t dict, xpc_dictionary_applier_t applier) { (void)dict; (void)applier; return false; }
xpc_type_t xpc_get_type(xpc_object_t obj) { (void)obj; return NULL; }
uint64_t xpc_uint64_get_value(xpc_object_t obj) { (void)obj; return 0; }

// XPC_TYPE_UINT64 dummy
const struct { int dummy; } _xpc_type_uint64 = { 0 };
