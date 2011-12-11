# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit eutils

DESCRIPTION="inhatch plugin for vlc player"
HOMEPAGE="http://inhatch.com/"
SRC_URI="ftp://calculate.linuxmaniac.net/pub/inhatch/inhatch-0.8-x86.tar.xz"

LICENSE=""
SLOT="unstable"
KEYWORDS="~x86"
IUSE=""

DEPEND=">=media-video/vlc-1.1.10[lua] !!<=media-video/vlc-1.0.99999 
		>=dev-lang/lua-5.1.4"
RDEPEND="${DEPEND}"

src_unpack() {
unpack $A || die
}

src_install() {
cd "${WORKDIR}"
cp -R * "${D}/" || die "install failed"
cd "${FILESDIR}"
dobin inhatchgui || die "install failed"

doicon "${FILESDIR}"/icon/inhatch_PLUGIN_LOGO.png
domenu "${FILESDIR}"/icon/inhatchgui-inhatch.desktop
#make_desktop_entry inhatchgui

elog "За да можете да използвате приставката трябва да добавите адрес с плейлистата в секцията Add URL на vlc player -> Линк http://inhatch.com/channel/playlist.xspf"
elog "За да използвате графичния интерфейс изпълнете в терминала 'inhatchgui'или Меню/Интернет/inhatch Може да е на различно място в зависимост от десктоп
средата!"
elog "Това е все още тестова версия и на приставката и на графичния интерфейс,
паралелно с inhatch team ще подобрим приставката и евентуално графичния
интерфейс. Благодаря за разбирането: Росен Александров - sandikata@yandex.ru -
roko@jabber.calculate-linux.org"
echo
}
