#!/usr/bin/env bats

load 'util/init.sh'

@test "properly list for no installed packages" {
	test_util.create_package 'username/p1'

	run do-list

	assert_success
	assert_output ""
}

@test "properly list for 2 installed packages in mode simple list" {
	local site='github.com'

	test_util.create_package 'username/p1'
	test_util.create_package 'username2/p2'
	test_util.create_package 'username2/p3'
	test_util.fake_clone "$site/username/p1"
	test_util.fake_clone "$site/username2/p2"

	run do-list --simple

	assert_success
	assert_line -n 0 "$site/username2/p2"
	assert_line -n 1 "$site/username/p1"
	refute_line "$site/username2/p3"
}

@test "properly list for local packages in simple list" {
	local site='github.com'
	local pkg='somepath/project2'

	test_util.mock_command do-plumbing-add-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	test_util.create_package "$pkg"
	do-link "$BPM_ORIGIN_DIR/$site/$pkg"

	run do-list --simple

	assert_success
	assert_output "local/project2"
}

@test "properly list for 2 installed packages in mode non-simple list" {
	local site='github.com'

	test_util.create_package 'username/p1'
	test_util.create_package 'username2/p2'
	test_util.create_package 'username2/p3'
	test_util.fake_clone "$site/username/p1"
	test_util.fake_clone "$site/username2/p2"

	run do-list

	# Note that all the tests for non-simple list do not include 'state' up to date since that is not emulated
	# in the test
	assert_success
	assert_output "$site/username2/p2
  Branch: master
$site/username/p1
  Branch: master"
}


@test "properly list for local packages in mode non-simple list" {
	local site='github.com'
	local pkg='somepath/project2'

	test_util.mock_command do-plumbing-add-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	test_util.create_package "$pkg"
	do-link "$BPM_ORIGIN_DIR/$site/$pkg"

	run do-list

	assert_success
	assert_output "local/project2
  Branch: master"
}

@test "properly list outdated packages" {
	local site="github.com"
	local pkg1='username/outdated'
	local pkg2='username/uptodate'

	test_util.create_package "$pkg1"
	test_util.create_package "$pkg2"
	test_util.fake_clone "$site/$pkg1"
	test_util.fake_clone "$site/$pkg2"

	# Make pkg1 outdated by commiting to it
	cd "$BPM_ORIGIN_DIR/$site/$pkg1"; {
		mkdir -p bin
		touch "bin/exec"
		git add .
		git commit -m "Add exec"
	}; cd "$BPM_CWD"

	run do-list --outdated

	assert_success
	assert_output 'github.com/username/outdated'
}
