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

ifndef KVERSION
KVERSION := $(shell awk '$$1 == "%define" && $$2 == "base_sublevel" { \
				print "2.6." $$3 \
			 }' $(SPECFILE))
endif

prep:
	fedpkg -v prep --arch=$(PREPARCH)

extremedebug:
	@perl -pi -e 's/# CONFIG_DEBUG_PAGEALLOC is not set/CONFIG_DEBUG_PAGEALLOC=y/' config-nodebug

debug:
	@perl -pi -e 's/# CONFIG_SLUB_DEBUG_ON is not set/CONFIG_SLUB_DEBUG_ON=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_LOCK_STAT is not set/CONFIG_LOCK_STAT=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_STACK_USAGE is not set/CONFIG_DEBUG_STACK_USAGE=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_SLAB is not set/CONFIG_DEBUG_SLAB=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_MUTEXES is not set/CONFIG_DEBUG_MUTEXES=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_RT_MUTEXES is not set/CONFIG_DEBUG_RT_MUTEXES=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_RWSEMS is not set/CONFIG_DEBUG_RWSEMS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_LOCK_ALLOC is not set/CONFIG_DEBUG_LOCK_ALLOC=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_PROVE_LOCKING is not set/CONFIG_PROVE_LOCKING=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_PROVE_RCU is not set/CONFIG_PROVE_RCU=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_SPINLOCK is not set/CONFIG_DEBUG_SPINLOCK=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_VM is not set/CONFIG_DEBUG_VM=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_SLEEP_IN_IRQ is not set/CONFIG_DEBUG_SLEEP_IN_IRQ=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAULT_INJECTION is not set/CONFIG_FAULT_INJECTION=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAILSLAB is not set/CONFIG_FAILSLAB=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAIL_PAGE_ALLOC is not set/CONFIG_FAIL_PAGE_ALLOC=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAIL_IO_TIMEOUT is not set/CONFIG_FAIL_IO_TIMEOUT=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAIL_MAKE_REQUEST is not set/CONFIG_FAIL_MAKE_REQUEST=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAULT_INJECTION_DEBUG_FS is not set/CONFIG_FAULT_INJECTION_DEBUG_FS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_FAULT_INJECTION_STACKTRACE_FILTER is not set/CONFIG_FAULT_INJECTION_STACKTRACE_FILTER=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_SG is not set/CONFIG_DEBUG_SG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_WRITECOUNT is not set/CONFIG_DEBUG_WRITECOUNT=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_OBJECTS is not set/CONFIG_DEBUG_OBJECTS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_OBJECTS_FREE is not set/CONFIG_DEBUG_OBJECTS_FREE=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_OBJECTS_TIMERS is not set/CONFIG_DEBUG_OBJECTS_TIMERS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_X86_PTDUMP is not set/CONFIG_X86_PTDUMP=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_CAN_DEBUG_DEVICES is not set/CONFIG_CAN_DEBUG_DEVICES=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_MODULE_FORCE_UNLOAD is not set/CONFIG_MODULE_FORCE_UNLOAD=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_SYSCTL_SYSCALL_CHECK is not set/CONFIG_SYSCTL_SYSCALL_CHECK=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_NOTIFIERS is not set/CONFIG_DEBUG_NOTIFIERS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DMA_API_DEBUG is not set/CONFIG_DMA_API_DEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_PM_TEST_SUSPEND is not set/CONFIG_PM_TEST_SUSPEND=y/' config-generic
	@perl -pi -e 's/# CONFIG_PM_ADVANCED_DEBUG is not set/CONFIG_PM_ADVANCED_DEBUG=y/' config-generic
	@perl -pi -e 's/# CONFIG_BOOT_TRACER is not set/CONFIG_BOOT_TRACER=y/' config-generic
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
	@perl -pi -e 's/# CONFIG_DEBUG_CFQ_IOSCHED is not set/CONFIG_DEBUG_CFQ_IOSCHED=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DRBD_FAULT_INJECTION is not set/CONFIG_DRBD_FAULT_INJECTION=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_ATH_DEBUG is not set/CONFIG_ATH_DEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_CARL9170_DEBUGFS is not set/CONFIG_CARL9170_DEBUGFS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_IWLWIFI_DEVICE_TRACING is not set/CONFIG_IWLWIFI_DEVICE_TRACING=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_OBJECTS_WORK is not set/CONFIG_DEBUG_OBJECTS_WORK=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set/CONFIG_DEBUG_STRICT_USER_COPY_CHECKS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DMADEVICES_DEBUG is not set/CONFIG_DMADEVICES_DEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DMADEVICES_VDEBUG is not set/CONFIG_DMADEVICES_VDEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_CEPH_LIB_PRETTYDEBUG is not set/CONFIG_CEPH_LIB_PRETTYDEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_QUOTA_DEBUG is not set/CONFIG_QUOTA_DEBUG=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_KGDB_KDB is not set/CONFIG_KGDB_KDB=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_KDB_KEYBOARD is not set/CONFIG_KDB_KEYBOARD=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_CPU_NOTIFIER_ERROR_INJECT is not set/CONFIG_CPU_NOTIFIER_ERROR_INJECT=m/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_PER_CPU_MAPS is not set/CONFIG_DEBUG_PER_CPU_MAPS=y/' config-nodebug
	@perl -pi -e 's/CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y/# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set/' config-nodebug
	#@perl -pi -e 's/# CONFIG_PCI_DEFAULT_USE_CRS is not set/CONFIG_PCI_DEFAULT_USE_CRS=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set/CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y/' config-nodebug
	@perl -pi -e 's/# CONFIG_TEST_LIST_SORT is not set/CONFIG_TEST_LIST_SORT=y/' config-nodebug

	@perl -pi -e 's/# CONFIG_DEBUG_SET_MODULE_RONX is not set/CONFIG_DEBUG_SET_MODULE_RONX=y/' config-nodebug

	@# just in case we're going from extremedebug -> debug
	@perl -pi -e 's/CONFIG_DEBUG_PAGEALLOC=y/# CONFIG_DEBUG_PAGEALLOC is not set/' config-nodebug

	@perl -pi -e 's/CONFIG_NR_CPUS=256/CONFIG_NR_CPUS=512/' config-x86_64-generic

	@perl -pi -e 's/^%define debugbuildsenabled 1/%define debugbuildsenabled 0/' kernel.spec
	@perl -pi -e 's/^%define rawhide_skip_docs 0/%define rawhide_skip_docs 1/' kernel.spec

