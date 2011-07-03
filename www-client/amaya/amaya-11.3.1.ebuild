# Copyright 1999-2009 Gentoo Foundation
# Authors: Bruno Marmol & Emilien Kia & David Christensen
# Distributed under the terms of the GNU General Public License v2

# bugs:
# - can use variable for version number: for re-use after new version

inherit libtool eutils

S="${WORKDIR}/Amaya/LINUX-ELF"

DESCRIPTION="The W3C Web-Browser"
HOMEPAGE="http://www.w3.org/Amaya/"
SRC_URI="http://www.w3.org/Amaya/Distribution/${PN}-fullsrc-${PV}.tgz"
#SRC_URI="http://wam.inrialpes.fr/software/amaya/${PN}-fullsrc-${PV/_/-}3.tgz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc64 ~alpha"
IUSE="debug opengl svg +xml"
EAPI="2"

DEPEND="net-libs/libwww
				media-libs/raptor
				x11-libs/wxGTK
				svg? ( gnome-base/librsvg )
				opengl? ( virtual/opengl )"
RDEPEND="${DEPEND}"

EPATCH_OPTS="-l"

src_prepare() {
#   ${FILESDIR}/${PN}-intptr.patch \
   cd Amaya &&  epatch \
   ${FILESDIR}/${PN}-libpng14.patch \
   ${FILESDIR}/${PN}-splitmode.patch \
   ${FILESDIR}/${PN}-wakeupidle.patch \
   ${FILESDIR}/${PN}-wxyield.patch
		use opengl && rm -rf "${WORKDIR}/Mesa/"
		rm -rf "${WORKDIR}/wxWidgets"
		rm -rf "${WORKDIR}/libwww"
		rm -rf "${WORKDIR}/redland"
}

src_configure() {
    local myconf
    mkdir ${S}
    cd ${S}

    use opengl && myconf="${myconf} --with-gl"
    use debug && myconf="${myconf} --with-debug"
    use svg || myconf="${myconf} --disable-svg"
    use xml || myconf="${myconf} --disable-generic-xml"

    ../configure \
        --prefix=/usr \
        --host=${CHOST} \
        --mandir=/usr/share/man\
        --infodir=/usr/share/info \
        --datadir=/usr/share \
        --sysconfdir=/etc \
        --localstatedir=/var/lib \
        --docdir=/usr/share/doc/${PF} \
        --enable-system-libwww \
        --enable-system-raptor \
        --enable-system-wx \
        ${myconf}

#        --bindir=/usr/bin \
#        --sbindir=/usr/sbin \
#        --libexecdir=/usr/libexec \
#        --libdir=/usr/lib \
#        --includedir=/usr/include \


}

src_compile() {
#	make CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" || die
	make || die
}

src_install () {
		dodir /usr
		einstall || die
		#make install DESTDIR=${D} || die
		./script_install_gnomekde . ${D}/usr/share /usr || die

		rm ${D}/usr/bin/amaya
		rm ${D}/usr/bin/print
		dosym /usr/Amaya/wx/bin/amaya /usr/bin/amaya
		dosym /usr/Amaya/wx/bin/print /usr/bin/print

		domenu share/applications/amaya.desktop
		newicon ${WORKDIR}/Amaya/resources/bundle/logo.png amaya.png
}
