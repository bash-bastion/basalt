#!/usr/bin/env bats

load 'util/init.sh'

@test "default BPM_ROOT" {
	BPM_ROOT= run bpm --global echo BPM_ROOT
	assert_output "$HOME/.local/share/bpm"
}

@test "inherited BPM_ROOT" {
	BPM_ROOT=/tmp/bpm run bpm --global echo BPM_ROOT
	assert_output "/tmp/bpm"
}

@test "default BPM_PREFIX" {
	BPM_ROOT= BPM_PREFIX= run bpm --global echo BPM_PREFIX
	assert_output "$HOME/.local/share/bpm/cellar"
}

@test "inherited BPM_PREFIX" {
	BPM_PREFIX=/usr/local run bpm --global echo BPM_PREFIX
	assert_output "/usr/local"
}

@test "BPM_PREFIX based on BPM_ROOT" {
	BPM_ROOT=/tmp/bpm BPM_PREFIX= run bpm --global echo BPM_PREFIX
	assert_output "/tmp/bpm/cellar"
}

@test "inherited BPM_PACKAGES_PATH" {
	BPM_PACKAGES_PATH=/usr/local/packages run bpm --global echo BPM_PACKAGES_PATH
	assert_output "/usr/local/packages"
}

@test "BPM_PACKAGES_PATH based on BPM_PREFIX" {
	BPM_PREFIX=/tmp/bpm BPM_PACKAGES_PATH= run bpm --global echo BPM_PACKAGES_PATH
	assert_output "/tmp/bpm/packages"
}

@test "default BPM_INSTALL_BIN" {
	BPM_ROOT= BPM_PREFIX= BPM_INSTALL_BIN= run bpm --global echo BPM_INSTALL_BIN
	assert_output "$HOME/.local/share/bpm/cellar/bin"
}

@test "inherited BPM_INSTALL_BIN" {
	BPM_INSTALL_BIN=/opt/bin run bpm --global echo BPM_INSTALL_BIN
	assert_output "/opt/bin"
}

@test "BPM_INSTALL_BIN based on BPM_PREFIX" {
	BPM_INSTALL_BIN= BPM_ROOT=/tmp/bpm BPM_PREFIX=/usr/local run bpm --global echo BPM_INSTALL_BIN
	assert_output "/usr/local/bin"
}

@test "default BPM_INSTALL_MAN" {
	BPM_ROOT= BPM_PREFIX= BPM_INSTALL_MAN= run bpm --global echo BPM_INSTALL_MAN
	assert_output "$HOME/.local/share/bpm/cellar/man"
}

@test "inherited BPM_INSTALL_MAN" {
	BPM_INSTALL_MAN=/opt/man run bpm --global echo BPM_INSTALL_MAN
	assert_output "/opt/man"
}

@test "BPM_INSTALL_MAN based on BPM_PREFIX" {
	BPM_INSTALL_MAN= BPM_PREFIX=/usr/local run bpm --global echo BPM_INSTALL_MAN
	assert_output "/usr/local/man"
}

@test "default BPM_INSTALL_COMPLETIONS" {
	BPM_ROOT= BPM_PREFIX= BPM_INSTALL_COMPLETIONS= run bpm --global echo BPM_INSTALL_COMPLETIONS
	assert_output "$HOME/.local/share/bpm/cellar/completions"
}

@test "inherited BPM_INSTALL_COMPLETIONS" {
	BPM_INSTALL_COMPLETIONS=/opt/completions run bpm --global echo BPM_INSTALL_COMPLETIONS
	assert_output "/opt/completions"
}

@test "BPM_INSTALL_COMPLETIONS based on BPM_PREFIX" {
	BPM_INSTALL_COMPLETIONS= BPM_PREFIX=/usr/local run bpm --global echo BPM_INSTALL_COMPLETIONS
	assert_output "/usr/local/completions"
}



@test "non-global default BPM_ROOT" {
	touch 'bpm.toml'

	BPM_ROOT= run bpm echo BPM_ROOT

	assert_success
	assert_line -p "$PWD"
}

@test "non-global default BPM_PREFIX" {
	touch 'bpm.toml'

	BPM_ROOT= BPM_PREFIX= run bpm echo BPM_PREFIX

	assert_success
	assert_line -p "$PWD/bpm_packages"
}

@test "non-global default BPM_PACKAGES_PATH" {
	touch 'bpm.toml'

	BPM_ROOT= BPM_PACKAGES_PATH= run bpm echo BPM_PACKAGES_PATH

	assert_success
	assert_line -p "$PWD/bpm_packages/packages"
}

@test "non-global default BPM_INSTALL_BIN" {
	touch 'bpm.toml'

	BPM_ROOT= BPM_INSTALL_BIN= run bpm echo BPM_INSTALL_BIN

	assert_success
	assert_line -p "$PWD/bpm_packages/bin"
}

@test "non-global default BPM_INSTALL_MAN" {
	touch 'bpm.toml'

	BPM_ROOT= BPM_INSTALL_MAN= run bpm echo BPM_INSTALL_MAN

	assert_success
	assert_line -p "$PWD/bpm_packages/man"
}

@test "non-global default BPM_INSTALL_COMPLETIONS" {
	touch 'bpm.toml'

	BPM_ROOT= BPM_INSTALL_COMPLETIONS= run bpm echo BPM_INSTALL_COMPLETIONS

	assert_success
	assert_line -p "$PWD/bpm_packages/completions"
}
