
EAPI=2
inherit eutils

DESCRIPTION="Gentoo update manager"
HOMEPAGE="http://mon1.saske.sk/"
SRC_URI="http://mon1.saske.sk/gentoo/gentoo-src/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

src_install() {
  insinto /etc/${PN}
  newins "${WORKDIR}/${P}/${PN}/gentoo-update-master.conf" gentoo-update-master.conf || die

  insinto /var/log/${PN}
#   newins "${WORKDIR}/${P}/log/${PN}" xproofd.log || die

  dobin "${WORKDIR}/${P}/bin/gentoo-update-master" || die

  newinitd "${WORKDIR}/${P}/init.d/gentoo-update-master" gentoo-update-master
}
