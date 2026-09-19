# Copyright 2026 Noah Burchell
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit toolchain-funcs

DESCRIPTION="small init"
HOMEPAGE="https://github.com/noahburchell/ninit"
SRC_URI="https://github.com/noahburchell/${PN}/releases/download/v${PV}/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~x86"

IUSE="authshell busybox debug lto native o3 quiet +tools"
REQUIRED_USE="debug? ( !lto !native !o3 )"
RESTRICT="native? ( bindist )"

RDEPEND="
	app-shells/bash
	authshell? ( sys-apps/util-linux )
	busybox? ( sys-apps/busybox )
"

pkg_pretend() {
	[[ ${MERGE_TYPE} == binary ]] && return

	if tc-is-gcc && [[ $(gcc-major-version) -lt 14 ]]; then
		die "ninit needs gcc 14 or newer (or clang 18+) for -std=gnu23"
	fi
	if tc-is-clang && [[ $(clang-major-version) -lt 18 ]]; then
		die "ninit needs clang 18 or newer for -std=gnu23"
	fi
}

ninit_no_user_flags() {
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS
}

src_configure() {
	ninit_no_user_flags
	tc-export CC

	local myconf=(
		--sbindir="${EPREFIX}"/sbin
		--with-service-dir="${EPREFIX}"/etc/ninit.d
		--with-shell="${EPREFIX}"/bin/bash
		--with-shell-name=bash
		$(use_enable authshell)
		$(use_enable debug)
		$(use_enable lto)
		$(use_enable native)
		$(use_enable o3)
		$(use_enable quiet)
		$(usex busybox --with-busybox="${EPREFIX}"/bin/busybox --without-busybox)
	)

	econf "${myconf[@]}"
}

src_compile() {
	ninit_no_user_flags
	default
}

src_install() {
	ninit_no_user_flags
	default
	use tools && emake DESTDIR="${D}" tools-install
	dodoc -r docs/ninit.d
	keepdir /etc/ninit.d
}

pkg_postinst() {
	elog "Example service files are in ${EROOT}/usr/share/doc/${PF}/ninit.d."
	elog "Put service files in /etc/ninit.d and compile them with:"
	elog "    ninitctl init"
	elog "then boot with init=/sbin/ninit on the kernel command line."

	if use debug; then
		ewarn "USE=debug builds pid 1 with sanitizers"
	fi

	if use tools; then
		local n
		for n in shutdown poweroff halt reboot telinit; do
			if [[ -e ${EROOT}/sbin/${n}.old ]]; then
				elog "${n} was saved as ${n}.old; 'emake tools-uninstall' puts it back."
				break
			fi
		done
	else
		ewarn "USE=-tools skips the shutdown/poweroff/halt/reboot/telinit binaries."
		ewarn "Signal pid 1 directly instead:"
		ewarn "    kill -TERM 1   # reboot (also ctrl-alt-del)"
		ewarn "    kill -USR2 1   # poweroff"
		ewarn "    kill -USR1 1   # halt"
		ewarn "busybox reboot, poweroff and halt send the same signals."
	fi
}
