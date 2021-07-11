# Getting Started

Succinctly, bpm is a fancy combination of `git clone` and `ln -s`. It clones a repositories, and puts all of its man pages, completion scripts, and binaries in common folders. Let's see it in action

## Installing a simple package

For this demonstration, we're going to install and use [bash2048](JosefZIla/bash2048). Note that this will still work, even if Zsh or Fish is your default shell

```sh
bpm --global add github.com/JosefZIla/bash2048
```

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
# Globally install z
bpm --global add rupa/z
```

As you can see, if you do not include the domain, it automatically uses github.com

This clones `z` to `$HOME/.local/share/bpm/cellar/packages/github.com/rupa/z`

It adds a symlink from the repository's `z.1` man page to `$HOME/.local/share/bpm/cellar/man/man1/z.1`

Now, (assuming you completed [Installation](./installation.md) properly), you can display the manual right away

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

But it doesn't work - this is standard behavior. When looking for binaries, bpm _does_ look at the root directory, but only symlinks shell scripts that are marked as _executable_ (`chmod +x z.sh`)

The authors of `z` did not mark the file as executable because they did not intend for you to execute the file - you are supposed to `source` it. This is why the `package-path` command exists:

```sh
$ bpm --global package-path z.sh
/home/username/bpm/cellar/packages/rupa/z
```

Now, use the `package-path` to source `z.sh`. Note that `z.sh` only supports either Bash or Zsh, so you need to currently be in one of those shells for this to work

```sh
$ source "$(bpm --global package-path rupa/z)/z.sh"
$ z
common:    /tmp/tmp.MBF063fdlK/completions
29988      /tmp/tmp.MBF063fdlK/completions
```

Note that if `z` does not show output, that's normal. You may need to `cd` to some directories to build the database

If you want to do this persistantly, just add this to your `~/.bashrc` (or `~/.zshrc`).

## Remove packages

If you completed boht previous steps, two packages should be installed
```sh
$ bpm --global list
github.com/JosefZIla/bash2048
github.com/rupa/z
```

Remove them with `remove`

```sh
$ bpm --global remove \
  git@github.com:JosefZIla/bash2048 \
  https://github.com/rupa/z
$ bpm --global list
```

Note that we specified the SSH URL and the HTTPS URL when removing. You can specify the package this way with all commands, including the `add`, `package-path`, and `upgrade` commands

And you are done! To learn more, see [Recepies](./.recepies.md), [Reference](./reference.md), or [Tips](./tips.md)
