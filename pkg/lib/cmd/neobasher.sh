# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob

main() {
	export NEOBASHER_ROOT="${NEOBASHER_ROOT:-"${XDG_DATA_HOME:-$HOME/.local/share}/neobasher"}"
	export NEOBASHER_PREFIX="${NEOBASHER_PREFIX:-"$NEOBASHER_ROOT/cellar"}"
	export NEOBASHER_PACKAGES_PATH="${NEOBASHER_PACKAGES_PATH:-"$NEOBASHER_PREFIX/packages"}"
	export NEOBASHER_INSTALL_BIN="${NEOBASHER_INSTALL_BIN:-"$NEOBASHER_PREFIX/bin"}"
	export NEOBASHER_INSTALL_MAN="${NEOBASHER_INSTALL_MAN:-"$NEOBASHER_PREFIX/man"}"

	mkdir -p "$NEOBASHER_PREFIX"

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
			# TODO
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
