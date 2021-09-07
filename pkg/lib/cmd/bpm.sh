# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob

main() {
	for f in "$PROGRAM_LIB_DIR"/{commands,commands-global,plumbing,util}/?*.sh; do
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
		-*)
			die "Global flag '$arg' not recognized"
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
