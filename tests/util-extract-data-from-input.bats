#!/usr/bin/env bats

load 'util/init.sh'


@test "fails on no arguments" {
	run util.extract_data_from_input

	assert_failure
	assert_line -p "Must supply a repository"
}

@test "parses with full https url" {
	util.extract_data_from_input 'https://gitlab.com/eankeen/proj'

	assert [ "$REPLY1" = 'https://gitlab.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with full http url" {
	util.extract_data_from_input 'http://gitlab.com/eankeen/proj'

	assert [ "$REPLY1" = 'http://gitlab.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with full https url with .git ending" {
	util.extract_data_from_input 'https://gitlab.com/eankeen/proj'

	assert [ "$REPLY1" = 'https://gitlab.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with full http url with .git ending" {
	util.extract_data_from_input 'http://gitlab.com/eankeen/proj.git'

	assert [ "$REPLY1" = 'http://gitlab.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with full ssh url" {
	util.extract_data_from_input 'git@gitlab.com:eankeen/proj.git'

	assert [ "$REPLY1" = 'git@gitlab.com:eankeen/proj' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with package and domain" {
	util.extract_data_from_input 'gitlab.com/eankeen/proj'

	assert [ "$REPLY1" = 'https://gitlab.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with package and domain and ref" {
	util.extract_data_from_input 'gitlab.com/eankeen/proj@v0.1.0'

	assert [ "$REPLY1" = 'https://gitlab.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = 'v0.1.0' ]
}

@test "parses with package and domain with ssh" {
	util.extract_data_from_input 'gitlab.com/eankeen/proj' 'yes'

	assert [ "$REPLY1" = 'git@gitlab.com:eankeen/proj' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with package and domain and ref with ssh" {
	util.extract_data_from_input 'gitlab.com/eankeen/proj@v0.1.0' 'yes'

	assert [ "$REPLY1" = 'git@gitlab.com:eankeen/proj' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = 'v0.1.0' ]
}

@test "parses with package" {
	util.extract_data_from_input 'eankeen/proj'

	assert [ "$REPLY1" = 'https://github.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'github.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with package and ref" {
	util.extract_data_from_input 'eankeen/proj@v0.2.0'

	assert [ "$REPLY1" = 'https://github.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'github.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = 'v0.2.0' ]
}

@test "parses with package with ssh" {
	util.extract_data_from_input 'eankeen/proj' 'yes'

	assert [ "$REPLY1" = 'git@github.com:eankeen/proj' ]
	assert [ "$REPLY2" = 'github.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with package with ssh and ref" {
	util.extract_data_from_input 'eankeen/proj@v0.2.0' 'yes'

	assert [ "$REPLY1" = 'git@github.com:eankeen/proj' ]
	assert [ "$REPLY2" = 'github.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = 'v0.2.0' ]
}

@test "parses with local" {
	util.extract_data_from_input 'local/project2' 'no'
	assert [ "$REPLY1" = '' ]
	assert [ "$REPLY2" = 'local' ]
	assert [ "$REPLY3" = 'project2' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with local and ref" {
	util.extract_data_from_input 'local/project2@v0.2.0' 'no'
	assert [ "$REPLY1" = '' ]
	assert [ "$REPLY2" = 'local' ]
	assert [ "$REPLY3" = 'project2' ]
	assert [ "$REPLY4" = 'v0.2.0' ]
}

# This is strictly an undocumented feature
@test "parses with file:// protocol" {
	util.extract_data_from_input 'file:///home/directory' 'no'
	assert [ "$REPLY1" = 'file:///home/directory' ]
	assert [ "$REPLY2" = 'github.com' ]
	assert [ "$REPLY3" = 'home/directory' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with file:// protocol and ref" {
	util.extract_data_from_input 'file:///home/user/directory@v0.2.0' 'no'
	assert [ "$REPLY1" = 'file:///home/user/directory' ]
	assert [ "$REPLY2" = 'github.com' ]
	assert [ "$REPLY3" = 'user/directory' ]
	assert [ "$REPLY4" = 'v0.2.0' ]
}

@test "fails to parse with file:// protocol if no parent directory" {
	run util.extract_data_from_input 'file:///directory' 'no'

	assert_failure
	assert_line -p "Directory specified with file protocol must have at least one parent directory"
}

@test "errors with friendly message if format is not proper" {
	run util.extract_data_from_input 'UwU'

	assert_failure
	assert_line -p "Package 'UwU' does not appear to be formatted correctly"
}
