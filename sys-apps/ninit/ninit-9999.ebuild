# Copyright 2026 Noah Burchell
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )

inherit autotools fcaps git-r3 python-any-r1 toolchain-funcs

DESCRIPTION="small init"
HOMEPAGE="https://github.com/noahburchell/ninit"
EGIT_REPO_URI="https://github.com/noahburchell/ninit.git"

LICENSE="GPL-3"
SLOT="0"

KEYWORDS=""
IUSE="busybox debug hardened power quiet sulogin test +tools"
RESTRICT="!test? ( test )"

RDEPEND="
	app-shells/bash
	power? ( acct-group/power )
	sulogin? ( sys-apps/util-linux )
	busybox? ( sys-apps/busybox )
"
BDEPEND="
	power? ( acct-group/power )
	test? (
		amd64? ( app-emulation/qemu[qemu_softmmu_targets_x86_64] )
		dev-lang/lua
		dev-lang/perl
		${PYTHON_DEPS}
		sys-apps/busybox[static]
		sys-apps/util-linux
	)
"
PROPERTIES="live"

FILECAPS=( -m 4710 -M 0710 cap_kill sbin/ninit-shutdown )

pkg_setup() {
	use test && python-any-r1_pkg_setup
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
	local -x NINIT_TEST_KERNEL=${NINIT_TEST_KERNEL}

	if [[ -z ${NINIT_TEST_KERNEL} ]]; then
		ewarn "NINIT_TEST_KERNEL is not set, the qemu tests are skipped"
	elif [[ ! -r ${NINIT_TEST_KERNEL} ]]; then
		die "NINIT_TEST_KERNEL=${NINIT_TEST_KERNEL} is not readable"
	fi
	addwrite /dev/kvm
	if [[ ! -c /dev/kvm || ! -r /dev/kvm || ! -w /dev/kvm ]]; then
		ewarn "/dev/kvm is not usable by portage, the qemu tests run under tcg"
	fi

	emake check
}

src_install() {
	default
	use tools && emake DESTDIR="${D}" tools-install
	if use power; then
		fowners root:power /sbin/ninit-shutdown
		fperms 0710 /sbin/ninit-shutdown
	fi
	dodoc -r docs/ninit.d
	docompress -x /usr/share/doc/${PF}/ninit.d
	keepdir /etc/ninit.d
}

pkg_postinst() {
	use power && fcaps_pkg_postinst

	elog "Example service files are in ${EROOT}/usr/share/doc/${PF}/ninit.d."
	elog "Put service files in /etc/ninit.d and compile them with:"
	elog "    ninitctl init"
	elog "then boot with init=/sbin/ninit on the kernel command line."

	if use debug; then
		ewarn "USE=debug builds pid 1 with sanitizers"
	fi

	if use power; then
		elog "Members of the power group may run poweroff, reboot and halt without root."
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
