# shellcheck shell=bash

test_util.fatal() {
	local msg="$1"

	printf '%s\n' "FATAL: ${FUNCNAME[1]}: $msg" >&2
}

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

test_util.init_app() {
	local name="$1"
	local dir="${2:-.}"

	if [ -z "$name" ]; then
		test_util.fatal "Parameter 'name' must not be empty"
	fi

	if [ -f './basalt.toml' ]; then
		test_util.fatal "A package already exists at '$dir'"
	fi


	mkdir -p "./$dir/pkg/bin/$name"
}

test_util.init_lib() {
	local dir="$1"
}

test_util.create_fake_remote() {
	unset REPLY; REPLY=
	local package="$1"
	local version="${2:-v0.0.1}"

	local git_dir="$BATS_TEST_TMPDIR/fake_remote_${package%/*}_${package#*/}"

	{
		mkdir -p "$git_dir"
		ensure.cd "$git_dir"
		git init
		touch 'README.md'
		git add .
		git commit -m 'Initial commit'
		git branch -M main
		git commit --allow-empty -m "$version"
		git tag -m "$version" "$version"
	} >/dev/null 2>&1

	REPLY="$git_dir"
}

# @description This stubs a command by creating a function for it, which
# prints the command name and its arguments
test_util.stub_command() {
	eval "$1() { echo \"$1 \$*\"; }"
}
