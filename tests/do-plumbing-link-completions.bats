#!/usr/bin/env bats

load 'util/init.sh'

@test "does not fail if there are no completions" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		:
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
}


## BASH ##

@test "adds bash completions determined from package.sh" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo "BASH_COMPLETIONS='ff/comp.bash'" > 'package.sh'
		mkdir 'ff'
		touch 'ff/comp.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/comp.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/ff/comp.bash" ]
}


@test "adds bash completions determined from package.sh (and not from heuristics)" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo "BASH_COMPLETIONS=" > 'package.sh'
		mkdir 'completions'
		touch 'completions/prof.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/bash/prof.bash" ]
}

@test "adds bash completions determined from bpm.toml" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "weird_completions" ]' > 'bpm.toml'
		mkdir 'weird_completions'
		touch 'weird_completions/comp.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/comp.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/weird_completions/comp.bash" ]
}

@test "adds bash completions determined from bpm.toml (and not from heuristics)" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "weird_completions" ]' > 'bpm.toml'
		mkdir 'completions'
		touch 'completions/prof.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/bash/prof.bash" ]
}

@test "adds bash completions determined with heuristics (./?(contrib/)completion?(s))" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		mkdir -p ./{contrib/,}completion{,s}
		touch "completion/c1.bash"
		touch "completions/c2.bash"
		touch "contrib/completion/c3.bash"
		touch "contrib/completions/c4.bash"
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c1.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/completion/c1.bash" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c2.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/completions/c2.bash" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c3.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/contrib/completion/c3.bash" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c4.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/contrib/completions/c4.bash" ]
}

@test "adds bash completions determined with heuristics (root directory)" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		mkdir 'etc'

		touch 'git-flow-completion.bash'
		touch 'etc/some-completion.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/git-flow-completion.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/git-flow-completion.bash" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/some-completion.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/etc/some-completion.bash" ]
}

@test "adds bash completions determined with heuristics (share/etc)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir -p 'share/bash-completion/completions'
		mkdir -p 'etc/bash_completion.d'

		touch 'share/bash-completion/completions/c1'
		touch 'share/bash-completion/completions/c2.sh'
		touch 'share/bash-completion/completions/c3.bash'
		touch 'etc/bash_completion.d/c4'
		touch 'etc/bash_completion.d/c5.sh'
		touch 'etc/bash_completion.d/c6.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c1.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/share/bash-completion/completions/c1" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c2.sh")" = "$BPM_PACKAGES_PATH/$site/$pkg/share/bash-completion/completions/c2.sh" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c3.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/share/bash-completion/completions/c3.bash" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c4.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/etc/bash_completion.d/c4" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c5.sh")" = "$BPM_PACKAGES_PATH/$site/$pkg/etc/bash_completion.d/c5.sh" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c6.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/etc/bash_completion.d/c6.bash" ]
}

@test "adds bash completions determined from heuristics when when ZSH_COMPLETIONS is specified in package.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'ZSH_COMPLETIONS=""' > 'package.sh'
		mkdir 'completion'
		touch "completion/prog.bash"
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ -f "$BPM_INSTALL_COMPLETIONS/bash/prog.bash" ]
}

@test "do not add bash completions from heuristics when BASH_COMPLETIONS is specified in package.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'BASH_COMPLETIONS=""' > 'package.sh'
		mkdir 'completion'
		touch "completion/prog.bash"
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/bash/prog.bash" ]
}

@test "do not add bash completions from heuristics when completionDirs is specified in bpm.toml" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "dirr" ]' > 'bpm.toml'
		mkdir 'completion'
		touch "completion/prog.bash"
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/bash/prog.bash" ]
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/bash/prog.bash" ]
}

@test "bash completions without file extension have an extension appended" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		mkdir -p 'share/bash-completion/completions'

		touch 'share/bash-completion/completions/seven'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/seven.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/share/bash-completion/completions/seven" ]

	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/bash/prog.bash" ]
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/bash/prog.bash" ]
}


## ZSH ##

@test "adds zsh compsys completions determined from package.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'ZSH_COMPLETIONS="dirr/_exec"' > 'package.sh'
		mkdir 'dirr'
		echo '#compdef' > "dirr/_exec"
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compsys/_exec")" = "$BPM_PACKAGES_PATH/$site/$pkg/dirr/_exec" ]
}

@test "adds zsh compctl completions determined from pacakge.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'ZSH_COMPLETIONS="dirr/exec"' > 'package.sh'
		mkdir 'dirr'
		touch "dirr/exec"
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/exec")" = "$BPM_PACKAGES_PATH/$site/$pkg/dirr/exec" ]
}

@test "adds zsh compsys completions determined from bpm.toml" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "dirr" ]' > 'bpm.toml'
		mkdir 'dirr'
		echo '#compdef' > "dirr/_exec.zsh"
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compsys/_exec.zsh")" = "$BPM_PACKAGES_PATH/$site/$pkg/dirr/_exec.zsh" ]
}

