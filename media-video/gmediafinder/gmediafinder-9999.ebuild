# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

PYTHON_DEPEND="2"

EGIT_REPO_URI="https://github.com/smolleyes/gmediafinder"

inherit gnome2-utils git-2

DESCRIPTION="Software to search/play stream and/or download files form youtube, youporn and some mp3 searchengines"
HOMEPAGE="https://github.com/smolleyes/gmediafinder"

LICENSE="GPL-2"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~x86"

DEPEND="dev-python/setuptools 
  	dev-python/python-distutils-extra
	dev-vcs/git"
	
RDEPEND="dev-python/pygtk:2
	 dev-python/gst-python
	 >=dev-python/beautifulsoup-3.2
	 dev-python/html5lib
	 dev-python/mechanize
	 dev-python/gdata
	 dev-python/configobj
	 media-plugins/gst-plugins-ffmpeg
	 media-plugins/gst-plugins-libvisual
	 dev-python/python-xlib"

src_prepare() {
        :
}

src_configure() {
	:
}

src_compile()	{
	:
}

src_install()	{
	python setup.py install --root=${D}
}

pkg_postins()	{
	gnome2_icon_cache_update
}
