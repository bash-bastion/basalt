#!/usr/bin/env bats

load 'util/init.sh'

@test "default BPM_ROOT" {
	BPM_ROOT= run bpm echo BPM_ROOT
	assert_output "$HOME/.local/share/bpm"
}

@test "inherited BPM_ROOT" {
	BPM_ROOT=/tmp/bpm run bpm echo BPM_ROOT
	assert_output "/tmp/bpm"
}

@test "default BPM_PREFIX" {
	BPM_ROOT= BPM_PREFIX= run bpm echo BPM_PREFIX
	assert_output "$HOME/.local/share/bpm/cellar"
}

@test "inherited BPM_PREFIX" {
	BPM_PREFIX=/usr/local run bpm echo BPM_PREFIX
	assert_output "/usr/local"
}

@test "BPM_PREFIX based on BPM_ROOT" {
	BPM_ROOT=/tmp/bpm BPM_PREFIX= run bpm echo BPM_PREFIX
	assert_output "/tmp/bpm/cellar"
}

@test "inherited BPM_PACKAGES_PATH" {
	BPM_PACKAGES_PATH=/usr/local/packages run bpm echo BPM_PACKAGES_PATH
	assert_output "/usr/local/packages"
}

@test "BPM_PACKAGES_PATH based on BPM_PREFIX" {
	BPM_PREFIX=/tmp/bpm BPM_PACKAGES_PATH= run bpm echo BPM_PACKAGES_PATH
	assert_output "/tmp/bpm/packages"
}

@test "default BPM_INSTALL_BIN" {
	BPM_ROOT= BPM_PREFIX= BPM_INSTALL_BIN= run bpm echo BPM_INSTALL_BIN
	assert_output "$HOME/.local/share/bpm/cellar/bin"
}

@test "inherited BPM_INSTALL_BIN" {
	BPM_INSTALL_BIN=/opt/bin run bpm echo BPM_INSTALL_BIN
	assert_output "/opt/bin"
}

@test "BPM_INSTALL_BIN based on BPM_PREFIX" {
	BPM_INSTALL_BIN= BPM_ROOT=/tmp/bpm BPM_PREFIX=/usr/local run bpm echo BPM_INSTALL_BIN
	assert_output "/usr/local/bin"
}

@test "default BPM_INSTALL_MAN" {
	BPM_ROOT= BPM_PREFIX= BPM_INSTALL_MAN= run bpm echo BPM_INSTALL_MAN
	assert_output "$HOME/.local/share/bpm/cellar/man"
}

@test "inherited BPM_INSTALL_MAN" {
	BPM_INSTALL_MAN=/opt/man run bpm echo BPM_INSTALL_MAN
	assert_output "/opt/man"
}

@test "BPM_INSTALL_MAN based on BPM_PREFIX" {
	BPM_INSTALL_MAN= BPM_PREFIX=/usr/local run bpm echo BPM_INSTALL_MAN
	assert_output "/usr/local/man"
}

@test "default BPM_INSTALL_COMPLETIONS" {
	BPM_ROOT= BPM_PREFIX= BPM_INSTALL_COMPLETIONS= run bpm echo BPM_INSTALL_COMPLETIONS
	assert_output "$HOME/.local/share/bpm/cellar/completions"
}

@test "inherited BPM_INSTALL_COMPLETIONS" {
	BPM_INSTALL_COMPLETIONS=/opt/completions run bpm echo BPM_INSTALL_COMPLETIONS
	assert_output "/opt/completions"
}

@test "BPM_INSTALL_COMPLETIONS based on BPM_PREFIX" {
	BPM_INSTALL_COMPLETIONS= BPM_PREFIX=/usr/local run bpm echo BPM_INSTALL_COMPLETIONS
	assert_output "/usr/local/completions"
}
