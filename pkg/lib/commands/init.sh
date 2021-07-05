# shellcheck shell=bash

print_sh_variables(){
	cat <<-EOF
	export BPM_ROOT="$BPM_ROOT"
	export BPM_PREFIX="$BPM_PREFIX"
	export BPM_PACKAGES_PATH="$BPM_PACKAGES_PATH"

	if [ "\${PATH#*\$BPM_ROOT/cellar/bin}" = "\$PATH" ]; then
	  export PATH="\$BPM_ROOT/cellar/bin:\$PATH"
	fi

	EOF
}

basher-init() {
	local shell="$1"

	if [ -z "$shell" ]; then
		die "Shell not specified"
	fi

	# Set common bpm variables; add PATH
	case "$shell" in
	fish)
		cat <<-EOF
		set -gx BPM_ROOT $BPM_ROOT
		set -gx BPM_PREFIX $BPM_PREFIX
		set -gx BPM_PACKAGES_PATH $BPM_PACKAGES_PATH

		if not contains \$BPM_ROOT/cellar/bin \$PATH
		  set -gx PATH \$BPM_ROOT/cellar/bin \$PATH
		end
		EOF
		;;
	bash)
		print_sh_variables
		cat <<-"EOF"
		for f in $(command ls "$BPM_ROOT/cellar/completions/bash"); do
		  source "$BPM_ROOT/cellar/completions/bash/$f"
		done

		EOF
		;;
	zsh)
		print_sh_variables
		cat <<-"EOF"
		fpath=("$BPM_ROOT/cellar/completions/zsh/compsys" $fpath)
		for f in $(command ls "$BPM_ROOT/cellar/completions/zsh/compctl"); do
		  source "$BPM_ROOT/cellar/completions/zsh/compctl/$f"
		done

		EOF
		;;
	sh)
		print_sh_variables
		;;
	*)
		cat <<-EOF
		echo "Error: Shell '$shell' is not a valid shell"
		EOF
		exit 1
	esac

	# Include and completion
	cat <<-EOF
	if [ -f "\$BPM_ROOT/pkg/lib/share/include.$shell" ]; then
	  . "\$BPM_ROOT/pkg/lib/share/include.$shell"
	fi

	if [ -f "\$BPM_ROOT/pkg/completions/bpm.$shell" ]; then
	  . "\$BPM_ROOT/pkg/completions/bpm.$shell"
	fi
	EOF

	# TODO: Man?
}
