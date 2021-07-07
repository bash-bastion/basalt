#!/usr/bin/env bats

load 'util/init.sh'

@test "on no dependencies, does nothing" {
	local package='user/main'

	create_package "$package"
	test_util.fake_clone "$package"

	test_util.mock_command do-install
	run do-plumbing-deps "$package"

	assert_success ""
}

@test "on package.sh dependencies, installs properly" {
	local package='user/main'

	create_package "$package"
	cd "$BPM_ORIGIN_DIR/$package"
	echo 'DEPS=user/dep1:user/dep2' >| package.sh
	git add .
	git commit -m "Add deps"
	cd "$BPM_CWD"
	test_util.fake_clone "$package"

	test_util.mock_command do-install
	run do-plumbing-deps "$package"

	assert_success
	assert_line "do-install user/dep1"
	assert_line "do-install user/dep2"
}

@test "on bpm.toml dependencies, installs properly" {
	local package='user/main'

	create_package "$package"
	cd "$BPM_ORIGIN_DIR/$package"
	echo 'dependencies = [ "user/dep1", "user/dep2" ]' >| bpm.toml
	git add .
	git commit -m "Add dependencies"
	cd "$BPM_CWD"
	test_util.fake_clone "$package"

	test_util.mock_command do-install
	run do-plumbing-deps "$package"

	assert_success
	assert_line "do-install user/dep1"
	assert_line "do-install user/dep2"
}

@test "bpm.toml has presidence over package.sh" {
	local package='user/main'
	create_package "$package"

	cd "$BPM_ORIGIN_DIR/$package"
	echo 'dependencies = [ "user/good_dep" ]' >| bpm.toml
	echo 'DEPS=user/bad_dep' >| package.sh
	git add .
	git commit -m "Add dependencies"
	cd "$BPM_CWD"
	test_util.fake_clone "$package"

	test_util.mock_command do-install
	run do-plumbing-deps "$package"

	assert_success
	assert_line "do-install user/good_dep"
	refute_line "do-install user/bad_dep"
}
