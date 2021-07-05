# shellcheck shell=bash

print_fish_variables() {
	cat <<EOF
set -gx BASHER_SHELL $shell
set -gx NEOBASHER_ROOT $NEOBASHER_ROOT
set -gx NEOBASHER_PREFIX $NEOBASHER_PREFIX
set -gx NEOBASHER_PACKAGES_PATH $NEOBASHER_PACKAGES_PATH

if not contains \$NEOBASHER_ROOT/cellar/bin \$PATH
	set -gx PATH \$NEOBASHER_ROOT/cellar/bin \$PATH
end
EOF
	}

print_sh_variables(){
	cat <<EOF
export BASHER_SHELL=$shell
export NEOBASHER_ROOT=$NEOBASHER_ROOT
export NEOBASHER_PREFIX=$NEOBASHER_PREFIX
export NEOBASHER_PACKAGES_PATH=$NEOBASHER_PACKAGES_PATH

if [ "\${PATH#*\$NEOBASHER_ROOT/cellar/bin}" = "\$PATH" ]; then
	export PATH="\$NEOBASHER_ROOT/cellar/bin:\$PATH"
fi
EOF
}

print_bash_completions() {
	cat <<"EOF"
for f in $(command ls "$NEOBASHER_ROOT/cellar/completions/bash"); do
	source "$NEOBASHER_ROOT/cellar/completions/bash/$f"
done
EOF
}

print_zsh_completions() {
	cat <<"EOF"
fpath=("$NEOBASHER_ROOT/cellar/completions/zsh/compsys" $fpath)
for f in $(command ls "$NEOBASHER_ROOT/cellar/completions/zsh/compctl"); do
	source "$NEOBASHER_ROOT/cellar/completions/zsh/compctl/$f"
done
EOF
}

basher-init() {
	local shell="$1"

	if [ -z "$shell" ]; then
		die "Shell not specified"
	fi

	case "$shell" in
	fish)
		print_fish_variables
		;;
	bash)
		print_sh_variables
		print_bash_completions
		;;
	zsh)
		print_sh_variables
		print_zsh_completions
		;;
	*)
		print_sh_variables
		;;
	esac

	cat <<EOF
if [ -f "\$NEOBASHER_ROOT/lib/include.$shell" ]; then
	. "\$NEOBASHER_ROOT/lib/include.$shell"
fi

if [ -f "\$NEOBASHER_ROOT/completions/basher.$shell" ]; then
	. "\$NEOBASHER_ROOT/completions/basher.$shell"
fi
EOF
}
