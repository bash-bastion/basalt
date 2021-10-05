# bats-common-utils

An aggregation of the three most popular [Bats](https://github.com/bats-core/bats-core) utility libraries

- [bats-core/bats-support](https://github.com/bats-core/bats-support)
- [bats-core/bats-assert](https://github.com/bats-core/bats-assert)
- [bats-core/bats-file](https://github.com/bats-core/bats-file)

Full file history of the projects has been preserved (facilitated with `git merge --allow-unrelated-histories`)

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to add this project as a dependency

```sh
basalt add hyperupcall/bats-common-utils
```

Note that if you are using Basalt, you need to source this project manually (`basalt.load 'github.com/hyperupcall/bats-common-utils' 'load.bash'`) within your tests. Adding entries to `sourceDirs` would mean the testing functions would get sourced even when not testing

If you don't wish to use Basalt, the `load.bash` file has been modified to work with this repository structure

## Roadmap

- Address issues and merge PR's from both `bats-assert` and `bats-file`

## License

Original code is licensed under `CC0-1.0`. Modifications are licensed under `BSD-3-Clause`
