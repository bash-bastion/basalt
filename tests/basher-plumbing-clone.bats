#!/usr/bin/env bats

load 'util/init.sh'

@test "install a specific version" {
	test_util.mock_command git

	run basher-plumbing-clone false site username/package version
	assert_success
	assert_output "git clone --depth=1 -b version --recursive https://site/username/package.git $NEOBASHER_PACKAGES_PATH/username/package"
}

@test "does nothing if package is already present" {
	mkdir -p "$NEOBASHER_PACKAGES_PATH/username/package"

	run basher-plumbing-clone false github.com username/package

	assert_success
	assert_output -e "Package 'username/package' is already present"
}

@test "using a different site" {
	test_util.mock_command git

	run basher-plumbing-clone false site username/package
	assert_success
	assert_output "git clone --depth=1 --recursive https://site/username/package.git $NEOBASHER_PACKAGES_PATH/username/package"
}

@test "without setting BASHER_FULL_CLONE, clones a package with depth option" {
	export BASHER_FULL_CLONE=
	test_util.mock_command git

	run basher-plumbing-clone false github.com username/package
	assert_success
	assert_output "git clone --depth=1 --recursive https://github.com/username/package.git $NEOBASHER_PACKAGES_PATH/username/package"
}

@test "setting BASHER_FULL_CLONE to true, clones a package without depth option" {
	export BASHER_FULL_CLONE=true
	test_util.mock_command git

	run basher-plumbing-clone false github.com username/package
	assert_success
	assert_output "git clone --recursive https://github.com/username/package.git $NEOBASHER_PACKAGES_PATH/username/package"
}

@test "setting BASHER_FULL_CLONE to false, clones a package with depth option" {
	export BASHER_FULL_CLONE=false
	test_util.mock_command git

	run basher-plumbing-clone false github.com username/package
	assert_success
	assert_output "git clone --depth=1 --recursive https://github.com/username/package.git $NEOBASHER_PACKAGES_PATH/username/package"
}

@test "using ssh protocol" {
	test_util.mock_command git

	run basher-plumbing-clone true site username/package
	assert_success
	assert_output "git clone --depth=1 --recursive git@site:username/package.git $NEOBASHER_PACKAGES_PATH/username/package"
}
