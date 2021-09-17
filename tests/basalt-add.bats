# shellcheck shell=bash

load './util/init.sh'

@test "Adds dependency" {
	test_util.create_fake_remote 'user/repo'; dir="$REPLY"

	basalt init
	basalt add "file://$dir"

	run printf '%s' "$(<basalt.toml)"

	assert_success
	assert_line -n 7 -e "dependencies = \['file://$dir@[a-z0-9]*'\]"
}

@test "Adds two dependencies" {
	test_util.create_fake_remote 'user/repo1'; dir1="$REPLY"
	test_util.create_fake_remote 'user/repo2'; dir2="$REPLY"

	basalt init
	basalt add "file://$dir1"
	basalt add "file://$dir2"

	run printf '%s' "$(<basalt.toml)"

	assert_success
	assert_line -n 7 -e "dependencies = \['file://$dir1@[a-z0-9]*'\], 'file://$dir2@[a-z0-9]*'\]"
}
