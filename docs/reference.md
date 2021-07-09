# Reference

## Environment Variables

### `BPM_ROOT`

The location of the root `bpm` folder. Defaults to `"${XDG_DATA_HOME:-$HOME/.local/share}/bpm"`

### `BPM_FULL_CLONE`

Set to a non-null string to clone the full repo history instead of only the last commit (useful for package development)

### `BPM_PREFIX`

Set the installation and package checkout prefix (default is `$BPM_ROOT/cellar`).  Setting this to `/usr/local`, for example, will install binaries to `/usr/local/bin`, manpages to `/usr/local/man`, completions to `/usr/local/completions`, and clone packages to `/usr/local/packages`.  This allows you to manage "global packages", distinct from individual user packages.

## `bpm.toml`

Use `bpm.toml` for more fine grained control of where `bpm` searches for binaries, completions, and man pages. _Note_ that arrays _must only_ span a single line (the line it was defined on) due to limitations with the toml parser. This should be lifted in the future

### `dependencies`

### `binDirs`

### `binRemoveExtensions`

TODO: make boolean option

Set to the string `yes` to remove extensions when linking bins

For example if a file in a repository was at `./bin/git-list-all-aliases.sh`, it would be linked and you would call it as `git-list-all-aliases`

### `completionDirs`

### `manDirs`

## `package.sh`

Use `package.sh` to customize how `bpm` searches for executables and completions. Note that this is only kept for backwards-compatability with `bpm` - you should use `bpm.toml` instead



Example

```sh
BINS="folder/file1:folder/file2.sh"
DEPS="user1/repo1:user2/repo2"
BASH_COMPLETIONS="completions/package"
ZSH_COMPLETIONS="completions/_package"
```

### `BINS`

Colon separated list of executable files. BINS specified in this fashion have higher precedence then the inference rules above

### `DEPS`

Colon separated list of dependencies

### `BASH_COMPLETIONS`

Colon separates list of Bash completions

### `ZSH_COMPLETIONS`

Colon separated list of Zsh completions
