# shellcheck shell=bash

do-init() {
	local flag_type=
	local -a args=()
	local arg=
	for arg; do case $arg in
	--type*)
		IFS='=' read -r _ flag_type <<< "$arg"
		;;
	-*)
		bprint.die "Flag '$arg' not recognized"
		;;
	*)
		args+=("$arg")
		;;
	esac; done; unset -v arg

	if ((${#args[@]} == 0)); then
		bprint.die "An initialization directory must be specified"
	fi

	if ((${#args[@]} > 1)); then
		bprint.die "Only one initialization directory may be specified"
	fi

	local dir="${args[0]}"
	case $flag_type in
	'')
		bprint.die "Must specify the '--type' flag"
		;;
	app)
		ensure.cd "$dir"

		if [ -f './basalt.toml' ]; then
			bprint.die "A package already exists at '$dir'"
		fi

		if ! cp -r "$BASALT_GLOBAL_REPO/pkg/share/templates/bare-app/." .; then
			bprint.die "Failed 'cp' command"
		fi

		printf '%s' 'New Project Slug: '
		local template_slug=
		read -re template_slug

		if ! mv './bin/TEMPLATE_SLUG' "./bin/$template_slug"; then
			bprint.die "Failed 'mv' command"
		fi
		if ! mv './pkg/src/cmd/TEMPLATE_SLUG.sh' "./pkg/src/cmd/$template_slug.sh"; then
			bprint.die "Failed 'mv' command"
		fi

		if ! sed -i -e "s/TEMPLATE_SLUG/$template_slug/g" \
			'./basalt.toml' \
			"./bin/$template_slug" \
			"./pkg/src/cmd/$template_slug.sh" \
			'./tests/util/init.sh' \
			'./tests/test_alfa.bats'; then
			bprint.die "Failed 'sed' command"
		fi

		sleep 2 # Timestamps are (usually) second-accurate
		basalt install
		;;
	lib)
		ensure.cd "$dir"

		if [ -f './basalt.toml' ]; then
			bprint.die "A package already exists at '$dir'"
		fi

		if ! cp -r "$BASALT_GLOBAL_REPO/pkg/share/templates/bare-lib/." .; then
			bprint.die "Failed 'cp' command"
		fi

		printf '%s' 'New Project Slug: '
		local template_slug=
		read -re template_slug

		if ! mv './pkg/src/public/TEMPLATE_SLUG.sh' "./pkg/src/public/$template_slug.sh"; then
			bprint.die "Failed 'mv' command"
		fi

		if ! sed -i -e "s/TEMPLATE_SLUG/$template_slug/g" \
			'./basalt.toml' \
			"./pkg/src/public/$template_slug.sh" \
			'./tests/test_alfa.bats'; then
			bprint.die "Failed 'sed' command"
		fi

		sleep 2 # Timestamps are (usually) second-accurate
		basalt install
		;;
	*)
		bprint.die "Type '$flag_type' not recognized. Only 'app' and 'lib' are supported"
	esac
}
