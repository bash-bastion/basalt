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
	test_util.mock_add 'username/p1'
	test_util.mock_add 'username2/p2'

	run do-list --simple

	assert_success
	assert_line -n 0 "$site/username/p1"
	assert_line -n 1 "$site/username2/p2"
	refute_line "$site/username2/p3"
}

@test "properly simple list for packages specified as arguments" {
	local site='github.com'

	test_util.create_package 'username/p1'
	test_util.create_package 'username2/p2'
	test_util.create_package 'username2/p3'
	test_util.mock_add 'username/p1'
	test_util.mock_add 'username2/p2'
	test_util.mock_add 'username2/p3'

	run do-list --simple 'username/p1' 'username2/p2'

	assert_success
	assert_line -n 0 "$site/username/p1"
	assert_line -n 1 "$site/username2/p2"
	refute_line "$site/username2/p3"
}

@test "properly non-simple list for packages specified as arguments" {
	local site='github.com'

	test_util.create_package 'username/p1'
	test_util.create_package 'username2/p2'
	test_util.create_package 'username2/p3'
	test_util.mock_add 'username/p1'
	test_util.mock_add 'username2/p2'
	test_util.mock_add 'username2/p3'

	run do-list 'username/p1' 'username2/p2'

	assert_success
	assert_output -e "$site/username/p1
  Branch: master
  Revision: ([a-z0-9]*)
  State: Up to date
$site/username2/p2
  Branch: master
  Revision: ([a-z0-9]*)
  State: Up to date"
}

@test "error if non-existant packages are specified as arguments" {
	local site='github.com'
	local pkg='username/p1'

	run do-list --simple "$pkg"

	assert_failure
	assert_line -p "Package '$site/$pkg' is not installed"
}

@test "error if ref is specified in arguments" {
	local site='github.com'

	test_util.create_package 'username/p1'
	test_util.mock_add 'username/p1'

	run do-list --simple 'username/p1@v0.1.0'

	assert_failure
	assert_line -p "Refs must be omitted when listing packages. Remove ref '@v0.1.0'"
}

@test "properly list for local packages in simple list" {
	local site='github.com'
	local pkg='somepath/project2'

	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	test_util.create_package "$pkg"
	do-link "$BPM_ORIGIN_DIR/$pkg"

	run do-list --simple

	assert_success
	assert_output "local/project2"
}

@test "properly list for 2 installed packages in mode non-simple list" {
	local site='github.com'

	test_util.create_package 'username/p1'
	test_util.create_package 'username2/p2'
	test_util.create_package 'username2/p3'
	test_util.mock_add "username/p1"
	test_util.mock_add "username2/p2"

	run do-list

	# Note that all the tests for non-simple list do not include 'state' up to date since that is not emulated
	# in the test
	assert_success
	assert_output -e "$site/username/p1
  Branch: master
  Revision: ([a-z0-9]*)
  State: Up to date
$site/username2/p2
  Branch: master
  Revision: ([a-z0-9]*)
  State: Up to date"
}


@test "properly list for local packages in mode non-simple list" {
	local site='github.com'
	local dir='somepath/project2'

	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	test_util.create_package "$dir"
	test_util.mock_link "$dir" "$site/$dir"

	run do-list

	assert_success
	assert_output -e "local/project2
  Branch: master"
}

@test "properly list out of date package" {
	local site='github.com'
	local pkg='somedir/package'

	test_util.create_package "$pkg"
	test_util.mock_clone "$pkg" "$site/$pkg"

	cd "$BPM_ORIGIN_DIR/$pkg"
	touch 'script2.sh'
	git add .
	git commit -m 'Add script'
	cd "$BPM_CWD"

	do-list --fetch
	run do-list

	assert_success
	assert_output -e "github.com/$pkg
  Branch: master
  Revision: ([a-z0-9]*)
  State: Out of date"
}

@test "error if tries to list a non-git repository with details" {
	local site="github.com"
	local pkg='username/outdated'

	mkdir -p "$BPM_PACKAGES_PATH/$site/$pkg"
	run do-list

	assert_failure
	assert_line -n 0 -p "Package '$site/$pkg' is not a Git repository. Unlink or"
}
