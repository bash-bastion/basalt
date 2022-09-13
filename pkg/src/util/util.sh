# shellcheck shell=bash

util.get_full_path() {
	if [ ! -d "$1" ]; then
			print.fatal "Package located at '$1' does not exist"
		fi
	if ! REPLY=$(realpath "$1"); then
		print.fatal "Failed to execute 'realpath' successfully"
	fi
}

# @description Ensure the downloaded file is really a .tar.gz file...
util.file_is_targz() {
	local file="$1"

	ensure.nonzero 'file'

	local magic_byte=
	if magic_byte="$(od -An -N2 -x "$file")"; then
		if [[ ${magic_byte#* } != *'8b1f'* ]]; then
			return 1
		fi
	else
		return 1
	fi
}

# @description Abort with error message relating to unexpected value
util.die_unexpected_value() {
	local variable="$1"

	ensure.nonzero 'variable'

	local -n __value="$variable"
	print.fatal "Variable '$variable' has unexpected value of '$__value'"
}


# @description Check if the package exists (either as a remote URL or file)
util.does_package_exist() {
	local repo_type="$1"
	local url="$2"

	ensure.nonzero 'repo_type'
	ensure.nonzero 'url'

	if [ "$repo_type" = 'remote' ]; then
		# TODO: make this cleaner (use GitHub, GitLab, etc. API)?
		if ! curl -LsfIo /dev/null --connect-timeout 1 --max-time 2.5 --retry 0 "$url"; then
			return 1
		fi
	elif [ "$repo_type" = 'local' ]; then
		# Assume '.git/' contains Git repository information
		if [ ! -d "${url:7}/.git" ]; then
			return 1
		fi
	else
		util.die_unexpected_value 'repo_type'
	fi

	return 0
}

# @description Get path to download tarball of particular package revision
util.get_tarball_url() {
	local site="$1"
	local package="$2"
	local ref="$3"

	ensure.nonzero 'site'
	ensure.nonzero 'package'
	ensure.nonzero 'ref'

	if [ "$site" = 'github.com' ]; then
		REPLY="https://github.com/$package/archive/refs/tags/$ref.tar.gz"
	elif [ "$site" = 'gitlab.com' ]; then
		REPLY="https://gitlab.com/$package/-/archive/$ref/${package#*/}-$ref.tar.gz"
	else
		print.die "Could not construct the location of the package tarball since '$site' is not supported"
	fi
}

util.show_help() {
	cat <<"EOF"
Usage:
  basalt [--help|--version]
  basalt <local-subcommand> [args...]
  basalt global <global-subcommand> [args...]

Local subcommands:
  init --type=<app|lib>
    Creates a new Basalt package in the current directory

  add <package>
    Adds a dependency to the current local project

  remove [--force] <package>
    Removes a dependency from the current local project

  install
    Resolves and installs all dependencies for the current local
    project

  list [--fetch] [--format=<simple>] [package...]
    Lists particular dependencies for the current local project

  run <command>
    Runs a particular command from any particular locally installed package

  release [--yes] [new-version]
    Prepare and release a package

Global subcommands:
  init <shell>
    Prints shell code that must be evaluated during shell
    initialization for the proper functioning of Basalt

  add <package>
    Installs a global package

  remove [--force] [package...]
    Uninstalls a global package

  install
    Installs all global dependencies

  list [--fetch] [--format=<simple>] [package...]
    List all installed packages or just the specified ones

Examples:
  basalt global add tj/git-extras
  basalt global add github.com/tj/git-extras
  basalt global add https://github.com/tj/git-extras
  basalt global add git@github.com:tj/git-extras
  basalt global add hyperupcall/bash-args --branch=main
  basalt global add hyperupcall/bash-args@v0.6.1 # out of date
EOF
}
