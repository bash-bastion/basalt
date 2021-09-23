# shellcheck shell=bash

load './util/init.sh'

@test "fails with invalid remote" {
	run util.does_package_exist 'remote' "https://github.com/hyperupcall/basaltaa.git"

	assert_failure
	assert_output ''
}

@test "fails with invalid file" {
	run util.does_package_exist 'local' "file:///whatever"

	assert_failure
	assert_output ''
}

@test "works with valid remote" {
	run util.does_package_exist 'remote' "https://github.com/hyperupcall/basalt.git"

	assert_success
	assert_output ''
}

@test "works with valid file" {
	local dir=
	test_util.create_fake_remote 'user/repo'; dir="$REPLY"

	run util.does_package_exist 'local' "file://$dir"

	assert_success
	assert_output ''
}