@test "adds zsh compctl completions determined from bpm.toml" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "dirr" ]' > 'bpm.toml'
		mkdir 'dirr'
		touch "dirr/exec.zsh"
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/exec.zsh")" = "$BPM_PACKAGES_PATH/$site/$pkg/dirr/exec.zsh" ]
}

@test "adds zsh completions determined with heuristics (./?(contrib/)completion?(s))" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		mkdir -p ./{contrib/,}completion{,s}
		touch "completion/c1.zsh"
		echo '#compdef' > "completions/c2.zsh"
		touch "contrib/completion/c3.zsh"
		echo '#compdef' > "contrib/completions/c4.zsh"
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/c1.zsh")" = "$BPM_PACKAGES_PATH/$site/$pkg/completion/c1.zsh" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compsys//c2.zsh")" = "$BPM_PACKAGES_PATH/$site/$pkg/completions/c2.zsh" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/c3.zsh")" = "$BPM_PACKAGES_PATH/$site/$pkg/contrib/completion/c3.zsh" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compsys//c4.zsh")" = "$BPM_PACKAGES_PATH/$site/$pkg/contrib/completions/c4.zsh" ]
}

@test "adds zsh completions determined with heuristics (root directory)" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		mkdir 'etc'

		touch 'git-flow-completion.zsh'
		touch 'etc/some-completion.zsh'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/git-flow-completion.zsh")" = "$BPM_PACKAGES_PATH/$site/$pkg/git-flow-completion.zsh" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/some-completion.zsh")" = "$BPM_PACKAGES_PATH/$site/$pkg/etc/some-completion.zsh" ]
}

@test "adds zsh completions determined from heuristics when when BASH_COMPLETIONS is specified in package.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'BASH_COMPLETIONS=""' > 'package.sh'
		mkdir completion{,s}
		touch "completion/c1.zsh"
		echo '#compdef' > "completions/c2.zsh"
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/c1.zsh")" = "$BPM_PACKAGES_PATH/$site/$pkg/completion/c1.zsh" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compsys//c2.zsh")" = "$BPM_PACKAGES_PATH/$site/$pkg/completions/c2.zsh" ]
}

@test "do not add zsh completions from heuristics when ZSH_COMPLETIONS is specified in package.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'ZSH_COMPLETIONS=""' > 'package.sh'
		mkdir 'completion'
		touch "completion/prog.zsh"
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/zsh/compctl/prog.zsh" ]
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/zsh/compsys/prog.zsh" ]
}

@test "do not add zsh completions from heuristics when completionDirs is specified in bpm.toml" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "dirr" ]' > 'bpm.toml'
		mkdir 'completion'
		touch "completion/prog.zsh"
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/zsh/compctl/prog.zsh" ]
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/zsh/compsys/prog.zsh" ]
}

@test "zsh completions without file extension have an extension appended" {
	skip
}


## FISH ##

@test "adds fish completions determined from bpm.toml" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "weird_completions" ]' > 'bpm.toml'
		mkdir 'weird_completions'
		touch 'weird_completions/comp.fish'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/fish/comp.fish")" = "$BPM_PACKAGES_PATH/$site/$pkg/weird_completions/comp.fish" ]
}

@test "adds fish completions determined from bpm.toml (and not from heuristics)" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "weird_completions" ]' > 'bpm.toml'
		mkdir 'completions'
		touch 'completions/prof.fish'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert_success [ ! -f "$BPM_INSTALL_COMPLETIONS/fish/prof.fish" ]
}

@test "adds fish completions determined with heuristics (./?(contrib/)completion?(s))" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		mkdir -p ./{contrib/,}completion{,s}
		touch "completion/c1.fish"
		touch "completions/c2.fish"
		touch "contrib/completion/c3.fish"
		touch "contrib/completions/c4.fish"
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/fish/c1.fish")" = "$BPM_PACKAGES_PATH/$site/$pkg/completion/c1.fish" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/fish/c2.fish")" = "$BPM_PACKAGES_PATH/$site/$pkg/completions/c2.fish" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/fish/c3.fish")" = "$BPM_PACKAGES_PATH/$site/$pkg/contrib/completion/c3.fish" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/fish/c4.fish")" = "$BPM_PACKAGES_PATH/$site/$pkg/contrib/completions/c4.fish" ]
}

@test "adds fish completions determined with heuristics (root directory)" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		mkdir 'etc'

		touch 'git-flow-completion.fish'
		touch 'etc/some-completion.fish'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/fish/git-flow-completion.fish")" = "$BPM_PACKAGES_PATH/$site/$pkg/git-flow-completion.fish" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/fish/some-completion.fish")" = "$BPM_PACKAGES_PATH/$site/$pkg/etc/some-completion.fish" ]
}

@test "do not add fish completions from heuristics when completionDirs is specified in bpm.toml" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "dirr" ]' > 'bpm.toml'
		mkdir 'completion'
		touch "completion/prog.fish"
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/fish/prog.fish" ]
	assert [ ! -f "$BPM_INSTALL_COMPLETIONS/fish/prog.fish" ]
}


