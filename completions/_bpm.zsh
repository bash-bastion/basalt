#compdef _bpm bpm

local -a _1st_arguments
_1st_arguments=(
	'add:Add a package'
	'echo:Debugging command to print internal variable'
	'init:Print shell initialization code'
	'link:Link a local package'
	'list:List packages'
	'prune:Prune all packages'
	'remove:Uninstall a package'
	'upgrade:[TASK] Upgrade a package'
	'--version:Print version'
	'--help:Show help'
)

local expl
# local -a boxes installed_boxes

local curcontext="$curcontext" state line
local -A opt_args

_arguments -C \
	':command:->command' \
	'*::options:->options'

case $state in
(command)
	_describe -t commands "gem subcommand" _1st_arguments
	return
	;;
(options)
	case $line[1] in
		(add)
			local -a subcommandOptions=()
			_describe -t commands "gem subcommand" subcommandOptions
			;;
		(init)
			local -a subcommandOptions=(sh bash zsh fish)
			_describe -t commands "gem subcommand" subcommandOptions
			;;
		(link)
			local -a subcommandOptions=()
			_describe -t commands "gem subcommand" subcommandOptions
			;;
		(list)
			local -a subcommandOptions=(--outdated)
			_describe -t commands "gem subcommand" subcommandOptions
			;;
		(remove)
			local -a subcommandOptions=(--all --force)
			_describe -t commands "gem subcommand" subcommandOptions
			;;
		(upgrade)
			local subcommandOptions=()
			subcommandOptions=("${(@f)$(bpm complete upgrade)}")
			# TODO: Check if bpm complete upgrade was successfull?
			_describe -t commands "gem subcommand" subcommandOptions
			;;
	esac
	;;
esac
