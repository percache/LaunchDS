# LaunchdDS

iOS system log viewer with kernel exploit. Reads `launchd.log` and other system logs that are normally inaccessible to apps.

## Tested only on iOS 18.6.2 22G100 A17!

## What it does

iOS apps are sandboxed — they can’t read system logs. LaunchdDS uses DarkSword kernel exploit to escape the sandbox and read `/var/log/` directly.

**launchd** is the first process on iOS (pid 1). Its log (`/var/log/com.apple.xpc.launchd/launchd.log`) records every process launch, crash, and service event on the system. This is the most useful log for understanding what iOS is doing.

## Flow

```
Launch animation → Exploit → Log viewer
```

1. **kexploit_opa334** — gets kernel read/write via ICMPv6 socket corruption
2. **sandbox_escape** — patches sandbox extensions in kernel memory
3. **Log viewer** — reads `/var/log/` files + streams own-process logs via `os_activity_stream`

## Supported

- **iOS** 17.0 – 18.7, experimental 26.0
- **Chips** A10 – A18, M1 – M4
- **Devices** iPhone 7 through iPhone 16, iPads with matching chips

Hardcoded kernel struct offsets for every iOS version and chip combination (from [ds-kexploit-fun](https://github.com/nicookie/ds-kexploit-fun)).

## Build

Requires [Theos](https://theos.dev/) with iPhoneOS SDK.

```bash
export THEOS=~/theos
make clean && make package FINALPACKAGE=1
```

Output: `packages/AntoineDS.ipa` — sideload via TrollStore or similar.

## Based on

| Project | What we use |
|---------|-------------|
| [Antoine](https://github.com/SerenaKit/Antoine) | Log viewer UI, `os_activity_stream` integration |
| [ds-kexploit-fun](https://github.com/nicookie/ds-kexploit-fun) | DarkSword exploit, kernel offsets for iOS 17–26 |
| [lara](https://github.com/rooootdev/lara) | Sandbox escape approach (`proc_ro → ucred → sandbox → ext_set`) |
| [opa334](https://github.com/opa334) | kexploit_opa334 (physical OOB r/w → socket corruption) |
| [libgrabkernel2](https://github.com/alfiecg24/libgrabkernel2) | Kernelcache download for dynamic offset resolution |
| [XPF](https://github.com/alfiecg24/XPF) + [ChOma](https://github.com/alfiecg24/ChOma) | Kernel patchfinder |

## Credits

- **[percache](https://github.com/percache)** — maintainer
- **[Serena](https://github.com/SerenaKit)** — Antoine
- **[seo](https://github.com/nicookie)** — DarkSword, offsets
- **[rooootdev](https://github.com/rooootdev)** — lara, sandbox escape
- **[opa334](https://github.com/opa334)** — kexploit
- **[alfiecg24](https://github.com/alfiecg24)** — libgrabkernel2, XPF, ChOma

## License

MIT
