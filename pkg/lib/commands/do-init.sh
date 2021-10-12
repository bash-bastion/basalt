# shellcheck shell=bash

do-init() {
	local flag_type=
	local -a args=()
	for arg; do case "$arg" in
	--bare)
		flag_type='bare'
		;;
	--full)
		flag_type='full'
		;;
	-*)
		bprint.die "Flag '$arg' not recognized"
		;;
	*)
		args+=("$arg")
		;;
	esac done

	if ((${#args[@]} > 0)); then
		bprint.die "No arguments must be specified"
	fi

	case "$flag_type" in
	'')
		bprint.die "Must either specify '--bare' or '--full'. No default choice has been implemented"
		;;
	bare)
		if [ -f 'basalt.toml' ]; then
			bprint.die "File 'basalt.toml' already exists"
		fi

		local file1="./basalt.toml"
		if ! cat >| "$file1" <<-"EOF"; then
		[package]
		name = ''
		slug = ''
		version = ''
		authors = []
		description = ''

		[run]
		dependencies = []
		sourceDirs = []
		builtinDirs = []
		binDirs = []
		completionDirs = []
		manDirs = []

		[run.shellEnvironment]

		[run.setOptions]

		[run.shoptOptions]
		EOF
			bprint.die "Could not write to $file1"
		fi
		bprint.info "Created $file1"


		mkdir -p 'pkg/bin'
		local file2="./pkg/bin/file"
		if ! cat >| "$file2" <<-"EOF"; then
		#!/usr/bin/env bash

		eval "$(basalt-package-init)"; basalt.package-init
		basalt.package-load

		source "$BASALT_PACKAGE_DIR/pkg/lib/cmd/file.sh"
		file.main "$@"
		EOF
			bprint.die "Could not write to $file2"
		fi
		bprint.info "Created $file2"


		mkdir -p 'pkg/lib/cmd'
		local file3="./pkg/lib/cmd/file.sh"
		if ! cat >| "$file3" <<"EOF"; then
# shellcheck shell=bash

file.main() {
	printf '%s\n' "Woof!"
}
EOF
			bprint.die "Could not write to $file3"
		fi
		bprint.info "Created $file3"


		mkdir -p 'tests/util'
		local file4='./tests/util/init.sh'
		if ! cat >| "$file4" <<"EOF"; then
# shellcheck shell=bash

eval "$(basalt-package-init)"; basalt.package-init
basalt.package-load
# basalt.load 'github.com/hyperupcall/bats-common-utils' 'load.bash'

load './util/test_util.sh'

export NO_COLOR=

setup() {
	ensure.cd "$BATS_TEST_TMPDIR"
}

teardown() {
	ensure.cd "$BATS_SUITE_TMPDIR"
}
EOF
			bprint.die "Could not write to $file4"
		fi
		bprint.info "Created $file4"

		mkdir -p 'tests/util'
		local file5='./tests/util/test_util.sh'
		if ! cat >| "$file5" <<"EOF"; then
# shellcheck shell=bash
EOF
			bprint.die "Could not write to $file5"
		fi
		bprint.info "Created $file5"
		;;
	full)
		local repo='github.com/hyperupcall/template-bash'
		if ! git clone -q "https://$repo" .; then
			bprint.die "Could not clone the full bash template"
		fi
		bprint.info "Cloned $repo"
		;;
	esac
}
