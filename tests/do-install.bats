#!/usr/bin/env bats

load 'util/init.sh'

@test "fails when no packages are specified" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install

	assert_failure
	assert_line -n 0 -p "At least one package must be supplied"
}

@test "executes install steps in right order" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install username/package

	assert_success
	assert_line -n 0 -p "Installing 'username/package'"
	assert_line -n 1 'bpm-plumbing-clone false github.com username package'
	assert_line -n 2 'bpm-plumbing-deps username/package'
	assert_line -n 3 'bpm-plumbing-link-bins username/package'
	assert_line -n 4 'bpm-plumbing-link-completions username/package'
}

@test "executes install steps in right order for multiple packages" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install username/package username2/package2

	assert_success
	assert_line -n 0 -p "Installing 'username/package'"
	assert_line -n 1 'bpm-plumbing-clone false github.com username package'
	assert_line -n 2 'bpm-plumbing-deps username/package'
	assert_line -n 3 'bpm-plumbing-link-bins username/package'
	assert_line -n 4 'bpm-plumbing-link-completions username/package'
	assert_line -n 5 -p "Installing 'username2/package2'"
	assert_line -n 6 'bpm-plumbing-clone false github.com username2 package2'
	assert_line -n 7 'bpm-plumbing-deps username2/package2'
	assert_line -n 8 'bpm-plumbing-link-bins username2/package2'
	assert_line -n 9 'bpm-plumbing-link-completions username2/package2'
}


@test "uses longhand (https) site to clone from, if specified" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install https://gitlab.com/username/package

	assert_success
	assert_line "bpm-plumbing-clone false gitlab.com username package"
}

@test "uses longhand (http) site to clone from, if specified" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install http://gitlab.com/username/package

	assert_success
	assert_line "bpm-plumbing-clone false gitlab.com username package"
}

@test "uses shorthand site to clone from, if specified" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install site/username/package

	assert_success
	assert_line "bpm-plumbing-clone false site username package"
}

@test "uses GitHub as default site, if not specified" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install username/package

	assert_success
	assert_line "bpm-plumbing-clone false github.com username package"
}

@test "uses ssh protocol, when specified" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install --ssh username/package

	assert_success
	assert_line "bpm-plumbing-clone true github.com username package"
}

@test "uses custom version, when specified" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install username/package@v1.2.3

	assert_success
	assert_line "bpm-plumbing-clone false github.com username package v1.2.3"
}

@test "does not use custom version, when not specified" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install username/package@

	assert_success
	assert_line "bpm-plumbing-clone false github.com username package"
}
