# shellcheck shell=bash

basalt-init() {
	local flag_type=
	local -a args=()
	local arg=
	for arg; do case $arg in
	--type*)
		IFS='=' read -r _ flag_type <<< "$arg"
		;;
	-*)
		print.die "Flag '$arg' not recognized"
		;;
	*)
		args+=("$arg")
		;;
	esac; done; unset -v arg

	if ((${#args[@]} == 0)); then
		print.die 'An initialization directory must be specified'
	fi

	if ((${#args[@]} > 1)); then
		print.die 'Only one initialization directory may be specified'
	fi

	local dir="${args[0]}"
	case $flag_type in
	'')
		print.die "Must specify the '--type' flag"
		;;
	app)
		ensure.cd "$dir"

		if [ -f './basalt.toml' ]; then
			print.die "A package already exists at '$dir'"
		fi

		if ! cp -r "$BASALT_GLOBAL_REPO/pkg/share/templates/bare-app/." .; then
			print.die "Failed 'cp' command"
		fi

		printf '%s' 'New Project Slug: '
		local template_slug=
		read -re template_slug

		if ! mv './pkg/bin/TEMPLATE_SLUG' "./pkg/bin/$template_slug"; then
			print.die "Failed 'mv' command"
		fi

		if ! chmod +x "./pkg/bin/$template_slug"; then
			print.die "Failed 'chmod' command"
		fi

		if ! mv './pkg/src/bin/TEMPLATE_SLUG.sh' "./pkg/src/bin/$template_slug.sh"; then
			print.die "Failed 'mv' command"
		fi

		if ! sed -i -e "s/TEMPLATE_SLUG/$template_slug/g" \
			'./basalt.toml' \
			"./pkg/bin/$template_slug" \
			"./pkg/src/bin/$template_slug.sh" \
			'./tests/util/init.sh' \
			'./tests/test_alfa.bats'; then
			print.die "Failed 'sed' command"
		fi

		;;
	lib)
		ensure.cd "$dir"

		if [ -f './basalt.toml' ]; then
			print.die "A package already exists at '$dir'"
		fi

		if ! cp -r "$BASALT_GLOBAL_REPO/pkg/share/templates/bare-lib/." .; then
			print.die "Failed 'cp' command"
		fi

		printf '%s' 'New Project Slug: '
		local template_slug=
		read -re template_slug

		if ! mv './pkg/src/public/TEMPLATE_SLUG.sh' "./pkg/src/public/$template_slug.sh"; then
			print.die "Failed 'mv' command"
		fi

		if ! sed -i -e "s/TEMPLATE_SLUG/$template_slug/g" \
			'./basalt.toml' \
			"./pkg/src/public/$template_slug.sh" \
			'./tests/test_alfa.bats'; then
			print.die "Failed 'sed' command"
		fi


		;;
	*)
		print.die "Type '$flag_type' not recognized. Only 'app' and 'lib' are supported"
	esac

	sleep 2 # Timestamps are (usually) second-accurate
	basalt install
}
