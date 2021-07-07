#!/usr/bin/env bats

load 'util/init.sh'


@test "without dependencies, does nothing" {
	test_util.mock_command plumbing-clone
	test_util.mock_command do-install
	create_package "user/main"
	do-plumbing-clone false site user/main

	run do-plumbing-deps user/main

	assert_success ""
}

@test "installs dependencies" {
	test_util.mock_command plumbing-clone
	test_util.mock_command do-install
	create_package "user/main"
	create_dep "user/main" "user/dep1"
	create_dep "user/main" "user/dep2"
	do-plumbing-clone false site user/main

	run do-plumbing-deps user/main

	assert_success
	assert_line "do-install user/dep1"
	assert_line "do-install user/dep2"
}
