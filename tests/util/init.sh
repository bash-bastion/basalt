# shellcheck shell=bash

eval "$(basalt-package-init)" || exit
basalt.package-init || exit
basalt.package-load
# basalt.load 'github.com/hyperupcall/bats-all' 'load.bash'

load './util/test_util.sh'

load "$BASALT_PACKAGE_DIR/pkg/src/bin/bash-std.sh"
bash-std() { main.bash-std "$@"; }

export NO_COLOR=

setup() {
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
