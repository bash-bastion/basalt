# shellcheck shell=bash

# @file util.sh
# @brief Utility functions for all subcommands

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

	link [--no-deps] <directory> <package>
		Installs a local directory as a basher package

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
	neobasher install eankeen/neobasher
EOF
}
