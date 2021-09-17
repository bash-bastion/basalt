# shellcheck shell=bash

load './util/init.sh'

@test "basalt init creates basalt.toml" {
	assert_file_not_exist 'basalt.toml'

	run basalt init
	assert_success

	assert_file_exist 'basalt.toml'
}
