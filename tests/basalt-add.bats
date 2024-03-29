# shellcheck shell=bash

load './util/init.sh'

setup_file() {
	test_util.stub_command 'basalt-install'
}

@test "Fails if dependency is bogus" {
	test_util.init_app 'project-echo' '.'

	run basalt add 'UwU'

	assert_failure
	assert_line -p "String 'UwU' does not look like a package"
}

@test "Fails if dependency does not exist 1" {
	test_util.init_app 'project-echo' '.'

	run basalt add 'hyperupcall/basaltqq'

	assert_failure
	assert_line -p "Package located at 'https://github.com/hyperupcall/basaltqq' does not exist"
}

@test "Fails if dependency does not exist 2" {
	test_util.init_app 'project-echo' '.'

	run basalt add 'gitlab.com/hyperupcall/basaltqq'

	assert_failure
	assert_line -p "Package located at 'https://gitlab.com/hyperupcall/basaltqq' does not exist"
}

@test "Fails if dependency does not exist 3" {
	test_util.init_app 'project-echo' '.'

	run basalt add 'https://github.com/hyperupcall/basaltqq'

	assert_failure
	assert_line -p "Package located at 'https://github.com/hyperupcall/basaltqq' does not exist"
}

@test "Fails if dependency does not exist 4" {
	test_util.init_app 'project-echo' '.'

	run basalt add 'file:///some/fake/directory'

	assert_failure
	assert_line -p "Package located at '/some/fake/directory' does not exist"
}

# @test "Adds one dependency" {
# 	local dir=
# 	test_util.create_fake_remote 'user/repo'; dir="$REPLY"

# 	basalt init --bare
# 	basalt add "file://$dir"

# 	run printf '%s' "$(<basalt.toml)"
# 	assert_success
# 	assert_line -n 7 -e "dependencies = \['file://$dir@[a-z0-9]+'\]"
# }

# @test "Adds one dependency with release version" {
# 	local dir=
# 	test_util.create_fake_remote 'user/repo'; dir="$REPLY"

# 	basalt init --bare
# 	basalt add "file://$dir@v0.0.1"

# 	run printf '%s' "$(<basalt.toml)"
# 	assert_success
# 	assert_line -n 7 -e "dependencies = \['file://$dir@v0.0.1'\]"
# }

# @test "Adds one dependency with ref" {
# 	local dir=
# 	test_util.create_fake_remote 'user/repo'; dir="$REPLY"

# 	basalt init --bare
# 	basalt add "file://$dir@1c6caee378cf31b30971e78f6b9d10273a340ca0"

# 	run printf '%s' "$(<basalt.toml)"
# 	assert_success
# 	assert_line -n 7 -e "dependencies = \['file://$dir@[a-z0-9]+'\]"
# }

# @test "Adds two dependencies" {
# 	local dir1= dir2=
# 	test_util.create_fake_remote 'user/repo1'; dir1="$REPLY"
# 	test_util.create_fake_remote 'user/repo2'; dir2="$REPLY"

# 	basalt init --bare
# 	basalt add "file://$dir1" "file://$dir2"

# 	run printf '%s' "$(<basalt.toml)"
# 	assert_success
# 	assert_line -n 7 -e "dependencies = \['file://$dir1@[a-z0-9]+', 'file://$dir2@[a-z0-9]+'\]"
# }
