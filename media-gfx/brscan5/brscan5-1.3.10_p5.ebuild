# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm udev

MY_PV="${PV/_p/-}"

DESCRIPTION="SANE driver for Brother DS-series scanners (brscan5)"
HOMEPAGE="http://welcome.solutions.brother.com/bsc/public_s/id/linux/en/index.html"
SRC_URI="https://download.brother.com/welcome/dlf104036/${PN/-bin}-${MY_PV}.x86_64.rpm"

RESTRICT="strip mirror"
QA_PREBUILT=".*"

LICENSE="Brother-EULA"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	media-gfx/sane-backends
	net-dns/avahi[dbus]
	"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_unpack() {
	rpm_unpack ${A}
}

src_install() {
	local v
	local l

	for l in libLxBsNetDevAccs.so.1.0.0 libLxBsScanCoreApi.so.3.2.1 libLxBsUsbDevAccs.so.1.0.0 libLxBsDeviceAccs.so.1.0.0 libsane-brother5.so.1.0.7
	do
		v=$(echo "$l" | sed 's/^.*\.so\.//')
		p=$(basename "$l" ".$v")

		ln -s "$l" "opt/brother/scanner/brscan5/$p."$(ver_cut 1 $v) || die
		ln -s "$l" "opt/brother/scanner/brscan5/$p" || die
	done

	# ???
	dosym "libLxBsScanCoreApi.so.3.2.1" "usr/lib64/libScanCoreApi.so"

	dolib.so "${WORKDIR}"/opt/brother/scanner/brscan5/libLxBs*.so*

	insinto /usr/lib64/sane
	insopts -m0755
	doins opt/brother/scanner/brscan5/libsane-brother5.so*

	insinto /etc/sane.d/dll.d
	insopts -m0644
	doins "${FILESDIR}/brother5.conf"

	# path is hard-coded in libsane-brother5 library
	insinto /etc/opt/brother/scanner/brscan5
	insopts -m0644
	doins "opt/brother/scanner/brscan5/brscan5.ini"
	doins "opt/brother/scanner/brscan5/brsanenetdevice.cfg"

	# path is hard-coded in libsane-brother5 library
	insinto /opt/brother/scanner/brscan5/models
	doins "opt/brother/scanner/brscan5/models"/*

	exeinto /usr/bin
	doexe "opt/brother/scanner/brscan5/setupSaneScan5"
	doexe "opt/brother/scanner/brscan5/brscan_gnetconfig"
	doexe "opt/brother/scanner/brscan5/brscan_cnetconfig"
	doexe "opt/brother/scanner/brscan5/brsaneconfig5"

	# fix SYSFS in udev rules
	sed -i -e 's/SYSFS/ATTR/g' "opt/brother/scanner/brscan5/udev-rules/NN-brother-mfp-brscan5-1.0.2-2.rules"
	udev_dorules "opt/brother/scanner/brscan5/udev-rules/NN-brother-mfp-brscan5-1.0.2-2.rules"
}

