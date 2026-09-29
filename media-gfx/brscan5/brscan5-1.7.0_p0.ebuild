# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm udev

MY_PV="${PV/_p/-}"

DESCRIPTION="SANE driver for Brother scanners (brscan5)"
HOMEPAGE="https://support.brother.com"
SRC_URI="https://download.brother.com/welcome/dlf104036/${PN}-${MY_PV}.x86_64.rpm"

LICENSE="Brother-EULA"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RESTRICT="strip mirror"
QA_PREBUILT="*"

RDEPEND="
	media-gfx/sane-backends
	net-dns/avahi[dbus]
	virtual/libusb:1
"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_unpack() {
	rpm_unpack ${A}
}

src_install() {
	local lib
	local libs=(
		libLxBsScanCoreApi.so.3.2.6
		libLxBsNetDevAccs.so.1.0.0
		libLxBsDeviceAccs.so.1.0.0
		libLxBsUsbDevAccs.so.1.0.0
	)
	local bins=(
		brsaneconfig5
		brscan_cnetconfig
		brscan_gnetconfig
		setupSaneScan5
	)

	# 1. Install core shared libraries and create SONAME symlinks in /usr/lib64
	for lib in "${libs[@]}"; do
		dolib.so "opt/brother/scanner/brscan5/${lib}"

		# Extract base name (libX.so) and major version (e.g., 3 or 1)
		local base="${lib%%.so.*}.so"
		local ver="${lib#*.so.}"
		local major="${ver%%.*}"

		# Creates symlinks: libLxBsScanCoreApi.so.3.2.6 -> libLxBsScanCoreApi.so.3 -> libLxBsScanCoreApi.so
		dosym "${lib}" "/usr/lib64/${base}.${major}"
		dosym "${base}.${major}" "/usr/lib64/${base}"
	done

	# 2. Install SANE backend library and its version symlinks
	exeinto /usr/lib64/sane
	doexe opt/brother/scanner/brscan5/libsane-brother5.so.1.0.7
	dosym libsane-brother5.so.1.0.7 /usr/lib64/sane/libsane-brother5.so.1
	dosym libsane-brother5.so.1 /usr/lib64/sane/libsane-brother5.so

	# 3. Enable backend in SANE configuration directory
	insinto /etc/sane.d/dll.d
	newins - brother5.conf <<< "brother5"

	# 4. Install configuration files and models (required due to hardcoded paths in binaries)
	insinto /etc/opt/brother/scanner/brscan5
	doins opt/brother/scanner/brscan5/brscan5.ini
	doins opt/brother/scanner/brscan5/brsanenetdevice.cfg

	insinto /opt/brother/scanner/brscan5/models
	doins opt/brother/scanner/brscan5/models/*

	# 5. Install binaries to /usr/bin and maintain symlinks under /opt/brother/...
	into /usr
	for bin in "${bins[@]}"; do
		dobin "opt/brother/scanner/brscan5/${bin}"
		dosym "/usr/bin/${bin}" "/opt/brother/scanner/brscan5/${bin}"
	done

	# 6. Install udev rules
	if [[ -d "opt/brother/scanner/brscan5/udev-rules" ]]; then
		local rule_file
		rule_file=$(ls opt/brother/scanner/brscan5/udev-rules/*.rules 2>/dev/null | head -n1)
		if [[ -n "${rule_file}" ]]; then
			sed -i -e '/SYSFS/d' -e 's/SYSFS/ATTR/g' "${rule_file}" || die
			udev_newrules "${rule_file}" 40-${PN}.rules
		fi
	fi
}
