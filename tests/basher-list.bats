#!/usr/bin/env bats

load 'util/init.sh'

@test "list installed packages" {
	mock.command _clone
	create_package username/p1
	create_package username2/p2
	create_package username2/p3
	basher-install username/p1
	basher-install username2/p2

	run basher-list
	assert_success
	assert_line "username/p1"
	assert_line "username2/p2"
	refute_line "username2/p3"
}

# TODO: integrate outdated back into test suite
@test "displays nothing if there are no packages" {
	skip

	run basher-outdated
	assert_success
	assert_output ""
}

@test "displays outdated packages" {
	skip

	mock.command _clone
	create_package username/outdated
	create_package username/uptodate
	basher-install username/outdated
	basher-install username/uptodate
	create_exec username/outdated "second"

	run basher-outdated
	assert_success
	assert_output username/outdated
}
