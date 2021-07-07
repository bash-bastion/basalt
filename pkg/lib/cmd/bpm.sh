# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob

main() {
	: "${BPM_ROOT:="${XDG_DATA_HOME:-$HOME/.local/share}/bpm"}"
	: "${BPM_PREFIX:="$BPM_ROOT/cellar"}"
	: "${BPM_PACKAGES_PATH:="$BPM_PREFIX/packages"}"
	: "${BPM_INSTALL_BIN:="$BPM_PREFIX/bin"}"
	: "${BPM_INSTALL_MAN:="$BPM_PREFIX/man"}"
	: "${BPM_INSTALL_COMPLETIONS:="$BPM_PREFIX/completions"}"

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
		bpm-complete "$@"
		exit
		;;
	echo)
		shift
		bpm-echo "$@"
		exit
		;;
	init)
		shift
		bpm-init "$@"
		exit
		;;
	install)
		shift
		bpm-install "$@"
		exit
		;;
	link)
		shift
		bpm-link "$@"
		exit
		;;
	list)
		shift
		bpm-list "$@"
		exit
		;;
	outdated)
		shift
		bpm-outdated "$@"
		exit
		;;
	package-path)
		shift
		bpm-package-path "$@"
		exit
		;;
	uninstall)
		shift
		bpm-uninstall "$@"
		exit
		;;
	upgrade)
		shift
		bpm-upgrade "$@"
		exit
		;;
	*)
		log.error "No command given"
		util.show_help
		;;
	esac
}

main "$@"
