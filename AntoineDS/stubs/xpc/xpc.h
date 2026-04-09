// xpc.h stub for cross-compilation
#ifndef _XPC_XPC_H
#define _XPC_XPC_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

typedef void *xpc_object_t;
typedef const void *xpc_type_t;

extern const struct { int dummy; } _xpc_type_uint64;
#define XPC_TYPE_UINT64 ((xpc_type_t)&_xpc_type_uint64)

xpc_object_t xpc_dictionary_create_empty(void);
void xpc_dictionary_set_uint64(xpc_object_t dict, const char *key, uint64_t val);
int64_t xpc_dictionary_get_int64(xpc_object_t dict, const char *key);
void xpc_release(xpc_object_t obj);

typedef bool (^xpc_dictionary_applier_t)(const char *key, xpc_object_t value);
bool xpc_dictionary_apply(xpc_object_t dict, xpc_dictionary_applier_t applier);
xpc_type_t xpc_get_type(xpc_object_t obj);
uint64_t xpc_uint64_get_value(xpc_object_t obj);

#endif /* _XPC_XPC_H */
