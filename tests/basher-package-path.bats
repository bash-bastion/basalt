#!/usr/bin/env bats

load 'util/init.sh'

@test "outputs the package path" {
	mock.command _clone
	create_package username/package
	basher-install username/package

	run basher-package-path username/package
	assert_success "$BASHER_PACKAGES_PATH/username/package"
}
