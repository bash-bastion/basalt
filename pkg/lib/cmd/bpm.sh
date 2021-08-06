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

	BPM_MODE='local'

	for arg; do
		case "$arg" in
		--help|-h)
			util.show_help
			exit
			;;
		--version|-v)
			cat <<-EOF
			Version: v0.6.0
			EOF
			exit
			;;
		--global|-g)
			# shellcheck disable=SC2034
			BPM_MODE='global'
			shift
			;;
		*)
			break
			;;
		esac
	done

	case "$1" in
	add)
		shift
		do-add "$@"
		;;
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
	link)
		shift
		do-link "$@"
		;;
	list)
		shift
		do-list "$@"
		;;
	package-path)
		shift
		do-package-path "$@"
		;;
	prune)
		shift
		do-prune "$@"
		;;
	remove)
		shift
		do-remove "$@"
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
