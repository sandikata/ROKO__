EAPI=8

inherit desktop xdg

DESCRIPTION="LM Studio – Local LLM desktop app (binary .deb repack)"
HOMEPAGE="https://lmstudio.ai/"
SRC_URI="https://installers.lmstudio.ai/linux/x64/${PV}-2/LM-Studio-${PV}-2-x64.deb"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip mirror"
IUSE="rocm"

# ar е нужен само за unpack на .deb
BDEPEND="
    sys-devel/binutils
"

RDEPEND="
    app-arch/xz-utils
    dev-libs/nss
    media-libs/alsa-lib
    x11-libs/libX11
    x11-libs/libxcb
"

QA_PREBUILT="*"

S="${WORKDIR}"

src_unpack() {
    einfo "Unpacking Debian package"
    ar x "${DISTDIR}/${A}" || die "ar unpack failed"

    einfo "Extracting data.tar"
    tar xf data.tar.* || die "data.tar extract failed"
}

src_install() {
    einfo "Installing LM Studio files"

    cp -R opt "${D}/" || die
    cp -R usr "${D}/" || die

    #exeinto /usr/bin
    #doexe "${FILESDIR}"/lmstudio-wrapper.sh

    dodoc "${WORKDIR}"/usr/share/doc/lm-studio/* 2>/dev/null || true

    if [ -f "${D}/usr/share/applications/lm-studio.desktop" ]; then
        sed -i 's|^Icon=.*|Icon=/usr/share/icons/hicolor/0x0/apps/lm-studio.png|' \
            "${D}/usr/share/applications/lm-studio.desktop"
    fi

	use rocm && domenu ${FILESDIR}/lm-studio-rocm.desktop

}

pkg_postinst() {
    einfo "LM Studio successfully installed."
    einfo ""
    einfo "Run it with:"
    einfo "    lm-studio"
    einfo ""
    einfo "Models will be stored in:"
    einfo "    ~/.cache/lm-studio"
}

