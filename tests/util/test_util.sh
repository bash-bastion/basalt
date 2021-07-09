# shellcheck shell=bash
# shellcheck disable=SC2164

# @description This mocks a command by creating a function for it, which
# prints all the arguments to the command, in addition to the command name
test_util.mock_command() {
	# This creates a function with a name of the first argument. When called, it prints the command name, along with the arguments
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
		local package="$1"

		test_util.fake_clone "$package"
		do-plumbing-deps "$package"
		do-plumbing-link-bins "$package"
		do-plumbing-link-completions "$package"
		do-plumbing-link-man "$package"
}

test_util.readlink() {
	if command -v realpath &>/dev/null; then
		realpath "$1"
	else
		readlink -f "$1"
	fi
}

# @description Creates a 'bpm package', and cd's into it
test_util.setup_pkg() {
	local package="$1"

	create_package "$package"
	cd "$BPM_ORIGIN_DIR/$package"
}

# @description Commits changes and cd's out of the package directory
# into the regular testing directory
test_util.finish_pkg() {
	git add .
	git commit -m "commit"
	cd "$BPM_CWD"
}
