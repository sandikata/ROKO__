# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/oss/oss-4.2.2010.ebuild,v 1.7 2014/11/01 20:31:48 -tclover Exp $

EAPI=5

inherit eutils flag-o-matic libtool

MY_P=${PN}-v${PV:0:3}-build${PV:4:7}-src-gpl

DESCRIPTION="OSSv4 portable, mixing-capable, high quality sound system for Unix"
HOMEPAGE="http://developer.opensound.com/"
SRC_URI="http://www.4front-tech.com/developer/sources/stable/gpl/${MY_P}.tar.bz2"

unset MY_P

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

AUDIO_CARDS=( ali5455 atiaudio audigyls audioloop audiopci cmi878x cmpci cs4281
cs461x digi96 emu10k1x envy24 envy24ht fmedia geode hdaudio ich imux madi midiloop
midimix sblive sbpci sbxfi solo trident usb userdev via823x via97 ymf7xx )
DEFAULT_CARDS=( hdaudio ich imux midiloop midimix )

for card in ${AUDIO_CARDS[@]}; do
	has ${card} ${DEFAULT_CARDS[@]} &&
	CARDS=(${CARDS[@]} +oss_cards_${card}) ||
	CARDS=(${CARDS[@]} oss_cards_${card})
done

IUSE="alsa +midi pax_kernel ${CARDS[@]}"
REQUIRED_USE="oss_cards_midiloop? ( midi ) oss_cards_midimix? ( midi )
	|| ( ${CARDS[@]//+} )"
unset CARDS

DEPEND="sys-apps/gawk
	x11-libs/gtk+:2
	>=sys-kernel/linux-headers-2.6.11
	!media-sound/oss-devel"

RDEPEND="${DEPEND}"

src_unpack()
{
	default
	mv ${PN}-* ${P} || die
}

src_prepare()
{
	filter-flags '-fPIC'
	sed -e 's,-O3 ,,g' -i setup/srcconf*.inc

	cp "${FILESDIR}"/oss.initd "${S}"/setup/Linux/oss/etc/S89oss
	use pax_kernel && epatch "${FILESDIR}"/pax_kernel.patch

	elibtoolize
}

src_configure()
{
	local drv=osscore
	for card in ${AUDIO_CARDS[@]}; do
		if use oss_cards_${card} ||
		has ${card} ${OSS_CARDS} || has ${card} ${DEFAULT_CARDS[@]};then
			drv+=,oss_${card}
		fi
	done

	local myconfargs=(
		$(usex alsa '' '--enable-libsalsa=NO')
		$(usex midi '--config-midi=YES' '')
		--only-drv=$drv
	)
	mkdir -p ../build && pushd ../build
	"${S}"/configure "${myconfargs[@]}"
}

src_compile()
{
	pushd ../build
	emake build
}

src_install()
{
	pushd ../build
	cp -a prototype/* "${ED}" || die

	# install a pkgconfig file and make symlink to standard library dir
	newinitd "${FILESDIR}"/oss.initd oss
	local libdir=/usr/$(get_libdir)
	insinto ${libdir}/pkgconfig
	doins "${FILESDIR}"/OSSlib.pc
	dosym ${libdir}/{oss/lib/,}libOSSlib.so
	dosym ${libdir}/{oss/lib/,}libossmix.so
	use alsa && dosym ${libdir}/{oss/lib/,}libsalsa.so.2.0.0
	dosym ${libdir}/oss/include /usr/include/oss
}

pkg_postinst()
{
	elog ""
	elog "To use ${P} for the first time you must run: \`/etc/init.d/oss start'"
	elog "If you are upgrading, run: \`/etc/init.d/oss restart'"
	elog ""
}
