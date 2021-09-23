# shellcheck shell=bash

load './util/init.sh'

@test "Ensure locking works" {
	basalt init
	basalt add &

	run basalt add

	assert_failure
	assert_line -p "Cannot run Basalt at this time because another Basalt process is already running"

	kill $(jobs -p)
}
