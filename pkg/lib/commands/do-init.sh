# shellcheck shell=bash

echo_posix_shell_variables() {
	cat <<-EOF
	# bpm variables
	export BPM_ROOT="$BPM_ROOT"
	export BPM_PREFIX="$BPM_PREFIX"
	export BPM_PACKAGES_PATH="$BPM_PACKAGES_PATH"

	# bpm packages PATH
	if [ "\${PATH#*\$BPM_ROOT/cellar/bin}" = "\$PATH" ]; then
	  export PATH="\$BPM_ROOT/cellar/bin:\$PATH"
	fi

	EOF
}

# For each shell, items are printed in order
# - Setting bpm variables
# - Setting bpm package PATH
# - Sourcing bpm package completion
# - Sourcing bpm completion
# - Sourcing 'include' function
do-init() {
	local shell="$1"

	if [ -z "$shell" ]; then
		die "Shell not specified"
	fi

	# Set common bpm variables; add PATH
	case "$shell" in
	fish)
		cat <<-EOF
		# bpm variables
		set -gx BPM_ROOT $BPM_ROOT
		set -gx BPM_PREFIX $BPM_PREFIX
		set -gx BPM_PACKAGES_PATH $BPM_PACKAGES_PATH

		# bpm packages PATH
		if not contains \$BPM_ROOT/cellar/bin \$PATH
		  set -gx PATH \$BPM_ROOT/cellar/bin \$PATH
		end

		EOF
		;;
	bash)
		echo_posix_shell_variables
		cat <<-"EOF"
		# bpm packages completions
		for f in "$BPM_ROOT"/cellar/completions/bash/?*.{sh,bash}; do
		  source "$f"
		done
		unset f

		EOF
		;;
	zsh)
		echo_posix_shell_variables
		cat <<-"EOF"
		# bpm packages completions
		fpath=("$BPM_ROOT/cellar/completions/zsh/compsys" $fpath)
		for f in "$BPM_ROOT"/cellar/completions/zsh/compctl/?*.zsh; do
		  source "$f"
		done
		unset f

		EOF
		;;
	sh)
		echo_posix_shell_variables
		;;
	*)
		cat <<-EOF
		echo "Error: Shell '$shell' is not a valid shell"
		EOF
		exit 1
	esac

	cat <<-EOF
	# bpm completions
	if [ -f "\$BPM_ROOT/pkg/completions/bpm.$shell" ]; then
	  . "\$BPM_ROOT/pkg/completions/bpm.$shell"
	fi

	# bpm include
	if [ -f "\$BPM_ROOT/pkg/share/include.$shell" ]; then
	  . "\$BPM_ROOT/pkg/share/include.$shell"
	fi

	EOF
}
