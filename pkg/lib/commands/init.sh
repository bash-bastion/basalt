# shellcheck shell=bash

print_sh_variables(){
	cat <<-EOF
	export NEOBASHER_ROOT="$NEOBASHER_ROOT"
	export NEOBASHER_PREFIX="$NEOBASHER_PREFIX"
	export NEOBASHER_PACKAGES_PATH="$NEOBASHER_PACKAGES_PATH"

	if [ "\${PATH#*\$NEOBASHER_ROOT/cellar/bin}" = "\$PATH" ]; then
	  export PATH="\$NEOBASHER_ROOT/cellar/bin:\$PATH"
	fi

	EOF
}

basher-init() {
	local shell="$1"

	if [ -z "$shell" ]; then
		die "Shell not specified"
	fi

	# Set common neobasher variables; add PATH
	case "$shell" in
	fish)
		cat <<-EOF
		set -gx NEOBASHER_ROOT $NEOBASHER_ROOT
		set -gx NEOBASHER_PREFIX $NEOBASHER_PREFIX
		set -gx NEOBASHER_PACKAGES_PATH $NEOBASHER_PACKAGES_PATH

		if not contains \$NEOBASHER_ROOT/cellar/bin \$PATH
		  set -gx PATH \$NEOBASHER_ROOT/cellar/bin \$PATH
		end
		EOF
		;;
	bash)
		print_sh_variables
		cat <<-"EOF"
		for f in $(command ls "$NEOBASHER_ROOT/cellar/completions/bash"); do
		  source "$NEOBASHER_ROOT/cellar/completions/bash/$f"
		done

		EOF
		;;
	zsh)
		print_sh_variables
		cat <<-"EOF"
		fpath=("$NEOBASHER_ROOT/cellar/completions/zsh/compsys" $fpath)
		for f in $(command ls "$NEOBASHER_ROOT/cellar/completions/zsh/compctl"); do
		  source "$NEOBASHER_ROOT/cellar/completions/zsh/compctl/$f"
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
	if [ -f "\$NEOBASHER_ROOT/pkg/lib/share/include.$shell" ]; then
	  . "\$NEOBASHER_ROOT/pkg/lib/share/include.$shell"
	fi

	if [ -f "\$NEOBASHER_ROOT/pkg/completions/neobasher.$shell" ]; then
	  . "\$NEOBASHER_ROOT/pkg/completions/neobasher.$shell"
	fi
	EOF

	# TODO: Man?
}
