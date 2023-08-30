# `basalt.conf`

This is a complete reference to the `basalt.conf` file, found in Bash packages. There are currently two top-level objects: `package` and `run`.

Note that none of these options have any defaults, and arrays _**must**_ only span single lines.

## Configuration

There are two sections to the configuration:

1. `[package]`: Metadata that describes the package and its purpose.
2. `[run]`: Metadata that affects how the package is ran (either as a library or executable).

When the description of a configuration field mentions `a list`, it means the field can be specified multiples times. Internally, the field is represented as an array.

An example configuration is shown at the way end.

### `[package].type`

Required. The type of package. Currently, only `bash` is supported.

### `[package].name`

Required. The name of the package.

## `[package].namespace`

Required. The namespace used to prefix all functions.

### `[package].version`

Required. The current version of the package.

### `[package].author`

Required. A list of authors.

### `[package].description`

Required. The package description.

### `[run].dependency`

Optional. A list of dependencies.

By default, it's empty.

```conf
dependency = https://github.com/hyperupcall/bats-all@v4.6.0
dependency = https://github.com/hyperupcall/bash-core@v0.12.0
dependency = https://github.com/hyperupcall/bash-term@v0.6.3
dependency = https://github.com/hyperupcall/bash-utility@v0.4.0
```

### `[run].binDir`

Optional. A list of binary directories.

By default, it has a value of `pkg/bin`

Array of directories that contain executable files. Locally, these files will be symlinked under `.basalt/bin`; globally, these files wil be symlinked and available to the current user.

### `[run].sourceDir`

Optional. A list of directories to source files from.

By default, it's empty.

Each file in these directories are sourced during the initialization process. In other words, after a package calls `basalt.package-init`, Basalt will source each file in each directory, for each `sourceDir`, for each declared package dependency.

### `[run].builtinDir`

Optional. A list of directories to use as custom dynamic builtins.

By default, it has a value of `pkg/builtins`

Array of directories that contain C source code for custom dynamic builtins. These files will automatically be loaded, somewhat analogous to `sourceDirs`

### `[run].completionDir`

Optional. A list of directories to use as completion files.

By default, it has a value of `pkg/completions`

Array of directories that contain completion scripts. Locally, these files will be symlinked under `.basalt/completion`; globally, these files will automatically be made available to the shell after `basalt global init <shell>`

### `[run].manDir`

Optional. A list of directories that contain manpages.

By default, it has a value of `pkg/man`

It does not traverse subdirectories, including `man1`, `man3`, etc. These files will be symlinked under a `man` directory in `.basalt`. Currently, the `MANPATH` is not modified for global installations; the manpages should be detected automatically

### `[run.env].*`

Optional. An object of environment variables to inject into your application.

By default, it is empty. # TODO

```conf
[run.env]
LANG = C
LC_ALL = C
```

### `[run.setOptions].*`

Optional. An object of what shell options to enable or disable

By default, it is empty. # TODO

```conf
[run.setOptions]
errexit = on
pipefail = on
```

### `[run.shoptOptions].*`

Optional. An object of bash-specific shell options to enable or disable

By default, it is empty. # TODO

```conf
[run.shoptOptions]
extglob = on
nullglob = on
```

## Example Configuration

```conf
[package]
type = bash
name = woof
slug = woof
version = 0.4.0
author = Edwin Kofler <edwin@kofler.dev>
description = The version manager to end all version managers

[run]
dependency = https://github.com/hyperupcall/bats-all@v4.6.0
dependency = https://github.com/hyperupcall/bash-core@v0.12.0
dependency = https://github.com/hyperupcall/bash-term@v0.6.3
dependency = https://github.com/hyperupcall/bash-utility@v0.4.0
sourceDir = pkg/src/util
builtinDir = pkg/builtins
binDir = pkg/bin
completionDir = pkg/completions

[run.setOptions]
errexit = on
pipefail = on

[run.shoptOptions]
shift_verbose = on

```
