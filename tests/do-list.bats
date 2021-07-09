#!/usr/bin/env bats

load 'util/init.sh'

@test "properly list for 2 installed packages" {
	create_package 'username/p1'
	create_package 'username2/p2'
	create_package 'username2/p3'
	test_util.fake_clone 'username/p1'
	test_util.fake_clone 'username2/p2'

	run do-list

	assert_success
	assert_line "username2/p2"
	assert_line "username/p1"
	refute_line "username2/p3"
}

@test "properly list for no installed packages" {
	create_package username/p1

	run do-list

	assert_success
	assert_output ""
}

@test "properly list outdated packages" {
	create_package username/outdated
	create_package username/uptodate
	test_util.fake_clone username/outdated
	test_util.fake_clone username/uptodate
	create_exec username/outdated "second"

	run do-list --outdated

	assert_success
	assert_output username/outdated
}
