# shellcheck shell=bash
# TODO

load './util/init.sh'

# TODO: print error message / have standard error interface

@test "Valid site 1" {
	run util.assert_package_valid 'github.com' 'a/a' 'va'

	assert_success
}

@test "Invalid site 1" {
	run util.assert_package_valid 'githubcom' 'a/a' 'va'

	assert_failure
}

@test "Invalid site 2" {
	run util.assert_package_valid $'github.com\n' 'a/a' 'va'

	assert_failure
}

@test "Invalid site 3" {
	run util.assert_package_valid '' 'a/a' 'va'

	assert_failure
}

@test "Valid package 1" {
	run util.assert_package_valid 'a.a' 'usern_ame/a_package' 'va'

	assert_success
}

@test "Valid package 2" {
	run util.assert_package_valid 'a.a' 'user-name/a-package' 'va'

	assert_success
}

@test "Invalid package 1" {
	run util.assert_package_valid 'a.a' '' 'va'

	assert_failure
}

@test "Invalid package 2" {
	run util.assert_package_valid 'a.a' $'a/a\n' 'va'

	assert_failure
}

@test "Valid ref 1" {
	run util.assert_package_valid 'a.a' 'a/a' 'vany'

	assert_success
}

@test "Valid ref 2" {
	run util.assert_package_valid 'a.a' 'a/a' '48e734ce06f9ae2ab0a40d5fe6be1ec50d55d9fc'

	assert_success
}

# @test "Fails with alphanumeric package starting with a hyphen" {
# 	run util.assert_package_valid "owner/-one"

# 	assert_failure
# }

# @test "Fails with package including a space" {
# 	run util.assert_package_valid "owner/o ne"

# 	assert_failure
# }

# @test "Fails with alphanumeric username including a space" {
# 	run util.assert_package_valid "own er/something"

# 	assert_failure
# }
