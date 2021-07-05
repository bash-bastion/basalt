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

export NEOBASHER_ROOT="$BATS_TEST_DIRNAME/.."
export NEOBASHER_PREFIX="$BASHER_TEST_DIR/cellar"
export NEOBASHER_PACKAGES_PATH="$NEOBASHER_PREFIX/packages"
export NEOBASHER_INSTALL_BIN="$NEOBASHER_PREFIX/bin"
export NEOBASHER_INSTALL_MAN="$NEOBASHER_PREFIX/man"

mkdir -p "$BASHER_TEST_DIR" "$BASHER_ORIGIN_DIR" "$BASHER_CWD"

export PATH="$NEOBASHER_ROOT/pkg/bin:$PATH"

for f in "$NEOBASHER_ROOT"/pkg/lib/{commands,util}/?*.sh; do
	source "$f"
done

setup() {
	# shellcheck disable=SC2164
	cd "$BASHER_CWD"
}

teardown() {
	rm -rf "$BASHER_TEST_DIR"
}
