# shellcheck shell=bash

# @description This mocks a command by creating a function for it, which
# prints all the arguments to the command, in addition to the command name
test_util.mock_command() {
	# This creates a function with the first argument (the function to
	# mock). When called, it prints the command name, along with the arguments
	# it was called with
	eval "$1() { echo \"$1 \$*\"; }"
}

# @description Fakes a clone. This is meant to be used for
# the download step
test_util.fake_clone() {
	local package="$1"

	git clone "$BPM_ORIGIN_DIR/$package" "$BPM_PACKAGES_PATH/$package"
}

# @description Clones the repository, and performs any linking, etc.
test_util.fake_install() {
	:
}

test_util.readlink() {
	if command -v realpath &>/dev/null; then
		realpath "$1"
	else
		readlink -f "$1"
	fi
}
