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

	if [ -z "$repoSpec" ]; then
		die "Must supply a repository"
	fi

	local site= package= ref=

	local regex="^https?://"
	local regex2="^git@"
	local regex3="^local/"
	local regex4="^file://"
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
	elif [[ "$repoSpec" =~ $regex3 ]]; then
		repoSpec="${repoSpec#local\/}"
		IFS='@' read -r package ref <<< "$repoSpec"

		REPLY1=
		REPLY2='local'
		REPLY3="$package"
		REPLY4="$ref"
	elif [[ "$repoSpec" =~ $regex4 ]]; then
		local dir=

		repoSpec="${repoSpec#file:\/\/}"
		IFS='@' read -r dir ref <<< "$repoSpec"

		REPLY1="file://$dir"
		REPLY2="github.com"
		REPLY3="${dir%/*}"; REPLY3="${REPLY3##*/}/${dir##*/}"
		REPLY4="$ref"

		if [ -z "${REPLY3%/*}" ]; then
			die "Directory specified with file protocol must have at least one parent directory (for the package name)"
		fi
	else
		repoSpec="${repoSpec%.git}"

		if [[ "$repoSpec" == */*/* ]]; then
			IFS='/' read -r site package <<< "$repoSpec"
		elif [[ "$repoSpec" = */* ]]; then
			site="github.com"
			package="$repoSpec"
		else
			die "Package '$repoSpec' does not appear to be formatted correctly"
		fi

		if [[ "$package" == *@* ]]; then
			IFS='@' read -r package ref <<< "$package"
		fi


		REPLY1="https://$site/$package.git"
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
				log.error "Array for key '$keyName' not valid"
				return 2
			fi
		done
	else
		log.error "Key '$keyName' in file '$tomlFile' must be set to an array that spans one line"
		return 2
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

# @description Ensures particular variables exist and sets the current mode of
# operation
util.init_command() {
	if [[ -z "$BPM_REPO_SOURCE" || -z "$BPM_CELLAR" ]]; then
		die "Either 'BPM_REPO_SOURCE' or 'BPM_CELLAR' is empty. Did you forget to run add 'bpm init <shell>' in your shell configuration?"
	fi


	if [ "$BPM_MODE" = local ]; then
		local project_root_dir=
		if project_root_dir="$(util.get_project_root_dir)"; then
			# TODO: improve this output
			# Output to standard error because some subcommands may be scriptable (ex. list)
			log.info "Operating in context of local bpm.toml" >&2
			if [ "${BPM_IS_TEST+x}" ]; then
				printf "  -> %s\n" "'$project_root_dir'"
			fi

			BPM_LOCAL_PROJECT_DIR="$project_root_dir"
			BPM_CELLAR="$project_root_dir/bpm_packages"
			BPM_PACKAGES_PATH="$BPM_CELLAR/packages"
			BPM_INSTALL_BIN="$BPM_CELLAR/bin"
			BPM_INSTALL_MAN="$BPM_CELLAR/man"
			BPM_INSTALL_COMPLETIONS="$BPM_CELLAR/completions"
		else
			die "Could not find a 'bpm.toml' file"
		fi
	else
		BPM_CELLAR="$BPM_CELLAR"
		BPM_PACKAGES_PATH="$BPM_CELLAR/packages"
		BPM_INSTALL_BIN="$BPM_CELLAR/bin"
		BPM_INSTALL_MAN="$BPM_CELLAR/man"
		BPM_INSTALL_COMPLETIONS="$BPM_CELLAR/completions"
	fi
}

util.show_help() {
	cat <<"EOF"
Usage:
  bpm [--help|--version]
  bpm <subcommand> [args...]
  bpm global <subcommand> [args...]

Subcommands (local):
  init
    Create a new bpm package in the current directory

  add [--branch=<name>] [[site/]<package>[@ref]...]
    Installs a package from GitHub (or a custom site)

  upgrade [--all] <package...>
    Upgrades a package

  remove [--all] [--force] <package...>
    Uninstalls a package

  link <directory...>
    Installs a package from a local directory. These have a
    namespace of 'local'

  prune
    Removes broken symlinks in the bins, completions, and man
    directories. This is usually only required if a package is
    force-removed

  list [--fetch] [--format=<simple>] [package...]
    List installed packages or just the specified ones

Subcommands (global):
  init <shell>
    Print shell variables and functions to be eval'd during shell initialization

  add [--branch=<name>] [[site/]<package>[@ref]...]
    Installs a package from GitHub (or a custom site)

  upgrade <package>
    Upgrades a package

  remove [--force] <package>
    Uninstalls a package

  link <directory>
    Installs a package from a local directory

  prune
    Removes broken symlinks

  list [--fetch] [--format=<simple>] [package...]
    List all installed packages or just the specified ones

Examples:
  bpm add tj/git-extras
  bpm add github.com/tj/git-extras
  bpm add https://github.com/tj/git-extras
  bpm add git@github.com:tj/git-extras
  bpm add hyperupcall/bash-args --branch=main
  bpm add hyperupcall/bash-args@v0.6.1 # out of date
EOF
}
