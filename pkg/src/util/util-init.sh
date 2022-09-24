# shellcheck shell=bash

# @description Initialize variables required for non-global subcommands
util.init_local() {
	util.init_global

	local local_project_root_dir=
	if local_project_root_dir="$(
		while [ ! -f 'basalt.toml' ] && [ "$PWD" != / ]; do
			if ! cd ..; then
				return 1
			fi
		done

		if [ "$PWD" = / ]; then
			return 1
		fi

		printf '%s' "$PWD"
	)"; then
		# shellcheck disable=SC2034
		BASALT_LOCAL_PROJECT_DIR="$local_project_root_dir"
	else
		print.die "Could not find a 'basalt.toml' file"
	fi
}

# @description Check for the initialization of variables essential for global subcommands
util.init_global() {
	if [ -z "$BASALT_GLOBAL_REPO" ] || [ -z "$BASALT_GLOBAL_DATA_DIR" ]; then
		print.die "Either 'BASALT_GLOBAL_REPO' or 'BASALT_GLOBAL_DATA_DIR' is empty. Did you forget to run add 'basalt global init <shell>' in your shell configuration?"
	fi

	if ! command -v curl &>/dev/null; then
		print.die "Program 'curl' not installed. Please install curl"
	fi
	if ! command -v md5sum &>/dev/null; then
		print.die "Program 'md5sum' not installed. Please install md5sum"
	fi

	if [ ! -d "$BASALT_GLOBAL_REPO" ]; then
		mkdir -p "$BASALT_GLOBAL_REPO"
	fi
	if [ ! -d "$BASALT_GLOBAL_DATA_DIR/global" ]; then
		mkdir -p "$BASALT_GLOBAL_DATA_DIR/global"
	fi
	if [ ! -d "$BASALT_GLOBAL_DATA_DIR/store" ]; then
		mkdir -p "$BASALT_GLOBAL_DATA_DIR/store"
	fi
	if [ ! -f "$BASALT_GLOBAL_DATA_DIR/global/dependencies" ]; then
		touch "$BASALT_GLOBAL_DATA_DIR/global/dependencies"
	fi
	if [ ! -d "$BASALT_GLOBAL_DATA_DIR/store/packages/local" ]; then
		mkdir -p "$BASALT_GLOBAL_DATA_DIR/store/packages/local"
	fi

	# I would prefer to check the existence of the target directory as well, but that would mean if the user installs
	# a package that creates for example a 'completion' directory, it would not show up until 'basalt' is executed again
	if [ ! -L "$BASALT_GLOBAL_DATA_DIR/global/bin" ]; then
		ln -sf "$BASALT_GLOBAL_DATA_DIR/global/.basalt/packages/bin" "$BASALT_GLOBAL_DATA_DIR/global/bin"
	fi
	if [ ! -L "$BASALT_GLOBAL_DATA_DIR/global/completion" ]; then
		ln -sf "$BASALT_GLOBAL_DATA_DIR/global/.basalt/packages/completion" "$BASALT_GLOBAL_DATA_DIR/global/completion"
	fi
	if [ ! -L "$BASALT_GLOBAL_DATA_DIR/global/man" ]; then
		ln -sf "$BASALT_GLOBAL_DATA_DIR/global/.basalt/packages/man" "$BASALT_GLOBAL_DATA_DIR/global/man"
	fi
}

util.init_lock() {
	if [ -z "$BASALT_GLOBAL_REPO" ] || [ -z "$BASALT_GLOBAL_DATA_DIR" ]; then
		print.die "Either 'BASALT_GLOBAL_REPO' or 'BASALT_GLOBAL_DATA_DIR' is empty. Did you forget to run add 'basalt global init <shell>' in your shell configuration?"
	fi

	# Use a lock directory for Basalt if not under testing
	if [ -z "$BATS_TMPDIR" ]; then
		___basalt_lock_dir=
		if [ -n "$XDG_RUNTIME_DIR" ]; then
			___basalt_lock_dir="$XDG_RUNTIME_DIR/basalt.lock"
		else
			___basalt_lock_dir="$BASALT_GLOBAL_DATA_DIR/basalt.lock"
		fi
		if mkdir "$___basalt_lock_dir" 2>/dev/null; then
			trap 'util.init_deinit' INT TERM EXIT
		else
			print.die "Cannot run Basalt at this time because another Basalt process is already running (lock directory '$___basalt_lock_dir' exists)"
		fi
	fi
}

