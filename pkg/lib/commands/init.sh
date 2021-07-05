# shellcheck shell=bash

print_fish_variables() {
	cat <<EOF
set -gx BASHER_SHELL $shell
set -gx BASHER_ROOT $BASHER_ROOT
set -gx BASHER_PREFIX $BASHER_PREFIX
set -gx BASHER_PACKAGES_PATH $BASHER_PACKAGES_PATH

if not contains \$BASHER_ROOT/cellar/bin \$PATH
	set -gx PATH \$BASHER_ROOT/cellar/bin \$PATH
end
EOF
	}

print_sh_variables(){
	cat <<EOF
export BASHER_SHELL=$shell
export BASHER_ROOT=$BASHER_ROOT
export BASHER_PREFIX=$BASHER_PREFIX
export BASHER_PACKAGES_PATH=$BASHER_PACKAGES_PATH

if [ "\${PATH#*\$BASHER_ROOT/cellar/bin}" = "\$PATH" ]; then
	export PATH="\$BASHER_ROOT/cellar/bin:\$PATH"
fi
EOF
}

print_bash_completions() {
	cat <<"EOF"
for f in $(command ls "$BASHER_ROOT/cellar/completions/bash"); do
	source "$BASHER_ROOT/cellar/completions/bash/$f"
done
EOF
}

print_zsh_completions() {
	cat <<"EOF"
fpath=("$BASHER_ROOT/cellar/completions/zsh/compsys" $fpath)
for f in $(command ls "$BASHER_ROOT/cellar/completions/zsh/compctl"); do
	source "$BASHER_ROOT/cellar/completions/zsh/compctl/$f"
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
if [ -f "\$BASHER_ROOT/lib/include.$shell" ]; then
	. "\$BASHER_ROOT/lib/include.$shell"
fi

if [ -f "\$BASHER_ROOT/completions/basher.$shell" ]; then
	. "\$BASHER_ROOT/completions/basher.$shell"
fi
EOF
}
