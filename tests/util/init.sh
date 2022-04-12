# shellcheck shell=bash

eval "$(basalt-package-init)" || exit
basalt.package-init || exit
basalt.package-load
basalt.load 'github.com/hyperupcall/bats-all' 'load.bash'

load './util/test_util.sh'

setup() {
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
