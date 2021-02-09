# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"

inherit multilib unpacker

MY_PV=${PV/_p/-}
MY_PN=${PN%%-bin-debian}

DESCRIPTION="Fast,free secure and powerful web browser based on Google-Chrome."
HOMEPAGE="http://www.slimjet.com/en/dlpage.php"
#SRC_URI="mirror://debian/pool/main/${PN:0:1}/${PN:0:8}-browser/${PN:0:8}_${MY_PV}_amd64.deb"
SRC_URI="amd64? ( http://www.slimjet.com/release/${PN}_amd64.deb )"

LICENSE="Freeware"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="app-arch/dpkg"
RDEPEND="
	sys-libs/libstdc++-v3
	>=dev-libs/openssl-0.9
	>=sys-libs/zlib-1.1.4
	media-libs/libjpeg-turbo
	>=media-libs/gstreamer-0.10
	media-libs/flac
	media-libs/harfbuzz
	x11-libs/libXtst
	dev-libs/nss
	dev-libs/nspr
	media-libs/opus
	app-arch/snappy
	app-accessibility/speech-dispatcher
	virtual/ttf-fonts
	x11-misc/xdg-utils
	dev-util/desktop-file-utils
	x11-themes/hicolor-icon-theme
	media-libs/libpng
	"

S=${WORKDIR}

QA_PREBUILT="usr/lib*/${MY_PN}/*"

RESTRICT="strip"

src_install() {
	cp -pPR "${WORKDIR}"/* "${D}"/ || die "copying files failed!"
	insinto opt/slimjet/lib
	#dosym  opt/slimjet/lib opt/slimjet/libffmpeg.so
	doins opt/slimjet/libffmpeg.so
	
	_libudev_0=libudev.so.0
    _libudev_1=libudev.so.1
    
    ln -snf "/$(get_libdir)/$_libudev_1" "${D}/opt/slimjet/$_libudev_0"
   
     _crypto_files="libnspr4.so.0d libplds4.so.0d libplc4.so.0d libssl3.so.1d libnss3.so.1d libsmime3.so.1d libnssutil3.so.1d"
    _libdir="/usr/lib"

       
      for f in $_crypto_files; do 
        target=$(echo $f | sed 's/.[01]d$//')
        if [ -f "/$_libdir/$target" ]; then
            ln -snf "/$_libdir/$target" "${D}/opt/slimjet/$f"
            else echo "CHECK NSS, OPENSSL, AND NSPR VERSIONS"
            exit 1
        fi
        done

	for i in 16x16 22x22 24x24 32x32 48x48 64x64 128x128 256x256; do
        install -Dm644 "${D}"/opt/slimjet/product_logo_${i/x*}.png \
                       "${D}"/usr/share/icons/hicolor/$i/apps/flashpeak-slimjet.png
    done

}
