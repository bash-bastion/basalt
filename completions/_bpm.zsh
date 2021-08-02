#compdef _bpm bpm

local -a _1st_arguments
_1st_arguments=(
	'add:Add a package'
	'echo:Debugging command to print internal variable'
	'init:Print shell initialization code'
	'link:Link a local package'
	'list:List packages'
	'package-path:Print the full path of a package'
	'remove:Uninstall a package'
	'upgrade:[TASK] Upgrade a package'
	'init:[box_name] [box_url] Initializes current folder for Vagrant usage'
	'--version:Prints the Vagrant version information'
	'--global:Switch to global dependency management'
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
			local -a subcommandOptions=(--shh)
			_describe -t commands "gem subcommand" subcommandOptions
			;;
		(echo)
			local -a subcommandOptions=(BPM_ROOT BPM_PREFIX)
			_describe -t commands "gem subcommand" subcommandOptions
			;;
		(init)
			local -a subcommandOptions=(sh bash zsh fish)
			_describe -t commands "gem subcommand" subcommandOptions
			;;
		(link)
			local -a subcommandOptions=(--no-deps)
			_describe -t commands "gem subcommand" subcommandOptions
			;;
		(list)
			local -a subcommandOptions=(--outdated)
			_describe -t commands "gem subcommand" subcommandOptions
			;;
		(package-path)
			local subcommandOptions=()
			subcommandOptions=("${(@f)$(bpm complete package-path)}")
			_describe -t commands "gem subcommand" subcommandOptions
			;;
		(remove)
			;;
		(upgrade)
			local subcommandOptions=()
			subcommandOptions=("${(@f)$(bpm complete package-path)}")
			# TODO: Check if bpm complete package-path was successfull?
			_describe -t commands "gem subcommand" subcommandOptions
			;;
	esac
	;;
esac
