# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop
inherit xdg-utils
inherit git-r3

DESCRIPTION="Simple way to upgrade Gentoo system"
HOMEPAGE="https://github.com/Anard/upgrade-portage.git"
EGIT_REPO_URI="https://github.com/Anard/${PN}.git"
EGIT_BRANCH="master"
S="${WORKDIR}/${PF}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="+color l10n_fr"

RDEPEND=">=sys-apps/portage-3.0 app-portage/eix gnome-extra/zenity || ( lxqt-base/lxqt-openssh-askpass net-misc/ssh-askpass-fullscreen net-misc/x11-ssh-askpass ) color? ( >=scripts/shell-text-1.0-r2 )"
DEPEND="${RDEPEND}"

src_unpack() {
	git-r3_fetch
	git-r3_checkout
}

install_languages() {
	# supported languages
	langs=( fr )
	langs_hum=( french )
	# install
	for i in ${!langs[@]}; do
		lang="${langs[$i]}"
		if use "l10n_${lang}"; then
			moFile="${S}/locale/${lang}.mo"
			poFile="${S}/locale/${lang}.po"
			msgfmt -o "${moFile}" "${poFile}" && domo "${moFile}" || eerror "An error occurred while installing ${langs_hum[$i]} translated interface"
		fi
	done
}

src_install() {
	einfo 'Installing files...'
	dosbin "${S}/upgrade"
	dobin "${S}/upgrade-log.sh"
	dodoc "${S}/README.md"
	doicon -s 64 "${S}/upgrade-portage.png"
	domenu "${S}/upgrade.desktop"
	install_languages
}

pkg_postinst() {
	xdg_icon_cache_update
	grep -e '^Path askpass .*' "/etc/sudo.conf" > /dev/null
	if [ $? -gt 0 ]; then
		ewarn "Be sure to have properly configured an askpass program in /etc/sudo.conf"
	fi
	if ! type qlop &> /dev/null; then
		elog "qlop is used to estimate merge times, you can install it via emerge -a app-portage/portage-utils"
	fi
}

pkg_postrm() {
	xdg_icon_cache_update
}
