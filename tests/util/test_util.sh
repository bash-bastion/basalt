# shellcheck shell=bash

# @description This mocks a command by creating a function for it, which
# prints all the arguments to the command, in addition to the command name
test_util.mock_command() {
	case "$1" in
	plumbing-clone)
		bpm-plumbing-clone() {
			local use_ssh="$1"
			local site="$2"
			local user="$3"
			local repository="$4"

			git clone "$BPM_ORIGIN_DIR/$user/$repository" "$BPM_PACKAGES_PATH/$user/$repository"
		}
		;;
	*)
		# This creates a function with the first argument (the function to
		# mock). When called, it prints the command name, along with the arguments
		# it was called with
		eval "$1() { echo \"$1 \$*\"; }"
		;;
	esac
}

test_util.readlink() {
	if command -v realpath &>/dev/null; then
		realpath "$1"
	else
		readlink -f "$1"
	fi
}
