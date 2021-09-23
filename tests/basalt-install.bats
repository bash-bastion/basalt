# shellcheck shell=bash

load './util/init.sh'

@test "Installs one dependency" {
	local dir=
	test_util.create_fake_remote 'user/repo'; dir="$REPLY"

	basalt init
	run basalt add "file://$dir"

	assert_success
	assert [ "$(readlink "./basalt_packages/packages/local/fake_remote_user_repo")" = "$BASALT_GLOBAL_DATA_DIR/store/packages/local/fake_remote_user_repo" ]
}

@test "Installs two dependencies" {
	local dir1= dir2=
	test_util.create_fake_remote 'user/repo1'; dir1="$REPLY"
	test_util.create_fake_remote 'user/repo2'; dir2="$REPLY"

	basalt init
	run basalt add "file://$dir1" "file://$dir2"

	assert_success
	assert [ "$(readlink "./basalt_packages/packages/local/fake_remote_user_repo1")" = "$BASALT_GLOBAL_DATA_DIR/store/packages/local/fake_remote_user_repo1" ]
	assert [ "$(readlink "./basalt_packages/packages/local/fake_remote_user_repo2")" = "$BASALT_GLOBAL_DATA_DIR/store/packages/local/fake_remote_user_repo2" ]
}

@test "Installs transitive dependencies" {
	local dir1= dir2=
	test_util.create_fake_remote 'user/repo1'; dir1="$REPLY"
	test_util.create_fake_remote 'user/repo2'; dir2="$REPLY"
	(cd "$dir1" && basalt init && basalt add "file://$dir2" && git add -A && git commit -m 'Add dependency')

	basalt init
	run basalt add "file://$dir1"

	assert_success
	assert [ "$(readlink "./basalt_packages/packages/local/fake_remote_user_repo1")" = "$BASALT_GLOBAL_DATA_DIR/store/packages/local/fake_remote_user_repo1" ]
	assert [ "$(readlink "./basalt_packages/transitive/packages/local/fake_remote_user_repo2")" = "$BASALT_GLOBAL_DATA_DIR/store/packages/local/fake_remote_user_repo2" ]
}
