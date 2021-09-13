# shellcheck shell=bash

# @file util.sh
# @brief Utility functions for all subcommands

util.remove_local_basalt_packages() {
	# Everything in the local ./basalt_packages is a symlink to something in the global
	# cellar directory. Thus, we can just remove it since it won't take long to re-symlink.
	# This has the added benefit that outdated packages will automatically be pruned
	if ! rm -rf "${BASALT_LOCAL_STUFF_DIR:?}"; then
		print_simple.die "Could not remove local 'basalt_packages' directory"
	fi
}

# @description Get the working directory of the project. Note
# that this should always be called within a subshell
util.get_local_project_root_dir() {
	while [ ! -f 'basalt.toml' ] && [ "$PWD" != / ]; do
		cd ..
	done

	if [ "$PWD" = / ]; then
		return 1
	fi

	printf "%s" "$PWD"
}

util.init_local() {
	util.init_global

	local local_project_root_dir=
	if local_project_root_dir="$(util.get_local_project_root_dir)"; then
		BASALT_LOCAL_PROJECT_DIR="$local_project_root_dir"
		BASALT_LOCAL_STUFF_DIR="$local_project_root_dir/basalt_packages"
	else
		print_simple.die "Could not find a 'basalt.toml' file"
	fi
}

# @description Ensures particular variables exist and sets the current mode of
# operation
util.init_global() {
	if [ -z "$BASALT_GLOBAL_REPO" ] || [ -z "$BASALT_GLOBAL_DATA_DIR" ]; then
		print_simple.die "Either 'BASALT_GLOBAL_REPO' or 'BASALT_GLOBAL_DATA_DIR' is empty. Did you forget to run add 'basalt init <shell>' in your shell configuration?"
	fi
}

util.extract_data_from_input() {
	REPLY1=; REPLY2=; REPLY3=; REPLY4=; REPLY5=

	local repoSpec="$1"

	if [ -z "$repoSpec" ]; then
		print_simple.die "Must supply a repository"
	fi

	local site= package= ref=

	local regex="^https?://"
	local regex2="^git@"
	local regex3="^file://" # TODO:
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
		local dir=

		repoSpec="${repoSpec#file:\/\/}"
		IFS='@' read -r dir ref <<< "$repoSpec"

		REPLY1="file://$dir"
		REPLY2="github.com"
		REPLY3="${dir%/*}"; REPLY3="${REPLY3##*/}/${dir##*/}"
		REPLY4="$ref"

		if [ -z "${REPLY3%/*}" ]; then
			print_simple.die "Directory specified with file protocol must have at least one parent directory (for the package name)"
		fi
	else
		repoSpec="${repoSpec%.git}"

		if [[ "$repoSpec" == */*/* ]]; then
			IFS='/' read -r site package <<< "$repoSpec"
		elif [[ "$repoSpec" = */* ]]; then
			site="github.com"
			package="$repoSpec"
		else
			print_simple.die "Package '$repoSpec' does not appear to be formatted correctly"
		fi

		if [[ "$package" == *@* ]]; then
			IFS='@' read -r package ref <<< "$package"
		fi


		REPLY1="https://$site/$package.git"
		REPLY2="$site"
		REPLY3="$package"
		REPLY4="$ref"
	fi

	# TODO: do other sites
	if [ "$site" = github.com ]; then
		REPLY5="https://github.com/$package/archive/refs/tags/$ref.tar.gz"
	else
		print_simple.die "Could not construct tarball_uri for site '$site'"
	fi
}

# TODO: extract to own repo
# @description Retrieve a string key from a toml file
util.get_toml_string() {
	REPLY=
	local tomlFile="$1"
	local keyName="$2"

	if [ ! -f "$tomlFile" ]; then
		print_simple.die "File '$tomlFile' not found"
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
		print_simple.die "Value for key '$keyName' not valid"
	fi
}

# @description Retrieve an array key from a TOML file
util.get_toml_array() {
	declare -ga REPLIES=()
	local tomlFile="$1"
	local keyName="$2"

	if [ ! -f "$tomlFile" ]; then
		print.die 'Internal Error' "File '$tomlFile' does not exist"
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

util.show_help() {
	cat <<"EOF"
Basalt:
  The rock-solid Bash package manager

Usage:
  basalt [--help|--version]
  basalt <subcommand> [args...]
  basalt global <subcommand> [args...]

Subcommands (local):
  init
    Create a new basalt package in the current directory

  install
    Resolve and install dependencies specified in basalt.toml

  link <directory...>
    Installs a package from a local directory. These have a
    namespace of 'local'

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

  list [--fetch] [--format=<simple>] [package...]
    List all installed packages or just the specified ones

Examples:
  basalt add tj/git-extras
  basalt add github.com/tj/git-extras
  basalt add https://github.com/tj/git-extras
  basalt add git@github.com:tj/git-extras
  basalt add hyperupcall/bash-args --branch=main
  basalt add hyperupcall/bash-args@v0.6.1 # out of date
EOF
}
