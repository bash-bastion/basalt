# shellcheck shell=bash

# @file util.sh
# @brief Utility functions for all subcommands

# @description Given input of a particular package on the internet
# parse it into its components
util.parse_package_full() {
	local repoSpec="$1"

	if [ -z "$repoSpec" ]; then
		die "Must supply a repository"
	fi

	# Remove any http(s) prefixes
	repoSpec="${repoSpec#http?(s)://}"

	local site user repository
	if [[ "$repoSpec" = */*/* ]]; then
		IFS='/' read -r site user repository <<< "$repoSpec"
	elif [[ "$repoSpec" = */* ]]; then
		site="github.com"
		IFS='/' read -r user repository <<< "$repoSpec"
	fi

	if [[ "$repository" = *@* ]]; then
		IFS='@' read -r repository ref <<< "$repository"
	else
		ref=""
	fi

	ensure.nonZero 'site' "$site"
	ensure.nonZero 'user' "$user"
	ensure.nonZero 'repository' "$repository"

	REPLY="$site:$user:$repository:$ref"
}

util.resolve_link() {
	if type -p realpath >/dev/null; then
		realpath "$1"
	else
		readlink -f "$1"
	fi
}

# TODO: extract to own repo
# @description Retrieve a string key from a toml file
util.get_toml_string() {
	REPLY=
	local tomlFile="$1"
	local keyName="$2"

	if [ ! -f "$tomlFile" ]; then
		die "File '$tomlFile' not found"
	fi

	local grepLine=
	while IFS= read -r line; do
		if [[ $line == *"$keyName"*=* ]]; then
			grepLine="$line"
			break
		fi
	done < "$tomlFile"

	# If the grepLine is empty, it means the key wasn't found, and we continue to
	# the next configuration file. We need the intermediary grep check because
	# we don't want to set the value to an empty string if it the config key is
	# not found in the file (since piping to sed would result in something indistinguishable
	# from setting the key to an empty string value)
	if [ -z "$grepLine" ]; then
		REPLY=''
		return 1
	fi

	local regex="[ \t]*${keyName}[ \t]*=[ \t]*['\"](.*)['\"]"
	if [[ $grepLine =~ $regex ]]; then
		REPLY="${BASH_REMATCH[1]}"
	else
		die "Value for key '$keyName' not valid"
	fi
}

# @description Retrieve an array key from a TOML file
util.get_toml_array() {
	declare -ga REPLIES=()
	local tomlFile="$1"
	local keyName="$2"

	local grepLine=
	while IFS= read -r line; do
		if [[ $line == *"$keyName"*=* ]]; then
			grepLine="$line"
			break
		fi
	done < "$tomlFile"

	# If the grepLine is empty, it means the key wasn't found, and we continue to
	# the next configuration file. We need the intermediary grep check because
	# we don't want to set the value to an empty string if it the config key is
	# not found in the file (since piping to sed would result in something indistinguishable
	# from setting the key to an empty string value)
	if [ -z "$grepLine" ]; then
		REPLY=''
		# return 1
		return
	fi

	local regex="[ \t]*${keyName}[ \t]*=[ \t]*\[[ \t]*(.*)[ \t]*\]"
	if [[ "$grepLine" =~ $regex ]]; then
		local -r arrayString="${BASH_REMATCH[1]}"

		IFS=',' read -ra REPLIES <<< "$arrayString"
		for i in "${!REPLIES[@]}"; do
			# Treat all TOML strings the same; there shouldn't be
			# any escape characters anyways
			local regex="[ \t]*['\"](.*)['\"]"
			if [[ ${REPLIES[$i]} =~ $regex ]]; then
				REPLIES[$i]="${BASH_REMATCH[1]}"
			else
				die "Array for key '$keyName' not valid"
			fi
		done
	else
		die "Key '$keyName' in file '$tomlFile' must be set to an array that spans one line"
	fi
}

# @description Extract a shell variable from a shell file. Of course, this doesn't
# properly account for esacape characters and the such, but that shouldn't be included
# in this string in the first place
util.extract_shell_variable() {
	REPLY=

	local shellFile="$1"
	local variableName="$2"

	if [ ! -f "$shellFile" ]; then
		die "File '$shellFile' not found"
	fi

	ensure.nonZero 'variableName' "$variableName"

	# Note: the following code/regex fails on macOS, so a different parsing method was done below
	# local regex="^[ \t]*(declare.*? |typeset.*? )?$variableName=[\"']?([^('|\")]*)"
	# if [[ "$(<"$shellFile")" =~ $regex ]]; then
		# REPLY="${BASH_REMATCH[2]}"
	# fi

	while IFS='=' read -r key value; do
		if [ "$key" = "$variableName" ]; then
			REPLY="$value"
			REPLY="${REPLY#\'}"
			REPLY="${REPLY%\'}"
			REPLY="${REPLY#\"}"
			REPLY="${REPLY%\"}"
		fi
	done < "$shellFile"
}

util.show_help() {
	cat <<"EOF"
Usage:
  bpm [--help|--version] <command> [args...]

Subcommands:
  init <shell>
    Configure the shell environment for Basher

  install [--ssh] [site]/<package>[@ref]
    Installs a package from GitHub (or a custom site)

  uninstall <package>
    Uninstalls a package

  link [--no-deps] <directory>
    Installs a local directory as a basher package. These show up with
    a namespace of 'bpm-local'

  list [--outdated]
    List installed packages

  package-path <package>
    Outputs the path for a package

  upgrade <package>
    Upgrades a package

  complete <command>
    Perform the completion for a particular subcommand. Used by the completion scripts

  echo <variable>
    Echo a particular internal variable. Used by the testing suite

Examples:
  bpm install tj/git-extras
  bpm install github.com/tj/git-extras
  bpm install https://github.com/tj/git-extras
EOF
}
