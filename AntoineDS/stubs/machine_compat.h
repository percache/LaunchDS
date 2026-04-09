// Machine compatibility defines for newer CPU families
// Values from ds-kexploit-fun/machine_info.h (verified on real devices)
#ifndef _MACHINE_COMPAT_H
#define _MACHINE_COMPAT_H

#include <mach/machine.h>

#ifndef CPUFAMILY_ARM_COLL
#define CPUFAMILY_ARM_COLL     0x2876f5b5  // A17 Pro
#endif
#ifndef CPUFAMILY_ARM_TUPAI
#define CPUFAMILY_ARM_TUPAI    0x204526d0  // A18
#endif
#ifndef CPUFAMILY_ARM_IBIZA
#define CPUFAMILY_ARM_IBIZA    0xfa33415e  // M3
#endif
#ifndef CPUFAMILY_ARM_DONAN
#define CPUFAMILY_ARM_DONAN    0x6f5129ac  // M4
#endif

#endif
