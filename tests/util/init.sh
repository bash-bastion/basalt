# shellcheck shell=bash

set -o pipefail
shopt -s nullglob extglob

load 'vendor/bats-core/load'
load 'vendor/bats-assert/load'
load 'util/mocks.sh'
load 'util/package_helpers.sh'

export BASHER_TEST_DIR="$BATS_TMPDIR/basher"
export BASHER_ORIGIN_DIR="$BASHER_TEST_DIR/origin"
export BASHER_CWD="$BASHER_TEST_DIR/cwd"
export BASHER_TMP_BIN="$BASHER_TEST_DIR/bin"
export XDG_DATA_HOME=""

export NEOBASHER_ROOT="$BATS_TEST_DIRNAME/.."
export NEOBASHER_PREFIX="$BASHER_TEST_DIR/prefix"
export NEOBASHER_INSTALL_BIN="$NEOBASHER_PREFIX/bin"
export NEOBASHER_INSTALL_MAN="$NEOBASHER_PREFIX/man"
export NEOBASHER_PACKAGES_PATH="$NEOBASHER_PREFIX/packages"

mkdir -p "$BASHER_TEST_DIR/path"
mkdir -p "$BASHER_ORIGIN_DIR"
mkdir -p "$BASHER_CWD"
mkdir -p "$BASHER_TMP_BIN"

# TODO: FIX THIS
export PATH="$NEOBASHER_ROOT/pkg/bin:$PATH"
PATH="$BASHER_TMP_BIN:$PATH"

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
