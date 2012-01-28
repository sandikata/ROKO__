# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit kde4-base

CONTENT_NUMBER="144808"


DESCRIPTION="Жалко копие на dockbarx."
HOMEPAGE="http://www.kde-look.org/content/show.php?content=${CONTENT_NUMBER}"
LICENSE="GPL"

KEYWORDS="~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
SLOT="0"

SRC_URI="http://kde-look.org/CONTENT/content-files/${CONTENT_NUMBER}-${P}.tar.bz2"
