# shellcheck shell=bash

# @file util.sh
# @brief Utility functions for all subcommands

# @description Given some user input, this extracts
# data like the site it was cloned from, the owner of
# the repository, and the name of the repository
# @arg $1 repoSpec
# @arg $2 with_ssh Whether to clone with SSH (yes/no)
util.extract_data_from_input() {
	REPLY1=
	REPLY2=
	REPLY3=
	REPLY4=

	local repoSpec="$1"
	local with_ssh="${2:-no}"

	if [ -z "$repoSpec" ]; then
		die "Must supply a repository"
	fi

	local site= package= ref=

	local regex="^https?://"
	local regex2="^git@"
	if [[ "$repoSpec" =~ $regex ]]; then
		local http="${repoSpec%%://*}"
		repoSpec="${repoSpec#http?(s)://}"
		repoSpec="${repoSpec%.git}"

		IFS='/' read -r site package <<< "$repoSpec"

		REPLY1="$http://$repoSpec.git"
		REPLY2="$site"
		REPLY3="$package"
		REPLY4=
	elif [[ "$repoSpec" =~ $regex2 ]]; then
		repoSpec="${repoSpec#git@}"
		repoSpec="${repoSpec%.git}"

		IFS=':' read -r site package <<< "$repoSpec"

		REPLY1="git@$repoSpec"
		REPLY2="$site"
		REPLY3="$package"
		REPLY4=
	else
		repoSpec="${repoSpec%.git}"

		if [[ "$repoSpec" == */*/* ]]; then
			IFS='/' read -r site package <<< "$repoSpec"
		elif [[ "$repoSpec" = */* ]]; then
			site="github.com"
			package="$repoSpec"
		else
			die "Invalid repository '$repoSpec'"
		fi

		if [[ "$package" == *@* ]]; then
			IFS='@' read -r package ref <<< "$package"
		fi

		if [ "$with_ssh" = yes ]; then
			REPLY1="git@$site:$package"
		else
			REPLY1="https://$site/$package.git"
		fi
		REPLY2="$site"
		REPLY3="$package"
		REPLY4="$ref"
	fi
}

# @description Given a path to a package directory, this extracts
# data like the site it was cloned from, the owner of
# the repository, and the name of the repository
util.extract_data_from_package_dir() {
	REPLY1=
	REPLY2=
	REPLY3=
	REPLY4=

	local dir="$1"
	ensure.non_zero 'dir' "$dir"

	local site="${dir%/*}"; site="${site%/*}"; site="${site##*/}"
	local user="${dir%/*}"; user="${user##*/}"
	local repository="${dir##*/}"

	if [ "$user" = 'local' ]; then
		REPLY1="$user"
		REPLY2=''
		REPLY3="$repository"
	else
		REPLY1="$site"
		REPLY2="$user"
		REPLY3="$repository"
	fi
	REPLY4=
}

util.readlink() {
	if command -v realpath &>/dev/null; then
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
		return 1
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

	if [ ! -e "$shellFile" ]; then
		die "File '$shellFile' not found"
	fi

	ensure.non_zero 'variableName' "$variableName"

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

			return 0
		fi
	done < "$shellFile"

	return 1
}

# @description Get the working directory of the project. Note
# that this should always be called within a subshell
util.get_project_root_dir() {
	while [[ ! -f "bpm.toml" && "$PWD" != / ]]; do
		cd ..
	done

	if [[ $PWD == / ]]; then
		return 1
	fi

	printf "%s" "$PWD"
}

util.show_help() {
	cat <<"EOF"
Usage:
  bpm [--help|--version|--global|-g] <command> [args...]

Subcommands:
  init <shell>
    Configure shell environment for Basher

  add [--ssh] [[site/]<package>[@ref]...]
    Installs a package from GitHub (or a custom site)

  remove <package...>
    Uninstalls a package

  link [--no-deps] <directory...>
    Installs a local directory as a bpm package. These show up with
    a namespace of 'local'

  list [--outdated]
    List installed packages

  package-path <package>
    Outputs the path for a package

  upgrade <package...>
    Upgrades a package

  complete <command...>
    Perform the completion for a particular subcommand. Used by the completion scripts

Examples:
  bpm add tj/git-extras
  bpm add github.com/tj/git-extras
  bpm add https://github.com/tj/git-extras
  bpm add git@github.com:tj/git-extras
EOF
}
