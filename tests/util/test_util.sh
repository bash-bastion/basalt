# shellcheck shell=bash

test_util.fatal() {
	local msg="$1"

	printf '\033[0;31mFATAL ERROR:\033[0m %s\n' "$msg" >&2
	exit 1
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
		test_util.fatal "test_util.get_repo_root: Failed to get root"
	fi
}

test_util.init_app() {
	local name="$1"
	local dir="${2:-.}"
	local basaltTomlContent="$3"
	local appContent="$4"

	if [ -z "$name" ]; then
		test_util.fatal "test_util.init_app: Parameter 'name' must not be empty"
	fi

	if [ -f "./$dir/basalt.toml" ]; then
		test_util.fatal "test_util.init_app: A package already exists at '$dir'"
	fi

	mkdir -p "./$dir/pkg/bin" "./$dir/pkg/src/bin"

	cat <<-EOF > "./$dir/pkg/bin/$name"
	eval "\$(basalt-package-init)" || exit
	basalt.package-init
	basalt.package-load

	source "\$BASALT_PACKAGE_DIR/pkg/src/bin/$name.sh"
	main.$name "\$@"
	EOF

	if [ -z "$appContent" ]; then
		cat <<-EOF > "./$dir/pkg/src/bin/$name.sh"
		main.TEMPLATE_SLUG() {
		   printf '%s\n' 'woofers!'
		}
		EOF
	else
		cat <<< "$appContent" > "./$dir/pkg/src/bin/$name.sh"
	fi

	if [ -z "$basaltTomlContent" ]; then
		cat <<-EOF > "./$dir/basalt.toml"
		[package]
		type = 'bash'
		name = '$name'
		slug = '$name'
		version = '0.1.0'
		authors = []
		description = 'This is the $name package'

		[run]
		dependencies = []
		binDirs = ['./$dir/pkg/bin']
		sourceDirs = []

		[run.shellEnvironment]

		[run.setOptions]
		errexit = 'on'
		pipefail = 'on'

		[run.shoptOptions]
		nullglob = 'on'
		shift_verbose = 'on'
		EOF
	else
		cat <<< "$basaltTomlContent" > "./$dir/basalt.toml"
	fi
}

test_util.init_lib() {
	local name="$1"
	local dir="${2:-.}"
	local basaltTomlContent="$3"
	local libContent="$4"

	if [ -z "$name" ]; then
		test_util.fatal "test_util.init_app: Parameter 'name' must not be empty"
	fi

	if [ -f "./$dir/basalt.toml" ]; then
		test_util.fatal "test_util.init_app: A package already exists at '$dir'"
	fi

	mkdir -p "./$dir/pkg/src/public"

	if [ -z "$libContent" ]; then
		cat <<-EOF > "./$dir/pkg/src/public/$name.sh"
		$name.fn() {
		   printf '%s\n' 'foxxy!'
		}
		EOF
	else
		cat <<< "$libContent" > "./$dir/pkg/src/public/$name.sh"
	fi

	if [ -z "$basaltTomlContent" ]; then
		cat <<-EOF > "./$dir/basalt.toml"
		[package]
		type = 'bash'
		name = '$name'
		slug = '$name'
		version = '0.1.0'
		authors = []
		description = 'This is the $name package'

		[run]
		dependencies = []
		binDirs = []
		sourceDirs = ['./$dir/pkg/public']

		[run.shellEnvironment]

		[run.setOptions]
		errexit = 'on'
		pipefail = 'on'

		[run.shoptOptions]
		nullglob = 'on'
		shift_verbose = 'on'
		EOF
	else
		cat <<< "$basaltTomlContent" > "./$dir/basalt.toml"
	fi
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
