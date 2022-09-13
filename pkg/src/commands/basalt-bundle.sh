# shellcheck shell=bash

basalt-bundle() {
	local dir="$1"

	local project_dir=
	if [ -z "$dir" ]; then
		util.init_local
		project_dir=$BASALT_LOCAL_PROJECT_DIR
	fi

	local final_dir="./output"
	rm -rf "$final_dir"
	mkdir -p "$final_dir"

	basalt-install

	cp "$project_dir/basalt.toml" "$final_dir"
	sleep 1

	cp -r --preserve=all "$project_dir/pkg" "$final_dir/pkg" || :
	rm -rf "$final_dir/share/bin"

	# if ! (cd "$final_dir" && basalt-install); then
	# 	print.die "Failed to run 'basalt install'"
	# fi

	if bash_toml.quick_array_get "$project_dir/basalt.toml" 'package.binDirs'; then
		local -a bin_dirs="${REPLY[@]}"

		if ((${#bin_dirs[@]} == 0)); then
			print.die "binDirs must have a non-zero length"
		fi

		local dir=
		for dir in "${bin_dirs[@]}"; do
			for file in "$dir"/*; do
				if [ ! -f "$file" ]; then
					continue
				fi

				local file_name="${file##*/}"
				local bin_file="$final_dir/bin/$file_name"
				mkdir -p "${bin_file%/*}"

				if ! util.init_package_print > "$bin_file"; then
					print.die "Failed to write to file: $bin_file"
				fi
				if ! printf '%s\n' "
export BASALT_BUNDLED=yes
basalt.package-init || exit
basalt.package-load

source \"\$BASALT_PACKAGE_DIR/pkg/src/bin/woof.sh\"
main.woof \"\$@\"" >> "$bin_file"; then
					print.die "Failed to write to file: $bin_file"
				fi


				if ! chmod +x "$bin_file"; then
					print.die "Failed to 'chmod +x' file: $bin_file"
				fi

			done; unset -v file
		done; unset -v dir
	else
		print.die "Only pacakges with 'binDirs' defined can be bundlable"
	fi

	if bash_toml.quick_array_get "$project_dir/basalt.toml" 'package.dependencies'; then
		local -a source_dirs="${REPLY[@]}"
	else
		print.die "To use 'basalt version', a you must have a 'version' field set to at least an empty string"
	fi

	if bash_toml.quick_array_get "$project_dir/basalt.toml" 'package.sourceDirs'; then
		local -a source_dirs="${REPLY[@]}"
	else
		print.die "To use 'basalt version', a you must have a 'version' field set to at least an empty string"
	fi
}
