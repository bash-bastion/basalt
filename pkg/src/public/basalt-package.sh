# shellcheck shell=bash

# Contains functions only usable in Basalt packages (i.e. this file is sourced by 'basalt.package-init')
# Since calling these functions are only valid in a fresh Bash context, we can use 'exit 1'

basalt.package-load() {
	local __basalt_shopt_nullglob=

	if [ -z "${BASALT_PACKAGE_DIR:-}" ]; then
		printf '%s\n' "Error: basalt.package-load: Variable '\$BASALT_PACKAGE_DIR' is empty" >&2
		exit 1
	fi

	# These checks always ensure the generated files are in sync the 'basalt.toml'
	if [ ! -f "$BASALT_PACKAGE_DIR/.basalt/generated/done.sh" ]; then
		printf '%s\n' "Error: basalt.package-load: Command 'basalt install' must be ran again in '$BASALT_PACKAGE_DIR'" >&2
		exit 1
	fi

	# BSD `date(1)` does not have '-r'
	local basalt_file_last_modified_at= done_file_last_modified_at=
	basalt_file_last_modified_at=$(stat --format '%Y' "$BASALT_PACKAGE_DIR/basalt.toml")
	done_file_last_modified_at=$(stat --format '%Y' "$BASALT_PACKAGE_DIR/.basalt/generated/done.sh")
	if ((basalt_file_last_modified_at >= done_file_last_modified_at)); then # '>=' so automated 'basalt install' work on fast computers
		printf '%s\n' "Error: basalt.package-load: Command 'basalt install' must be ran again in '$BASALT_PACKAGE_DIR'" >&2
		exit 1
	fi

	if shopt -q nullglob; then
		__basalt_shopt_nullglob='yes'
	else
		__basalt_shopt_nullglob='no'
	fi
	shopt -s nullglob

	# This can be made cleaner with glob expansion in arrays, but the code is fine as it is,
	# especially for larger dependency hierarchies
	local __basalt_site= __basalt_repository_owner=  __basalt_package=
	if [ -d "$BASALT_PACKAGE_DIR"/.basalt/packages ]; then
		for __basalt_site in "$BASALT_PACKAGE_DIR"/.basalt/packages/*/; do
			local __basalt_site_basename="${__basalt_site%/}"
			__basalt_site_basename="${__basalt_site_basename##*/}"

			# Source local packages
			if [ "$__basalt_site_basename" = 'local' ]; then
				for __basalt_package in "$__basalt_site"*/; do
					if [ "$__basalt_shopt_nullglob" = 'yes' ]; then
						shopt -s nullglob
					else
						shopt -u nullglob
					fi

					if [ -f "$__basalt_package.basalt/generated/source_all.sh" ]; then
						if BASALT_PACKAGE_DIR=$__basalt_package source "$__basalt_package.basalt/generated/source_all.sh"; then :; else
							printf '%s\n' "Error: basalt.package-load: Could not successfully source 'source_all.sh'" >&2
							return $?
						fi
					fi

					shopt -s nullglob # TODO:
				done; unset -v __basalt_package
				continue
			fi
			unset -v __basalt_site_basename

			# Source regular packages
			for __basalt_repository_owner in "$__basalt_site"*/; do
				for __basalt_package in "$__basalt_repository_owner"*/; do
					if [ "$__basalt_shopt_nullglob" = 'yes' ]; then
						shopt -s nullglob
					else
						shopt -u nullglob
					fi

					if [ -f "$__basalt_package.basalt/generated/source_all.sh" ]; then
						if BASALT_PACKAGE_DIR=$__basalt_package source "$__basalt_package.basalt/generated/source_all.sh"; then :; else
							printf '%s\n' "Error: basalt.package-load: Could not successfully source 'source_all.sh'" >&2
							return $?
						fi
					fi

					shopt -s nullglob # TODO: unecessary and can put at bottom?
				done; unset -v __basalt_package
			done; unset -v __basalt_repository_owner
		done; unset -v __basalt_site
	fi

	if [ "$__basalt_shopt_nullglob" = 'yes' ]; then
		shopt -s nullglob
	else
		shopt -u nullglob
	fi

	if [ -f "$BASALT_PACKAGE_DIR/.basalt/generated/source_all.sh" ]; then
		# shellcheck disable=SC1091
		source "$BASALT_PACKAGE_DIR/.basalt/generated/source_all.sh"
	fi

	unset __basalt_shopt_nullglob
}
