#!/usr/bin/env bats

load './util/init.sh'

@test "core.get_package_info version works" {
	core.get_package_info "$BATS_TEST_DIRNAME/testdata/info1" 'version'
	
	assert [ "$REPLY" = '0.4.0' ]
}

@test "core.get_package_info version works 2" {
	core.get_package_info "$BATS_TEST_DIRNAME/testdata/info2" 'version2'

	assert [ "$REPLY" = '0.4.0' ]
}

@test "core.should_output_color works" {
	unset NO_COLOR COLORTERM TERM

	NO_COLOR= run core.should_output_color
	assert_failure

	COLORTERM='truecolor' run core.should_output_color
	assert_success

	TERM='dumb' run core.should_output_color
	assert_failure
}