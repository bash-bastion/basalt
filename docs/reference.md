# Reference

## For Packages

After running `basalt-package-init`, the following variables and functions are accessible

### `BASALT_INTERNAL_DID_BASALT_INIT`

Internal variable that you should not mess with

### TODO

## Environment Variables

### `BASALT_LOCAL_PROJECT_DIR`

The location of the root `basalt` folder. Defaults to `"${XDG_DATA_HOME:-$HOME/.local/share}/basalt"`

### `BASALT_FULL_CLONE`

Set to a non-null string to clone the full repository history instead of only the last commit. By default, only the latest commit is cloned (`--depth=1`). The only exception to this is when a specific version is specified with `@v0.1.0` notation. When that is specified, the whole history is downloaded

### `BASALT_GLOBAL_CELLAR`

Set the installation and package checkout prefix (default is `$BASALT_LOCAL_PROJECT_DIR/cellar`).  Setting this to `/usr/local`, for example, will install binaries to `/usr/local/bin`, manpages to `/usr/local/man`, completions to `/usr/local/completions`, and clone packages to `/usr/local/packages`

## `basalt.toml`

Place a `basalt.toml` at the root of a repository to directly control where `basalt` searches for binaries, completions, and man pages for that repository. **Note** that arrays _must only_ span a single line (the line it was defined on) due to limitations with the TOML parser. This restriction should be lifted in the future. All relative paths are relative to their respective `basalt.toml` file

If any particular toml key is defined, it means automatic directory search with heuristics will not be performed. For example, if you define `binDirs`, `basalt` will only look for binaries that you specify in that array and will _not_ search `./bin`, `./bins`, etc.

### `dependencies`

Specify subdependencies of a particular project. These will be installed automatically when your repository is installed

### `binDirs`

Specify the directories to search for binary files (script executables)

##### Example

```sh
binDirs = [ './pkg/bin' ]
```

### `binRemoveExtensions`

Set to `yes` to to remove the extension when symlinking. For example, if a file in a repository was at `./bin/git-list-all-aliases.sh`, it would be sylinked with a filename of `git-list-all-aliases`

##### Example

```sh
binRemoveExtensions = 'yes'
```

TODO: replace the option with a boolean. Do NOT use this option since it will become a boolean option

### `completionDirs`

Specify the directories to search for completion files

```sh
completionDirs = [ './my-completions' ]
```

### `manDirs`

Specify the directories to search for man files

```sh
manDirs = [ './manuals' ]
```

## `package.sh`

This file is an alternative configuration mechanism kept to preserve backwards compatibility with [Basher](https://github.com/basherpm/basher). If you create a `basalt.toml` file, then `package.sh` will NOT be read

Similar to `basalt.toml`, specifying a particular key will cause basalt not to automatically search for files specific to that key. For example, if `BASH_COMPLETIONS` is specified, basalt will no longer search for _Bash_ completions in `./completion`, `./completions`, etc.

Note that unlike Basher, basalt does not source this file. It performs single-line regular expression matching and splits the capturing group into an array with `IFS=: read -ra`. This was changed to prevent arbitrary code execution by child packages during the installation process

Example

```sh
BINS="folder/file1:folder/file2.sh"
DEPS="user1/repo1:user2/repo2"
BASH_COMPLETIONS="completions/package"
ZSH_COMPLETIONS="completions/_package"
```

### `BINS`

Colon separates list of binaries

### `DEPS`

Colon separated list of dependencies

### `BASH_COMPLETIONS`

Colon separates list of Bash completions

### `ZSH_COMPLETIONS`

Colon separated list of Zsh completions
