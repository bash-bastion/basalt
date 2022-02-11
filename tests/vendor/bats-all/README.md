# bats-all

An aggregation of the three most popular [Bats](https://github.com/bats-core/bats-core) utility libraries

- [bats-core/bats-support](https://github.com/bats-core/bats-support)
- [bats-core/bats-assert](https://github.com/bats-core/bats-assert)
- [bats-core/bats-file](https://github.com/bats-core/bats-file)

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to add this project as a dependency

```sh
basalt add hyperupcall/bats-alls
```

If you are using Basalt, you need to source this project manually (`basalt.load 'github.com/hyperupcall/bats-alls' 'load.bash'`) within your tests. Entries are not added to this projects' `sourceDirs` because that would mean this library would be sourced, even when not testing

Of course, if you're not using Basalt, you can use something like `git-submodule(1)`

## Merged Changes

The repositories are managed with `git-subtree(1)`. Each subtree points to my fork of each respective project. This is done so I can add features, since the repositories at bats-core don't seem actively maintained. My forks are

- [hyperupcall/bats-support](https://github.com/hyperupcall/bats-support)
- [hyperupcall/bats-assert](https://github.com/hyperupcall/bats-assert)
- [hyperupcall/bats-file](https://github.com/hyperupcall/bats-file)

All tracked changes are in [./issues.md](./issues.md). Right now, at least two changes have been integrated

## License

Original code is licensed under `CC0-1.0`. Modifications are licensed under `BSD-3-Clause`
