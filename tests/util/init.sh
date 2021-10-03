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
for f in "$REPO_ROOT"/pkg/lib/{cmd,commands,public,util}/?*.sh; do
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
export BASALT_GLOBAL_REPO="$BATS_TEST_TMPDIR/source"
export BASALT_GLOBAL_DATA_DIR="$BATS_TEST_TMPDIR/localshare"

setup() {
	ensure.cd "$BATS_TEST_TMPDIR"
}

teardown() {
	ensure.cd "$BATS_SUITE_TMPDIR"
}
