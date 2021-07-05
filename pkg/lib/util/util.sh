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

util.show_help() {
	cat <<"EOF"
Usage:
  neobasher [--help|--version] <command> [args...]

Subcommands:
  init <shell>
    Configure the shell environment for Basher

  install [--ssh] [site]/<package>[@ref]
    Installs a package from GitHub (or a custom site)

  uninstall <package>
    Uninstalls a package

  link [--no-deps] <directory>
    Installs a local directory as a basher package. These show up with
    a namespace of 'neobasher-local'

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
  neobasher install tj/git-extras
  neobasher install github.com/tj/git-extras
  neobasher install https://github.com/tj/git-extras
EOF
}
