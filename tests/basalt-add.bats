# shellcheck shell=bash

load './util/init.sh'

@test "Adds dependency" {
	local dir=
	test_util.create_fake_remote 'user/repo'; dir="$REPLY"

	basalt init

	run basalt add "file://$dir"
	assert_success

	run printf '%s' "$(<basalt.toml)"
	assert_success
	assert_line -n 7 -e "dependencies = \['file://$dir@[a-z0-9]*'\]"

	assert [ "$(readlink "./basalt_packages/packages/local/fake_remote_user_repo")" = "$BASALT_GLOBAL_DATA_DIR/store/packages/local/fake_remote_user_repo" ]
}

@test "Adds two dependencies" {
	local dir1= dir2=
	test_util.create_fake_remote 'user/repo1'; dir1="$REPLY"
	test_util.create_fake_remote 'user/repo2'; dir2="$REPLY"

	basalt init
	basalt add "file://$dir1" "file://$dir2"

	run printf '%s' "$(<basalt.toml)"

	assert_success
	assert_line -n 7 -e "dependencies = \['file://$dir1@[a-z0-9]*', 'file://$dir2@[a-z0-9]*'\]"

	assert [ "$(readlink "./basalt_packages/packages/local/fake_remote_user_repo1")" = "$BASALT_GLOBAL_DATA_DIR/store/packages/local/fake_remote_user_repo1" ]
	assert [ "$(readlink "./basalt_packages/packages/local/fake_remote_user_repo2")" = "$BASALT_GLOBAL_DATA_DIR/store/packages/local/fake_remote_user_repo2" ]
}
