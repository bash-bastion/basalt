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
	unset -v NO_COLOR FORCE_COLOR TERM

	NO_COLOR= run core.should_output_color
	assert_failure

	FORCE_COLOR=0 run core.should_output_color
	assert_failure

	FORCE_COLOR=1 run core.should_output_color
	assert_success

	FORCE_COLOR=2 run core.should_output_color
	assert_success

	FORCE_COLOR=3 run core.should_output_color
	assert_success

	# NO_COLOR has precedent over FORCE_COLOR
	NO_COLOR= FORCE_COLOR=1 run core.should_output_color
	assert_failure

	TERM='dumb' run core.should_output_color
	assert_failure
}