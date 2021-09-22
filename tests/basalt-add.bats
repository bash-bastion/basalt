# shellcheck shell=bash

load './util/init.sh'

setup() {
	# this affects lines="$($output)" # TODO Bats 1.5 remove
	shopt -u nullglob
	test_util.stub_command 'do-install'
}

@test "Adds one dependency" {
	local dir=
	test_util.create_fake_remote 'user/repo'; dir="$REPLY"

	basalt init
	basalt add "file://$dir"

	run printf '%s' "$(<basalt.toml)"
	assert_success
	assert_line -n 7 -e "dependencies = \['file://$dir@[a-z0-9]+'\]"
}

@test "Adds two dependencies" {
	local dir1= dir2=
	test_util.create_fake_remote 'user/repo1'; dir1="$REPLY"
	test_util.create_fake_remote 'user/repo2'; dir2="$REPLY"

	basalt init
	basalt add "file://$dir1" "file://$dir2"

	run printf '%s' "$(<basalt.toml)"
	assert_success
	assert_line -n 7 -e "dependencies = \['file://$dir1@[a-z0-9]+', 'file://$dir2@[a-z0-9]+'\]"
}
