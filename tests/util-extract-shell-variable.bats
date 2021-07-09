#!/usr/bin/env bats

load 'util/init.sh'

@test "fails on invalid file" {
	run util.extract_shell_variable 'file'

	assert_failure
	assert_line -p "File 'file' not found"
}

@test "properly extracts value (no quotes)" {
	util.extract_shell_variable <(cat <<-"EOF"
	key=valuee
	EOF
	) 'key'

	assert [ "$REPLY" = 'valuee' ]
}

@test "properly extracts value (single quotes)" {
	util.extract_shell_variable <(cat <<-"EOF"
	key='valuee'
	EOF
	) 'key'

	assert [ "$REPLY" = 'valuee' ]
}


@test "properly extracts value (double quotes)" {
	util.extract_shell_variable <(cat <<-"EOF"
	key="valuee"
	EOF
	) 'key'

	assert [ "$REPLY" = 'valuee' ]
}
