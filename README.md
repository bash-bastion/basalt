# basalt

The rock-solid Bash package manager

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
bash2048.sh -> .../.local/share/basalt/store/packages/github.com/JosefZIla/bash2048@.../bash2048.sh
bashtop -> .../.local/share/basalt/store/packages/github.com/aristocratos/bashtop@.../bashtop
git-alias -> .../.local/share/basalt/store/packages/github.com/tj/git-extras@.../bin/git-alias
git-archive-file -> .../.local/share/basalt/store/packages/github.com/tj/git-extras@.../bin/git-archive-file
...
```

To be able to access the binaries, completion files, and man pages in your shell, simply add a two-liner in your shell configuration. The [installation script](./scripts/install.sh) already does this for you

```sh
# ~/.bashrc
export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source/pkg/bin:$PATH"
eval "$(basalt global init bash)" # zsh and fish are also supported
```

***NOTE***: Basalt is currently BETA. There are known bugs that will be fixed. I _highly_ recommended to wait until `v1.0.0` before trying anything out

See [Installation](./docs/tutorials/installation.md) and [Getting Started](./docs/tutorials/getting-started.md) for more details

## Features

- Install most Bash/Zsh/Fish projects out of the box
- Local Bash packages (Awk/Zsh/Fish/Ksh,Powershell coming later)
- Custom builtins for Bash packages (not yet implemented)
- Robust (lockfile usage, transaction rollback (not yet implemented), great error handling)
- Bundle (bundle a project and its dependencies into a single file) (not yet implemented)

## Ecosystem

Because of Basalt, I've been able to make

- [Woof](https://github.com/hyperupcall/woof) - The version manager to end all version managers (replaces pyenv, nvm, rbenv etc.)
- [shtest](https://github.com/hyperupcall/shtest) - POSIX shell test runner (like Bats for POSIX shell)
- [bash-object](https://github.com/hyperupcall/bash-object) - Primitives for object oriented Bash (manipulate heterogenous data hierarchies in Bash)

See the full list [awesome-basalt](https://github.com/hyperupcall/awesome-basalt)

## License

Original code is licensed under `MIT` by Juan Ibiapina. Modifications are licensed under `BSD-3-Clause` by Edwin Kofler
