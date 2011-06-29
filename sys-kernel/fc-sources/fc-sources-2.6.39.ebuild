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

#	cp ${FILESDIR}/${PVR}/config-* . || die "cannot copy kernel config";
#	cp ${FILESDIR}/${PVR}/merge.pl ${FILESDIR}/${PVR}/Makefile.config . || die "cannot copy kernel files";
#	make -f Makefile.config VERSION=${PVR}-fc configs || die "cannot generate kernel .config files from config-* files"

#	for cfg in config-*; do
#		rm -f $cfg
#	done;

	echo
	einfo "A long time ago in a galaxy far, far away...."
	echo

	epatch "${FILESDIR}"/"${PVR}"/acpi-ec-add-delay-before-write.patch

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
