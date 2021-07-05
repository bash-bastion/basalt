#!/usr/bin/env bats

load 'util/init.sh'

@test "upgrades a package to the latest version" {
	test_util.mock_command _clone
	create_package username/package
	basher-install username/package
	create_exec username/package "second"

	basher-upgrade username/package

	run basher-list --outdated
	assert_output ""
}
