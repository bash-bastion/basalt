# bpm

`bpm` is the ultimate Bash (and Zsh, Fish, etc.) Package Manager

---

`bpm` is a fork of [basher](https://github.com/basherpm/basher) that adds a _ton_ of new functionality. It makes it significantly easier to install Bash, Zsh, etc. projects to your computer. Often, these projects / scripts are _not_ available through official `apt`, `DNF`, `pacman` repositories, or even from unofficial sources like third party apt repositories or the [AUR](https://aur.archlinux.org)

Let's say you want to install [rupa/z](https://github.com/rupa/z), [tj/git-extras](https://github.com/tj/git-extras), [aristocratos/bashtop](https://github.com/aristocratos/bashtop), and [JosefZIla/bash2048](https://github.com/JosefZIla/bash2048). Simply run the following (as you can see, many formats are supported)

```sh
$ bpm install \
  rupa/z \
  github.com/tj/git-extras \
  https://github.com/aristocratos/bashtop \
  git@github.com:JosefZIla/bash2048
```

This symlinks all executable scripts to a common directory. It does this for completion files and man pages as well

```sh
$ ls -l --color=always ~/.local/share/bpm/cellar/bin/
... bash2048.sh -> /home/edwin/.local/share/bpm/cellar/packages/JosefZIla/bash2048/bash2048.sh
... bashtop -> /home/edwin/.local/share/bpm/cellar/packages/aristocratos/bashtop/bashtop
... git-alias -> /home/edwin/.local/share/bpm/cellar/packages/tj/git-extras/bin/git-alias
... git-archive-file -> /home/edwin/.local/share/bpm/cellar/packages/tj/git-extras/bin/git-archive-file
...
```

If you want to automatically add the bin directory to your path, source the completion files, and add the man pages to your man path, simply add a two-liner in your shell configuration

```sh
export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/bpm/source/pkg/bin:$PATH"
eval "$(bpm init bash)" # replace 'bash' with your shell
```

See [Getting Started](./docs/getting-started.md) for more details

## Alternatives Comparison

Why not use `bpkg` or `Basher`? Because `bpm`...

- Can install multiple packages at once
- Does not use a `package.json` that clobbers with NPM's `package.json` (bpkg)
- Does not automatically invoke `make` commands on your behalf (bpkg)
- Does not automatically source a `package.sh` for package configuration (basher)
- Is able to install more repositories
- Respects the XDG Base Directory specification (bpkg)
- Is faster (bpm considers exec and subshell creation overhead)
- Has a _much_ improved help output (basher)
- Prints why a command failed, rather than just printing the help menu (basher)
- Has actually been updated recently
- Better bpm completion scripts
- More flexibly parses command line arguments (basher)

I originally created a [different](https://github.com/eankeen/shell-installer) Shell package manager but later abandoned it. When I _really_ needed the functionality, I forked Basher because it had an excellent test suite and its behavior for installing packages actually made sense, compared to `bpkg`
