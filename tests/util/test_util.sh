# shellcheck shell=bash
# shellcheck disable=SC2164

# @description This stubs a command by creating a function for it, which
# prints the command name and its arguments
test_util.stub_command() {
	eval "$1() { echo \"$1 \$*\"; }"
}

# @description Fakes a clone. This is meant to be used for
# the download step
test_util.mock_clone() {
	local id="$1"
	ensure.non_zero 'id' "$id"

	git clone "$BPM_ORIGIN_DIR/$id" "$BPM_PACKAGES_PATH/$id"
}

# @description Clones the repository, and performs any linking, etc.
test_util.mock_add() {
		local pkg="$1"
		ensure.non_zero 'pkg' "$pkg"

		git clone "$BPM_ORIGIN_DIR/github.com/$pkg" "$BPM_PACKAGES_PATH/github.com/$pkg"
		do-plumbing-add-deps "github.com/$pkg"
		do-plumbing-link-bins "github.com/$pkg"
		do-plumbing-link-completions "github.com/$pkg"
		do-plumbing-link-man "github.com/$pkg"
}

# @description Mocks a 'bpm link'
test_util.mock_link() {
	local dir="$1"
	ensure.non_zero 'dir' "$dir"

	mkdir -p "$BPM_PACKAGES_PATH/local"

	mkdir -p "$BPM_PACKAGES_PATH/local"
	ln -s "$BPM_ORIGIN_DIR/github.com/$dir" "$BPM_PACKAGES_PATH/local"

	do-plumbing-add-deps "local/$dir"
	do-plumbing-link-bins "local/$dir"
	do-plumbing-link-completions "local/$dir"
	do-plumbing-link-man "local/$dir"
}

# @description Utility to begin creating a package
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

# @description Utility to finish completing a package
test_util.finish_pkg() {
	git add .
	git commit --allow-empty -m "Make changes"
	cd "$BPM_CWD"
}

# @description Utility function to create an empty package
test_util.create_package() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"

	test_util.setup_pkg "$pkg"; {
		:
	}; test_util.finish_pkg
}

# @description Create a package (to be linked later)
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

# TODO: deprecate for test_util and mock_clone
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
