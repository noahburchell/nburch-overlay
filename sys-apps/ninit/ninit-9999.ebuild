# Copyright 2026 Noah Burchell
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit autotools git-r3 toolchain-funcs

DESCRIPTION="small init"
HOMEPAGE="https://github.com/noahburchell/ninit"
EGIT_REPO_URI="https://github.com/noahburchell/ninit.git"

LICENSE="GPL-3"
SLOT="0"

KEYWORDS=""
IUSE="busybox debug hardened quiet sulogin test +tools"
RESTRICT="!test? ( test )"

RDEPEND="
	app-shells/bash
	sulogin? ( sys-apps/util-linux )
	busybox? ( sys-apps/busybox )
"
BDEPEND="
	test? (
		amd64? ( app-emulation/qemu[qemu_softmmu_targets_x86_64] )
		sys-apps/busybox[static]
		sys-apps/util-linux
	)
"
PROPERTIES="live"

pkg_setup() {
	if tc-is-gcc && [[ $(gcc-major-version) -lt 14 ]]; then
		die "ninit needs gcc 14 or newer (or clang 18+) for -std=gnu23"
	fi
	if tc-is-clang && [[ $(clang-major-version) -lt 18 ]]; then
		die "ninit needs clang 18 or newer for -std=gnu23"
	fi
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	tc-export CC

	local myconf=(
		--sbindir="${EPREFIX}"/sbin
		--with-service-dir="${EPREFIX}"/etc/ninit.d
		--with-shell="${EPREFIX}"/bin/bash
		--with-shell-name=bash
		$(use_enable debug)
		$(use_enable hardened)
		$(use_enable quiet)
		$(use_with sulogin)
		$(usex busybox --with-busybox="${EPREFIX}"/bin/busybox --without-busybox)
	)

	econf "${myconf[@]}"
}

src_test() {
	# the qemu tests boot the kernel named here, set it in /etc/portage/env
	local -x NINIT_TEST_KERNEL=${NINIT_TEST_KERNEL}

	if [[ -z ${NINIT_TEST_KERNEL} ]]; then
		ewarn "NINIT_TEST_KERNEL is not set, the qemu tests are skipped"
	elif [[ ! -r ${NINIT_TEST_KERNEL} ]]; then
		die "NINIT_TEST_KERNEL=${NINIT_TEST_KERNEL} is not readable"
	fi
	if [[ -c /dev/kvm && -r /dev/kvm && -w /dev/kvm ]]; then
		addwrite /dev/kvm
	else
		ewarn "/dev/kvm is not usable by portage, the qemu tests run under tcg"
	fi

	emake check
}

src_install() {
	default
	use tools && emake DESTDIR="${D}" tools-install
	dodoc -r docs/ninit.d
	docompress -x /usr/share/doc/${PF}/ninit.d
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
