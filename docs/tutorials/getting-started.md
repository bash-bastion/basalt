# Getting Started

(TODO: add output for functions)
(TODO: only provide output for newly added files?)

Succinctly, basalt is a fancy combination of `curl`, `tar xaf` and `ln -s`. It clones repositories (usually in the form of tarballs), and puts all of its man pages, completion scripts, and binaries in common folders. Let's see it in action.

This page assumes you have completed the [Installation](./installation.md) properly.

## Installing an executable

For this demonstration, we're going to install and use [bash2048](JosefZIla/bash2048). Note that this will still work, even if Zsh or Fish is your default shell.

```sh
$ basalt global add github.com/JosefZIla/bash2048
```

This does the following:

- Clones `JosefZIla/bash2048` to a temporary directory
- Extracts the latest commit into a tarball to `$BASALT_GLOBAL_DATA_DIR/store/tarballs/github.com/JosefZIla/bash2048@37da5210d6d70713bc8630cf45c907102a53e3cf.tar.gz` using `git-archive(1)`
- Extracts the tarball to `$BASALT_GLOBAL_DATA_DIR/store/tarballs/github.com/JosefZIla/bash2048@37da5210d6d70713bc8630cf45c907102a53e3cf` using `tar(1)`
- Adds a symlink from the repository's `bash2048.sh` script to `$BASALT_GLOBAL_DATA_DIR/global/.basalt/packages/bin/bash2048.sh`

That's it - now you can use it!

```sh
$ bash2048.sh
Bash 2048 v1.1 (https://github.com/mydzor/bash2048) pieces=6 target=2048 score=60

/------+------+------+------\
|      |      |      |      |
|------+------+------+------|
|    4 |      |      |      |
|------+------+------+------|
|    2 |    2 |      |      |
|------+------+------+------|
|   16 |    8 |      |    2 |
\------+------+------+------/
```

## Install a Bash function

For the second demonstration, we're going to install [z](https://github.com/rupa/z). If you already have it installed, don't worry - it will be installed to a different location and you can remove it separately.

# TODO: have `@latest` which skips the latest release (since it could be outdated) and go straight to latest commit
```sh
$ basalt global add rupa/z
```

This does the following

- It clones and extracts similarly to `bash2048`, but instead of creating a symlink to `bash2048.sh`, it...
- Adds a symlink from the repository's `z.1` man page to `$BASALT_GLOBAL_DATA_DIR/global/.basalt/packages/man/man1/z.1`

Now, you can display the manual right away.

```sh
man z
```

You might also try to execute `z.sh`:

```sh
$ z
bash: z: command not found
$ z.sh
bash: z.sh: command not found
```

But it doesn't work - this is standard behavior. When looking for binaries, basalt _does_ look at the root directory, but only for shell scripts that are marked as _executable_ (`chmod +x z.sh`).

The authors of `z` did not mark the file as executable because they did not intend for you to execute the file - you are supposed to `source` it. This is why the `basalt.load` function exists. This function is available to you after running `basalt global init <shell>`.

```sh
$ basalt.load --global --dry github.com/rupa/z z.sh
Would have sourced file '/home/edwin/.local/share/basalt/global/.basalt/packages/github.com/rupa/z@v1.9/z.sh'
```

Now, use the `basalt-load` to source `z.sh`. Note that `z.sh` only supports either Bash or Zsh, so you need to currently be in one of those shells for this to work.

```sh
$ basalt.load --global github.com/rupa/z z.sh
$ z
common:    /tmp/tmp.MBF063fdlK/completions
29988      /tmp/tmp.MBF063fdlK/completions
```

Note that if `z` does not show output, that's normal. You may need to `cd` to some directories to build the database.

If you want to do this persistently, just add this to your `~/.bashrc` (or `~/.zshrc`).

## Remove packages

If you completed both previous steps, two packages should be installed.
```sh
$ basalt global list
```

Remove them with `remove`

```sh
$ basalt global remove \
  git@github.com:JosefZIla/bash2048 \
  https://github.com/rupa/z
$ basalt global list
```

# TODO: deprecate SSH urls (use `ssh://` instead)

Note that we specified the SSH URL and the HTTPS URL when removing. You can specify the package this way with all commands, including the `add`, `remove`, and `upgrade` commands.

And you are done! To learn more, check the `reference` and `how-to` directories.
