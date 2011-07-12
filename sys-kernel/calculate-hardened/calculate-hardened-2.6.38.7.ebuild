# Автор: Росен Александров - e-mail: sandikata@yandex.ru - jabber: roko@calculate-linux.org - Freenode - ROKO__
# Лиценз: GPL2
# $Header: $

ETYPE="sources"
inherit kernel-2 eutils
detect_version
EAPI=3
LICENSE="GPL-2"
SLOT="0"
IUSE="hardened vmlinuz +symlink"
DESCRIPTION="Calculate Linux Ядро с допълнителна поддръжка за Hardened ${KV_MAJOR}.${KV_MINOR}"
HOMEPAGE="http://calculate-linux.ru/"
KEYWORDS="amd64 x86"
CKV=2.6.38.7
KERNEL_ARCHIVE="linux-${CKV}.tar.bz2"
SRC_URI="http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.38.7.tar.bz2"
UNIPATCH="${FILESDIR}/calculate-sources-2.6.38.tar.bz2" 
#UNIPATCH="${FILESDIR}/hardened-patches-2.6.38.8.extras.tar.bz2"

DEPEND="vmlinuz? ( >=sys-kernel/calckernel-3.4.15-r5
	>=sys-apps/calculate-builder-2.2.14
	|| ( app-arch/xz-utils app-arch/lzma-utils )
	sys-apps/v86d )"

RDEPEND="=sys-apps/gradm-2.2.2*"

CL_KERNEL_OPTS="--lvm --mdadm --dmraid"

src_unpack() {
unpack ${KERNEL_ARCHIVE}

	if use hardened
	then
#		unipatch ${DISTDIR}/hardened-patches-2.6.38.8.extras.tar.bz2 || die

		epatch "${FILESDIR}/2.6.38/4420_grsecurity-2.2.2-2.6.38.7-201105222331.patch"
		epatch "${FILESDIR}/2.6.38/4421_grsec-remove-localversion-grsec.patch"
		epatch "${FILESDIR}/2.6.38/4422_grsec-mute-warnings.patch"
		epatch "${FILESDIR}/2.6.38/4423_grsec-remove-protected-paths.patch"
		epatch "${FILESDIR}/2.6.38/4425_grsec-pax-without-grsec.patch"
		epatch "${FILESDIR}/2.6.38/4430_grsec-kconfig-default-gids.patch"
		epatch "${FILESDIR}/2.6.38/4435_grsec-kconfig-gentoo.patch"
		epatch "${FILESDIR}/2.6.38/4440_selinux-avc_audit-log-curr_ip.patch"
		epatch "${FILESDIR}/2.6.38/4445_disable-compat_vdso.patch"
		

	fi
}

pkg_postinst() {
	kernel-2_pkg_postinst

	local GRADM_COMPAT="sys-apps/gradm-2.2.2*"

	ewarn "Hardened Calculate предлага три профила за сигурност:"
	ewarn "[server], [workstation], and [virtualization]."
	ewarn "За тези които искат да направят собствена настройка на профила, е нужно да се направи справка с документацията."
	ewarn "Потребителите които ползват RBAC, трябва да съобразят какви програми използват, и да позволят достъп да за изпълнение."	
	ewarn "За използване като десктоп система трябва да се избере профил [workstation]."
	ewarn "За премахване на MPROTECT от бинарния файл на някоя програма -> paxctl -C /path/to/binary ; paxctl -m /path/to/binary ."

	elog "Ако желаете ядрото да се компилира и инсталира автоматично, добавете флаг "vmlinuz"."
	elog "Ако желаете ядрото да поддържа Hardened, добавете флаг "hardened"."

}

