#!/usr/bin/env bats

load 'util/init.sh'

@test "install a specific version" {
	test_util.mock_command git

	run do-plumbing-clone https://site/username/package.git username/package version

	assert_success
	assert_line -n 1 "git clone --recursive --depth=1 --branch version https://site/username/package.git $BPM_PACKAGES_PATH/username/package"
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
	test_util.mock_command git

	run do-plumbing-clone https://site/username/package.git username/package

	assert_success
	assert_line -n 1 "git clone --recursive --depth=1 https://site/username/package.git $BPM_PACKAGES_PATH/username/package"
}

# This is a difference in behavior compared to Basher. Setting
# the variable at all will result in a full clone
@test "with setting BPM_FULL_CLONE, clones a package without depth option" {
	export BPM_FULL_CLONE=
	test_util.mock_command git

	run do-plumbing-clone https://github.com/username/package.git username/package

	assert_success
	assert_line -n 1 "git clone --recursive https://github.com/username/package.git $BPM_PACKAGES_PATH/username/package"
}

@test "setting BPM_FULL_CLONE to true, clones a package without depth option" {
	export BPM_FULL_CLONE=true
	test_util.mock_command git

	run do-plumbing-clone https://github.com/username/package.git username/package

	assert_success
	assert_line -n 1 "git clone --recursive https://github.com/username/package.git $BPM_PACKAGES_PATH/username/package"
}

# This is a difference in behavior compared to Basher. Setting
# the variable at all will result in a full clone
@test "setting BPM_FULL_CLONE to false, clones a package without depth option" {
	export BPM_FULL_CLONE=false
	test_util.mock_command git

	run do-plumbing-clone https://github.com/username/package.git username/package

	assert_success
	assert_line -n 1 "git clone --recursive https://github.com/username/package.git $BPM_PACKAGES_PATH/username/package"
}

@test "using ssh protocol" {
	test_util.mock_command git

	run do-plumbing-clone git@site:username/package.git username/package

	assert_success
	assert_line -n 1 "git clone --recursive --depth=1 git@site:username/package.git $BPM_PACKAGES_PATH/username/package"
}
