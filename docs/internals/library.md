# Bash

## Package Characteristics

All usages of a package require that package's `bin` directory to be added to the path

## Usage as a binary

If a particular bin file of a package is meant to be used as a binary, it should look like this. Since it's going to be executing, the shebang is being added for the kernel. Using `main` is highly recommended. Do NOT name the function name with the same name as the executable, as this is reserved for libraries. `main` implies that the entrypoint will be executed within its own shell context, and that there is no worry that another Bash function will be named `main`. This works because libraries do NOT define `main`, and other binaries are executed in their own shell context, so there is no interference

### Definition

For a file called `bash-args` in the `PATH`

```sh
#!/usr/bin/env bash

main() {
	:
}

main "$@"
```

### Callsite

The execution context of the callsite can be within either a binary or a library

```sh
basalt install hyperupcall/bash-args
```

## Usage as a library

For a file called `bash-toml` in the `PATH`

### Definition

```sh
# shellcheck shell=bash

bash-toml() {
	:
}
```

### Callsite

The execution context of the callsite can be within either a binary or a library

```sh
# Note that `basalt` provides a useful interface that skips this. Note that `bash-toml` HERE is the
# _name of the package_, rather than the name of the binary
basalt-load 'bash-toml'

declare -gA OBJ=([zulu]=yankee)

basalt-toml get-string 'OBJ' 'zulu'

assert [ "$REPLY" = yankee ]
```

## Importing

This applies for _both_ libraries and binaries. `main_fn_name` must either be `main`, or the name of the file, depending on whether the file is meant to be used as a binary or file

### Binary

```sh
#!/usr/bin/env bash

ROOT_DIR="$(dirname "$0")"

source "$ROOT_DIR/util/util.sh"
source "$ROOT_DIR/util/commands.sh"

main() {
	:
}
```

### Library

Since everything from library will be loaded in the global scope, we have to make sure the variable names do not clobber

```sh
# shellcheck shell=bash

ROOT_BASH_BENCH="$(dirname "${BASH_SOURCE[0]}")"

source "$ROOT_BASH_BENCH/util/util.sh"
source "$ROOT_BASH_BENCH/util/commands.sh"

bash-toml() {
	:
}
```

## Testing

Testing, especially Bash programs is a must. The previous structure will make working with tests work as well

## Future Development

Later, it would be good to have some equivalent of automatically sourcing the necessary files and adding the correct path.

Also good to have `library` and `binary` files be in different directories
