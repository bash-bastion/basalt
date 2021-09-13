# shellcheck shell=bash

test_util.get_repo_root() {
	unset REPLY; REPLY=

	if ! REPLY="$(
		while [ ! -d ".git" ] && [ "$PWD" != / ]; do
			if ! cd ..; then
				exit 1
			fi
		done

		if [ "$PWD" = / ]; then
			exit 1
		fi

		printf '%s' "$PWD"
	)"; then
		printf '%s\n' "Error: test_util.get_repo_root failed"
		exit 1
	fi
}

# @description This stubs a command by creating a function for it, which
# prints the command name and its arguments
test_util.stub_command() {
	eval "$1() { echo \"$1 \$*\"; }"
}
