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

RDEPEND="
	acct-group/nhttp
	acct-user/nhttp
"

pkg_setup() {
	if tc-is-gcc && [[ $(gcc-major-version) -lt 14 ]]; then
		die "nhttp needs gcc 14 or newer (or clang 18+) for -std=gnu23"
	fi
	if tc-is-clang && [[ $(clang-major-version) -lt 18 ]]; then
		die "nhttp needs clang 18 or newer for -std=gnu23"
	fi
}

src_compile() {
	emake CC="$(tc-getCC)"
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
	einstalldocs
}

pkg_postinst() {
	elog "nhttp must be started as root. it listens on port 80, chroots to the"
	elog "document root and switches to the nhttp user before serving, so"
	elog "every request handler runs unprivileged inside the document root"
	elog
	elog "the port, the 10 s read/write timeout, the 8192 byte header cap and"
	elog "the 128 connection limit are compile-time constants in src/main.c"
	elog "nhttp is ipv4 only"
}
