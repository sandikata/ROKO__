# Copyleft Calculate Linux 2007 - 2011
# Автор: Росен Александров - sandikata@yandex.ru - roko@jabber.calculate-linux.org - Freenode - ROKO__
# $Header: $
EAPI=3

DESCRIPTION="Програма за извличане на подробна информация за системата."
HOMEPAGE="http://code.google.com/p/inxi/"
SRC_URI="http://smxi.org/inxi"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"

src_unpack() {
	cp "${DISTDIR}"/inxi ${PN} || die
}

src_install() {
	dobin ${PN} || die
}

pkg_postinst() {
	distutils_pkg_postinst
	elog "За да видите кратка или пълна информация за системата."
	elog "inxi -b за кратка и inxi -F за пълна информация."
	elog "inxi -h за да видите допълнителните опции."
	echo
	bash-completion_pkg_postinst
}


