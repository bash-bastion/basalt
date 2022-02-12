# shellcheck shell=bash

load './util/init.sh'

@test "basalt init creates basalt.toml" {
	skip

	assert_file_not_exist 'basalt.toml'

	run basalt init --bare
	assert_success

	assert_file_exist 'basalt.toml'
}
