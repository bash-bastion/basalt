# shellcheck shell=bash

load './util/init.sh'

teardown() {
	if [ -n "$XDG_RUNTIME_DIR" ]; then
		rm -rf "$XDG_RUNTIME_DIR/basalt.lock"
	else
		rm -rf "$BASALT_GLOBAL_DATA_DIR/basalt.lock"
	fi

	ensure.cd "$BATS_SUITE_TMPDIR"
}

@test "Ensure locking works" {
	basalt init
	BATS_TMPDIR= basalt add &

	BATS_TMPDIR= run basalt add
	wait

	assert_failure
	assert_line -p "Cannot run Basalt at this time because another Basalt process is already running"
}
