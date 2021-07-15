#!/usr/bin/env bats

load 'util/init.sh'

# TODO: replace output checking with actual cloning using file://

@test "installs a specific version" {
	local site='github.com'
	local pkg='username/package'

	test_util.stub_command git

	run do-plumbing-clone https://github.com/username/package.git github.com/username/package v1.2.3

	assert_success
	assert_line "git clone --recursive https://github.com/username/package.git $BPM_PACKAGES_PATH/$site/$pkg"
	assert_line "git -C $BPM_PACKAGES_PATH/$site/$pkg reset --hard v1.2.3"
}

@test "does nothing if package is already present" {
	mkdir -p "$BPM_PACKAGES_PATH/username/package"

	run do-plumbing-clone https://github.com/username/package.git username/package

	assert_failure
	assert_line -p "Package 'username/package' is already present"
}

@test "does nothing if package is already present (as erroneous file)" {
	mkdir -p "$BPM_PACKAGES_PATH/username"
	touch "$BPM_PACKAGES_PATH/username/package"

	run do-plumbing-clone https://github.com/username/package.git username/package

	assert_failure
	assert_line -p "Package 'username/package' is already present"
}

@test "using a different site" {
	test_util.stub_command git

	run do-plumbing-clone https://site/username/package.git username/package

	assert_success
	assert_line -n 1 "git clone --recursive --depth=1 https://site/username/package.git $BPM_PACKAGES_PATH/username/package"
}

# This is a difference in behavior compared to Basher. Setting
# the variable at all will result in a full clone
@test "with setting BPM_FULL_CLONE, clones a package without depth option" {
	export BPM_FULL_CLONE=
	test_util.stub_command git

	run do-plumbing-clone https://github.com/username/package.git username/package

	assert_success
	assert_line -n 1 "git clone --recursive https://github.com/username/package.git $BPM_PACKAGES_PATH/username/package"
}

@test "setting BPM_FULL_CLONE to true, clones a package without depth option" {
	export BPM_FULL_CLONE=true
	test_util.stub_command git

	run do-plumbing-clone https://github.com/username/package.git username/package

	assert_success
	assert_line -n 1 "git clone --recursive https://github.com/username/package.git $BPM_PACKAGES_PATH/username/package"
}

# This is a difference in behavior compared to Basher. Setting
# the variable at all will result in a full clone
@test "setting BPM_FULL_CLONE to false, clones a package without depth option" {
	export BPM_FULL_CLONE=false
	test_util.stub_command git

	run do-plumbing-clone https://github.com/username/package.git username/package

	assert_success
	assert_line -n 1 "git clone --recursive https://github.com/username/package.git $BPM_PACKAGES_PATH/username/package"
}

@test "using ssh protocol" {
	test_util.stub_command git

	run do-plumbing-clone git@site:username/package.git username/package

	assert_success
	assert_line -n 1 "git clone --recursive --depth=1 git@site:username/package.git $BPM_PACKAGES_PATH/username/package"
}

@test "setting branch works" {
	local site='github.com'
	local pkg='username/package'

	test_util.stub_command git

	run do-plumbing-clone https://github.com/username/package.git github.com/username/package '' a_branch

	assert_success
	assert_line -n 1 "git clone --recursive --depth=1 --single-branch --branch a_branch https://github.com/username/package.git $BPM_PACKAGES_PATH/$site/username/package"
}
