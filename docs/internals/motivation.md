# Motivation

A mechanism to facilitate composability within the Bash ecosystem, á la a package manager

The general idea isn't new; there exist two prominent package managers (`bpkg` and `Basher`) along with a slew of other highly prolific Bash/shell projects (`oh-my-zsh`, `bash-it`, `bash-oo-framework`) that aim to solve similar problems. How is Basalt different?

1. `oh-my-zsh`, `bash-it`, and friends are more geared towards reusability (not composability) in the context of shell initialization
2. `bash-oo-framework` contains a lot of useful functionality, but as the name implies, it must be used as a framework rather than a library; this doesn't mame it very composable. Furthermore, the project itself recommends directly copying and pasting code from the repository as a usage pattern, which is highly laborious and frictious
3. `bpkg` and `Basher` are two projects that fit the criteria, but have some disadvantages in my opinion

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

These disadvantages gave me reason to create a new package manager that was significantly improved. I originally forked Basher because it had an excellent test suite and its behavior for installing packages made more sense to me. However, since a massive refactoring effort in addition to a near-complete rewrite took effect, there is almost no original Basher code that exists currently
