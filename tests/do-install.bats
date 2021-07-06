#!/usr/bin/env bats

load 'util/init.sh'

@test "executes install steps in right order" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install username/package
	assert_success "bpm-plumbing-clone false github.com username package
bpm-plumbing-deps username/package
bpm-plumbing-link-bins username/package
bpm-plumbing-link-completions username/package
bpm-plumbing-link-completions username/package"
}

@test "with site, overwrites site" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install site/username/package

	assert_line "bpm-plumbing-clone false site username package"
}

@test "without site, uses github as default site" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install username/package

	assert_line "bpm-plumbing-clone false github.com username package"
}

@test "using ssh protocol" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install --ssh username/package

	assert_line "bpm-plumbing-clone true github.com username package"
}

@test "installs with custom version" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install username/package@v1.2.3

	assert_line "bpm-plumbing-clone false github.com username package v1.2.3"
}

@test "empty version is ignored" {
	test_util.mock_command bpm-plumbing-clone
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions
	test_util.mock_command bpm-plumbing-link-completions

	run bpm-install username/package@

	assert_line "bpm-plumbing-clone false github.com username package"
}

@test "doesn't fail" {
	create_package username/package
	test_util.mock_command _clone

	run bpm-install username/package
	assert_success
}
