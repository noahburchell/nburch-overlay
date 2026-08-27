# Copyright 2026 Noah Burchell
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="spinning cube (and platonic solids)"
HOMEPAGE="https://github.com/noahburchell/cube"
EGIT_REPO_URI="https://github.com/noahburchell/cube.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
PROPERTIES="live"

pkg_pretend() {
	[[ ${MERGE_TYPE} == binary ]] && return

	if tc-is-gcc && [[ $(gcc-major-version) -lt 14 ]]; then
		die "GCC 14 or newer is required, found $(gcc-fullversion)"
	elif tc-is-clang && [[ $(clang-major-version) -lt 19 ]]; then
		die "Clang 19 or newer is required, found $(clang-fullversion)"
	fi
}

src_compile() {
	emake CC="$(tc-getCC)"
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
	einstalldocs
}
