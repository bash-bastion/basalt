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
