# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_REPO_URI="https://git.sr.ht/~iank/evhz"

inherit git-r3 toolchain-funcs

DESCRIPTION="Mouse refresh rate under evdev"
HOMEPAGE="https://gitlab.com/iankelling/evhz"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

src_compile() {
	"$(tc-getCC)" -o evhz evhz.c || die "gcc failed"
}

src_install() {
	einstalldocs
	dobin evhz
}
