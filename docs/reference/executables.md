# Executables

When creating a Bash application, executables are placed in `./pkg/bin/<NAME>`. There are two ways this file can properly execute its corresponding file in `./pkg/src/bin/<NAME>.sh`; an new way and an old way.

## New Way

```sh
#!/usr/bin/env bash

eval "$(basalt-package-init --no-assert-version woof)"
main.woof "$@"
```

The new way _must_ have at least one argument to `basalt-package-init`. There are also optional flags, which must come first:

### `--no-assert-version`

Do not print an error and exit Bash if the minimum Bash version cannot be met. Instead, don't source any dependencies, only run the executable. This is useful if you want an escape hatch from the default behavior if Bash is not the latest version.

## Old Way

The old way exists for backwards compatibility and is not recommended. Please migrate to the more succinct method as the old way may be removed in the future.

```sh
# shellcheck shell=bash

eval "$(basalt-package-init)"
basalt.package-init || exit
basalt.package-load

. "$BASALT_PACKAGE_DIR/pkg/src/bin/shelltest.sh"
main.shelltest "$@"
```
