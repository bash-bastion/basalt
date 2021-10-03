# shellcheck shell=bash

# This function is only usable by those who executed 'basalt-package-init'

basalt.package-load() {
	local __basalt_shopt_nullglob=

	if [ -z "${BASALT_PACKAGE_PATH:-}" ]; then
		printf '%s\n' "Error: basalt.package-load: Variable 'BASALT_PACKAGE_PATH' is empty"
		return 1
	fi

	if shopt -q nullglob; then
		__basalt_shopt_nullglob='yes'
	else
		__basalt_shopt_nullglob='no'
	fi
	shopt -s nullglob

	local __basalt_site= __basalt_repository_owner=  __basalt_package=
	for __basalt_site in "$BASALT_PACKAGE_PATH"/.basalt/packages/*; do
		for __basalt_repository_owner in "$__basalt_site"/*; do
			for __basalt_package in "$__basalt_repository_owner"/*; do
				if [ "$__basalt_shopt_nullglob" = 'yes' ]; then
					shopt -s nullglob
				else
					shopt -u nullglob
				fi

				if [ -f "$__basalt_package/.basalt/generated/source-package.sh" ]; then
					source "$__basalt_package/.basalt/generated/source-package.sh"
				fi

				shopt -s nullglob
			done
		done
	done
	unset __basalt_site __basalt_repository_owner __basalt_package

	if [ -f "$BASALT_PACKAGE_PATH/.basalt/generated/source-package.sh" ]; then
		source "$BASALT_PACKAGE_PATH/.basalt/generated/source-package.sh"
	fi

	if [ "$__basalt_shopt_nullglob" = 'yes' ]; then
		shopt -s nullglob
	else
		shopt -u nullglob
	fi
}
