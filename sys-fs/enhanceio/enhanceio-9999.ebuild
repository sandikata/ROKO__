# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2


EAPI=4
if [ ${PV} != 9999 ]; then
	EGIT_BRANCH="stable_v${PV}"
fi

inherit eutils git-2 linux-info linux-mod

DESCRIPTION="SSD caching software, based on Facebook's open source Flashcache project"
HOMEPAGE="https://github.com/stec-inc/EnhanceIO"
EGIT_REPO_URI="git://github.com/stec-inc/EnhanceIO.git"
ETYPE="sources"

LICENSE="GPL-2"
SLOT="0"

[[ ${PV} == *9999* ]] || KEYWORDS="~amd64 ~arm ~ppc ~x86 ~amd64-linux ~x86-linux"

IUSE="doc"

RDEPEND="dev-vcs/git"
DEPEND="${RDEPEND}"

#CONFIG_CHECK="MD BLK_DEV_DM DM_UEVENT"

S="${WORKDIR}"

#ARCH="x86"
BUILD_TARGETS=" "
MODULE_NAMES="enhanceio(extra:Driver/enhanceio) enhanceio_lru(extra:Driver/enhanceio) enhanceio_fifo(extra:Driver/enhanceio) enhanceio_rand(extra:Driver/enhanceio)"

src_compile() {
         set_arch_to_kernel
	 cd Driver/enhanceio
         emake -j1 || die "Compile fialed" 
 
 }
 
src_install() {
         linux-mod_src_install || die "install failed"
 
         (
                 cd "${WORKDIR}/CLI"
                 dosbin eio_cli || die "Install failed"
         )
 
	doman "${WORKDIR}/CLI/eio_cli.8" || die "Install failed"
        ewarn " "
	ewarn "EnhanceIO caches are persistent by default. A udev rule file named"
        ewarn "94-enhanceio-<cache_name>.rules is created, removed by create, delete"
	ewarn "sub-commands in eio_cli. "
        ewarn " "
        ewarn "NOTE: Creating a writeback cache on root device is not supported."
        ewarn "This is because the root device is mounted as read only prior to "
        ewarn "the processing of udev rules."
        ewarn " "
	ewarn "Make sure you've added \"enhanceio_lru enhanceio_fifo enhanceio_rand enhanceio\" "
	ewarn "to your /etc/conf.d/modules in order to load enhanceio at the boot."

 }