nodebuginfo:
	@perl -pi -e 's/^%define with_debuginfo %\{\?_without_debuginfo: 0\} %\{\?\!_without_debuginfo: 1\}/%define with_debuginfo %\{\?_without_debuginfo: 0\} %\{\?\!_without_debuginfo: 0\}/' kernel.spec
nodebug: release
	@perl -pi -e 's/^%define debugbuildsenabled 1/%define debugbuildsenabled 0/' kernel.spec
release:
	@perl -pi -e 's/CONFIG_SLUB_DEBUG_ON=y/# CONFIG_SLUB_DEBUG_ON is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_LOCK_STAT=y/# CONFIG_LOCK_STAT is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_STACK_USAGE=y/# CONFIG_DEBUG_STACK_USAGE is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_SLAB=y/# CONFIG_DEBUG_SLAB is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_MUTEXES=y/# CONFIG_DEBUG_MUTEXES is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_RT_MUTEXES=y/# CONFIG_DEBUG_RT_MUTEXES is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_RWSEMS=y/# CONFIG_DEBUG_RWSEMS is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_LOCK_ALLOC=y/# CONFIG_DEBUG_LOCK_ALLOC is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_PROVE_LOCKING=y/# CONFIG_PROVE_LOCKING is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_PROVE_RCU=y/# CONFIG_PROVE_RCU is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_SPINLOCK=y/# CONFIG_DEBUG_SPINLOCK is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_VM=y/# CONFIG_DEBUG_VM is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_SLEEP_IN_IRQ=y/# CONFIG_DEBUG_SLEEP_IN_IRQ is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_FAULT_INJECTION=y/# CONFIG_FAULT_INJECTION is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_FAILSLAB=y/# CONFIG_FAILSLAB is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_FAIL_PAGE_ALLOC=y/# CONFIG_FAIL_PAGE_ALLOC is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_FAIL_IO_TIMEOUT=y/# CONFIG_FAIL_IO_TIMEOUT is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_FAIL_MAKE_REQUEST=y/# CONFIG_FAIL_MAKE_REQUEST is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_FAULT_INJECTION_DEBUG_FS=y/# CONFIG_FAULT_INJECTION_DEBUG_FS is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_FAULT_INJECTION_STACKTRACE_FILTER=y/# CONFIG_FAULT_INJECTION_STACKTRACE_FILTER is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_SG=y/# CONFIG_DEBUG_SG is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_WRITECOUNT=y/# CONFIG_DEBUG_WRITECOUNT is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_OBJECTS=y/# CONFIG_DEBUG_OBJECTS is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_OBJECTS_FREE=y/# CONFIG_DEBUG_OBJECTS_FREE is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_OBJECTS_TIMERS=y/# CONFIG_DEBUG_OBJECTS_TIMERS is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_X86_PTDUMP=y/# CONFIG_X86_PTDUMP is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_CAN_DEBUG_DEVICES=y/# CONFIG_CAN_DEBUG_DEVICES is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_MODULE_FORCE_UNLOAD=y/# CONFIG_MODULE_FORCE_UNLOAD is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_SYSCTL_SYSCALL_CHECK=y/# CONFIG_SYSCTL_SYSCALL_CHECK is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_NOTIFIERS=y/# CONFIG_DEBUG_NOTIFIERS is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DMA_API_DEBUG=y/# CONFIG_DMA_API_DEBUG is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_PM_TEST_SUSPEND=y/#\ CONFIG_PM_TEST_SUSPEND\ is\ not\ set/' config-generic
	@perl -pi -e 's/CONFIG_PM_ADVANCED_DEBUG=y/#\ CONFIG_PM_ADVANCED_DEBUG\ is\ not\ set/' config-generic
	@perl -pi -e 's/CONFIG_BOOT_TRACER=y/#\ CONFIG_BOOT_TRACER\ is\ not\ set/' config-generic
	@perl -pi -e 's/CONFIG_B43_DEBUG=y/# CONFIG_B43_DEBUG is not set/' config-generic
	@perl -pi -e 's/CONFIG_B43LEGACY_DEBUG=y/# CONFIG_B43LEGACY_DEBUG is not set/' config-generic
	@perl -pi -e 's/CONFIG_MMIOTRACE=y/# CONFIG_MMIOTRACE is not set/' config-nodebug
	@perl -pi -e 's/# CONFIG_STRIP_ASM_SYMS is not set/CONFIG_STRIP_ASM_SYMS=y/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_CREDENTIALS=y/# CONFIG_DEBUG_CREDENTIALS is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y/# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_ACPI_DEBUG=y/# CONFIG_ACPI_DEBUG is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_EXT4_DEBUG=y/# CONFIG_EXT4_DEBUG is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_PERF_USE_VMALLOC=y/# CONFIG_DEBUG_PERF_USE_VMALLOC is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_JBD2_DEBUG=y/# CONFIG_JBD2_DEBUG is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_CFQ_IOSCHED=y/# CONFIG_DEBUG_CFQ_IOSCHED is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DRBD_FAULT_INJECTION=y/# CONFIG_DRBD_FAULT_INJECTION is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_ATH_DEBUG=y/# CONFIG_ATH_DEBUG is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_CARL9170_DEBUGFS=y/# CONFIG_CARL9170_DEBUGFS is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_IWLWIFI_DEVICE_TRACING=y/# CONFIG_IWLWIFI_DEVICE_TRACING is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_OBJECTS_WORK=y/# CONFIG_DEBUG_OBJECTS_WORK is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_STRICT_USER_COPY_CHECKS=y/# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DMADEVICES_DEBUG=y/# CONFIG_DMADEVICES_DEBUG is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DMADEVICES_VDEBUG=y/# CONFIG_DMADEVICES_VDEBUG is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_CEPH_LIB_PRETTYDEBUG=y/# CONFIG_CEPH_LIB_PRETTYDEBUG is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_QUOTA_DEBUG=y/# CONFIG_QUOTA_DEBUG is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_CPU_NOTIFIER_ERROR_INJECT=m/# CONFIG_CPU_NOTIFIER_ERROR_INJECT is not set/' config-nodebug
	#@perl -pi -e 's/CONFIG_KGDB_KDB=y/# CONFIG_KGDB_KDB is not set/' config-nodebug
	#@perl -pi -e 's/CONFIG_KDB_KEYBOARD=y/# CONFIG_KDB_KEYBOARD is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_PER_CPU_MAPS=y/# CONFIG_DEBUG_PER_CPU_MAPS is not set/' config-nodebug
	@perl -pi -e 's/# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set/CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y/' config-nodebug
	#@perl -pi -e 's/CONFIG_PCI_DEFAULT_USE_CRS=y/# CONFIG_PCI_DEFAULT_USE_CRS is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y/# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set/' config-nodebug
	@perl -pi -e 's/CONFIG_TEST_LIST_SORT=y/# CONFIG_TEST_LIST_SORT is not set/' config-nodebug

	@perl -pi -e 's/CONFIG_DEBUG_SET_MODULE_RONX=y/# CONFIG_DEBUG_SET_MODULE_RONX is not set/' config-nodebug

	@perl -pi -e 's/CONFIG_DEBUG_PAGEALLOC=y/# CONFIG_DEBUG_PAGEALLOC is not set/' config-debug
	@perl -pi -e 's/CONFIG_DEBUG_PAGEALLOC=y/# CONFIG_DEBUG_PAGEALLOC is not set/' config-nodebug

	@perl -pi -e 's/CONFIG_NR_CPUS=512/CONFIG_NR_CPUS=256/' config-x86_64-generic

	@perl -pi -e 's/^%define debugbuildsenabled 0/%define debugbuildsenabled 1/' kernel.spec
	@perl -pi -e 's/^%define rawhide_skip_docs 1/%define rawhide_skip_docs 0/' kernel.spec

