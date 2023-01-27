# shellcheck shell=bash

# Usually, a Basalt package won't have calls to `set`, `shopt`, `source`, etc., since
# that is specified declaritively in `basalt.toml`. But, since that behavior is dependent
# on Basalt, and Basalt doesn't bootstrap itself, we must setup the environment here.

main.basalt() {
	if [ "$BASALT_INTERNAL_IS_TESTING" != 'yes' ]; then
		if [ -z "$__basalt_dirname" ]; then
			printf '%s\n' "Fatal: main.basalt: Variable '__basalt_dirname' is empty"
			exit 1
		fi
		source "$__basalt_dirname/pkg/src/util/init.sh"
	fi
	if ! init.assert_bash_version; then
		printf '%s\n' 'Fatal: main.basalt: Basalt requires at least Bash version 4.3' >&2
		exit 1
	fi

	# Don't re-source files when doing testing. This speeds up testing and also
	# ensures function stubs are not overriden
	if [ "$BASALT_INTERNAL_IS_TESTING" != 'yes' ]; then
		init.common_init "$__basalt_dirname"
	fi

	local arg=
	for arg; do case $arg in
	--help|-h)
		util.show_help
		exit
		;;
	--version|-v)
		cat <<-EOF
		Version: v0.10.0
		EOF
		exit
		;;
	-*)
		print.die "Top-level flag '$arg' is not recognized"
		;;
	*)
		break
		;;
	esac done; unset -v arg

	if [ -z "$GITHUB_TOKEN" ]; then
		local github_token_file="${XDG_CONFIG_HOME}/basalt/token" # TODO: XDG library
		if [ -f "$github_token_file" ]; then
			GITHUB_TOKEN=$(<"$github_token_file")
			export GITHUB_TOKEN
		else
			core.print_die "No GitHub token file found in '$github_token_file'"
		fi
	fi

	case $1 in
	init)
		if ! shift; then core.panic 'Failed to shift'; fi
		basalt-init "$@" ;;
	add)
		if ! shift; then core.panic 'Failed to shift'; fi
		util.init_lock
		basalt-add "$@" ;;
	remove)
		if ! shift; then core.panic 'Failed to shift'; fi
		util.init_lock
		basalt-remove "$@" ;;
	install)
		if ! shift; then core.panic 'Failed to shift'; fi
		util.init_lock
		basalt-install "$@" ;;
	list)
		if ! shift; then core.panic 'Failed to shift'; fi
		util.init_lock
		basalt-list "$@" ;;
	run)
		if ! shift; then core.panic 'Failed to shift'; fi
		util.init_lock
		basalt-run "$@" ;;
	release)
		if ! shift; then core.panic 'Failed to shift'; fi
		util.init_lock
		basalt-release "$@" ;;
	complete)
		if ! shift; then core.panic 'Failed to shift'; fi
		util.init_lock
		basalt-complete "$@" ;;
	global)
		if ! shift; then core.panic 'Failed to shift'; fi
		case $1 in
		init)
			if ! shift; then core.panic 'Failed to shift'; fi
			basalt-global-init "$@" ;;
		add)
			if ! shift; then core.panic 'Failed to shift'; fi
			util.init_lock
			basalt-global-add "$@" ;;
		remove)
			if ! shift; then core.panic 'Failed to shift'; fi
			util.init_lock
			basalt-global-remove "$@" ;;
		install)
			if ! shift; then core.panic 'Failed to shift'; fi
			util.init_lock
			basalt-global-install "$@" ;;
		list)
			if ! shift; then core.panic 'Failed to shift'; fi
			util.init_lock
			basalt-global-list "$@" ;;
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
