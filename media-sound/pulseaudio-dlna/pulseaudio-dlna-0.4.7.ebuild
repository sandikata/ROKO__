# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="threads(+)"
RESTRICT_PYTHON_ABIS="3.*"

inherit eutils python-r1 git-r3

DESCRIPTION="A lightweight streaming server which brings DLNA / UPNP and Chromecast support to PulseAudio and Linux"
HOMEPAGE="https://github.com/masmu/pulseaudio-dlna"
EGIT_REPO_URI="https://github.com/masmu/pulseaudio-dlna.git"
EGIT_COMMIT="0.4.7"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-python/beautifulsoup:python-2
	dev-python/virtualenv[python_targets_python2_7?]
	dev-python/dbus-python[python_targets_python2_7?]
	dev-python/docopt[python_targets_python2_7?]
	dev-python/requests[python_targets_python2_7?]
	dev-python/pygobject:2[python_targets_python2_7?]
	dev-python/setproctitle[python_targets_python2_7?]
	dev-libs/protobuf[python_targets_python2_7?]
	dev-python/notify-python[python_targets_python2_7?]
	dev-python/psutil[python_targets_python2_7?]
	dev-python/futures[python_targets_python2_7?]
	dev-python/chardet[python_targets_python2_7?]
	dev-python/netifaces[python_targets_python2_7?]"
RDEPEND="${DEPEND}"
