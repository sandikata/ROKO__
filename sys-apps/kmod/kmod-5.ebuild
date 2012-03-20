# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/kmod/kmod-6.ebuild,v 1.2 2012/03/09 23:51:10 williamh Exp $

EAPI=4

EGIT_REPO_URI="git://git.kernel.org/pub/scm/utils/kernel/${PN}/${PN}.git"

[[ "${PV}" == "9999" ]] && vcs=git-2
inherit ${vcs}  autotools eutils toolchain-funcs
unset vcs

if [[ "${PV}" != "9999" ]] ; then
	SRC_URI="mirror://kernel/linux/utils/kernel/kmod/${P}.tar.xz"
	KEYWORDS="~amd64 ~arm ~hppa ~mips ~ppc ~ppc64 ~x86"
fi

DESCRIPTION="library and tools for managing linux kernel modules"
HOMEPAGE="http://git.kernel.org/?p=utils/kernel/kmod/kmod.git"

LICENSE="LGPL-2"
SLOT="0"
IUSE="+compat doc debug lzma static-libs +rootfs-install +tools zlib"

REQUIRED_USE="compat? ( tools )"

COMMON_DEPEND="tools? (
		!sys-apps/module-init-tools
		!sys-apps/modutils
	)
	lzma? ( app-arch/xz-utils )
	zlib? ( sys-libs/zlib )"

DEPEND="${COMMON_DEPEND}
	doc? ( dev-util/gtk-doc )"
RDEPEND="${COMMON_DEPEND}"

src_prepare()
{
	epatch ${FILESDIR}/${PN}-3-install-binaries-to-sbin.patch

	if use doc; then
		gtkdocize --copy --docdir libkmod/docs ||  die "gtkdocize failed"
	else
		touch libkmod/docs/gtk-doc.make
	fi

	eautoreconf
}

src_configure()
{
	econf \
		$(use rootfs-install && echo --exec-prefix=/) \
		$(use_enable debug) \
		$(use_enable doc gtk-doc) \
		$(use_with lzma xz) \
		$(use_enable static-libs static) \
		$(use_enable tools) \
		$(use_with zlib)
}

src_install()
{
	default

	# we have a .pc file for people to use
	find "${D}" -name libkmod.la -delete

	if use rootfs-install ; then
		dodir /usr/$(get_libdir)
		# move pkg-config file and static libs to /usr
		if use static-libs ; then
			mv "${D}"/$(get_libdir)/*.a "${D}"/usr/$(get_libdir)/ || die
			gen_usr_ldscript libkmod.so
			sed -i -e 's:/lib:/usr/lib:' \
				"${D}"/$(get_libdir)/pkgconfig/*.pc || die
		fi
		mv "${D}"/$(get_libdir)/pkgconfig "${D}"/usr/$(get_libdir)/ || die
	fi

	use tools || { rm "${D}"/usr/share/man -r || die ; }

	# If the tools are installed, add compatibility symbolic links
	local prefix=/usr
	if use compat && use tools ; then
		use rootfs-install && prefix=
		dodir ${prefix}/bin
		dosym ../sbin/kmod ${prefix}/bin/lsmod
		for cmd in depmod insmod modinfo modprobe rmmod; do
			dosym kmod ${prefix}/sbin/$cmd
		done
	fi
}
