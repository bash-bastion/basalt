# shellcheck shell=bash

# @file util.sh
# @brief Utility functions

# @description Initialize variables required for non-global subcommands
util.init_local() {
	util.init_global

	local local_project_root_dir=
	if local_project_root_dir="$(
		while [ ! -f 'basalt.toml' ] && [ "$PWD" != / ]; do
			if ! cd ..; then
				return 1
			fi
		done

		if [ "$PWD" = / ]; then
			return 1
		fi

		printf '%s' "$PWD"
	)"; then
		BASALT_LOCAL_PROJECT_DIR="$local_project_root_dir"
	else
		print_simple.die "Could not find a 'basalt.toml' file"
	fi
}

# @description Check for the initialization of variables essential for global subcommands
util.init_global() {
	if [ -z "$BASALT_GLOBAL_REPO" ] || [ -z "$BASALT_GLOBAL_DATA_DIR" ]; then
		print_simple.die "Either 'BASALT_GLOBAL_REPO' or 'BASALT_GLOBAL_DATA_DIR' is empty. Did you forget to run add 'basalt init <shell>' in your shell configuration?"
	fi
}

util.remove_local_basalt_packages() {
	# Everything in the local ./basalt_packages is a symlink to something in the global
	# cellar directory. Thus, we can just remove it since it won't take long to re-symlink.
	# This has the added benefit that outdated packages will automatically be pruned
	if ! rm -rf "$BASALT_LOCAL_PROJECT_DIR/basalt_packages"; then
		print_simple.die "Could not remove local 'basalt_packages' directory"
	fi
}

util.get_package_info() {
	REPLY1=; REPLY2=; REPLY3=; REPLY4=; REPLY5=

	local input="$1"

	if [ -z "$input" ]; then
		print_simple.die "Must supply a repository"
	fi

	local regex1="^https?://"
	local regex2="^git@"
	local regex3="^file://"
	if [[ "$input" =~ $regex1 ]]; then
		local site= package=
		local http="${input%%://*}"
		input="${input#http?(s)://}"
		input="${input%.git}"

		IFS='/' read -r site package <<< "$input"

		REPLY1="$http://$input.git"
		REPLY2="$site"
		REPLY3="$package"
		REPLY4=
	elif [[ "$input" =~ $regex2 ]]; then
		local site= package=

		input="${input#git@}"
		input="${input%.git}"

		IFS=':' read -r site package <<< "$input"

		REPLY1="git@$input"
		REPLY2="$site"
		REPLY3="$package"
		REPLY4=
	elif [[ "$input" =~ $regex3 ]]; then
		local ref= dir=

		input="${input#file:\/\/}"
		IFS='@' read -r dir ref <<< "$input"

		REPLY1="file://$dir"
		REPLY2="github.com"
		REPLY3="${dir%/*}"; REPLY3="${REPLY3##*/}/${dir##*/}"
		REPLY4="$ref"

		# TODO
		if [ -z "${REPLY3%/*}" ]; then
			print_simple.die "Directory specified with file protocol must have at least one parent directory (for the package name)"
		fi
	else
		local site= package=
		input="${input%.git}"

		if [[ "$input" == */*/* ]]; then
			IFS='/' read -r site package <<< "$input"
		elif [[ "$input" = */* ]]; then
			site="github.com"
			package="$input"
		else
			print_simple.die "Package '$input' does not appear to be formatted correctly"
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

# @description Get path to download tarball of particular package revision
util.get_tarball_url() {
	local site="$1"
	local package="$2"
	local ref="$3"

	if [ "$site" = github.com ]; then
		REPLY="https://github.com/$package/archive/refs/tags/$ref.tar.gz"
	elif [ "$site" = gitlab.com ]; then
		REPLY="https://gitlab.com/$package/-/archive/$ref/${package#*/}-$ref.tar.gz"
	else
		print_simple.die "Could not construct tarball_uri for site '$site'"
	fi
}

# @description Get the latest package version
util.get_latest_package_version() {
	unset REPLY; REPLY=
	local repo_uri="$1"
	local site="$2"
	local package="$3"

	local index_url=
	local -a index_jq=()
	if [ "$site" = 'github.com' ]; then
		index_url="https://api.github.com/repos/$package/releases/latest"
		index_jq=(jq -r '.name')
	else
		# TODO gitlab
		print_simple.die "Site '$site' not supported"
	fi

	# TODO: will it get beta/alpha/pre-releases??
	# Get the latest pacakge version that has been released

	local latest_package_version=
	if latest_package_version="$(
		curl -LsS "$index_url" | "${index_jq[@]}"
	)"; then
		if [ "$latest_package_version" != null ]; then
			REPLY="${latest_package_version##*/}"
			return
		fi
	fi

	# If there is not a release, then just get the latest commit
	# of the project
	local latest_commit=
	if latest_commit="$(
		git ls-remote "$repo_uri" | awk '{ if($2 == "HEAD") print $1 }'
	)"; then
		REPLY="$latest_commit"
		return
	fi

	print.die "Could not get latest release or commit for package '$package'"
}

util.assert_package_valid() {
	# local site="$1"
	# local package="$2"
	# local ref="$3"

	# if [[ "$site" =~ ^.*\..*$ ]]; then
	# 	return 0
	# else
	# 	return 1
	# fi

	# if [[ "$package" =~ ^[-a-zA-Z0-9_]*/[a-zA-Z][-a-zA-Z0-9_]*$ ]]; then
	# 	return 0
	# else
	# 	return 1
	# fi

	# if [[ "$ref" =~ ^(v|{"}"})*$ ]]; then
	# 	return 0
	# else
	# 	print_simple.die "Package owner or name has invalid characters"
	# fi
	:
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
