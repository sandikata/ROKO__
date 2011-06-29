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

	# revert upstream patches we get via other methods
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-upstream-reverts.patch

	# Standalone patches
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-hotfixes.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-tracehook.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-utrace.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-utrace-ptrace.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6.29-sparc-IOC_TYPECHECK.patch

#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-32bit-mmap-exec-randomization.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-i386-nx-emulation.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-debug-sizeof-structs.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-debug-taint-vm.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-debug-vm-would-have-oomkilled.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-debug-always-inline-kzalloc.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-defaults-pci_no_msi.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-defaults-pci_use_crs.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-defaults-aspm.patch
	epatch "${FILESDIR}"/"${PVR}"/pci-_osc-supported-field-should-contain-supported-features-not-enabled-ones.patch

#	epatch "${FILESDIR}"/"${PVR}"/ima-allow-it-to-be-completely-disabled-and-default-off.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-defaults-acpi-video.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-acpi-video-dos.patch
	epatch "${FILESDIR}"/"${PVR}"/acpi-ec-add-delay-before-write.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-acpi-debug-infinite-loop.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-input-kill-stupid-messages.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6.30-no-pcspkr-modalias.patch
#	epatch "${FILESDIR}"/"${PVR}"/thinkpad-acpi-fix-backlight.patch

#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-serial-460800.patch

	epatch "${FILESDIR}"/"${PVR}"/die-floppy-die.patch

#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-noise.patch
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-fbcon-logo.patch
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-selinux-mprotect-checks.patch
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-sparc-selinux-mprotect-checks.patch

	epatch "${FILESDIR}"/"${PVR}"/hda_intel-prealloc-4mb-dmabuffer.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-e1000-ich9-montevina.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-crash-driver.patch

	# crypto

	# virt 0 ksm patches
	epatch "${FILESDIR}"/"${PVR}"/fix_xen_guest_on_old_EC2.patch

	# DRM

	# nouveau 0 drm fixes
#	epatch "${FILESDIR}"/"${PVR}"/drm-nouveau-updates.patch
#	epatch "${FILESDIR}"/"${PVR}"/drm-intel-big-hammer.patch
	# intel drm is all merged upstream
#	epatch "${FILESDIR}"/"${PVR}"/drm-intel-next.patch
	# make sure the lvds comes back on lid open
	epatch "${FILESDIR}"/"${PVR}"/drm-intel-make-lvds-work.patch
	epatch "${FILESDIR}"/"${PVR}"/drm-intel-edp-fixes.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-intel-iommu-igfx.patch

	# linux1394 git patches
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-firewire-git-update.patch
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-firewire-git-pending.patch

	# Quiet boot fixes
	# silence the ACPI blacklist code
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-acpi-blacklist.patch

	# media patches
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-v4l-dvb-fixes.patch
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-v4l-dvb-update.patch
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-v4l-dvb-experimental.patch
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-v4l-dvb-uvcvideo-update.patch

#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-v4l-dvb-add-lgdt3304-support.patch
#	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-v4l-dvb-ir-core-update.patch

	#epatch ${FILESDIR}/${PV}/lirc-staging-2.6.36-fixes.patch
	#epatch ${FILESDIR}/${PV}/hdpvr-ir-enable.patch

	epatch "${FILESDIR}"/"${PVR}"/flexcop-fix-xlate_proc_name-warning.patch

	# fs fixes

	# NFSv4

	# patches headed upstream
#	epatch "${FILESDIR}"/"${PVR}"/perf-gcc460-build-fixes.patch
	epatch "${FILESDIR}"/"${PVR}"/add-appleir-usb-driver.patch
	epatch "${FILESDIR}"/"${PVR}"/disable-i8042-check-on-apple-mac.patch
#	epatch "${FILESDIR}"/"${PVR}"/prevent-runtime-conntrack-changes.patch
	epatch "${FILESDIR}"/"${PVR}"/neuter_intel_microcode_load.patch
	epatch "${FILESDIR}"/"${PVR}"/apple_backlight.patch
	epatch "${FILESDIR}"/"${PVR}"/efifb_update.patch
	epatch "${FILESDIR}"/"${PVR}"/acpi_reboot.patch
	epatch "${FILESDIR}"/"${PVR}"/efi_default_physical.patch

	# Runtime power management
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-ehci-check-port-status.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-usb-pci-autosuspend.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-enable-more-pci-autosuspend.patch
#	epatch "${FILESDIR}"/"${PVR}"/runtime_pm_fixups.patch

	epatch "${FILESDIR}"/"${PVR}"/dmar-disable-when-ricoh-multifunction.patch

#	epatch "${FILESDIR}"/"${PVR}"/fs-call-security_d_instantiate-in-d_obtain_alias.patch

#	epatch "${FILESDIR}"/"${PVR}"/ath5k-fix-fast-channel-change.patch

	# rhbz#676860
#	epatch "${FILESDIR}"/"${PVR}"/usb-sierra-add-airprime-direct-ip.patch


# END OF PATCH APPLICATIONS

#my
#	epatch "${FILESDIR}"/"${PVR}"/font_8x16_iso_latin-1.patch

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
