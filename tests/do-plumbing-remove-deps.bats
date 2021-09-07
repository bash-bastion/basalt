#!/usr/bin/env bats

load 'util/init.sh'

@test "removes properly given package.sh dependencies" {
	local site='github.com'
	local pkg='username/package'

	test_util.stub_command 'do-actual-add'

	test_util.setup_pkg "$pkg"; {
		echo 'DEPS=user/dep1:user/dep2' > 'package.sh'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run plumbing.remove-dependencies "$site/$pkg"

	assert_success
	assert_line -p "Removing '$site/user/dep1'"
	assert_line -p "Removing '$site/user/dep2'"
}

@test "on bpm.toml dependencies, installs properly" {
	local site='github.com'
	local pkg='username/package'

	test_util.stub_command 'do-actual-add'

	test_util.setup_pkg "$pkg"; {
		echo 'dependencies = [ "user/dep1", "user/dep2" ]' > 'bpm.toml'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run plumbing.remove-dependencies "$site/$pkg"

	assert_success
	assert_line -p "Removing '$site/user/dep1'"
	assert_line -p "Removing '$site/user/dep2'"
}
