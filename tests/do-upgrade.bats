#!/usr/bin/env bats

load 'util/init.sh'

@test "upgrades a package to the latest version" {
	test_util.mock_command plumbing-clone
	create_package username/package
	bpm-install username/package
	create_exec username/package "second"

	bpm-upgrade username/package

	run bpm-list --outdated
	assert_output ""
}
