#!/usr/bin/env bats

load 'util/init.sh'

@test "does not fail if there are no completions" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		:
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	assert_success
}


## BASH ##

@test "adds bash completions determined from package.sh" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir 'completions'
		touch 'completions/comp.bash'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions username/package

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/comp.bash")" = "$BPM_PACKAGES_PATH/$pkg/completions/comp.bash" ]
}


@test "adds bash completions determined from package.sh (and not from heuristics)" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo "BASH_COMPLETIONS=" > 'package.sh'
		mkdir 'completions'
		touch 'completions/prof.bash'
	}; test_util.finish_pkg

	run do-plumbing-link-completions "$pkg"

	! [ -f "$BPM_INSTALL_COMPLETIONS/bash/prof.bash" ]
}

@test "adds bash completions determined from bpm.toml" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "weird_completions" ]' > 'bpm.toml'
		mkdir 'weird_completions'
		touch 'weird_completions/comp.bash'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/comp.bash")" = "$BPM_PACKAGES_PATH/$pkg/weird_completions/comp.bash" ]
}

@test "adds bash completions determined from bpm.toml (and not from heuristics)" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "weird_completions" ]' > 'bpm.toml'
		mkdir 'completions'
		touch 'completions/prof.bash'
	}; test_util.finish_pkg

	run do-plumbing-link-completions "$pkg"

	! [ -f "$BPM_INSTALL_COMPLETIONS/bash/prof.bash" ]
}

@test "adds bash completions determined with heuristics (./?(contrib/)completion?(s))" {
	local pkg="username/package$i"

	test_util.setup_pkg "$pkg"; {
		mkdir -p ./{contrib/,}completion{,s}
		touch "completion/c1.bash"
		touch "completions/c2.bash"
		touch "contrib/completion/c3.bash"
		touch "contrib/completions/c4.bash"
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c1.bash")" = "$BPM_PACKAGES_PATH/$pkg/completion/c1.bash" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c2.bash")" = "$BPM_PACKAGES_PATH/$pkg/completions/c2.bash" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c3.bash")" = "$BPM_PACKAGES_PATH/$pkg/contrib/completion/c3.bash" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c4.bash")" = "$BPM_PACKAGES_PATH/$pkg/contrib/completions/c4.bash" ]
}

@test "adds bash completions determined from heuristics when when ZSH_COMPLETIONS is specified in package.sh" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'ZSH_COMPLETIONS=""' > 'package.sh'
		mkdir 'completion'
		touch "completion/prog.bash"
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	[ -f "$BPM_INSTALL_COMPLETIONS/bash/prog.bash" ]
}

@test "do not add bash completions from heuristics when BASH_COMPLETIONS is specified in package.sh" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'BASH_COMPLETIONS=""' > 'package.sh'
		mkdir 'completion'
		touch "completion/prog.bash"
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	[ ! -f "$BPM_INSTALL_COMPLETIONS/bash/prog.bash" ]
}

@test "do not add bash completions from heuristics when completionDirs is specified in bpm.toml" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "dirr" ]' > 'bpm.toml'
		mkdir 'completion'
		touch "completion/prog.bash"
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/bash/prog.bash" ]
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/bash/prog.bash" ]
}

## ZSH ##

@test "adds zsh compsys completions determined from package.sh" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'ZSH_COMPLETIONS="dirr/_exec"' > 'package.sh'
		mkdir 'dirr'
		echo '#compdef' > "dirr/_exec"
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compsys/_exec")" = "$BPM_PACKAGES_PATH/$pkg/dirr/_exec" ]
}

@test "adds zsh compctl completions determined from pacakge.sh" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'ZSH_COMPLETIONS="dirr/exec"' > 'package.sh'
		mkdir 'dirr'
		touch "dirr/exec"
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/exec")" = "$BPM_PACKAGES_PATH/$pkg/dirr/exec" ]
}

@test "adds zsh compsys completions determined from bpm.toml" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "dirr" ]' > 'bpm.toml'
		mkdir 'dirr'
		echo '#compdef' > "dirr/_exec.zsh"
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compsys/_exec.zsh")" = "$BPM_PACKAGES_PATH/$pkg/dirr/_exec.zsh" ]
}

@test "adds zsh compctl completions determined from bpm.toml" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "dirr" ]' > 'bpm.toml'
		mkdir 'dirr'
		touch "dirr/exec.zsh"
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/exec.zsh")" = "$BPM_PACKAGES_PATH/$pkg/dirr/exec.zsh" ]
}

@test "adds zsh completions determined with heuristics (./?(contrib/)completion?(s))" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		mkdir -p ./{contrib/,}completion{,s}
		touch "completion/c1.zsh"
		echo '#compdef' > "completions/c2.zsh"
		touch "contrib/completion/c3.zsh"
		echo '#compdef' > "contrib/completions/c4.zsh"
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/c1.zsh")" = "$BPM_PACKAGES_PATH/$pkg/completion/c1.zsh" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compsys//c2.zsh")" = "$BPM_PACKAGES_PATH/$pkg/completions/c2.zsh" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/c3.zsh")" = "$BPM_PACKAGES_PATH/$pkg/contrib/completion/c3.zsh" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compsys//c4.zsh")" = "$BPM_PACKAGES_PATH/$pkg/contrib/completions/c4.zsh" ]
}

@test "adds zsh completions determined from heuristics when when BASH_COMPLETIONS is specified in package.sh" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'BASH_COMPLETIONS=""' > 'package.sh'
		mkdir completion{,s}
		touch "completion/c1.zsh"
		echo '#compdef' > "completions/c2.zsh"
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/c1.zsh")" = "$BPM_PACKAGES_PATH/$pkg/completion/c1.zsh" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compsys//c2.zsh")" = "$BPM_PACKAGES_PATH/$pkg/completions/c2.zsh" ]
}

@test "do not add zsh completions from heuristics when ZSH_COMPLETIONS is specified in package.sh" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'ZSH_COMPLETIONS=""' > 'package.sh'
		mkdir 'completion'
		touch "completion/prog.zsh"
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/zsh/compctl/prog.zsh" ]
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/zsh/compsys/prog.zsh" ]
}

@test "do not add zsh completions from heuristics when completionDirs is specified in bpm.toml" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "dirr" ]' > 'bpm.toml'
		mkdir 'completion'
		touch "completion/prog.zsh"
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/zsh/compctl/prog.zsh" ]
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/zsh/compsys/prog.zsh" ]
}
