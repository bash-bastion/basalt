# shellcheck shell=bash
# shellcheck disable=SC2164

test_util.is_exported() {
	local variable_name="$1"

	if (( BASH_VERSINFO[0] > 4 )) || (( BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4 )); then
		local -n variable="$variable_name"
		if [[ "${variable@a}" == *x* ]]; then
			return 0
		else
			return 1
		fi
	else
		if declare -x | while read -r line; do
			case "$line" in
				"declare -x $variable_name"=*) return 10 ;;
			esac
		done; then
			return 1
		else
			if (($? == 10)); then
				return 0
			else
				return 1
			fi
		fi
	fi
}

test_util.get_repo_root() {
	REPLY=
	if ! REPLY="$(
		while [[ ! -d ".git" && "$PWD" != / ]]; do
			if ! cd ..; then
				printf "%s\n" "Error: Could not cd to BPM directory" >&2
				exit 1
			fi
		done

		if [[ $PWD == / ]]; then
			printf "%s\n" "Error: Could not find root BPM directory" >&2
			exit 1
		fi

		printf "%s" "$PWD"
	)"; then
		exit 1
	fi
}

# @description This stubs a command by creating a function for it, which
# prints the command name and its arguments
test_util.stub_command() {
	eval "$1() { echo \"$1 \$*\"; }"
}

# @description Fakes a clone. It accepts a directory
test_util.mock_clone() {
	local srcDir="$1"
	local destDir="$2"

	ensure.non_zero 'srcDir' "$srcDir"
	ensure.non_zero 'destDir' "$destDir"
	ensure.not_absolute_path "$srcDir"
	ensure.not_absolute_path "$destDir"

	# Be explicit with the 'file' protocol. The upstream "repository"
	# is just another (non-bare) Git repository
	git clone "file://$BPM_ORIGIN_DIR/$srcDir" "$BPM_PACKAGES_PATH/$destDir"
}

# @description Clones the repository, and performs any linking, etc.
test_util.mock_add() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"
	ensure.not_absolute_path "$dir"

	if [[ "$pkg" != */* ]]; then
		die "Improper package path. If you are passing in a single directory name, just make it nested within another subdirectory. This is to ensure BPM_PACKAGES_PATH has the correct layout"
	fi

	test_util.mock_clone "$pkg" "github.com/$pkg"
	do-plumbing-add-deps "github.com/$pkg"
	do-plumbing-link-bins "github.com/$pkg"
	do-plumbing-link-completions "github.com/$pkg"
	do-plumbing-link-man "github.com/$pkg"
}

# @description Mocks a 'bpm link'. This function is still useful in cases
# where a symlink is _expected_ (rather than just cloning to 'local/subdir')
test_util.mock_link() {
	local dir="$1"
	ensure.non_zero 'dir' "$dir"
	ensure.not_absolute_path "$dir"

	mkdir -p "$BPM_PACKAGES_PATH/local"
	ln -s "$BPM_ORIGIN_DIR/$dir" "$BPM_PACKAGES_PATH/local"

	do-plumbing-add-deps "local/$dir"
	do-plumbing-link-bins "local/$dir"
	do-plumbing-link-completions "local/$dir"
	do-plumbing-link-man "local/$dir"
}

# @description Utility to begin creating a package
test_util.setup_pkg() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"
	ensure.not_absolute_path "$pkg"

	# We create the "upstream" repository with the same relative
	# filepath as 'pkg' so we can use the same variable to
	# cd to it (rather than having to do ${pkg#*/})
	mkdir -p "$BPM_ORIGIN_DIR/$pkg"
	cd "$BPM_ORIGIN_DIR/$pkg"

	git init .
	touch 'README.md'
	git add .
	git commit -m "Initial commit"
	git branch -M master
}

# @description Utility to finish completing a package
test_util.finish_pkg() {
	git add .
	git commit --allow-empty -m "Make changes"
	cd "$BATS_TEST_TMPDIR"
}

# @description Utility function to create an empty package
test_util.create_package() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"

	test_util.setup_pkg "$pkg"; {
		:
	}; test_util.finish_pkg
}
