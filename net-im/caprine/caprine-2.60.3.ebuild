# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-im-caprine-appimage-update.yaml
EAPI=8
DESCRIPTION="Elegant Facebook Messenger desktop app"
HOMEPAGE="https://sindresorhus.com/caprine"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND="sys-libs/glibc sys-libs/zlib "
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI="
  amd64? ( https://github.com/sindresorhus/caprine/releases/download/v2.60.3/Caprine-${PV}.AppImage -> ${P}-Caprine-${PV}.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-Caprine-${PV}.AppImage" "caprine.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "caprine.AppImage"  || die "Can't chmod archive file"
  "./caprine.AppImage" --appimage-extract "caprine.desktop" || die "Failed to extract .desktop from appimage"
  "./caprine.AppImage" --appimage-extract "usr/share/icons" || die "Failed to extract hicolor icons from app image"
  "./caprine.AppImage" --appimage-extract "*.png" || die "Failed to extract root icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/caprine.AppImage:' 'squashfs-root/caprine.desktop'
  find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm {} \; 
  find squashfs-root -type d -exec rmdir -p --ignore-fail-on-non-empty {} \; 
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "caprine.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/caprine.desktop" || die "Failed to install desktop file"
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

