# Copyright 1999-2011 Ciaran McCreesh
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#EAPI="paludis-1"
EAPI="4"
inherit bash-completion-r1 eutils git-2

DESCRIPTION="paludis, the other package mangler"
HOMEPAGE="http://paludis.exherbo.org/"
SRC_URI=""
EGIT_REPO_URI="git://git.exherbo.org/paludis/paludis.git"

IUSE="ask doc gemcutter pbins pink portage python-bindings ruby-bindings search-index sort-world vim-syntax visibility xml zsh-completion"
LICENSE="GPL-2 vim-syntax? ( vim )"
SLOT="0"
KEYWORDS=""

COMMON_DEPEND="
	>=app-admin/eselect-1.2_rc1
	>=app-shells/bash-3.2
	dev-libs/libpcre[cxx]
	pbins? ( >=app-arch/libarchive-2.8.4 )
	ruby-bindings? ( dev-ruby/rubygems )
	python-bindings? ( >=dev-lang/python-2.6 >=dev-libs/boost-1.41.0[python] )
	gemcutter? ( >=dev-libs/jansson-1.3 )
	xml? ( >=dev-libs/libxml2-2.6 )
	search-index? ( dev-db/sqlite:3 )"

DEPEND="${COMMON_DEPEND}
    >=app-text/asciidoc-8.6.3
    app-text/xmlto
	sys-devel/autoconf:2.5
	sys-devel/automake:1.11
	doc? (
		|| ( >=app-doc/doxygen-1.5.3 <=app-doc/doxygen-1.5.1 )
		media-gfx/imagemagick
		python-bindings? ( dev-python/epydoc dev-python/pygments )
		ruby-bindings? ( dev-ruby/syntax dev-ruby/allison )
	)
	dev-util/pkgconfig
	dev-cpp/gtest[threads]"

RDEPEND="${COMMON_DEPEND}
	sys-apps/sandbox"

# Keep syntax as a PDEPEND. It avoids issues when Paludis is used as the
# default virtual/portage provider.
PDEPEND="
	vim-syntax? ( >=app-editors/vim-core-7 )
	app-admin/eselect-package-manager
		dev-vcs/git
		dev-vcs/subversion
		dev-vcs/cvs
		dev-vcs/darcs
		net-misc/rsync
		net-misc/wget"

create-paludis-user() {
	enewgroup "paludisbuild"
	enewuser "paludisbuild" -1 -1 "/var/tmp/paludis" "paludisbuild,tty"
}

pkg_setup() {
	if use pbins && \
		built_with_use app-arch/libarchive xattr; then
		eerror "With USE pbins you need libarchive build without the xattr"
		eerror "use flag."
		die "Rebuild app-arch/libarchive without USE xattr"
	fi
	create-paludis-user
}

src_unpack() {
	git-2_src_unpack
	cd "${S}"
	use sort-world && epatch ${FILESDIR}/0001-paludis-sort-world.patch
	use ask && epatch ${FILESDIR}/0002-cave-resolve-ask.patch
	./autogen.bash || die "autogen.bash failed"
}

src_compile() {
	format_list() { echo $@ | tr -s \  ,; }
	local repositories="default repository unavailable unpackaged $(usev gemcutter)"
	local environments="default $(usev portage)"
	econf \
		$(use_enable doc doxygen ) \
		$(use_enable pink ) \
		$(use_enable pbins ) \
		$(use_enable ruby-bindings ruby ) \
		$(useq ruby-bindings && useq doc && echo --enable-ruby-doc ) \
		$(use_enable python-bindings python ) \
		$(useq python-bindings && useq doc && echo --enable-python-doc ) \
		$(use_enable search-index) \
		$(use_enable vim-syntax vim ) \
		$(use_enable visibility ) \
		$(use_enable xml ) \
		--with-vim-install-dir=/usr/share/vim/vimfiles \
		--with-repositories=$(format_list ${repositories}) \
		--with-environments=$(format_list ${environments}) \
		--with-git-head="$(git rev-parse HEAD)" \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS README NEWS

	dobashcomp bash-completion/cave
	if use zsh-completion ; then
		insinto /usr/share/zsh/site-functions
		doins zsh-completion/_cave
	fi
	find ${D} -name '*.la' -exec rm -f {} +
}

src_test() {
	# Work around Portage bugs
	export PALUDIS_DO_NOTHING_SANDBOXY="portage sucks"
	export BASH_ENV=/dev/null

	if [[ `id -u` == 0 ]] ; then
		# hate
		export PALUDIS_REDUCED_UID=0
		export PALUDIS_REDUCED_GID=0
	fi

	if ! emake check ; then
		eerror "Tests failed. Looking for files for you to add to your bug report..."
		find "${S}" -type f -name '*.epicfail' -or -name '*.log' | while read a ; do
			eerror "    $a"
		done
		die "Make check failed"
	fi
}

