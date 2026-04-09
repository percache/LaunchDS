export THEOS ?= $(HOME)/theos
export ARCHS = arm64
export TARGET = iphone:clang:16.5:15.0
export SYSROOT = $(THEOS)/sdks/iPhoneOS16.5.sdk

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = AntoineDS

AntoineDS_FILES = \
	AntoineDS/AppDelegate.swift \
	AntoineDS/SceneDelegate.swift \
	AntoineDS/Backend/BackgroundSupport/ApplicationMonitor.swift \
	AntoineDS/Backend/BackgroundSupport/BackgroundMode.swift \
	AntoineDS/Backend/BackgroundSupport/LocationController.swift \
	AntoineDS/Backend/Entry/CodableEntry.swift \
	AntoineDS/Backend/Entry/Entry.swift \
	AntoineDS/Backend/Entry/MessageEvent.swift \
	AntoineDS/Backend/Entry/StreamEntry.swift \
	AntoineDS/Backend/Entry/StreamEntryType.swift \
	AntoineDS/Backend/Extensions/Foundation.swift \
	AntoineDS/Backend/Extensions/SwiftUIGIF.swift \
	AntoineDS/Backend/Extensions/UIKit.swift \
	AntoineDS/Backend/Filter/EntryFilter.swift \
	AntoineDS/Backend/Filter/TextFilter.swift \
	AntoineDS/Backend/Localization/Language.swift \
	AntoineDS/Backend/Other/AlderisStub.swift \
	AntoineDS/Backend/Other/BasicLayoutAnchorsHolding.swift \
	AntoineDS/Backend/Other/CodableColor.swift \
	AntoineDS/Backend/Other/CreditsPerson.swift \
	AntoineDS/Backend/Other/Menu.swift \
	AntoineDS/Backend/Other/UniqueCollection.swift \
	AntoineDS/Backend/Preferences/Preferences.swift \
	AntoineDS/Backend/Preferences/Storage.swift \
	AntoineDS/Backend/Stream/ActivityStream.swift \
	AntoineDS/Backend/Stream/ActivityStreamDelegate.swift \
	AntoineDS/Backend/Stream/StreamEvent.swift \
	AntoineDS/Backend/Stream/StreamOption.swift \
	AntoineDS/UI/CreditsView.swift \
	AntoineDS/UI/EntryCollectionViewCell.swift \
	AntoineDS/UI/EntryViewController.swift \
	AntoineDS/UI/ExploitViewController.swift \
	AntoineDS/UI/Filter/DataSource.swift \
	AntoineDS/UI/Filter/Delegate.swift \
	AntoineDS/UI/Filter/EntryFilterViewController.swift \
	AntoineDS/UI/Filter/TextViewDelegate.swift \
	AntoineDS/UI/PreferencesViewController.swift \
	AntoineDS/UI/PreferredLanguageViewController.swift \
	AntoineDS/UI/KernelLogViewController.swift \
	AntoineDS/UI/LaunchAnimationViewController.swift \
	AntoineDS/UI/StreamViewController.swift \
	AntoineDS/UI/SystemLogViewController.swift \
	AntoineDS/Backend/Bridge/Bridge.m \
	AntoineDS/DarkSword/DarkSwordExploit.m \
	AntoineDS/DarkSword/sandbox_escape.m \
	AntoineDS/kexploit/kexploit_opa334.m \
	AntoineDS/kexploit/krw.m \
	AntoineDS/kexploit/kutils.m \
	AntoineDS/kexploit/kernel_log_reader.m \
	AntoineDS/kexploit/offsets.m \
	AntoineDS/kexploit/dynamic_offsets.m \
	AntoineDS/kexploit/vnode.m \
	AntoineDS/kpf/patchfinder.m \
	AntoineDS/TaskRop/Exception.m \
	AntoineDS/TaskRop/MigFilterBypassThread.m \
	AntoineDS/TaskRop/PAC.m \
	AntoineDS/TaskRop/RemoteCall.m \
	AntoineDS/TaskRop/Thread.m \
	AntoineDS/TaskRop/VM.m \
	AntoineDS/utils/file.c \
	AntoineDS/utils/hexdump.c \
	AntoineDS/utils/process.c \
	AntoineDS/utils/xpc_stub.c \
	AntoineDS/XPF/src/bad_recovery.c \
	AntoineDS/XPF/src/common.c \
	AntoineDS/XPF/src/decompress.c \
	AntoineDS/XPF/src/non_ppl.c \
	AntoineDS/XPF/src/ppl.c \
	AntoineDS/XPF/src/xpf.c \
	AntoineDS/XPF/external/ChOma/include/choma/Base64.c \
	AntoineDS/XPF/external/ChOma/include/choma/BufferedStream.c \
	AntoineDS/XPF/external/ChOma/include/choma/CSBlob.c \
	AntoineDS/XPF/external/ChOma/include/choma/CodeDirectory.c \
	AntoineDS/XPF/external/ChOma/include/choma/DER.c \
	AntoineDS/XPF/external/ChOma/include/choma/DyldSharedCache.c \
	AntoineDS/XPF/external/ChOma/include/choma/Entitlements.c \
	AntoineDS/XPF/external/ChOma/include/choma/Fat.c \
	AntoineDS/XPF/external/ChOma/include/choma/FileStream.c \
	AntoineDS/XPF/external/ChOma/include/choma/Host.c \
	AntoineDS/XPF/external/ChOma/include/choma/MachO.c \
	AntoineDS/XPF/external/ChOma/include/choma/MachOLoadCommand.c \
	AntoineDS/XPF/external/ChOma/include/choma/MemoryStream.c \
	AntoineDS/XPF/external/ChOma/include/choma/PatchFinder.c \
	AntoineDS/XPF/external/ChOma/include/choma/PatchFinder_arm64.c \
	AntoineDS/XPF/external/ChOma/include/choma/Util.c \
	AntoineDS/XPF/external/ChOma/include/choma/arm64.c

