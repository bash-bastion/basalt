# shellcheck shell=bash

load 'vendor/bats-core/load.bash'
load 'vendor/bats-assert/load.bash'
load 'util/test_util.sh'

export LANG="C"
export LANGUAGE="C"
export LC_ALL="C"
export XDG_DATA_HOME=

# Test-specific
export BASALT_TEST_DIR="$BATS_TMPDIR/basalt"
export BASALT_ORIGIN_DIR="$BASALT_TEST_DIR/origin"
export BASALT_IS_TEST=

# Stub common variables
test_util.get_repo_root
# The root of the real source. This is a separate variable because we want to
# set 'BASALT_LOCAL_PROJECT_DIR' to some other value
export BASALT_TEST_REPO_ROOT="$REPLY"
export PROGRAM_LIB_DIR="$BASALT_TEST_REPO_ROOT/pkg/lib"

export BASALT_LOCAL_PROJECT_DIR=
export BASALT_GLOBAL_REPO="$BASALT_TEST_DIR/source"
export BASALT_GLOBAL_CELLAR="$BASALT_TEST_DIR/cellar"
# TODO: this should be removed
export BASALT_PACKAGES_PATH="$BASALT_GLOBAL_CELLAR/packages"
export BASALT_INSTALL_BIN="$BASALT_GLOBAL_CELLAR/bin"
export BASALT_INSTALL_MAN="$BASALT_GLOBAL_CELLAR/man"
export BASALT_INSTALL_COMPLETIONS="$BASALT_GLOBAL_CELLAR/completions"

export PATH="$BASALT_TEST_REPO_ROOT/pkg/bin:$PATH"
source "$BASALT_TEST_REPO_ROOT/pkg/lib/source/basalt-load.sh"

source "$BASALT_TEST_REPO_ROOT/pkg/lib/cmd/basalt.sh"
basalt() {
	_cmd_.basalt "$@"
}

setup() {
	mkdir -p "$BASALT_TEST_DIR" "$BASALT_ORIGIN_DIR"
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	rm -rf "$BASALT_TEST_DIR"
}
