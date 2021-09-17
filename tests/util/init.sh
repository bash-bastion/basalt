# shellcheck shell=bash

# Source testing dependencies
load './vendor/bats-assert/assert.sh'
load './vendor/bats-file/file.sh'
load './vendor/bats-file/temp.sh'
load './vendor/bats-support/error.sh'
load './vendor/bats-support/lang.sh'
load './vendor/bats-support/output.sh'
load './util/test_util.sh'

# Get the current directory of the Basalt git repository
test_util.get_repo_root
REPO_ROOT="$REPLY"

# Source Basalt
for f in "$REPO_ROOT"/pkg/lib/{cmd,commands,source,util}/?*.sh; do
	source "$f"
done; unset f

# Rather than append '$REPO_ROOT/pkg/bin' to the path, create functions with
# the same name. This way, the shell execution context remains the same, which
# allows us to actually mock functions
load "$REPO_ROOT/pkg/lib/cmd/basalt-package-init.sh"
load "$REPO_ROOT/pkg/lib/cmd/basalt.sh"
basalt-package-init() { basalt-package-init.main "$@"; }
basalt() { basalt.main "$@"; }

# Testing variables
export XDG_DATA_HOME=
export BASALT_TEST_DIR="$BATS_TMPDIR/basalt"
export BASALT_GLOBAL_REPO="$BASALT_TEST_DIR/source"
export BASALT_GLOBAL_DATA_DIR="$BASALT_TEST_DIR/localshare"

setup() {
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
