# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
ETYPE="sources"

K_USEPV="yes"
UNIPATCH_STRICTORDER="yes"
K_SECURITY_UNSUPPORTED="1"
GIT_COMMIT="6.11-2"

CKV="$(ver_cut 1-2)"

inherit kernel-2
#detect_version
K_NOSETEXTRAVERSION="don't_set_it"

DESCRIPTION="The Liquorix Kernel Sources v6.x"
HOMEPAGE="https://liquorix.net/"
LIQUORIX_VERSION="${GIT_COMMIT/_p[0-9]*}"
LIQUORIX_FILE="${P}.tar.gz"
LIQUORIX_URI="https://github.com/damentz/liquorix-package/archive/${LIQUORIX_VERSION}.tar.gz -> ${LIQUORIX_FILE}"
SRC_URI="${KERNEL_URI} ${LIQUORIX_URI}";

KEYWORDS="-* ~amd64 ~ppc ~ppc64 ~x86"

KV_FULL="${PVR/_p/-pf}"
S="${WORKDIR}"/linux-"${KV_FULL}"

pkg_setup(){
	ewarn
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "If you need support, please contact the Liquorix developers directly."
	ewarn "Do *not* open bugs in Gentoo's bugzilla unless you have issues with"
	ewarn "the ebuilds. Thank you."
	ewarn
	kernel-2_pkg_setup
}

src_unpack() {
	unpack "${LIQUORIX_FILE}"
	kernel-2_src_unpack
}

src_prepare(){
	# Taken from
	# linux-lqx AUR package
	local lqx_patches="${WORKDIR}/liquorix-package-${GIT_COMMIT}/linux-liquorix/debian/patches"
	grep -P '^(zen|lqx)/' "${lqx_patches}/series" | while IFS= read -r line
	do
		einfo "Patching sources with $line"
		eapply "${lqx_patches}/${line}"
	done

	# Adds config options for OpenRC/Systemd
	eapply "${FILESDIR}"/4567_distro-Gentoo-Kconfig.patch

	eapply_user
}

K_EXTRAEINFO="For more info on liquorix-sources and details on how to report problems, see: \
${HOMEPAGE}."
