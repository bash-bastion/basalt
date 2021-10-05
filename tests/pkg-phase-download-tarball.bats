# shellcheck shell=bash

load './util/init.sh'

@test "Fails for invalid repository" {
	skip

	pkg.phase_download_tarball 'remote' 'https://github.com/hyperupcall/bash-object.git' 'github.com' 'hyperupcall/bash-object' 'v0.3.0'
}
