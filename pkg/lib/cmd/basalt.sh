# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob
export LANG="C" LANGUAGE="C" LC_ALL="C"
export GIT_TERMINAL_PROMPT=0

for f in "$PROGRAM_LIB_DIR"/{commands,plumbing,util}/?*.sh; do
	source "$f"
done

basalt.main() {
	util.init_always

	for arg; do case "$arg" in
	--help|-h)
		util.show_help
		exit
		;;
	--version|-v)
		cat <<-EOF
		Version: v0.9.0
		EOF
		exit
		;;
	-*)
		print.die "Top level flag '$arg' is not recognized"
		;;
	*)
		break
		;;
	esac done

	case "$1" in
		init) shift; do-init "$@" ;;
		add) shift; do-add "$@" ;;
		remove) shift; do-remove "$@" ;;
		install) shift; do-install "$@" ;;
		complete) shift; do-complete "$@" ;;
		global) shift
			case "$1" in
				init) shift; do-global-init "$@" ;;
				add) shift; do-global-add "$@" ;;
				remove) shift; do-global-remove "$@" ;;
				install) shift; do-global-install "$@" ;;
				list) shift; do-global-list "$@" ;;
				*)
					if [ -n "$1" ]; then
						print.die "Global subcommand '$1' is not a valid"
					else
						util.show_help
					fi
					;;
			esac
			;;
		*)
			if [ -n "$1" ]; then
				print.die "Subcommand '$1' is not valid"
			else
				util.show_help
			fi
			;;
	esac
}
