# Copyright 2026 Noah Burchell
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit toolchain-funcs

DESCRIPTION="spinning cube (and platonic solids)"
HOMEPAGE="https://github.com/noahburchell/cube https://nburch.org"
SRC_URI="https://github.com/noahburchell/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm64 x86 ~arm64-macos ~x64-macos"

cube_is_apple_clang() {
	[[ $($(tc-getCC) -E -P - <<<"__apple_build_version__" 2>/dev/null) == [0-9]* ]]
}

pkg_pretend() {
	[[ ${MERGE_TYPE} == binary ]] && return

	if tc-is-gcc; then
		if [[ $(gcc-major-version) -lt 14 ]]; then
			die "GCC 14 or newer is required, found $(gcc-fullversion)"
		fi
	elif tc-is-clang; then
		if cube_is_apple_clang; then
			if [[ $(clang-major-version) -lt 17 ]]; then
				die "Apple Clang 17 (Xcode 16.3) or newer is required, found $(clang-fullversion)"
			fi
		elif [[ $(clang-major-version) -lt 19 ]]; then
			die "Clang 19 or newer is required, found $(clang-fullversion)"
		fi
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
	elog "run 'cube --help' for shape list"
}
