# Reference

## Environment Variables

### `BPM_ROOT`

The location of the root `bpm` folder. Defaults to `"${XDG_DATA_HOME:-$HOME/.local/share}/bpm"`

### `BPM_FULL_CLONE`

Set to a non-null string to clone the full repository history instead of only the last commit. By default, only the latest commit is cloned (`--depth=1`). The only exception to this is when a specific version is specified with `@v0.1.0` notation. When that is specified, the whole history is downloaded

### `BPM_PREFIX`

Set the installation and package checkout prefix (default is `$BPM_ROOT/cellar`).  Setting this to `/usr/local`, for example, will install binaries to `/usr/local/bin`, manpages to `/usr/local/man`, completions to `/usr/local/completions`, and clone packages to `/usr/local/packages`

## `bpm.toml`

Place a `bpm.toml` at the root of a repository to directly control where `bpm` searches for binaries, completions, and man pages for that repository. **Note** that arrays _must only_ span a single line (the line it was defined on) due to limitations with the TOML parser. This restriction should be lifted in the future

If any particular toml key is defined, it means automatic directory search with heuristics will not be performed. For example, if you define `binDirs`, `bpm` will only look for binaries that you specify in that array and will _not_ search `./bin`, `./bins`, etc.

### `dependencies`

Specify subdependencies of a particular project. These will be installed automatically when your repository is installed

### `binDirs`

Specify the directories to search for binary files (script executables)

##### Example

```sh
binDirs = [ './pkg/bin' ]
```

### `binRemoveExtensions`

Set to `yes` to to remove the extension when symlinking. For example if a file in a repository was at `./bin/git-list-all-aliases.sh`, it would be sylinked with a filename of `git-list-all-aliases`

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

This file is an alternative configuration mechanism kept to preserve backwards compatibility with [Basher](https://github.com/basherpm/basher). If you create a `bpm.toml` file, then `package.sh` will NOT be read

Similar to `bpm.toml`, specifying a particular key will cause bpm not to automatically search for files specific to that key. For example, if `BASH_COMPLETIONS` is specified, bpm will no longer search for _Bash_ completions in `./completion`, `./completions`, etc.

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
