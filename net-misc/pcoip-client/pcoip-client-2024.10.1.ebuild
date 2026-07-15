# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit unpacker xdg-utils fcaps

DESCRIPTION="Teradici PCOIP client for x86_64 (64bit) Linux"

HOMEPAGE="https://www.teradici.com/"

UBUNTU="22.04"

SRC_URI="https://dl.teradici.com/DeAdBCiUYInHcSTy/pcoip-client/deb/ubuntu/pool/focal/main/p/pc/pcoip-client_${PV}-${UBUNTU}/pcoip-client_${PV}-${UBUNTU}_amd64.deb
http://se.archive.ubuntu.com/ubuntu/pool/main/p/protobuf/libprotobuf23_3.12.4-1ubuntu7_amd64.deb
http://se.archive.ubuntu.com/ubuntu/pool/universe/h/hiredis/libhiredis0.14_0.14.1-2_amd64.deb
http://se.archive.ubuntu.com/ubuntu/pool/main/b/boost1.71/libboost-system1.71.0_1.71.0-6ubuntu6_amd64.deb
http://se.archive.ubuntu.com/ubuntu/pool/main/b/boost1.71/libboost-thread1.71.0_1.71.0-6ubuntu6_amd64.deb
http://se.archive.ubuntu.com/ubuntu/pool/main/b/boost1.71/libboost-chrono1.71.0_1.71.0-6ubuntu6_amd64.deb
http://se.archive.ubuntu.com/ubuntu/pool/main/b/boost1.71/libboost-filesystem1.71.0_1.71.0-6ubuntu6_amd64.deb
http://se.archive.ubuntu.com/ubuntu/pool/universe/b/boost1.71/libboost-regex1.71.0_1.71.0-6ubuntu6_amd64.deb
http://se.archive.ubuntu.com/ubuntu/pool/main/b/boost1.71/libboost-serialization1.71.0_1.71.0-6ubuntu6_amd64.deb
http://se.archive.ubuntu.com/ubuntu/pool/universe/b/boost1.71/libboost-random1.71.0_1.71.0-6ubuntu6_amd64.deb
http://se.archive.ubuntu.com/ubuntu/pool/universe/b/boost1.71/libboost-container1.71.0_1.71.0-6ubuntu6_amd64.deb
"

LICENSE="Teradici"

SLOT="0"

KEYWORDS="-* ~amd64"

RDEPEND="
	sys-apps/pcsc-lite
"

BDEPEND="
	app-arch/gzip
	dev-util/patchelf
	sys-libs/libcap
"


S="${WORKDIR}"

QA_PREBUILT="
	/usr/bin/pcoip-client
	/usr/lib64/pcoip-client/*.so*
	/usr/lib64/pcoip-client/*/*.so*
	/usr/libexec/pcoip-client/usb-helper
"


src_prepare() {
	default

	patchelf --replace-needed libGraphicsMagick++-Q16.so.12 libGraphicsMagick++.so.12 "usr/lib/x86_64-linux-gnu/org.hp.pcoip-client/vchan_plugins/libvchan-plugin-clipboard.so" || die "Unable to patch libvchan-plugin-clipboard.so for libGraphicsMagick++.so.12"

	gunzip usr/share/man/man8/pcoip-configure-kernel-networking.8.gz || die "Failed to uncompress man"
}

src_install() {
	dobin usr/bin/pcoip-client-support-bundler
	exeinto /usr/sbin
	doexe usr/sbin/pcoip-configure-kernel-networking

	insinto /usr/lib64/pcoip-client
	patchelf --set-rpath  '/usr/lib64/pcoip-client' usr/libexec/pcoip-client/pcoip-client || die "Failed to set rpath"
	doins usr/libexec/pcoip-client/pcoip-client

	cat <<EOF > "${T}/pcoip-client"
#!/bin/sh
export QML2_IMPORT_PATH="/usr/lib64/pcoip-client/qml"
export QT_PLUGIN_PATH="/usr/lib64/pcoip-client/plugins"
export QT_QPA_PLATFORM_PLUGIN_PATH="/usr/lib64/pcoip-client/plugins/platforms"
exec /usr/lib64/pcoip-client/pcoip-client"\$@"
EOF

	dobin "${T}/pcoip-client"

	doins -r usr/lib/x86_64-linux-gnu/pcoip-client/*

	doins usr/lib/x86_64-linux-gnu/libprotobuf.so.23{,.0.4}
	doins usr/lib/x86_64-linux-gnu/libhiredis.so.0.14
	doins usr/lib/x86_64-linux-gnu/libboost_system.so.1.71.0
	doins usr/lib/x86_64-linux-gnu/libboost_thread.so.1.71.0
	doins usr/lib/x86_64-linux-gnu/libboost_chrono.so.1.71.0
	doins usr/lib/x86_64-linux-gnu/libboost_filesystem.so.1.71.0
	doins usr/lib/x86_64-linux-gnu/libboost_regex.so.1.71.0
	doins usr/lib/x86_64-linux-gnu/libboost_serialization.so.1.71.0
	doins usr/lib/x86_64-linux-gnu/libboost_random.so.1.71.0
	doins usr/lib/x86_64-linux-gnu/libboost_container.so.1.71.0

	insinto /usr/lib64/org.hp.pcoip-client/vchan_plugins
	doins usr/lib/x86_64-linux-gnu/org.hp.pcoip-client/vchan_plugins/libvchan-plugin-clipboard.so

	find "${ED}/usr/lib64/" -name "*.so*" -type f -exec chmod +x {} \; || die "Change .so permission failed"
	find "${ED}/usr/lib64/" -type f -name "*.so" -exec patchelf --set-rpath "/usr/lib64/pcoip-client" {} + || die "Failed to set rpath"

	exeinto /usr/libexec/pcoip-client
	doexe usr/libexec/pcoip-client/usb-helper

	insinto /usr/share/{applications,fonts,icons}
	doins -r usr/share/*

	insinto /usr/share/doc/"${P}"
	doins usr/share/doc/client/pcoip-client/copyright

	doman usr/share/man/man8/pcoip-configure-kernel-networking.8

}

pkg_postinst() {
	chmod +x /usr/lib64/pcoip-client/pcoip-client || die "Change pcoip-client permission failed"
	fcaps cap_setgid+p /usr/lib64/pcoip-client/pcoip-client

	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