reconfig:
	@rm -f kernel-*-config
	@VERSION=$(KVERSION) make -f Makefile.config configs
	@scripts/reconfig.sh

unused-kernel-patches:
	@for f in *.patch; do if [ -e $$f ]; then (egrep -q "^Patch[[:digit:]]+:[[:space:]]+$$f" $(SPECFILE) || echo "Unused:    $$f") && egrep -q "^ApplyPatch[[:space:]]+$$f|^ApplyOptionalPatch[[:space:]]+$$f" $(SPECFILE) || echo "Unapplied: $$f"; fi; done

# since i386 isn't a target...
compile compile-short: DIST_DEFINES += --target $(shell uname -m)

# 'make local' also needs to build the noarch firmware package
local: noarch

#
# Hacks for building vanilla (unpatched) kernel rpms.
# Use "make vanilla-TARGET" like "make TARGET" (make vanilla-scratch-build).
#
vanilla-%: $(SPECFILE:.spec=-vanilla.spec)
	@$(MAKE) $* SPECFILE=$<

$(SPECFILE:.spec=-vanilla.spec): $(SPECFILE)
	@rm -f $@
	(echo %define nopatches 1; cat $<) > $@

#scratch-build: NAME = $(shell rpm $(RPM_DEFINES) $(DIST_DEFINES) -q --qf "%{NAME}\n" --specfile $(SPECFILE)| head -1)
#scratch-build: test-srpm
#	$(BUILD_CLIENT) build $(BUILD_FLAGS) --scratch $(TARGET) \
#			$(SRCRPMDIR)/$(NAME)-$(VERSION)-$(RELEASE).src.rpm

