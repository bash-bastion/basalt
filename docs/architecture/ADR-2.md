# ADR 2: Simplify project initialization setup

## Status

Accepted

## Context

When initializing a local project, there are several lines of boilerplate code to write.

For example, if a package `woof` has executable `./pkg/bin/woof`), its content must look something like this:

```sh
# shellcheck shell=bash

eval "$(basalt-package-init)"
basalt.package-init || exit
basalt.package-load

. "$BASALT_PACKAGE_DIR/pkg/src/bin/woof.sh"
main.woof "$@"
```

Although 10 lines may not seem that much, there is already quite a bit of "boilerplate drift". For example, some packages don't have an `|| exit` after `basalt.package-init`. And, some do, after the `eval "$(basalt-package-init)"`.

The multiple lines originated from the early days of Basalt, when the structure of a Bash application or library were still being explored. Now that this question has been answered, there is no utility for the verbosity.

## Decision

Simplify the boilerplate to a single line. Like so:

```sh
#!/usr/bin/env bash

eval "$(basalt-package-init woof)"
__run "$@"
```

## Consequences

### Negatives

- There'll be two ways to initialize a project in the wild. This can be confusing, since there are two ways to do the same thing. Detailed documentation about the old and new way mitigates this downside.

- Basalt must be backwards-compatible with the old initialization method indefinitely.

### Positives

The simplified boilerplate streamlines the setup process for people new to Basalt. Additionally, the extra abstraction makes it easier to change things around internally.

Furthermore, the single line of setup makes it easier to add features. For example, a `--no-assert-version` flag to not `exit 1` if the current Bash version doesn't meet the minimum requirements.
