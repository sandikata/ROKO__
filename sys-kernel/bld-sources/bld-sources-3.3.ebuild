# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
K_SECURITY_UNSUPPORTED="1"
K_DEBLOB_AVAILABLE="1"
CKV=3.3.1
EXTRAVERSION=-bld
ETYPE="sources"
#inherit calculate-kernel-old
inherit kernel-2 eutils
detect_version
detect_arch

DESCRIPTION="This is an alternate CPU load distribution technique for Linux kernel scheduler. "
HOMEPAGE="http://code.google.com/p/bld/"
SRC_URI="${KERNEL_URI}"

LICENSE=""
SLOT="3.3"
KEYWORDS="amd64 x86"
IUSE="deblob +vmlinuz"

DEPEND="dev-libs/klibc
	sys-apps/v86d
	sys-kernel/calckernel"
RDEPEND="${DEPEND}"

src_prepare() {
	cp "${FILESDIR}"/config* . || die
#	cp config-desktop-`uname -m`-3.3 .config || die "Can't copy config file!"
	epatch "${FILESDIR}"/BLD_3.3-rc3-feb12.patch
	epatch "${FILESDIR}"/4200_fbcondecor-0.9.6.patch
}

src_compile() {
	! use vmlinuz && return
	install -d ${WORKDIR}/out/{lib,boot}
	install -d ${T}/{cache,twork}
	install -d $WORKDIR/build $WORKDIR/out/lib/firmware
	genkernel --kernel-config="config-desktop-`uname -m`-3.3" --no-save-config --loglevel=5 --kernname="${PN}" --kerneldir="$S" --tempdir=${WORKDIR}/build --makeopts="${MAKEOPTS}" --firmware-dir=${WORKDIR}/out/lib/firmware --cachedir="${T}/cache" --tempdir="${T}/twork" --logfile="${WORKDIR}/genkernel.log" --bootdir="${WORKDIR}/out/boot" --lvm --luks --iscsi --module-prefix="${WORKDIR}/out" all || die "genkernel failed"
}

src_install() {
	dodir /usr/src
	cp -a ${S} ${D}/usr/src/linux-${P} || die
	cd ${D}/usr/src/linux-${P}
	make mrproper || die
	cp ${T}/config .config || die
	yes "" | make oldconfig || die
	use binary || return
	make prepare || die
	make scripts || die
	cp -a ${WORKDIR}/out/* ${D}/ || die "couldn't copy output files into place"
	rm -f ${D}/lib/modules/*/source || die
	rm -f ${D}/lib/modules/*/build || die
	cd ${D}/lib/modules
	find -iname *.ko -exec strip --strip-debug {} \;
	local moddir="$(ls -d [23]*)"
	ln -s /usr/src/linux-${P} ${D}/lib/modules/${moddir}/source || die
	ln -s /usr/src/linux-${P} ${D}/lib/modules/${moddir}/build || die
}

pkg_postinst() {
	if [ ! -e ${ROOT}usr/src/linux ]
	then
	ln -s linux-${P} ${ROOT}usr/src/linux
	fi
}
