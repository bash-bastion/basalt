# shellcheck shell=bash

do-init() {
	if [ -e basalt.toml ]; then
		bprint.die "File 'basalt.toml' already exists"
	fi

	cat >| basalt.toml <<-"EOF"
	[package]
	name = ''
	slug = ''
	version = ''
	authors = []
	description = ''

	[run]
	dependencies = []
	sourceDirs = []
	builtinDirs = []
	binDirs = []
	completionDirs = []
	manDirs = []

	[run.shellEnvironment]

	[run.setOptions]

	[run.shoptOptions]
	EOF

	bprint.info "Created basalt.toml"
}
