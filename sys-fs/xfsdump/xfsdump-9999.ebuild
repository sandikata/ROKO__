# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit multilib autotools flag-o-matic toolchain-funcs git-r3

DESCRIPTION="xfs dump/restore utilities"
HOMEPAGE="https://xfs.wiki.kernel.org/"
EGIT_REPO_URI="git://git.kernel.org/pub/scm/fs/xfs/xfsdump-dev.git"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ~mips ppc ppc64 -sparc x86"
IUSE="ncurses nls"

RDEPEND="
	>=sys-apps/attr-2.4.19
	sys-apps/dmapi
	sys-apps/util-linux
	sys-fs/e2fsprogs
	>=sys-fs/xfsprogs-3.2.0
	ncurses? ( sys-libs/ncurses:0= )
"
DEPEND="${RDEPEND}
	nls? (
		sys-devel/gettext
		elibc_uclibc? ( dev-libs/libintl )
	)"

#src_prepare() {
	# Rerun autotools
#	einfo "Regenerating autotools files..."
#	eautoconf
#	eautomake
#}

#src_configure() {
#	unset PLATFORM #184564
#	export OPTIMIZER=${CFLAGS}
#	export DEBUG=-DNDEBUG

#	local myeconfargs=(
#		$(use_enable nls gettext)
#		--libdir="${EPREFIX}/$(get_libdir)"
#		--libexecdir="${EPREFIX}/usr/$(get_libdir)"
#		--sbindir="${EPREFIX}/sbin"
#	)
#	econf "${myeconfargs[@]}"
#}

src_compile() {
	# enable verbose build
	emake V=1
}
