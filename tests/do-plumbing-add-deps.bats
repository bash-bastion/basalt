#!/usr/bin/env bats

load 'util/init.sh'

@test "does nothing on no dependencies" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		:
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	test_util.stub_command 'do-add'
	run do-plumbing-add-deps "$site/$pkg"

	assert_success
	assert_output ''
}

@test "installs properly given package.sh dependencies" {
	local site='github.com'
	local pkg='username/package'

	test_util.stub_command 'do-add'

	test_util.setup_pkg "$pkg"; {
		echo 'DEPS=user/dep1:user/dep2' > 'package.sh'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-add-deps "$site/$pkg"

	assert_success
	assert_line "do-add user/dep1"
	assert_line "do-add user/dep2"
}

@test "on bpm.toml dependencies, installs properly" {
	local site='github.com'
	local pkg='username/package'

	test_util.stub_command 'do-add'

	test_util.setup_pkg "$pkg"; {
		echo 'dependencies = [ "user/dep1", "user/dep2" ]' > 'bpm.toml'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-add-deps "$site/$pkg"

	assert_success
	assert_line "do-add user/dep1"
	assert_line "do-add user/dep2"
}

@test "bpm.toml has presidence over package.sh add deps" {
	local site='github.com'
	local pkg='username/package'

	test_util.stub_command do-add

	test_util.setup_pkg "$pkg"; {
		echo 'DEPS=user/bad_dep' > 'package.sh'
		echo 'dependencies = [ "user/good_dep" ]' > 'bpm.toml'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-add-deps "$site/$pkg"

	assert_success
	refute_line "do-add user/bad_dep"
	assert_line "do-add user/good_dep"
}
