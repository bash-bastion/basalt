# shellcheck shell=bash

load './util/init.sh'

@test "Works (remote) with well-formed input" {
	pkgutil.get_package_id 'remote' 'https://github.com/hyperupcall/fake-project.git' 'github.com' 'hyperupcall/fake-project' 'v0.0.1'

	assert [ "$REPLY" = 'github.com/hyperupcall/fake-project@v0.0.1' ]
}

# This tests for when 'site' is empty as well
@test "Works (local) with well-formed input" {
	pkgutil.get_package_id 'local' 'file:///directories/to/fake/some_path' '' 'hyperupcall/fake-project' 'v0.0.1'

	assert [ "$REPLY" = 'local/some_path@v0.0.1' ]
}

@test "Fails (remote) with no site" {
	run pkgutil.get_package_id 'remote' 'https://github.com/hyperupcall/fake-project.git' '' 'hyperupcall/fake-project' 'v0.0.1'

	assert_failure
	assert_line -p "Fatal: Argument 'site' for function 'pkgutil.get_package_id' is empty"
}

@test "Fails (remote) with no version" {
	skip

	run pkgutil.get_package_id 'remote' 'https://github.com/hyperupcall/fake-project.git' 'github.com' 'hyperupcall/fake-project' ''

	assert_failure
	assert_line -p "Fatal: Argument 'version' for function 'pkgutil.get_package_id' is empty"
}

@test "Fails (local) with no version" {
	skip

	run pkgutil.get_package_id 'local' 'file:///directories/to/fake/some_path' '' 'hyperupcall/fake-project' ''

	assert_failure
	assert_line -p "Fatal: Argument 'version' for function 'pkgutil.get_package_id' is empty"
}

@test "Succeeds (remote) with no version with --allow-empty-version passed" {
	skip

	pkgutil.get_package_id --allow-empty-version 'remote' 'https://github.com/hyperupcall/fake-project.git' 'github.com' 'hyperupcall/fake-project' ''

	assert [ "$REPLY" = 'github.com/hyperupcall/fake-project' ]
}

@test "Succeeds (local) with no version with --allow-empty-version passed" {
	skip

	pkgutil.get_package_id --allow-empty-version 'local' 'file:///directories/to/fake/some_path' '' 'hyperupcall/fake-project' ''

	assert [ "$REPLY" = 'local/some_path' ]
}
