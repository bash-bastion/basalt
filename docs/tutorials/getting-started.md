# Getting Started

***NOTE***: Warning: THIS TUTORIAL IS OUT OF DATE (TODO)

***NOTE***: `basalt` is currently BETA quality. I would _highly_ recommend waiting to try out Basalt (TODO)

Succinctly, basalt is a fancy combination of `git clone` and `ln -s`. It clones a repositories, and puts all of its man pages, completion scripts, and binaries in common folders. Let's see it in action

This page assumes you have completed the [Installation](./installation.md) properly

## Installing an executable

For this demonstration, we're going to install and use [bash2048](JosefZIla/bash2048). Note that this will still work, even if Zsh or Fish is your default shell

```sh
$ basalt global add github.com/JosefZIla/bash2048
Info: Adding 'github.com/JosefZIla/bash2048'
  -> Cloning Git repository
  -> Symlinking bin files
```

This does the following

- Clones `JosefZIla/bash2048` to `$HOME/.local/share/basalt/packages/github.com/JosefZIla/bash2048`
- Adds a symlink from the repository's `bash2048.sh` script to `$HOME/.local/share/basalt/bin/bash2048.sh`

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

For the second demonstration, we're going to install [z](https://github.com/rupa/z). If you already have it installed, don't worry - it will be installed to a different location and you can remove it separately

```sh
$ basalt global add rupa/z
Info: Adding 'rupa/z'
  -> Cloning Git repository
  -> Symlinking man files
```

This does the following

- Clones `z` to `$HOME/.local/share/basalt/packages/github.com/rupa/z`
- Adds a symlink from the repository's `z.1` man page to `$HOME/.local/share/basalt/man/man1/z.1`

Now, you can display the manual right away

```sh
man z
```

You might also try to execute `z.sh`

```sh
$ z
bash: z: command not found
$ z.sh
bash: z.sh: command not found
```

But it doesn't work - this is standard behavior. When looking for binaries, basalt _does_ look at the root directory, but only for shell scripts that are marked as _executable_ (`chmod +x z.sh`)

The authors of `z` did not mark the file as executable because they did not intend for you to execute the file - you are supposed to `source` it. This is why the `basalt-load` command exists

```sh
$ basalt-load global --dry rupa/z z.sh
basalt-load: Would source file '/home/edwin/data/basalt/packages/github.com/rupa/z/z.sh'
```

Now, use the `basalt-load` to source `z.sh`. Note that `z.sh` only supports either Bash or Zsh, so you need to currently be in one of those shells for this to work.

```sh
$ basalt-load global 'rupa/z' 'z.sh'
$ z
common:    /tmp/tmp.MBF063fdlK/completions
29988      /tmp/tmp.MBF063fdlK/completions
```

Note that if `z` does not show output, that's normal. You may need to `cd` to some directories to build the database

If you want to do this persistantly, just add this to your `~/.bashrc` (or `~/.zshrc`).

## Remove packages

If you completed both previous steps, two packages should be installed
```sh
$ basalt global list
github.com/JosefZIla/bash2048
  Branch: master
  Revision: 37da521
  State: Up to date
github.com/rupa/z
  Branch: master
  Revision: b82ac78
  State: Up to date
```

Remove them with `remove`

```sh
$ basalt global remove \
  git@github.com:JosefZIla/bash2048 \
  https://github.com/rupa/z
$ basalt global list
```

Note that we specified the SSH URL and the HTTPS URL when removing. You can specify the package this way with all commands, including the `add`, `remove`, and `upgrade` commands

And you are done! To learn more, check the `reference` and `how-to` directories
