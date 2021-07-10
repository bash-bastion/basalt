#!/usr/bin/env bats

load 'util/init.sh'

@test "properly list for 2 installed packages" {
	test_util.create_package 'username/p1'
	test_util.create_package 'username2/p2'
	test_util.create_package 'username2/p3'
	test_util.fake_clone 'username/p1'
	test_util.fake_clone 'username2/p2'

	run do-list

	assert_success
	assert_line "username2/p2"
	assert_line "username/p1"
	refute_line "username2/p3"
}

@test "properly list for no installed packages" {
	test_util.create_package 'username/p1'

	run do-list

	assert_success
	assert_output ""
}

@test "properly list outdated packages" {
	local pkg1='username/outdated'
	local pkg2='username/uptodate'

	test_util.create_package "$pkg1"
	test_util.create_package "$pkg2"
	test_util.fake_clone "$pkg1"
	test_util.fake_clone "$pkg2"

	# Make pkg1 outdated by commiting to it
	cd "$BPM_ORIGIN_DIR/$pkg1"; {
		mkdir -p bin
		touch "bin/exec"
		git add .
		git commit -m "Add exec"
	}; cd "$BPM_CWD"

	run do-list --outdated

	assert_success
	assert_output 'username/outdated'
}
