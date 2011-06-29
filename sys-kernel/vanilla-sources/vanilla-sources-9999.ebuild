# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
SLOT="0"
ETYPE="sources"

CKV=`date +%F`
K_SECURITY_UNSUPPORTED="1"

inherit kernel-2 git
detect_version

K_NOUSENAME="yes"
K_NOSETEXTRAVERSION="yes"
K_SECURITY_UNSUPPORTED="1"

EGIT_REPO_URI="git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git"
EGIT_PROJECT="linux-2.6"

DESCRIPTION="Full sources for the Linux kernel"
HOMEPAGE="http://www.kernel.org"
SRC_URI=""

KEYWORDS="~amd64 ~x86"
IUSE="deblob"
