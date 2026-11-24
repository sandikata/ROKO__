
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
PYTHON_REQ_USE="ncurses"

inherit python-single-r1 systemd

DESCRIPTION="AMDGPU performance controller and read-only terminal monitor"
HOMEPAGE="https://github.com/ROKO__"
S="${WORKDIR}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="${PYTHON_DEPS}"

src_install() {
	python_domodule "${FILESDIR}/amdgpu_common.py"

	python_doscript \
		"${FILESDIR}/amdgpu-control" \
		"${FILESDIR}/amdgpu-monitor"

	insinto /etc
	doins "${FILESDIR}/amdgpu-control.conf"

	newinitd "${FILESDIR}/amdgpu-control.initd" amdgpu-control
	newconfd "${FILESDIR}/amdgpu-control.confd" amdgpu-control

	systemd_dounit "${FILESDIR}/amdgpu-control.service"

	dodoc \
		"${FILESDIR}/README.md" \
		"${FILESDIR}/rx6750xt.conf.example"
}
