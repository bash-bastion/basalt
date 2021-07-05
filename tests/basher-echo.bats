#!/usr/bin/env bats

load 'util/init.sh'

@test "default NEOBASHER_ROOT" {
	NEOBASHER_ROOT= run neobasher echo NEOBASHER_ROOT
	assert_output "$HOME/.local/share/neobasher"
}

@test "inherited NEOBASHER_ROOT" {
	NEOBASHER_ROOT=/tmp/basher run neobasher echo NEOBASHER_ROOT
	assert_output "/tmp/basher"
}

@test "default NEOBASHER_PREFIX" {
	NEOBASHER_ROOT= NEOBASHER_PREFIX= run neobasher echo NEOBASHER_PREFIX
	assert_output "$HOME/.local/share/neobasher/cellar"
}

@test "inherited NEOBASHER_PREFIX" {
	NEOBASHER_PREFIX=/usr/local run neobasher echo NEOBASHER_PREFIX
	assert_output "/usr/local"
}

@test "NEOBASHER_PREFIX based on NEOBASHER_ROOT" {
	NEOBASHER_ROOT=/tmp/basher NEOBASHER_PREFIX= run neobasher echo NEOBASHER_PREFIX
	assert_output "/tmp/basher/cellar"
}

@test "inherited NEOBASHER_PACKAGES_PATH" {
	NEOBASHER_PACKAGES_PATH=/usr/local/packages run neobasher echo NEOBASHER_PACKAGES_PATH
	assert_output "/usr/local/packages"
}

@test "NEOBASHER_PACKAGES_PATH based on NEOBASHER_PREFIX" {
	NEOBASHER_PREFIX=/tmp/basher NEOBASHER_PACKAGES_PATH= run neobasher echo NEOBASHER_PACKAGES_PATH
	assert_output "/tmp/basher/packages"
}

@test "default NEOBASHER_INSTALL_BIN" {
	NEOBASHER_ROOT= NEOBASHER_PREFIX= NEOBASHER_INSTALL_BIN= run neobasher echo NEOBASHER_INSTALL_BIN
	assert_output "$HOME/.local/share/neobasher/cellar/bin"
}

@test "inherited NEOBASHER_INSTALL_BIN" {
	NEOBASHER_INSTALL_BIN=/opt/bin run neobasher echo NEOBASHER_INSTALL_BIN
	assert_output "/opt/bin"
}

@test "NEOBASHER_INSTALL_BIN based on NEOBASHER_PREFIX" {
	NEOBASHER_INSTALL_BIN= NEOBASHER_ROOT=/tmp/basher NEOBASHER_PREFIX=/usr/local run neobasher echo NEOBASHER_INSTALL_BIN
	assert_output "/usr/local/bin"
}

@test "default NEOBASHER_INSTALL_MAN" {
	NEOBASHER_ROOT= NEOBASHER_PREFIX= NEOBASHER_INSTALL_MAN= run neobasher echo NEOBASHER_INSTALL_MAN
	assert_output "$HOME/.local/share/neobasher/cellar/man"
}

@test "inherited NEOBASHER_INSTALL_MAN" {
	NEOBASHER_INSTALL_MAN=/opt/man run neobasher echo NEOBASHER_INSTALL_MAN
	assert_output "/opt/man"
}

@test "NEOBASHER_INSTALL_MAN based on NEOBASHER_PREFIX" {
	NEOBASHER_INSTALL_MAN= NEOBASHER_PREFIX=/usr/local run neobasher echo NEOBASHER_INSTALL_MAN
	assert_output "/usr/local/man"
}
