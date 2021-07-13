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
	local id="$1"
	ensure.non_zero 'id' "$id"

	git clone "$BPM_ORIGIN_DIR/$id" "$BPM_PACKAGES_PATH/$id"
}

# @description Clones the repository, and performs any linking, etc.
test_util.fake_add() {
		local pkg="$1"
		ensure.non_zero 'pkg' "$pkg"

		git clone "$BPM_ORIGIN_DIR/github.com/$pkg" "$BPM_PACKAGES_PATH/github.com/$pkg"
		do-plumbing-add-deps "github.com/$pkg"
		do-plumbing-link-bins "github.com/$pkg"
		do-plumbing-link-completions "github.com/$pkg"
		do-plumbing-link-man "github.com/$pkg"
}

# @description Mocks a 'bpm link'
test_util.fake_link() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"

	mkdir -p "$BPM_PACKAGES_PATH/local"

	ls -al "$BPM_ORIGIN_DIR/github.com/$pkg" >&3
	ls -al "$BPM_PACKAGES_PATH/local" >&3
	mkdir -p "$BPM_PACKAGES_PATH/local"
	ln -s "$BPM_ORIGIN_DIR/github.com/$pkg" "$BPM_PACKAGES_PATH/local"

	do-plumbing-add-deps "$pkg"
	do-plumbing-link-bins "$pkg"
	do-plumbing-link-completions "$pkg"
	do-plumbing-link-man "$pkg"
}

# @description Creates a 'bpm package', and cd's into it
test_util.setup_pkg() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"

	mkdir -p "$BPM_ORIGIN_DIR/github.com/$pkg"
	cd "$BPM_ORIGIN_DIR/github.com/$pkg"

	git init .
	touch 'README.md'
	git add .
	git commit -m "Initial commit"
	git branch -M master
}

# @description Commits changes and cd's out of the package directory
# into the regular testing directory
test_util.finish_pkg() {
	git add .
	git commit --allow-empty -m "Make changes"
	cd "$BPM_CWD"
}

test_util.create_package() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"

	test_util.setup_pkg "$pkg"; {
		:
	}; test_util.finish_pkg
}

test_util.create_pkg_dir() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"

	mkdir -p "$BPM_ORIGIN_DIR/$pkg"
	cd "$BPM_ORIGIN_DIR/$pkg"

	git init .
	touch 'README.md'
	git add .
	git commit -m "Initial commit"

	cd "$BPM_CWD"
}

test_util.create_remote_and_local() {
	local site='github.com'
	local remote_dir="remote"
	local local_dir="local"

	mkdir -p "$BPM_ORIGIN_DIR/$remote_dir"
	cd "$BPM_ORIGIN_DIR/$remote_dir"
	git init .
	touch 'README.md'
	git add .
	git commit -m "Initial commit"

	cd "$BPM_ORIGIN_DIR"
	git clone "file://$BPM_ORIGIN_DIR/$remote_dir" "$BPM_PACKAGES_PATH/$site/username/$local_dir"

	cd "$BPM_CWD"
}