# === Frameworks ===
AntoineDS_FRAMEWORKS = UIKit Foundation CoreLocation UserNotifications SwiftUI AVFoundation IOSurface CoreGraphics QuartzCore Security
AntoineDS_PRIVATE_FRAMEWORKS = LoggingSupport

# === Compiler flags ===
AntoineDS_CFLAGS = \
	-I$(PWD)/AntoineDS/stubs \
	-I$(PWD)/AntoineDS/XPF/src \
	-I$(PWD)/AntoineDS/XPF/external/ChOma/include \
	-I$(PWD)/AntoineDS/kexploit \
	-I$(PWD)/AntoineDS/kpf \
	-I$(PWD)/AntoineDS/utils \
	-I$(PWD)/AntoineDS/TaskRop \
	-I$(PWD)/AntoineDS/DarkSword \
	-I$(PWD)/AntoineDS/Backend/Bridge \
	-I$(PWD)/AntoineDS/Backend/Bridge/ActivityEvents \
	-I$(PWD)/AntoineDS/Backend/Stream \
	-fobjc-arc \
	-w

AntoineDS_CCFLAGS = $(AntoineDS_CFLAGS)
AntoineDS_OBJCFLAGS = $(AntoineDS_CFLAGS)

AntoineDS_SWIFTFLAGS = \
	-import-objc-header $(PWD)/AntoineDS/Backend/Bridge/Bridge.h \
	-suppress-warnings

AntoineDS_LDFLAGS = \
	-L$(PWD)/AntoineDS/XPF/external/ChOma/external/ios \
	-lz \
	-lcrypto \
	-lssl \
	-weak_framework LoggingSupport \
	-weak_framework SwiftUI \
	-Xlinker -rpath -Xlinker @executable_path/Frameworks

AntoineDS_CODESIGN_FLAGS = -SAntoineDS.entitlements

include $(THEOS_MAKE_PATH)/application.mk

# === Copy resources and create IPA ===
after-AntoineDS-stage::
	@echo "=== Preparing .app bundle ==="
	$(ECHO_NOTHING)APPDIR=$(THEOS_STAGING_DIR)/Applications/AntoineDS.app && \
	cp AntoineDS/Info.plist "$$APPDIR/Info.plist" && \
	echo "APPL????" > "$$APPDIR/PkgInfo" && \
	mkdir -p "$$APPDIR/Frameworks" && \
	cp AntoineDS/lib/libgrabkernel2.dylib "$$APPDIR/Frameworks/" && \
	echo "=== Creating IPA ===" && \
	rm -rf $(THEOS_STAGING_DIR)/Payload && \
	mkdir -p $(THEOS_STAGING_DIR)/Payload packages && \
	cp -a "$$APPDIR" $(THEOS_STAGING_DIR)/Payload/ && \
	cd $(THEOS_STAGING_DIR) && zip -r9 $(PWD)/packages/AntoineDS.ipa Payload$(ECHO_END)

