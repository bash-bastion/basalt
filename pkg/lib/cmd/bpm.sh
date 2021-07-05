# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob

main() {
	export BPM_ROOT="${BPM_ROOT:-"${XDG_DATA_HOME:-$HOME/.local/share}/bpm"}"
	export BPM_PREFIX="${BPM_PREFIX:-"$BPM_ROOT/cellar"}"
	export BPM_PACKAGES_PATH="${BPM_PACKAGES_PATH:-"$BPM_PREFIX/packages"}"
	export BPM_INSTALL_BIN="${BPM_INSTALL_BIN:-"$BPM_PREFIX/bin"}"
	export BPM_INSTALL_MAN="${BPM_INSTALL_MAN:-"$BPM_PREFIX/man"}"

	mkdir -p "$BPM_PREFIX"

	for f in "$PROGRAM_LIB_DIR"/{commands,util}/?*.sh; do
		source "$f"
	done

	for arg; do
		case "$arg" in
		--help)
			util.show_help
			exit
			;;
		--version)
			cat <<-EOF
			Version: $PROGRAM_VERSION
			EOF
			exit
		;;
		esac
	done

	case "$1" in
	complete)
		shift
		basher-complete "$@"
		exit
		;;
	echo)
		shift
		basher-echo "$@"
		exit
		;;
	init)
		shift
		basher-init "$@"
		exit
		;;
	install)
		shift
		basher-install "$@"
		exit
		;;
	link)
		shift
		basher-link "$@"
		exit
		;;
	list)
		shift
		basher-list "$@"
		exit
		;;
	outdated)
		shift
		basher-outdated "$@"
		exit
		;;
	package-path)
		shift
		basher-package-path "$@"
		exit
		;;
	uninstall)
		shift
		basher-uninstall "$@"
		exit
		;;
	upgrade)
		shift
		basher-upgrade "$@"
		exit
		;;
	*)
		log.error "No command given"
		util.show_help
		;;
	esac
}

main "$@"
