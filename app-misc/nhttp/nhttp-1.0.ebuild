# Copyright 2026 Noah Burchell
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit toolchain-funcs

DESCRIPTION="minimal http server"
HOMEPAGE="https://github.com/noahburchell/nhttp"
SRC_URI="https://github.com/noahburchell/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

src_compile() {
	emake CC="$(tc-getCC)"
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
	einstalldocs
}

pkg_postinst() {
	elog "nhttp listens on port 80, so it needs root or the net_bind_service"
	elog "capability. To run it as an unprivileged user:"
	elog
	elog "    setcap cap_net_bind_service=+ep ${EROOT}/usr/bin/nhttp"
	elog
	elog "The port is a compile-time constant; changing it means editing"
	elog "src/main.c and rebuilding."
}
