EAPI="4"
PYTHON_DEPEND="2:2.7"


inherit eutils fdo-mime gnome2-utils python distutils

DESCRIPTION="Good music and video player"
HOMEPAGE="http://www.foobnix.com/"
SRC_URI="https://launchpad.net/~foobnix-team/+archive/ubuntu/foobnix-player/+files/foobnix_2.6.10raring.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RDEPEND="
	dev-python/setuptools
	dev-python/pygtk:2
	sys-devel/gettext
	dev-python/chardet
	dev-python/notify-python
	media-libs/mutagen
	dev-python/simplejson
	dev-python/gst-python:0.10
	media-plugins/gst-plugins-meta:0.10
	"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}_${PV}"

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	distutils_pkg_postinst
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	distutils_pkg_postrm
	gnome2_icon_cache_update
}
