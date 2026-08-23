# Copyright 2026 Noah Burchell
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit toolchain-funcs

DESCRIPTION="spinning cube (and platonic solids)"
HOMEPAGE="https://github.com/noahburchell/cube"
SRC_URI="https://github.com/noahburchell/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

pkg_pretend() {
	[[ ${MERGE_TYPE} == binary ]] && return

	if tc-is-gcc && [[ $(gcc-major-version) -lt 14 ]]; then
		die "GCC 14 or newer is required, found $(gcc-fullversion)"
	fi
}

src_compile() {
	emake CC="$(tc-getCC)"
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
	einstalldocs
}