## ALL ##

@test "adds completions for multiple shells from different directories with heuristics" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		mkdir 'completion' 'completions'
		touch 'completion/prog.fish'
		touch 'completion/prog1.bash'
		touch 'completions/prog2.bash'
		touch 'completions/prog.zsh'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/fish/prog.fish")" = "$BPM_PACKAGES_PATH/$site/$pkg/completion/prog.fish" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/prog1.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/completion/prog1.bash" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/prog2.bash")" = "$BPM_PACKAGES_PATH/$site/$pkg/completions/prog2.bash" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/prog.zsh")" = "$BPM_PACKAGES_PATH/$site/$pkg/completions/prog.zsh" ]
}

@test "fails bash link completions when specifying directory in package.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'BASH_COMPLETIONS="dir"' > 'package.sh'

		mkdir 'dir'
		touch 'dir/.gitkeep'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_failure
	assert_line -p "Specified directory 'dir' in package.sh; only files are valid"
}

@test "fails zsh link completions when specifying directory in package.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'ZSH_COMPLETIONS="dir"' > 'package.sh'

		mkdir 'dir'
		touch 'dir/.gitkeep'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_failure
	assert_line -p "Specified directory 'dir' in package.sh; only files are valid"
}


@test "warns bash link completions when specifying non-existent file in package.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'BASH_COMPLETIONS="some_file"' > 'package.sh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert_line -p "Completion file 'some_file' not found. Skipping"
}


@test "warns zsh link completions when specifying non-existent file in package.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'ZSH_COMPLETIONS="some_file"' > 'package.sh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert_line -p "Completion file 'some_file' not found. Skipping"
}

@test "warns link completions when specifying file in bpm.toml" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = ["dir"]' > 'bpm.toml'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert_line -p "Directory 'dir' with executable files not found. Skipping"
}

@test "warns link completions when specifying non-existent directory in bpm.toml" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = ["dir"]' > 'bpm.toml'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run do-plumbing-link-completions "$site/$pkg"

	assert_success
	assert_line -p "Directory 'dir' with executable files not found. Skipping"
}

@test "warns link bash completions if completion already exists" {
	local site='github.com'
	local pkg1="username/package"
	local pkg2='username/package2'

	test_util.setup_pkg "$pkg1"; {
		touch 'file2-completion.bash'
		chmod +x 'file2-completion.bash'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg1" "$site/$pkg1"

	test_util.setup_pkg "$pkg2"; {
		touch 'file2-completion.bash'
		chmod +x 'file2-completion.bash'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg2" "$site/$pkg2"

	do-plumbing-link-completions "$site/$pkg1"
	run do-plumbing-link-completions "$site/$pkg2"

	assert_success
	assert_line -p "Skipping 'file2-completion.bash' since an existing symlink with the same name already exists"
}

@test "warns link zsh compctl completions if completion already exists" {
	local site='github.com'
	local pkg1="username/package"
	local pkg2='username/package2'

	test_util.setup_pkg "$pkg1"; {
		touch 'file2-completion.zsh'
		chmod +x 'file2-completion.zsh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg1" "$site/$pkg1"

	test_util.setup_pkg "$pkg2"; {
		touch 'file2-completion.zsh'
		chmod +x 'file2-completion.zsh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg2" "$site/$pkg2"

	do-plumbing-link-completions "$site/$pkg1"
	run do-plumbing-link-completions "$site/$pkg2"

	assert_success
	assert_line -p "Skipping 'file2-completion.zsh' since an existing symlink with the same name already exists"
}

@test "warns link zsh compsys completions if completion already exists" {
	local site='github.com'
	local pkg1="username/package"
	local pkg2='username/package2'

	test_util.setup_pkg "$pkg1"; {
		echo '#compdef' > "file2-completion.zsh"
		chmod +x 'file2-completion.zsh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg1" "$site/$pkg1"

	test_util.setup_pkg "$pkg2"; {
		echo '#compdef' > "file2-completion.zsh"
		chmod +x 'file2-completion.zsh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg2" "$site/$pkg2"

	do-plumbing-link-completions "$site/$pkg1"
	run do-plumbing-link-completions "$site/$pkg2"

	assert_success
	assert_line -p "Skipping 'file2-completion.zsh' since an existing symlink with the same name already exists"
}

@test "warns link fish completions if completion already exists" {
	local site='github.com'
	local pkg1="username/package"
	local pkg2='username/package2'

	test_util.setup_pkg "$pkg1"; {
		touch "file2-completion.fish"
		chmod +x 'file2-completion.fish'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg1" "$site/$pkg1"

	test_util.setup_pkg "$pkg2"; {
		touch "file2-completion.fish"
		chmod +x 'file2-completion.fish'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg2" "$site/$pkg2"

	do-plumbing-link-completions "$site/$pkg1"
	run do-plumbing-link-completions "$site/$pkg2"

	assert_success
	assert_line -p "Skipping 'file2-completion.fish' since an existing symlink with the same name already exists"
}
