# Local Projects

Similar to `cargo`, `yarn` etc., Basalt allows for the installation of packages on a per-project basis. This page details how to do it with Basalt

First, create a project directory

```sh
mkdir 'my-project' && cd 'my-project'
```

Now, initialize a new project. We'll be passing in `--full`; if you want a more minimalist template, pass `--bare` instead

```sh
$ basalt init --full
       Info Cloned github.com/hyperupcall/template-bash
```

Naturally, the most important part of Basalt packages is the `basalt.toml` file

```toml
[package]
name = 'fox-track'
slug = 'fox_track'
version = '0.1.0'
authors = ['Edwin Kofler <edwin@kofler.dev>']
description = 'A template to get started writing Bash applications and projects'

[run]
dependencies = ['https://github.com/hyperupcall/bats-common-utils.git@v3.0.0']
sourceDirs = ['pkg/src/public', 'pkg/lib']
builtinDirs = []
binDirs = ['bin']
completionDirs = ['completions']
manDirs = []

[run.shellEnvironment]

[run.setOptions]

[run.shoptOptions]
```

In short, `name` is the pretty name for the package. Often, it has the same name as the repository. `slug` is the string used to prefix _all of_ your functions when you want your package to be consumed as a library. Lastly, `sourceDirs` are all the directories containing shell files you wish to source. Note that `pkg/lib/cmd` is _not_ added since it contains files that are entrypoints for new Bash processes

A detailed description for each key can be found at [`reference/basalt_toml`](./docs/reference/basalt_toml.md)

To execute this program, simply run

```sh
$ basalt run fox-track --help
fox-track: A fox tracking sample application

Commands:
  show
    Shows the current fox count

  set <number>
    Sets the current fox count

  add [number]
    Adds a number to the current fox count. If number is not specified, it defaults to 1

  remove [number]
    Adds a number to the current fox count. If number is not specified, it defaults to 1

Flags:
  --help
    Shows the help menu
```

This is similar to running `./bin/fox-track` directly, but using `basalt run` has another benefit: Basalt will look for commands of the specified name not just for the current project, but for all subdependencies as well

If you wish to add a dependency to the project, use the `add` subcommand

```sh
$ basalt add 'hyperupcall/bats-common-utils'
 Downloaded github.com/hyperupcall/bats-common-utils@v3.0.0
  Extracted github.com/hyperupcall/bats-common-utils@v3.0.0
Transformed github.com/hyperupcall/bats-common-utils@v3.0.0
```

Basalt will automatically find and download the version corresponding to the _latest GitHub release_. If there are no GitHub releases, it will use the latest commit. In this case, `v3.0.0` was the latest GitHub release

You can view the dependencies by looking in `basalt.toml` or running

```sh
$ basalt list
https://github.com/hyperupcall/bats-common-utils.git@v3.0.0
```
