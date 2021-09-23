# shellcheck shell=bash

load './util/init.sh'

@test "Ensure locking works" {
	basalt init
	BATS_TMPDIR= basalt add &

	BATS_TMPDIR= run basalt add
	wait

	assert_failure
	assert_line -p "Cannot run Basalt at this time because another Basalt process is already running"
}
