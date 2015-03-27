# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit multilib python-r1 unpacker

DESCRIPTION="ACE Stream Engine"
HOMEPAGE="http://torrentstream.org/"
SRC_URI=" amd64? ( http://dl.acestream.org/ubuntu/12/acestream_3.0.5.1_ubuntu_12.04_x86_64.tar.gz )
	  x86? ( http://dl.acestream.org/ubuntu/12/acestream_3.0.3_ubuntu_12.04_i686.tar.gz )"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+gtk"

DEPEND="dev-python/m2crypto[${PYTHON_USEDEP}]
		dev-python/apsw[${PYTHON_USEDEP}]
		gtk? ( dev-libs/acestream-python-appindicator )
		dev-python/python-xlib
		dev-python/setuptools"
RDEPEND="${DEPEND}"

S="${WORKDIR}"/acestream_3.0.5.1_ubuntu_12.04_x86_64

QA_PRESTRIPPED="usr/bin/acestreamengine
usr/share/acestream/lib/acestreamengine/Core.so
usr/share/acestream/lib/acestreamengine/node.so
usr/share/acestream/lib/acestreamengine/pycompat.so
usr/share/acestream/lib/acestreamengine/Transport.so
usr/share/acestream/lib/acestreamengine/CoreApp.so
usr/share/acestream/lib/acestreamengine/streamer.so"

pkg_setup() {
	use amd64 && S="${WORKDIR}"/acestream_3.0.5.1_ubuntu_12.04_x86_64
	use x86 && S="${WORKDIR}"/acestream_3.0.3_ubuntu_12.04_i686
}

src_install(){
	dodir /usr/share/acestream
	insinto /usr/share/acestream
	cp -R "${S}"/* "${D}/usr/share/acestream" || die "Install failed!"
	dosym /usr/share/acestream/acestreamengine /usr/bin/acestreamengine
}
