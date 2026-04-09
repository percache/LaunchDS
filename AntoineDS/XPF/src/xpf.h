#include <stdint.h>

#include <choma/Fat.h>
#include <choma/Util.h>
#include <choma/PatchFinder.h>
#include <choma/PatchFinder_arm64.h>
#include <choma/arm64.h>
// xpc support
#ifdef _XPC_XPC_H
// xpc/xpc.h already included
#else
typedef void *xpc_object_t;
xpc_object_t xpc_dictionary_create_empty(void);
void xpc_dictionary_set_uint64(xpc_object_t dict, const char *key, uint64_t val);
int64_t xpc_dictionary_get_int64(xpc_object_t dict, const char *key);
void xpc_release(xpc_object_t obj);
#endif

typedef struct s_XPFItem {
	struct s_XPFItem *nextItem;
	const char *name;
	uint64_t (*finder)(void *);
	void *ctx;
	bool cached;
	uint64_t cache;
} XPFItem;

typedef struct s_XPFSet {
	const char *name;
	bool (*supported)(void);
	const char *metrics[];
} XPFSet;

#define XPF_ASSERT(assert) if (!(assert)) { if (!xpf_get_error()) { xpf_set_error("[%s:%d] Failed assert in %s: %s", __FILE__, __LINE__, __FUNCTION__, #assert); } return 0; }

int xpf_start_with_kernel_path(const char *kernelPath);
void xpf_item_register(const char *name, void *finder, void *ctx);
uint64_t xpf_item_resolve(const char *name);
uint64_t xpfsec_decode_pointer(PFSection *section, uint64_t vmaddr, uint64_t value);
bool xpf_set_is_supported(const char *name);
int xpf_offset_dictionary_add_set(xpc_object_t xdict, XPFSet *set);
xpc_object_t xpf_construct_offset_dictionary(const char *sets[]);
void xpf_set_error(const char *error, ...);
const char *xpf_get_error(void);
void xpf_print_all_items(void);
void xpf_stop(void);

typedef struct s_XPF {
	int kernelFd;
	void *mappedKernel;
	size_t kernelSize;
	void *decompressedKernel;
	size_t decompressedKernelSize;

	Fat *kernelContainer;
	MachO *kernel;
	bool kernelIsFileset;
	bool kernelIsArm64e;
	bool isSPTMDevice;
	char *kernelVersionString;
	char *kernelInfoPlist;
	char *darwinVersion;
	char *xnuBuild;
	char *xnuPlatform;
	char *osVersion;

	uint64_t kernelBase;
	uint64_t kernelEntry;

	PFSection *kernelTextSection;
	PFSection *kernelPinstSection;
	PFSection *kernelPPLTextSection;
	PFSection *kernelStringSection;
	PFSection *kernelConstSection;
	PFSection *kernelDataConstSection;
	PFSection *kernelDataSection;
	PFSection *kernelOSLogSection;
	PFSection *kernelPrelinkTextSection;
	PFSection *kernelPLKTextSection;
	PFSection *kernelKmodInfoSection;
	PFSection *kernelPrelinkInfoSection;
	PFSection *kernelBootdataInit;
	PFSection *kernelAMFITextSection;
	PFSection *kernelAMFIStringSection;
	PFSection *kernelSandboxTextSection;
	PFSection *kernelSandboxStringSection;
	PFSection *kernelInfoPlistSection;

	XPFItem *firstItem;
} XPF;
extern XPF gXPF;
