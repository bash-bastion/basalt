# Reference

## Environment Variables

### `BPM_ROOT`

The location of the root `bpm` folder. Defaults to `"${XDG_DATA_HOME:-$HOME/.local/share}/bpm"`

### `BPM_FULL_CLONE`

Set to `true` to clone the full repo history instead of only the last commit (useful for package development)

### `BPM_PREFIX`

Set the installation and package checkout prefix (default is `$BPM_ROOT/cellar`).  Setting this to `/usr/local`, for example, will install binaries to `/usr/local/bin`, manpages to `/usr/local/man`, completions to `/usr/local/completions`, and clone packages to `/usr/local/packages`.  This allows you to manage "global packages", distinct from individual user packages.

## `bpm.toml`

Use `bpm.toml` for more fine grained control of where `bpm` searches for binaries, completions, and man pages

### `dependencies`

### `binFiles`

### `binDirs`

### `completionFiles`

### `completionDirs`

### `manFiles`

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
