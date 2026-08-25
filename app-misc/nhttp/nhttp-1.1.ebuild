# Copyright 2026 Noah Burchell
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit toolchain-funcs

DESCRIPTION="minimal http server"
HOMEPAGE="https://github.com/noahburchell/nhttp"
SRC_URI="https://github.com/noahburchell/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
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
	elog "This is recommended over running it with sudo: nhttp does not drop"
	elog "privileges, so under sudo the forked request handlers stay root."
	elog
	elog "The port, the 10s read/write timeout and the 8192 byte request cap"
	elog "are compile-time constants; changing them means editing src/main.c"
	elog "and rebuilding. nhttp is IPv4 only."
}
