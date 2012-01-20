# Makefile for source rpm: kernel
SPECFILE := kernel.spec

# use noarch for make prep instead of the current CPU
# noarch creates and checks all config files not just the current one,
# in addition "i386" isn't a valid kernel target
PREPARCH  = noarch

# we only check the .sign signatures
UPSTREAM_CHECKS = sign

.PHONY: help
help:
%:
	@echo "Try fedpkg $@ or something like that"
	@exit 1

include Makefile.config

prep:
	fedpkg -v prep --arch=$(PREPARCH)

noarch:
	fedpkg -v local --arch=noarch

# 'make local' also needs to build the noarch firmware package
local: noarch
	fedpkg -v local

extremedebug:
	@perl -pi -e 's/# CONFIG_DEBUG_PAGEALLOC is not set/CONFIG_DEBUG_PAGEALLOC=y/' config-nodebug

debug:
	@perl -pi -e 's/# CONFIG_SLUB_DEBUG_ON is not set/CONFIG_SLUB_DEBUG_ON=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_LOCK_STAT is not set/CONFIG_LOCK_STAT=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_STACK_USAGE is not set/CONFIG_DEBUG_STACK_USAGE=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_SLAB is not set/CONFIG_DEBUG_SLAB=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_MUTEXES is not set/CONFIG_DEBUG_MUTEXES=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_RT_MUTEXES is not set/CONFIG_DEBUG_RT_MUTEXES=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_LOCK_ALLOC is not set/CONFIG_DEBUG_LOCK_ALLOC=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_PROVE_LOCKING is not set/CONFIG_PROVE_LOCKING=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_PROVE_RCU is not set/CONFIG_PROVE_RCU=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_SPINLOCK is not set/CONFIG_DEBUG_SPINLOCK=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_VM is not set/CONFIG_DEBUG_VM=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAULT_INJECTION is not set/CONFIG_FAULT_INJECTION=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAILSLAB is not set/CONFIG_FAILSLAB=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAIL_PAGE_ALLOC is not set/CONFIG_FAIL_PAGE_ALLOC=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAIL_IO_TIMEOUT is not set/CONFIG_FAIL_IO_TIMEOUT=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAIL_MAKE_REQUEST is not set/CONFIG_FAIL_MAKE_REQUEST=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAIL_MMC_REQUEST is not set/CONFIG_FAIL_MMC_REQUEST=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAULT_INJECTION_DEBUG_FS is not set/CONFIG_FAULT_INJECTION_DEBUG_FS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAULT_INJECTION_STACKTRACE_FILTER is not set/CONFIG_FAULT_INJECTION_STACKTRACE_FILTER=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_SG is not set/CONFIG_DEBUG_SG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_WRITECOUNT is not set/CONFIG_DEBUG_WRITECOUNT=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_OBJECTS is not set/CONFIG_DEBUG_OBJECTS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_OBJECTS_FREE is not set/CONFIG_DEBUG_OBJECTS_FREE=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_OBJECTS_TIMERS is not set/CONFIG_DEBUG_OBJECTS_TIMERS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_OBJECTS_WORK is not set/CONFIG_DEBUG_OBJECTS_WORK=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set/CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set/CONFIG_DEBUG_OBJECTS_RCU_HEAD=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_X86_PTDUMP is not set/CONFIG_X86_PTDUMP=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_CAN_DEBUG_DEVICES is not set/CONFIG_CAN_DEBUG_DEVICES=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_MODULE_FORCE_UNLOAD is not set/CONFIG_MODULE_FORCE_UNLOAD=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_SYSCTL_SYSCALL_CHECK is not set/CONFIG_SYSCTL_SYSCALL_CHECK=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_NOTIFIERS is not set/CONFIG_DEBUG_NOTIFIERS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DMA_API_DEBUG is not set/CONFIG_DMA_API_DEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_PM_TEST_SUSPEND is not set/CONFIG_PM_TEST_SUSPEND=y/' config-generic
	@perl -pi -e 's/# CONFIG_PM_ADVANCED_DEBUG is not set/CONFIG_PM_ADVANCED_DEBUG=y/' config-generic
	@perl -pi -e 's/# CONFIG_B43_DEBUG is not set/CONFIG_B43_DEBUG=y/' config-generic
	@perl -pi -e 's/# CONFIG_B43LEGACY_DEBUG is not set/CONFIG_B43LEGACY_DEBUG=y/' config-generic
	@perl -pi -e 's/# CONFIG_MMIOTRACE is not set/CONFIG_MMIOTRACE=y/' config-nodebug
	@perl -pi -e 's/CONFIG_STRIP_ASM_SYMS=y/# CONFIG_STRIP_ASM_SYMS is not set/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_CREDENTIALS is not set/CONFIG_DEBUG_CREDENTIALS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set/CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_ACPI_DEBUG is not set/CONFIG_ACPI_DEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_EXT4_DEBUG is not set/CONFIG_EXT4_DEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_PERF_USE_VMALLOC is not set/CONFIG_DEBUG_PERF_USE_VMALLOC=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_JBD2_DEBUG is not set/CONFIG_JBD2_DEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_BLK_CGROUP is not set/CONFIG_DEBUG_BLK_CGROUP=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DRBD_FAULT_INJECTION is not set/CONFIG_DRBD_FAULT_INJECTION=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_ATH_DEBUG is not set/CONFIG_ATH_DEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_CARL9170_DEBUGFS is not set/CONFIG_CARL9170_DEBUGFS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_IWLWIFI_DEVICE_TRACING is not set/CONFIG_IWLWIFI_DEVICE_TRACING=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DMADEVICES_DEBUG is not set/CONFIG_DMADEVICES_DEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DMADEVICES_VDEBUG is not set/CONFIG_DMADEVICES_VDEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_CEPH_LIB_PRETTYDEBUG is not set/CONFIG_CEPH_LIB_PRETTYDEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_QUOTA_DEBUG is not set/CONFIG_QUOTA_DEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_KGDB_KDB is not set/CONFIG_KGDB_KDB=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_KDB_KEYBOARD is not set/CONFIG_KDB_KEYBOARD=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_CPU_NOTIFIER_ERROR_INJECT is not set/CONFIG_CPU_NOTIFIER_ERROR_INJECT=m/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_PER_CPU_MAPS is not set/CONFIG_DEBUG_PER_CPU_MAPS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_TEST_LIST_SORT is not set/CONFIG_TEST_LIST_SORT=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_ATOMIC_SLEEP is not set/CONFIG_DEBUG_ATOMIC_SLEEP=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DETECT_HUNG_TASK is not set/CONFIG_DETECT_HUNG_TASK=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set/CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y/' config-nodebug

	@# just in case we're going from extremedebug -> debug
	@perl -pi -e 's/CONFIG_DEBUG_PAGEALLOC=y/# CONFIG_DEBUG_PAGEALLOC is not set/' config-nodebug

	@perl -pi -e 's/CONFIG_NR_CPUS=256/CONFIG_NR_CPUS=512/' config-x86_64-generic

	@perl -pi -e 's/^%define debugbuildsenabled 1/%define debugbuildsenabled 0/' kernel.spec
	@perl -pi -e 's/^%define rawhide_skip_docs 0/%define rawhide_skip_docs 1/' kernel.spec
	@rpmdev-bumpspec -c "Reenable debugging options." kernel.spec

