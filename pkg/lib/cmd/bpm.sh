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
		*)
			break
			;;
		esac
	done

	case "$1" in
	complete)
		shift
		do-complete "$@"
		;;
	echo)
		shift
		do-echo "$@"
		;;
	init)
		shift
		do-init "$@"
		;;
	install)
		shift
		do-install "$@"
		;;
	link)
		shift
		do-link "$@"
		;;
	list)
		shift
		do-list "$@"
		;;
	outdated)
		shift
		bpm-outdated "$@"
		;;
	package-path)
		shift
		bpm-package-path "$@"
		;;
	uninstall)
		shift
		do-uninstall "$@"
		;;
	upgrade)
		shift
		do-upgrade "$@"
		;;
	*)
		if [ -n "$1" ]; then
			log.error "Command '$1' not valid"
		fi
		util.show_help
		;;
	esac
}

main "$@"