util.init_deinit() {
	rm -rf "$___basalt_lock_dir"
}

util.init_print_package_init() {
	local basalt_global_repo="$1"

	cat <<EOF
basalt.package-init() {
	# basalt variables
	export BASALT_GLOBAL_REPO="$basalt_global_repo"
EOF
	cat <<"EOF"
	export BASALT_GLOBAL_DATA_DIR="${BASALT_GLOBAL_DATA_DIR:-"${XDG_DATA_HOME:-$HOME/.local/share}/basalt"}"

	if [ -z "$BASALT_GLOBAL_DATA_DIR" ]; then
		printf '%s\n' "Error: basalt.package-init: Variable '\$BASALT_GLOBAL_DATA_DIR' is empty" >&2
		exit 1
	fi

	# basalt global and internal functions
	if [ ! -f "$BASALT_GLOBAL_REPO/pkg/src/public/basalt-global.sh" ]; then
		printf '%s\n' "Error: basalt.package-init: Failed to find file 'basalt-global.sh' in '\$BASALT_GLOBAL_REPO'" >&2
		exit 1
	fi
	source "$BASALT_GLOBAL_REPO/pkg/src/public/basalt-global.sh"

	if [ ! -f "$BASALT_GLOBAL_REPO/pkg/src/public/basalt-package.sh" ]; then
		printf '%s\n' "Error: basalt.package-init: Failed to find file 'basalt-package.sh' in '\$BASALT_GLOBAL_REPO'" >&2
		exit 1
	fi
	source "$BASALT_GLOBAL_REPO/pkg/src/public/basalt-package.sh"

	if [ -z "${BASALT_PACKAGE_DIR:-}" ]; then
		local __old_cd="$PWD"

		# Do not use "$0", since it won't work in some environments, such as Bats
		local __basalt_file="${BASH_SOURCE[0]}"
		if [ -L "$__basalt_file" ]; then
			local __basalt_target="$(readlink "$__basalt_file")"
			if ! cd "${__basalt_target%/*}"; then
				printf '%s\n' "Error: basalt.package-init: Could not cd to '${__basalt_target%/*}'" >&2
				exit 1
			fi
		else
			if ! cd "${__basalt_file%/*}"; then
				printf '%s\n' "Error: basalt.package-init: Could not cd to '${__basalt_file%/*}'" >&2
				exit 1
			fi
		fi

		# Note that this variable should not be exported. It can cause weird things to occur. For example,
		# if a Basalt local package called a command from a global package, things won't work since
		# 'BASALT_PACKAGE_DIR' would already be defined and won't be properly set for the global package
		if ! BASALT_PACKAGE_DIR="$(
			while [ ! -f 'basalt.toml' ] && [ "$PWD" != / ]; do
				if ! cd ..; then
					exit 1
				fi
			done

			if [ "$PWD" = / ]; then
				exit 1
			fi

			printf '%s' "$PWD"
		)"; then
			printf '%s\n' "Error: basalt.package-init: Could not find basalt.toml" >&2
			if ! cd "$__old_cd"; then
				printf '%s\n' "Error: basalt.package-init: Could not cd back to '$__old_cd'" >&2
				exit 1
			fi
			exit 1
		fi

		if ! cd "$__old_cd"; then
			printf '%s\n' "Error: basalt.package-init: Could not cd back to '$__old_cd'" >&2
			exit 1
		fi
	fi
}
EOF
}
