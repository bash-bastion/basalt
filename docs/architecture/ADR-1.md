# ADR 1: Restructure per-project dependencies

## Status

Accepted

## Context

Currently, for a per-project installation, all dependencies are installed to the `bpm_packages` directory. The way transitive dependencies are installed create some issues. For example, if B is a dependency of A, it will be installed in the `bpm_packages` directory of package A. This deep nesting caused a similar problem for early versions of `npm`, where, long paths names would cause installations to fail on Windows (`bpm` does not currently explicitly support Windows). Not only that, but it is harder to introspect the source code of transitive dependencies if they are deep in a dependency hierarchy. This is especially true for Bash and POSIX shell, where it is more commonplace to do so. It also wastes space if multiple packages depend on the same version of a package.

## Decision

When installing dependencies for a per-project installation, all dependencies should be hoisted to the top level, contained within `bpm_packages`. To prevent version conflicts, version numbers are appended to the package when downloading and extracting. For example, if B is a dependency of A, it will be installed in the `bpm_packages` directory of the current project (top level). More details can be found in [Package Installation](./docs/internals/package-installation.md)

## Consequences

Current users of `bpm` will have to completely remove their previous `bpm_packages` directory, and reinstall packages. Since the main `./bpm_packages/bin`, `./bpm_packages/completions`, and `./bpm_packages/man` folders are not changing, code changes are unecessary. Negative impact will be minimal. By implementing this, it will be easier to manage, transmogrify, and symlikn dependencies. It will also potentially decrease the total disk space of `bpm_packages`
