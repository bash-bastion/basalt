# shellcheck shell=bash
# Version: 0.1.2

# @name Hookah lib.sh
# @brief Hookah: An elegantly minimal solution for Git hooks
# @description Hookah streamlines the process of managing Git hooks. This file is a
# library of functions that can easily be used by hooks written in Bash. Use it by
# prepending your hook script with the following
#
# ```bash
# #!/usr/bin/env bash
#
# source "${0%/*}/.hookah/lib.sh"
# hookah.init
# ```
#
# Learn more about it [on GitHub](https://github.com/hyperupcall/hookah)

if [ -z "$BASH_VERSION" ]; then
	printf '%s\n' "Error: lib.sh: This script is only compatible with Bash. Exiting" >&2
	exit 1
fi

# @description Initiates the environment, sets up stacktrace printing on the 'ERR' trap,
# and sets the directory to the root of the Git repository
# @noargs
hookah.init() {
	set -Eeo pipefail
	shopt -s dotglob extglob globasciiranges globstar lastpipe shift_verbose
	export LANG='C' LC_CTYPE='C' LC_NUMERIC='C' LC_TIME='C' LC_COLLATE='C' \
		LC_MONETARY='C' LC_MESSAGES='C' LC_PAPER='C' LC_NAME='C' LC_ADDRESS='C' \
		LC_TELEPHONE='C' LC_MEASUREMENT='C' LC_IDENTIFICATION='C' LC_ALL='C'
	trap '__hookah_trap_err' 'ERR'

	while [ ! -d '.git' ] && [ "$PWD" != / ]; do
		if ! cd ..; then
			__hookah_internal_die "Failed to cd to nearest Git repository"
		fi
	done
	if [ "$PWD" = / ]; then
		__hookah_internal_die "Failed to cd to nearest Git repository"
	fi

	# Prevent any possibilities of 'stdin in is not a tty'
	if ! exec </dev/tty; then
		__hookah_internal_warn "Failed to redirect tty to standard input"
	fi

	__hookah_internal_info "Running ${BASH_SOURCE[1]##*/}"
}

# @description Prints a command before running it
# @arg $@ Command to execute
hookah.run() {
	__hookah_exec "$*"
	"$@"
}

# @description Prints a command before running it. But, if the command fails, do not abort execution
# @arg $@ Command to execute
hookah.run_allow_fail() {
	if ! hookah.run "$@"; then
		hookah.die 'Command failed'
	fi
}

# @description Prints `$1` formatted as an error and the stacktrace to standard error,
# then exits with code 1
# @arg $1 string Text to print
hookah.die() {
	if [ -n "$1" ]; then
		__hookah_internal_error "$1. Exiting" 'Hookah'
	else
		__hookah_internal_error 'Exiting' 'Hookah'
	fi

	exit 1
}

# @description Prints `$1` formatted as a warning to standard error
# @arg $1 string Text to print
hookah.warn() {
	__hookah_internal_warn "$1" 'Hookah'
}

# @description Prints `$1` formatted as information to standard output
# @arg $1 string Text to print
hookah.info() {
	__hookah_internal_info "$1" 'Hookah'
}

