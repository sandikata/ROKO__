# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Open Source Video Calls and Chat"
HOMEPAGE="https://jitsi.org/"
SRC_URI="https://github.com/${PN}/${PN}/archive/${PN^}-${PV}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=virtual/jdk-1.6"
RDEPEND=">=virtual/jre-1.6"

S=${WORKDIR}/${PN}-${PN^}-${PV}
RESTRICT="strip"

QA_PREBUILT="usr/share/jitsi/lib/native/*"

src_prepare() {
	epatch "${FILESDIR}"/${P}-gtk-laf.patch

	# Leave linux and mac .jars only (without mac we get build errors from src/net/java/sip/communicator/...)
	rm -R lib/os-specific/{freebsd,solaris,windows}/ || die

	# Leave linux-64 .so files only:
	rm -R lib/native/{freebsd{,-64},linux,mac,solaris{,-sparc},windows{,-64}}/ || die

	ewarn "Bundled .jar files left to unbundle:"
	ewarn "$(find . -type f -name '*.jar')"
	ewarn
	ewarn "Bundled .so files left to unbundle:"
	ewarn "$(find . -type f -name '*.so')"
}

src_compile() {
	eant make deploy-os-specific-bundles || die
}

src_install() {
	# Basically re-create .rpm structure
	# .jar files
	insinto /usr/share/${PN}/lib/bundle/
	doins lib/bundle/commons-logging.jar
	doins lib/bundle/log4j.jar
	doins lib/bundle/org.apache.felix.bundlerepository-1.6.4.jar

	insinto /usr/share/${PN}/lib/
	doins lib/felix.jar
	doins lib/jdic-all.jar
	doins lib/os-specific/linux/jdic_stub.jar

	insinto /usr/share/${PN}/
	doins -r sc-bundles
	rm -R "${D}"/usr/share/jitsi/sc-bundles/os-specific/{freebsd,macosx,solaris,windows}/ || die

	java-pkg_regjar /usr/share/${PN}/lib/jdic-all.jar
	java-pkg_regjar /usr/share/${PN}/lib/jdic_stub.jar
	java-pkg_regjar /usr/share/${PN}/lib/felix.jar
	java-pkg_regjar /usr/share/${PN}/sc-bundles/sc-launcher.jar
	java-pkg_regjar /usr/share/${PN}/sc-bundles/util.jar

	# *.properties
	insinto /usr/share/${PN}/lib/
	doins lib/felix.client.run.properties
	doins lib/logging.properties

	# .so files
	insinto /usr/share/${PN}/lib/native/
	doins lib/native/linux-64/*.so
	java-pkg_regso "${D}"/usr/share/${PN}/lib/native/*.so

	# Icons
	insinto /usr/share/pixmaps/
	doins resources/install/debian/${PN}.svg

	# Launchers
	local SCDIR=/usr/share/${PN}
	local LIBPATH=${SCDIR}/lib
	local FELIX_CONFIG=${LIBPATH}/felix.client.run.properties
	local LOG_CONFIG=${LIBPATH}/logging.properties

	local JAVA_ARGS="-client -Xmx1024m"
	JAVA_ARGS+=" -Djna.library.path=${LIBPATH}/native"
	JAVA_ARGS+=" -Dfelix.config.properties=file://${FELIX_CONFIG}"
	JAVA_ARGS+=" -Djava.util.logging.config.file=${LOG_CONFIG}"

	java-pkg_dolauncher ${PN} \
			--main net.java.sip.communicator.launcher.SIPCommunicator \
			--java_args "${JAVA_ARGS}" \
			--pwd "${SCDIR}"

	make_desktop_entry ${PN} ${PN^} ${PN}
}
