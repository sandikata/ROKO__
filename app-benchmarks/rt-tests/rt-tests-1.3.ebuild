# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python{2_7,3_{3,4}} )


case "${PV}" in
	(9999*)
		KEYWORDS=""
		VCS_ECLASS=git-2
		EGIT_REPO_URI="git://git.kernel.org/pub/scm/utils/${PN}/${PN}.git"
		EGIT_PROJECT="${PN}.git"
		;;
	(*)
		KEYWORDS="~amd64 ~x86"
		SRC_URI="https://www.kernel.org/pub/linux/utils/${PN}/${P}.tar.xz"
		;;
esac
inherit eutils python-any-r1 ${VCS_ECLASS}

DESCRIPTION="Programs that test various RT-Linux features"
HOMEPAGE="https://kernel.org "

LICENSE="GPL-2"
SLOT="0"
IUSE="nptl"
REQUIERED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="${PYTHON_DEPS}
	sys-process/numactl
	nptl? ( dev-libs/npth )"
RDEPEND="${DEPEND}"

DOCS=( MAINTAINERS README.markdown )

src_prepare()
{
	sed -e "s,-O[0-5],,g" -e "s,python ,${EPYTHON} ,g" -i Makefile
}

src_configure()
{
	:;
}

src_compile()
{
	emake HAVE_NPTL="$(usex nptl yes no)" \
		CFLAGS="${CFLAGS} -Wall" LDFLAGS="${LDFLAGS}"
}

src_install()
{
	emake DESTDIR="${ED}" prefix=/usr install
	dodoc "${DOCS[@]}"
}
