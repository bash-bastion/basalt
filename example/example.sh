# shellcheck shell=bash

for f in ./pkg/src/{public,util}/*.sh; do
	# shellcheck disable=SC1090
	source "$f"
done; unset -v f

# bash_toml.quick_array_get './basalt.toml' 'run.dependencies'
# for j in "${REPLY[@]}"; do
# 	printf '%s     ' "$j"
# done
# printf '\n'

# bash_toml.quick_array_append './basalt.toml' 'run.dependencies' 'rawrrrr'
# printf '%s' "$REPLY"

# bash_toml.quick_array_remove './basalt.toml' 'run.dependencies' 'https://github.com/hyperupcall/bats-all@v4.3.0'
# printf '%s' "$REPLY"

# bash_toml.quick_array_replace './basalt.toml' 'run.dependencies' 'https://github.com/hyperupcall/bats-all@v4.3.0' 'uwu'
# printf '%s' "$REPLY"

bash_toml.quick_object_get './basalt.toml' 'run.setOptions'
for key in "${!REPLY[@]}"; do
	echo "$key: ${REPLY[$key]}"
done
