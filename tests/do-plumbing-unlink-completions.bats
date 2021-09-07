#!/usr/bin/env bats

load 'util/init.sh'

@test "unlinks bash completions determined from package.sh" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'BASH_COMPLETIONS="somedir/comp.bash"' > 'package.sh'
		mkdir 'somedir'
		touch 'somedir/comp.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert [ -L "$BPM_INSTALL_COMPLETIONS/bash/comp.bash" ]

	run plumbing.unsymlink-completions "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/bash/comp.bash" ]
}

@test "unlinks bash completions determined from bpm.toml" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "somedir" ]' > 'bpm.toml'
		mkdir 'somedir'
		touch 'somedir/comp.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert [ -L "$BPM_INSTALL_COMPLETIONS/bash/comp.bash" ]

	run plumbing.unsymlink-completions "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/bash/comp.bash" ]
}

@test "unlinks bash completions determined from heuristics (completion?(s) directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir -p 'completions' 'completion'
		touch 'completions/comp.bash'
		touch 'completion/comp2.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert [ -L "$BPM_INSTALL_COMPLETIONS/bash/comp.bash" ]
	assert [ -L "$BPM_INSTALL_COMPLETIONS/bash/comp2.bash" ]

	run plumbing.unsymlink-completions "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/bash/comp.bash" ]
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/bash/comp2.bash" ]
}

@test "unlinks bash completions determined from heuristics (contrib/completion?(s) directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir -p contrib/completion{,s}
		touch 'contrib/completion/comp.bash'
		touch 'contrib/completions/comp2.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert [ -L "$BPM_INSTALL_COMPLETIONS/bash/comp.bash" ]
	assert [ -L "$BPM_INSTALL_COMPLETIONS/bash/comp2.bash" ]

	run plumbing.unsymlink-completions "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/bash/comp.bash" ]
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/bash/comp2.bash" ]
}

@test "unlinks zsh completions determined from package.sh" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'ZSH_COMPLETIONS="somedir/_comp1.zsh:otherdir/_comp3.zsh"' > 'package.sh'
		mkdir 'somedir' 'otherdir'
		touch 'somedir/_comp1.zsh'
		echo '#compdef' > 'otherdir/_comp3.zsh'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert [ -L "$BPM_INSTALL_COMPLETIONS/zsh/compctl/_comp1.zsh" ]
	assert [ -L "$BPM_INSTALL_COMPLETIONS/zsh/compsys/_comp3.zsh" ]

	run plumbing.unsymlink-completions "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/zsh/compctl/_comp1.zsh" ]
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/zsh/compsys/_comp3.zsh" ]
}

@test "unlinks zsh completions determined from bpm.toml" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "somedir", "otherdir" ]' > 'bpm.toml'
		mkdir 'somedir' 'otherdir'
		touch 'somedir/_comp1.zsh'
		echo '#compdef' > 'otherdir/_comp3.zsh'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert [ -L "$BPM_INSTALL_COMPLETIONS/zsh/compctl/_comp1.zsh" ]
	assert [ -L "$BPM_INSTALL_COMPLETIONS/zsh/compsys/_comp3.zsh" ]

	run plumbing.unsymlink-completions "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/zsh/compctl/_comp1.zsh" ]
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/zsh/compsys/_comp3.zsh" ]
}

@test "unlinks zsh completions determined from heuristics (completion?(s) directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir -p completion{,s}
		touch 'completion/_comp.zsh'
		echo '#compdef' > 'completions/_comp2.zsh'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert [ -L "$BPM_INSTALL_COMPLETIONS/zsh/compctl/_comp.zsh" ]
	assert [ -L "$BPM_INSTALL_COMPLETIONS/zsh/compsys/_comp2.zsh" ]

	run plumbing.unsymlink-completions "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/zsh/compctl/_comp.zsh" ]
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/zsh/compsys/_comp2.zsh" ]
}

@test "unlinks zsh completions determined from heuristics (contrib/completion?(s) directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir -p contrib/completion{,s}
		touch 'contrib/completion/_comp.zsh'
		echo '#compdef' > 'contrib/completions/_comp2.zsh'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert [ -L "$BPM_INSTALL_COMPLETIONS/zsh/compctl/_comp.zsh" ]
	assert [ -L "$BPM_INSTALL_COMPLETIONS/zsh/compsys/_comp2.zsh" ]

	run plumbing.unsymlink-completions "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/zsh/compctl/_comp.zsh" ]
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/zsh/compsys/_comp2.zsh" ]
}

@test "bpm.toml has presidence over package.sh unlink completions" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'BASH_COMPLETIONS="otherdir/c.bash"' > 'package.sh'
		mkdir 'otherdir'
		touch 'otherdir/c.bash'

		echo 'completionDirs = [ "somedir" ]' > 'bpm.toml'
		mkdir 'somedir'
		touch 'somedir/comp.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert [ ! -L "$BPM_INSTALL_COMPLETIONS/bash/c.bash" ]
	assert [ -L "$BPM_INSTALL_COMPLETIONS/bash/comp.bash" ]

	run plumbing.unsymlink-completions "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_COMPLETIONS/bash/comp.bash" ]
}
