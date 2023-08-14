# Motivation

A mechanism to facilitate composability within the Bash ecosystem, á la a package manager.

The general idea isn't new; there are many similar projects, but Basalt fills a unique void.

- It is not meant to be a replacement for `oh-my-zsh`, `bash-it`, etc. The aforementioned are used only in the context of shell initialization and are more geared towards reusability (not composability).

- It is unlike `bash-oo-framework` in that it facilitates the creation of _packages like_ `bash-oo-framework`. That is, cool features that are a part of `bash-oo-framework` like stack traces can be installable as a library rather than a greater framework.

- The two existing prominent package managers (`bpkg` and `Basher`) are most similar, but fall short. Some gripes are listed below.

### `bpkg` disadvantages

- Uses a `package.json` package format that clobbers with NPM's `package.json`
- During installation, `make` is automatically invoked ("ACE" on package download)
- Packages must be supported manually
- Does not respect the XDG Base Directory specification

### `Basher` disadvantages

- During installation a `package.sh` is automatically sourced ("ACE" on package download)
- Cannot install specific versions of packages
- Package names originating from different origins (i.e. github.com vs gitlab.com) clash
- Has subpar help output and CLI ergonomics (such as argument parsing)

### `bpkg` and `Basher` disadvantages

- Cannot install multiple packages at once
- Cannot install local, per-project dependencies
- Have subpar completion scripts


For each tool, the issues were systemic so I forked Basher and made heavy modifications, eventually doing a complete rewrite.