# @description Scans environment variables to determine if script is in a CI environment
# @exitcode 0 If in CI
# @exitcode 1 If not in CI
# @set REPLY Current provider for CI
hookah.is_ci() {
	unset -v REPLY; REPLY=

	# List from 'https://github.com/watson/ci-info/blob/master/vendors.json'
	if [[ -v 'APPVEYOR' ]]; then
		REPLY='AppVeyor'
	elif [[ -v 'SYSTEM_TEAMFOUNDATIONCOLLECTIONURI' ]]; then
		REPLY='Azure Pipelines'
	elif [[ -v 'AC_APPCIRCLE' ]]; then
		REPLY='Appcircle'
	elif [[ -v 'bamboo_planKey' ]]; then
		REPLY='Bamboo'
	elif [[ -v 'BITBUCKET_COMMIT' ]]; then
		REPLY='Bitbucket Pipelines'
	elif [[ -v 'BITRISE_IO' ]]; then
		REPLY='Bitrise'
	elif [[ -v 'BUDDY_WORKSPACE_ID' ]]; then
		REPLY='Buddy'
	elif [[ -v 'BUILDKITE' ]]; then
		REPLY='Buildkite'
	elif [[ -v 'CIRCLECI' ]]; then
		REPLY='CircleCI'
	elif [[ -v 'CIRRUS_CI' ]]; then
		REPLY='Cirrus CI'
	elif [[ -v 'CODEBUILD_BUILD_ARN' ]]; then
		REPLY='AWS CodeBuild'
	elif [[ -v 'CF_BUILD_ID' ]]; then
		REPLY='Codefresh'
	elif [[ -v '[object Object]' ]]; then
		REPLY='Codeship'
	elif [[ -v 'DRONE' ]]; then
		REPLY='Drone'
	elif [[ -v 'DSARI' ]]; then
		REPLY='dsari'
	elif [[ -v 'EAS_BUILD' ]]; then
		REPLY='Expo Application Services'
	elif [[ -v 'GITHUB_ACTIONS' ]]; then
		REPLY='GitHub Actions'
	elif [[ -v 'GITLAB_CI' ]]; then
		REPLY='GitLab CI'
	elif [[ -v 'GO_PIPELINE_LABEL' ]]; then
		REPLY='GoCD'
	elif [[ -v 'LAYERCI' ]]; then
		REPLY='LayerCI'
	elif [[ -v 'HUDSON_URL' ]]; then
		REPLY='Hudson'
	elif [[ -v 'JENKINS_URL,BUILD_ID' ]]; then
		REPLY='Jenkins'
	elif [[ -v 'MAGNUM' ]]; then
		REPLY='Magnum CI'
	elif [[ -v 'NETLIFY' ]]; then
		REPLY='Netlify CI'
	elif [[ -v 'NEVERCODE' ]]; then
		REPLY='Nevercode'
	elif [[ -v 'RENDER' ]]; then
		REPLY='Render'
	elif [[ -v 'SAILCI' ]]; then
		REPLY='Sail CI'
	elif [[ -v 'SEMAPHORE' ]]; then
		REPLY='Semaphore'
	elif [[ -v 'SCREWDRIVER' ]]; then
		REPLY='Screwdriver'
	elif [[ -v 'SHIPPABLE' ]]; then
		REPLY='Shippable'
	elif [[ -v 'TDDIUM' ]]; then
		REPLY='Solano CI'
	elif [[ -v 'STRIDER' ]]; then
		REPLY='Strider CD'
	elif [[ -v 'TASK_ID,RUN_ID' ]]; then
		REPLY='TaskCluster'
	elif [[ -v 'TEAMCITY_VERSION' ]]; then
		REPLY='TeamCity'
	elif [[ -v 'TRAVIS' ]]; then
		REPLY='Travis CI'
	elif [[ -v 'NOW_BUILDER' ]]; then
		REPLY='Vercel'
	elif [[ -v 'APPCENTER_BUILD_ID' ]]; then
		REPLY='Visual Studio App Center'
	else
		return 1
	fi
}

# @description Test whether color should be outputed
# @exitcode 0 if should print color
# @exitcode 1 if should not print color
# @internal
__hookah_is_color() {
	if [[ -v NO_COLOR || $TERM == dumb ]]; then
		return 1
	else
		return 0
	fi
}

# @internal
__hookah_exec() {
	if __hookah_is_color; then
		printf "\033[1mHookah \033[1m[exec]:\033[0m %s\n" "$*"
	else
		printf "Hookah [exec]: %s\n" "$*"
	fi
}

# @internal
__hookah_internal_die() {
	__hookah_internal_error "$1"
	exit 1
}

# @internal
__hookah_internal_error() {
	local str="${2:-"Hookah (internal)"}"

	if __hookah_is_color; then
		printf "\033[1;31m\033[1m$str \033[1m[error]:\033[0m %s\n" "$1"
	else
		printf "$str [error]: %s\n" "$1"
	fi
} >&2

# @internal
__hookah_internal_warn() {
	local str="${2:-"Hookah (internal)"}"

	if __hookah_is_color; then
		printf "\033[1;33m\033[1m$str \033[1m[warn]:\033[0m %s\n" "$1"
	else
		printf "$str [warn]: %s\n" "$1"
	fi
} >&2

# @internal
__hookah_internal_info() {
	local str="${2:-"Hookah (internal)"}"

	if __hookah_is_color; then
		printf "\033[0;36m\033[1m$str \033[1m[info]:\033[0m %s\n" "$1"
	else
		printf "$str [info]: %s\n" "$1"
	fi
}

# @internal
__hookah_trap_err() {
	local error_code=$?

	__hookah_internal_error "Your hook did not exit successfully (exit code $error_code)"

	exit $error_code
}
