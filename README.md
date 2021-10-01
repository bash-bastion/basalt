# basalt

`basalt` is the ultimate Bash (and Zsh, Fish, etc.) Package Manager

STATUS: BETA (expect breaking changes until a post-beta release)

---

`basalt` is a fork of [basher](https://github.com/basherpm/basher) that adds a _ton_ of new functionality. It makes it significantly easier to install Bash, Zsh, etc. projects to your computer. Often, these projects/scripts are _not_ available through official `apt`, `DNF`, `pacman` repositories, or even from unofficial sources like third-party apt repositories or the [AUR](https://aur.archlinux.org)

Let's say you want to install [rupa/z](https://github.com/rupa/z), [tj/git-extras](https://github.com/tj/git-extras), [aristocratos/bashtop](https://github.com/aristocratos/bashtop), and [JosefZIla/bash2048](https://github.com/JosefZIla/bash2048). Simply run the following

```sh
$ basalt global add rupa/z tj/git-extras aristocratos/bashtop JosefZIla/bash2048
```

This symlinks all executable scripts to a common directory. It does this for completion files and man pages as well

```sh
$ exa -l --no-permissions --no-filesize --no-user ~/.local/share/basalt/global/bin/
bash2048.sh -> /home/edwin/.local/share/basalt/store/packages/github.com/JosefZIla/bash2048/bash2048.sh
bashtop -> /home/edwin/.local/share/basalt/store/packages/github.com/aristocratos/bashtop/bashtop
git-alias -> /home/edwin/.local/share/basalt/store/packages/github.com/tj/git-extras/bin/git-alias
git-archive-file -> /home/edwin/.local/share/basalt/store/packages/github.com/tj/git-extras/bin/git-archive-file
...
```

To be able to access the binaries, completion files, and man pages in your shell, simply add a two-liner in your shell configuration

```sh
# ~/.bashrc
export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source/pkg/bin:$PATH"
eval "$(basalt init bash)" # zsh and fish are also supported
```

See [Installation](./docs/tutorials/installation.md) and [Getting Started](./docs/tutorials/getting-started.md) for more details


## Features

Note that many of these features have been implemented before, but require a reimplementation since the major rewrite

- [x] Lockfile usage
- [ ] Transaction rollback
- [ ] Works with essentially all popular Bash projects out of the box
- [ ] Specifying specific man, completion, etc. directories
- [x] Local package installation
- [x] Global (user-wide) package installation
- [ ] Custom builtins

## Ecosystem

There is a small, but growing number of packages installable with Basalt. See the list at [awesome-bash-packages](https://github.com/hyperupcall/awesome-bash-packages)
