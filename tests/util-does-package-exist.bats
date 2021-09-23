# shellcheck shell=bash

load './util/init.sh'

@test "one" {
	run util.does_package_exist 'remote' "https://github.com/hyperupcall/basalt.git"

	assert_success
}
