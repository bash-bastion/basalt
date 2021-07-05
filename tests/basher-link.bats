#!/usr/bin/env bats

load 'util/init.sh'

# TODO?
resolve_link() {
	if type -p realpath >/dev/null; then
		realpath "$1"
	else
		readlink -f "$1"
	fi
}

@test "fails with an invalid path" {
	run basher-link invalid namespace/name
	assert_failure
	assert_output -e "Directory 'invalid' not found"
}

@test "fails with a file path instead of a directory path" {
	touch file1
	run basher-link file1 namespace/name
	assert_failure
	assert_output -e "Directory 'file1' not found."
}

@test "fails with an invalid package name" {
	mkdir package1

	run basher-link package1 invalid
	assert_failure
	assert_line -e nonZero

	run basher-link package1 namespace1/
	assert_failure
	assert_line -e nonZero

	run basher-link package1 /package1
	assert_failure
	assert_line -e nonZero
}

@test "links the package to packages under the correct namespace" {
	mock.command basher-plumbing-link-bins
	mock.command basher-plumbing-link-completions
	mock.command basher-plumbing-link-completions
	mock.command basher-plumbing-deps
	mkdir package1
	run basher-link package1 namespace1/package1
	assert_success
	assert [ "$(resolve_link $NEOBASHER_PACKAGES_PATH/namespace1/package1)" = "$(resolve_link "$(pwd)/package1")" ]
}

@test "calls link-bins, link-completions, link-man and deps" {
	mock.command basher-plumbing-link-bins
	mock.command basher-plumbing-link-completions
	mock.command basher-plumbing-link-completions
	mock.command basher-plumbing-deps
	mkdir package2
	run basher-link package2 namespace2/package2
	assert_success
	assert_line "basher-plumbing-link-bins namespace2/package2"
	assert_line "basher-plumbing-link-completions namespace2/package2"
	assert_line "basher-plumbing-link-completions namespace2/package2"
	assert_line "basher-plumbing-deps namespace2/package2"
}

@test "respects --no-deps option" {
	mock.command basher-plumbing-link-bins
	mock.command basher-plumbing-link-completions
	mock.command basher-plumbing-link-completions
	mock.command basher-plumbing-deps
	mkdir package2
	run basher-link --no-deps package2 namespace2/package2
	assert_success
	refute_line "basher-plumbing-deps namespace2/package2"
}

@test "resolves current directory (dot) path" {
	mock.command basher-plumbing-link-bins
	mock.command basher-plumbing-link-completions
	mock.command basher-plumbing-link-completions
	mock.command basher-plumbing-deps
	mkdir package3
	cd package3
	run basher-link . namespace3/package3
	assert_success
	assert [ "$(resolve_link $NEOBASHER_PACKAGES_PATH/namespace3/package3)" = "$(resolve_link "$(pwd)")" ]
}

@test "resolves parent directory (dotdot) path" {
	mock.command basher-plumbing-link-bins
	mock.command basher-plumbing-link-completions
	mock.command basher-plumbing-link-completions
	mock.command basher-plumbing-deps
	mkdir package3
	cd package3
	run basher-link ../package3 namespace3/package3
	assert_success
	assert [ "$(resolve_link $NEOBASHER_PACKAGES_PATH/namespace3/package3)" = "$(resolve_link "$(pwd)")" ]
}

@test "resolves arbitrary complex relative path" {
	mock.command basher-plumbing-link-bins
	mock.command basher-plumbing-link-completions
	mock.command basher-plumbing-link-completions
	mock.command basher-plumbing-deps
	mkdir package3
	run basher-link ./package3/.././package3 namespace3/package3
	assert_success
	assert [ "$(resolve_link $NEOBASHER_PACKAGES_PATH/namespace3/package3)" = "$(resolve_link "$(pwd)/package3")" ]
}
