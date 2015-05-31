# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools

DESCRIPTION="extensions for cinnamon's file-manager nemo"
HOMEPAGE=""
SRC_URI="https://github.com/linuxmint/nemo-extensions/archive/2.2.x.zip"
LICENSE=""
SLOT="0"
KEYWORDS="~amd64"

# Possible extensions that have to be tested
# -compare -dropbox -foldercolor -gtkhash -imageconverter -mediacolumns -pastebin -preview -python -rabbitvcs -repairer -seahorse -share -terminal

# Tested extensions
IUSE="fileroller compare dropbox foldercolor gtkhash imageconverter mediacolumns pastebin preview -python rabbitvcs repairer seahorse share terminal"
MODULES=${IUSE//-/}

DEPEND="( =gnome-extra/nemo-2* )
		fileroller? ( app-arch/file-roller )"

RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
    cd "${S}"
	mv ${PN}-2.2.x ${P}
}

src_prepare () {
	for module in ${MODULES}
		do
		if use ${module}
			then
			elog "Preparing ${module}"
			pushd nemo-${module}
			eautoreconf
			popd
		fi
	done
}

src_configure () {
	for module in ${MODULES}
		do
		if use ${module}
			then
			elog "Configuring ${module}"
			pushd nemo-${module}
			econf
			popd
		fi
	done
}

src_compile () {
	for module in ${MODULES}
		do
		if use ${module}
			then
			elog "Compiling ${module}"
			pushd nemo-${module}
			emake
			popd
		fi
	done
}

src_install () {
	for module in ${MODULES}
		do
		if use ${module}
			then
			elog "Installing ${module}"
			pushd nemo-${module}
			emake DESTDIR="${D}" install
			elog "Removing .a and .la files"
			find ${D} -name "*.a" -exec rm {} + -o -name "*.la" -exec rm {} + || die
			dodoc README
			popd
		fi
	done
}