# Dismal kludge for building via brew from cvs after "make vanilla-tag".
ifdef BEEHIVE_SRPM_BUILD
export CHECKOUT_TAG ?= $(shell sed s/^.// CVS/Tag)
tag-pattern = $(TAG_NAME)-$(TAG_VERSION)-0_%_$(TAG_RELEASE)
ifeq (,$(filter-out $(tag-pattern),$(CHECKOUT_TAG)))
variant := $(patsubst $(tag-pattern),%,$(CHECKOUT_TAG))
srpm: SPECFILE := $(wildcard $(SPECFILE:.spec=-$(variant).spec) \
			     $(SPECFILE:.spec=.t.$(variant).spec))
srpm beehive-sprm: RELEASE := 0.$(variant).$(RELEASE)
endif
endif

#
# Hacks for building kernel rpms from upstream code plus local GIT branches.
# Use "make git/BRANCH/TARGET" like "make TARGET".
# Use "make git/BRANCH-fedora/TARGET" to include Fedora patches on top.
#
ifndef GIT_SPEC
git/%:
	@$(MAKE) GIT_SPEC=$(subst /,-,$(*D)) git-$(*F)
else
git-%: $(SPECFILE:.spec=.t.$(GIT_SPEC).spec)
	@$(MAKE) GIT_SPEC= $* SPECFILE=$<
endif

#
# Your git-branches.mk file can define GIT_DIR, e.g.:
#	GIT_DIR = ${HOME}/kernel/.git
# Make sure GIT_AUTHOR_NAME and GIT_AUTHOR_EMAIL are also set
# or your rpm changelogs will look like crap.
#
# For each branch it can define a variable branch-BRANCH or tag-BRANCH
# giving the parent of BRANCH to diff against in a separate patch.  If
# the parent is unknown, it will use $(branch-upstream) defaulting to
# "refs/remotes/upstream/master".
#
# Defining tag-BRANCH means the tag corresponds to an upstream patch in
# the sources file, so that is used instead of generating a patch with
# git.  If there is no tag-upstream defined, it will figure out a vNNN
# tag or vNNN-gitN pseudo-tag from the last patch in the sources file.
# For example:
#	tag-some-hacks = v2.6.21-rc5
#	branch-more-hacks = some-hacks
# Leads to patches:
#	git diff v2.6.21-rc5..more-hacks > linux-2.6.21-rc5-some-hacks.patch
#	git diff some-hacks..more-hacks > linux-2.6.21-rc5-more-hacks.patch
# Whereas having no git-branches.mk at all but doing
# "make GIT_DIR=... git/mybranch/test-srpm" does:
#	id=`cat patch-2.6.21-rc5-git4.id` # auto-fetched via upstream file
#	git diff $id..upstream > linux-2.6.21-rc5-git4-upstream.patch
#	git diff upstream..mybranch > linux-2.6.21-rc5-git4-mybranch.patch
# If the upstream patch (or any branch patch) is empty it's left out.
#
git-branches.mk:;
-include git-branches.mk

branch-upstream ?= refs/remotes/upstream/master

ifdef GIT_DIR
export GIT_DIR
export GIT_AUTHOR_NAME
export GIT_AUTHOR_EMAIL
gen-patches ?= gen-patches

ifndef havespec
$(SPECFILE:.spec=.t.%-fedora.spec): $(SPECFILE) $(gen-patches) FORCE
	./$(gen-patches) --fedora < $< > $@ $(gen-patches-args)
$(SPECFILE:.spec=.t.%.spec): $(SPECFILE) $(gen-patches) FORCE
	./$(gen-patches) < $< > $@ $(gen-patches-args)
.PRECIOUS: $(SPECFILE:.spec=.t.%.spec) $(SPECFILE:.spec=.t.%-fedora.spec)
endif

spec-%: $(SPECFILE:.spec=.t.%.spec) ;
$(SPECFILE):;
FORCE:;

branch-of-* = $(firstword $(head-$*) $*)
gen-patches-args = --name $* v$(KVERSION) $(call heads,$(branch-of-*))
define heads
$(if $(tag-$1),$(filter-out v$(KVERSION),$(tag-$1)),\
     $(call heads,$(firstword $(branch-$1) $(branch-upstream)))) $1
endef

files-%-fedora:
	@echo $(SPECFILE:.spec=.t.$*-fedora.spec)
	@$(call list-patches,$(branch-of-*))
files-%:
	@echo $(SPECFILE:.spec=.t.$*.spec)
	@$(call list-patches,$(branch-of-*))
define list-patches
$(if $(tag-$1),version=$(patsubst v%,%,$(tag-$1)),\
     $(call list-patches,$(firstword $(branch-$1) $(branch-upstream)))); \
echo linux-$${version}-$(patsubst refs/remotes/%/master,%,$1).patch
endef

ifndef tag-$(branch-upstream)
tag-$(branch-upstream) := $(shell \
	sed -n 's/^.*  *//;s/\.bz2$$//;s/patch-/v/;/^v/h;$${g;p}' sources)
endif
endif
