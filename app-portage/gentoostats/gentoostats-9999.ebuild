# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit distutils python git-2

DESCRIPTION="Package statistics client"
HOMEPAGE="http://soc.dev.gentoo.org/gentoostats"
SRC_URI=""

EGIT_REPO_URI="git://git.overlays.gentoo.org/proj/gentoostats.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	sys-apps/portage
	>=app-portage/gentoolkit-0.3.0.2
	dev-python/argparse
	dev-python/simplejson"

src_compile() {
	pushd "client"
	distutils_src_compile
}

src_install() {
	pushd "client"
	distutils_src_install

	dodir /etc/gentoostats || die
	insinto /etc/gentoostats
	doins payload.cfg || die

	# TODO(antarus): Vikram mentioned something along the lines of
	# userpriv not letting you have files owned by portage so we end up
	# setting perms in postinst instead.
	fowners root:portage /etc/gentoostats/payload.cfg || die
	fperms 0640 /etc/gentoostats/payload.cfg || die
}

generate_uuid() {
	if [[ -e /proc/sys/kernel/random/uuid ]]; then
		cat /proc/sys/kernel/random/uuid
	else
		AUTH1=$(< /dev/urandom tr -dc a-zA-Z0-9 | head -c8)
		AUTH2=$(< /dev/urandom tr -dc a-zA-Z0-9 | head -c4)
		AUTH3=$(< /dev/urandom tr -dc a-zA-Z0-9 | head -c4)
		AUTH4=$(< /dev/urandom tr -dc a-zA-Z0-9 | head -c4)
		AUTH5=$(< /dev/urandom tr -dc a-zA-Z0-9 | head -c12)
		echo "${AUTH1}-${AUTH2}-${AUTH3}-${AUTH4}-${AUTH5}"
	fi
}

pkg_postinst() {
	distutils_pkg_postinst

	AUTHFILE="${ROOT}/etc/gentoostats/auth.cfg"
	if ! [[ -f "${AUTHFILE}" ]]; then
		elog "Generating uuid and password in ${AUTHFILE}"
		touch "${AUTHFILE}"
		echo "[AUTH]" >> "${AUTHFILE}"
		echo -n "UUID : " >> "${AUTHFILE}"
		generate_uuid >> "${AUTHFILE}"
		echo -n "PASSWD : " >> "${AUTHFILE}"
		< /dev/urandom tr -dc a-zA-Z0-9 | head -c16 >> "${AUTHFILE}"
	fi
	chown root:portage "${AUTHFILE}"
	chmod 0640 "${AUTHFILE}"
}
