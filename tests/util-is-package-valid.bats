# shellcheck shell=bash
# TODO

load './util/init.sh'

@test "Succeeds with alphanumeric package" {
	run util.assert_package_valid "owner/one4"

	assert_success
}

@test "Fails with alphanumeric package starting with a number" {
	run util.assert_package_valid "owner/4one"

	assert_failure
}

@test "Fails with alphanumeric package starting with a hyphen" {
	run util.assert_package_valid "owner/-one"

	assert_failure
}

@test "Fails with package including a space" {
	run util.assert_package_valid "owner/o ne"

	assert_failure
}

@test "Fails with alphanumeric username including a space" {
	run util.assert_package_valid "own er/something"

	assert_failure
}
