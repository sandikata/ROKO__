# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

K_DEBLOB_AVAILABLE="0"
K_SECURITY_UNSUPPORTED="1"

ETYPE="sources"

inherit kernel-2 eutils
detect_version
detect_arch

DESCRIPTION="Fedora Core Linux patchset for the ${KV_MAJOR}.${KV_MINOR} linux kernel tree"
RESTRICT="nomirror"
IUSE=""
UNIPATCH_STRICTORDER="yes"
KEYWORDS="~amd64 ~x86"
HOMEPAGE="http://fedoraproject.org/ http://download.fedora.redhat.com/pub/fedora/linux/development/source/SRPMS/"
SRC_URI="${KERNEL_URI}"

KV_FULL=${KV_FULL/linux/fc}
K_NOSETEXTRAVERSION="1"
EXTRAVERSION=${EXTRAVERSION/linux/fc}
SLOT="${PV}"
S="${WORKDIR}/linux-${KV_FULL}"

src_unpack() {

	kernel-2_src_unpack
	cd "${S}"

	# manually set extraversion
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" Makefile

	cp ${FILESDIR}/${PVR}/config-* . || die "cannot copy kernel config";
	cp ${FILESDIR}/${PVR}/merge.pl ${FILESDIR}/${PVR}/Makefile.config . || die "cannot copy kernel files";
	make -f Makefile.config VERSION=${PVR}-fc configs || die "cannot generate kernel .config files from config-* files"

	for cfg in config-*; do
		rm -f $cfg
	done;

	echo
	einfo "A long time ago in a galaxy far, far away...."
	echo

#	epatch "${FILESDIR}"/"${PVR}"/git-linus.diff

	# we also need compile fixes for -vanilla
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-compile-fixes.patch

	# build tweak for build ID magic, even for -vanilla
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-makefile-after_link.patch

	# Git trees.

	# Standalone patches
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-hotfixes.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-utrace-revert-make-ptrace-functions-static.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-tracehook.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-utrace.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-utrace-ptrace.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6.29-sparc-IOC_TYPECHECK.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-32bit-mmap-exec-randomization.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-i386-nx-emulation.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-debug-sizeof-structs.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-debug-taint-vm.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-debug-vm-would-have-oomkilled.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-debug-always-inline-kzalloc.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-defaults-pci_no_msi.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-defaults-pci_use_crs.patch

	# ASPM: enable powersave by default
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-defaults-aspm.patch
	epatch "${FILESDIR}"/"${PVR}"/pci-pcie-links-may-not-get-configured-for-aspm-under-powersave-mode.patch
	epatch "${FILESDIR}"/"${PVR}"/pci-enable-aspm-state-clearing-regardless-of-policy.patch

#	epatch "${FILESDIR}"/"${PVR}"/ima-allow-it-to-be-completely-disabled-and-default-off.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-defaults-acpi-video.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-acpi-video-dos.patch
	epatch "${FILESDIR}"/"${PVR}"/acpi-ec-add-delay-before-write.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-acpi-debug-infinite-loop.patch

#	epatch "${FILESDIR}"/"${PVR}"/acpi_battery-fribble-sysfs-files-from-a-resume-notifier.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-input-kill-stupid-messages.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6.30-no-pcspkr-modalias.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-serial-460800.patch

	epatch "${FILESDIR}"/"${PVR}"/die-floppy-die.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-noise.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-fbcon-logo.patch
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-selinux-mprotect-checks.patch
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-sparc-selinux-mprotect-checks.patch

	epatch "${FILESDIR}"/"${PVR}"/hda_intel-prealloc-4mb-dmabuffer.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-e1000-ich9-montevina.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-crash-driver.patch

	# crypto/

	# virt + ksm patches
	epatch "${FILESDIR}"/"${PVR}"/fix_xen_guest_on_old_EC2.patch

	# DRM

	# nouveau + drm fixes
	epatch "${FILESDIR}"/"${PVR}"/drm-nouveau-fixes.patch
	epatch "${FILESDIR}"/"${PVR}"/drm-nouveau-updates.patch
	epatch "${FILESDIR}"/"${PVR}"/drm-ttm-move-notify.patch
	epatch "${FILESDIR}"/"${PVR}"/drm-intel-big-hammer.patch
	# intel drm is all merged upstream
	# fix for 945G corruption will hit stable eventually
	epatch "${FILESDIR}"/"${PVR}"/drm-i915-fix-pipelined-fencing.patch
	# make sure the lvds comes back on lid open
	epatch "${FILESDIR}"/"${PVR}"/drm-intel-make-lvds-work.patch
	epatch "${FILESDIR}"/"${PVR}"/drm-intel-edp-fixes.patch
	epatch "${FILESDIR}"/"${PVR}"/drm-intel-eeebox-eb1007-quirk.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-intel-iommu-igfx.patch

	# linux1394 git patches
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-firewire-git-update.patch
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-firewire-git-pending.patch

	# Quiet boot fixes
	# silence the ACPI blacklist code
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-acpi-blacklist.patch

	# media patches
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-v4l-dvb-update.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-v4l-dvb-experimental.patch

#	epatch "${FILESDIR}"/"${PVR}"/flexcop-fix-xlate_proc_name-warning.patch

	# fs fixes

	# NFSv4

	# patches headed upstream

	epatch "${FILESDIR}"/"${PVR}"/add-appleir-usb-driver.patch

	epatch "${FILESDIR}"/"${PVR}"/disable-i8042-check-on-apple-mac.patch

	epatch "${FILESDIR}"/"${PVR}"/neuter_intel_microcode_load.patch

	epatch "${FILESDIR}"/"${PVR}"/apple_backlight.patch
	epatch "${FILESDIR}"/"${PVR}"/efifb_update.patch
	epatch "${FILESDIR}"/"${PVR}"/acpi_reboot.patch

	# Runtime power management
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-usb-pci-autosuspend.patch
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-enable-more-pci-autosuspend.patch

	epatch "${FILESDIR}"/"${PVR}"/dmar-disable-when-ricoh-multifunction.patch

	epatch "${FILESDIR}"/"${PVR}"/printk-do-not-mangle-valid-userspace-syslog-prefixes.patch
	epatch "${FILESDIR}"/"${PVR}"/scsi-sd-downgrade-caching-printk-from-error-to-notice.patch

#	epatch "${FILESDIR}"/"${PVR}"/iwlwifi-do-not-set-tx-power-when-channel-is-changing.patch
#	epatch "${FILESDIR}"/"${PVR}"/iwl3945-do-not-deprecate-software-scan.patch
#	epatch "${FILESDIR}"/"${PVR}"/iwl3945-disable-hw-scan-by-default.patch
#	epatch "${FILESDIR}"/"${PVR}"/iwlwifi-fix-tx_power-initialization.patch

	#netconsole fixes
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-netconsole-deadlock.patch


# END OF PATCH APPLICATIONS

#my
	epatch "${FILESDIR}"/"${PVR}"/font-8x16-iso-latin-1.patch

#	if use reiser4 ; then
#		epatch ${DISTDIR}/reiser4-for-${PV}.patch.bz2
#	fi
}

src_install() {
	local version_h_name="usr/src/linux-${KV_FULL}/include/linux"
	local version_h="${ROOT}${version_h_name}"
	if [ -f "${version_h}" ]; then
		einfo "Discarding previously installed version.h to avoid collisions"
		addwrite "/${version_h_name}"
		rm -f "${version_h}"
	fi

	kernel-2_src_install
}