nodebuginfo:
	@perl -pi -e 's/^%define with_debuginfo %\{\?_without_debuginfo: 0\} %\{\?\!_without_debuginfo: 1\}/%define with_debuginfo %\{\?_without_debuginfo: 0\} %\{\?\!_without_debuginfo: 0\}/' kernel.spec
nodebug: release
	@perl -pi -e 's/^%define debugbuildsenabled 1/%define debugbuildsenabled 0/' kernel.spec
release: config-release
	@perl -pi -e 's/^%define debugbuildsenabled 0/%define debugbuildsenabled 1/' kernel.spec
	@perl -pi -e 's/^%define rawhide_skip_docs 1/%define rawhide_skip_docs 0/' kernel.spec
	@rpmdev-bumpspec -c "Disable debugging options." kernel.spec

include Makefile.release

unused-kernel-patches:
	@for f in *.patch; do if [ -e $$f ]; then (egrep -q "^Patch[[:digit:]]+:[[:space:]]+$$f" $(SPECFILE) || echo "Unused:    $$f") && egrep -q "^ApplyPatch[[:space:]]+$$f|^ApplyOptionalPatch[[:space:]]+$$f" $(SPECFILE) || echo "Unapplied: $$f"; fi; done

ifeq ($(MAKECMDGOALS),me a sandwich)
.PHONY: me a sandwich
me a:
	@:

sandwich:
	@[ `id -u` -ne 0 ] && echo "What? Make it yourself." || echo Okay.
endif
