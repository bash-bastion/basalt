#!/usr/bin/env bats

load 'util/init.sh'

@test "fails when no packages are specified" {
	test_util.mock_command do-plumbing-clone
	test_util.mock_command do-plumbing-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	run do-install

	assert_failure
	assert_line -n 0 -p "At least one package must be supplied"
}

@test "executes install steps in right order" {
	test_util.mock_command do-plumbing-clone
	test_util.mock_command do-plumbing-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	run do-install username/package

	assert_success
	assert_line -n 0 -p "Installing 'username/package'"
	assert_line -n 1 'do-plumbing-clone false github.com username/package'
	assert_line -n 2 'do-plumbing-deps username/package'
	assert_line -n 3 'do-plumbing-link-bins username/package'
	assert_line -n 4 'do-plumbing-link-completions username/package'
	assert_line -n 5 'do-plumbing-link-man username/package'
}

@test "executes install steps in right order for multiple packages" {
	test_util.mock_command do-plumbing-clone
	test_util.mock_command do-plumbing-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	run do-install username/package username2/package2

	assert_success
	assert_line -n 0 -p "Installing 'username/package'"
	assert_line -n 1 'do-plumbing-clone false github.com username/package'
	assert_line -n 2 'do-plumbing-deps username/package'
	assert_line -n 3 'do-plumbing-link-bins username/package'
	assert_line -n 4 'do-plumbing-link-completions username/package'
	assert_line -n 5 'do-plumbing-link-man username/package'
	assert_line -n 6 -p "Installing 'username2/package2'"
	assert_line -n 7 'do-plumbing-clone false github.com username2/package2'
	assert_line -n 8 'do-plumbing-deps username2/package2'
	assert_line -n 9 'do-plumbing-link-bins username2/package2'
	assert_line -n 10 'do-plumbing-link-completions username2/package2'
	assert_line -n 11 'do-plumbing-link-man username2/package2'
}


@test "uses longhand (https) site to clone from, if specified" {
	test_util.mock_command do-plumbing-clone
	test_util.mock_command do-plumbing-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	run do-install https://gitlab.com/username/package

	assert_success
	assert_line "do-plumbing-clone false gitlab.com username/package"
}

@test "uses longhand (http) site to clone from, if specified" {
	test_util.mock_command do-plumbing-clone
	test_util.mock_command do-plumbing-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	run do-install http://gitlab.com/username/package

	assert_success
	assert_line "do-plumbing-clone false gitlab.com username/package"
}

@test "uses shorthand site to clone from, if specified" {
	test_util.mock_command do-plumbing-clone
	test_util.mock_command do-plumbing-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	run do-install site/username/package

	assert_success
	assert_line "do-plumbing-clone false site username/package"
}

@test "uses GitHub as default site, if not specified" {
	test_util.mock_command do-plumbing-clone
	test_util.mock_command do-plumbing-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	run do-install username/package

	assert_success
	assert_line "do-plumbing-clone false github.com username/package"
}

@test "uses ssh protocol, when specified" {
	test_util.mock_command do-plumbing-clone
	test_util.mock_command do-plumbing-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	run do-install --ssh username/package

	assert_success
	assert_line "do-plumbing-clone true github.com username/package"
}

@test "uses custom version, when specified" {
	test_util.mock_command do-plumbing-clone
	test_util.mock_command do-plumbing-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	run do-install username/package@v1.2.3

	assert_success
	assert_line "do-plumbing-clone false github.com username/package v1.2.3"
}

@test "does not use custom version, when not specified" {
	test_util.mock_command do-plumbing-clone
	test_util.mock_command do-plumbing-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	run do-install username/package@

	assert_success
	assert_line "do-plumbing-clone false github.com username/package"
}
