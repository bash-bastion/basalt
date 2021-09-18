# shellcheck shell=bash

# TODO
set -ETeo pipefail
shopt -s nullglob extglob
export LANG="C" LANGUAGE="C" LC_ALL="C"
export GIT_TERMINAL_PROMPT=0

for f in "$PROGRAM_LIB_DIR"/{commands,plumbing,util}/?*.sh; do
	source "$f"
done

# TODO: ensure only one Basalt process running at the same time

basalt.main() {
	for arg; do case "$arg" in
	--help|-h)
		util.show_help
		exit
		;;
	--version|-v)
		# TODO: version string out of date
		cat <<-EOF
		Version: v0.9.0
		EOF
		exit
		;;
	-*)
		print_simple.die "Top level flag '$arg' is not recognized"
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
				upgrade) shift; do-global-upgrade "$@" ;;
				remove) shift; do-global-remove "$@" ;;
				*)
					if [ -n "$1" ]; then
						print_simple.die "Global subcommand '$1' is not a valid"
					else
						util.show_help
					fi
					;;
			esac
			;;
		*)
			if [ -n "$1" ]; then
				print_simple.die "Subcommand '$1' is not valid"
			else
				util.show_help
			fi
			;;
	esac
}
