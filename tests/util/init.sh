# shellcheck shell=bash

load 'vendor/bats-core/load'
load 'vendor/bats-assert/load'
load 'util/package_helpers.sh'
load 'util/test_util.sh'

set -ETeo pipefail
shopt -s nullglob extglob

export BASHER_TEST_DIR="$BATS_TMPDIR/basher"
export BASHER_ORIGIN_DIR="$BASHER_TEST_DIR/origin"
export BASHER_CWD="$BASHER_TEST_DIR/cwd"
export XDG_DATA_HOME=

export BPM_ROOT="$BATS_TEST_DIRNAME/.."
export BPM_PREFIX="$BASHER_TEST_DIR/cellar"
export BPM_PACKAGES_PATH="$BPM_PREFIX/packages"
export BPM_INSTALL_BIN="$BPM_PREFIX/bin"
export BPM_INSTALL_MAN="$BPM_PREFIX/man"

mkdir -p "$BASHER_TEST_DIR" "$BASHER_ORIGIN_DIR" "$BASHER_CWD"

export PATH="$BPM_ROOT/pkg/bin:$PATH"

for f in "$BPM_ROOT"/pkg/lib/{commands,util}/?*.sh; do
	source "$f"
done

setup() {
	# shellcheck disable=SC2164
	cd "$BASHER_CWD"
}

teardown() {
	rm -rf "$BASHER_TEST_DIR"
}
