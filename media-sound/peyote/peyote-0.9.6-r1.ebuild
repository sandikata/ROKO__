# $Header: $
EAPI=3
MY_PV="peyote_${PV}"
DESCRIPTION="Конзолен Медия Плейър написан на Python"
HOMEPAGE="http://peyote.sourceforge.net"
SRC_URI="http://sourceforge.net/projects/peyote/files/Linux/${MY_PV}.tar.bz2"
LICENSE="GPL v.3"
SLOT="0"
KEYWORDS="~x86  ~amd64"
IUSE="wv wav flac ape ogg mp3 m4a mp3 vma"

DEPEND=">=dev-lang/python-2.6
	=media-libs/mutagen-1.2*	
	=dev-python/pygobject-2.28.6
    =dev-python/dbus-python-0.84.0
	=dev-python/pyinotify-0.9*"

RDEPEND="${DEPEND}"


S="${WORKDIR}/${MY_PV}"

src_unpack() {
unpack ${A}
cd ${S}
}
src_configure() {
econf || die
}

src_compile() {
emake || die
}

src_install() {
emake install DESTDIR=${D} || die "make install failed"
}

pkg_postinst() {
		elog "Неофициална версия, все още е в процес на тестване и изчистване на забелязани бъгове."
			elog "За повече информация mail: sandikata@yandex.ru jabber: roko@jabber.calculate-linux.org"
					echo						
						}


