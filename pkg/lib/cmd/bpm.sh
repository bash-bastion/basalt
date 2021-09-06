# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob

main() {
	for f in "$PROGRAM_LIB_DIR"/{commands,commands-global,plumbing,util}/?*.sh; do
		source "$f"
	done

	if [ "$1" = init ] || [[ "$1" = - && "$2" = init ]]; then
		shift
		do-init "$@"
		return
	fi

	if [[ -z "$BPM_REPO_SOURCE" || -z "$BPM_CELLAR" ]]; then
		die "Either 'BPM_REPO_SOURCE' or 'BPM_CELLAR' is empty. Did you forget to run add \`bpm init <shell>\` in your shell configuration?"
	fi

	# 'BPM_LOCAL_PROJECT_DIR' is set in 'util.setup_mode'
	BPM_PACKAGES_PATH="$BPM_CELLAR/packages"
	BPM_INSTALL_BIN="$BPM_CELLAR/bin"
	BPM_INSTALL_MAN="$BPM_CELLAR/man"
	BPM_INSTALL_COMPLETIONS="$BPM_CELLAR/completions"

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
