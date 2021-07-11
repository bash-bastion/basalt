#!/usr/bin/env bats

load 'util/init.sh'

@test "directory with GitHub site" {
	util.extract_data_from_package_dir "cellar/packages/github.com/eankeen/bash-args"

	assert [ "$REPLY1" = 'github.com' ]
	assert [ "$REPLY2" = 'eankeen' ]
	assert [ "$REPLY3" = 'bash-args' ]
}

@test "directory with GitLab site" {
	util.extract_data_from_package_dir "cellar/packages/gitlab.com/eankeen/bash-args"

	assert [ "$REPLY1" = 'gitlab.com' ]
	assert [ "$REPLY2" = 'eankeen' ]
	assert [ "$REPLY3" = 'bash-args' ]
}

@test "directory installed locally" {
	util.extract_data_from_package_dir "cellar/packages/local/bash-args"

	assert [ "$REPLY1" = 'local' ]
	assert [ "$REPLY2" = '' ]
	assert [ "$REPLY3" = 'bash-args' ]
}
