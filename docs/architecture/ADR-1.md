# ADR 1: Restructure per-project dependencies

## Status

Accepted

## Context

Currently, for a per-project installation, all dependencies are installed to the `./.basalt` directory. The way transitive dependencies are installed create some issues. For example, if B is a dependency of A, it will be installed in the `./.basalt` directory of package A. This creates a deep hierarchy (early versions of `npm` ran into this)

## Decision

When installing dependencies for a per-project installation, all dependencies should be hoisted to the top level `./.basalt` directory, or to the `./.basalt` directory. To prevent version conflicts, version numbers are appended to the package when downloading and extracting. For example, if `package-b@v0.1.0` is a dependency of `package-a@v0.8.0`, it will be installed to the `./.basalt/transitive` directory. More details can be found in [Package Installation](./docs/internals/package-installation.md)

## Consequences

### Negatives

Current users of `basalt` will have to completely remove their previous `.basalt` directory, and reinstall packages. Since the main `./.basalt/bin`, `./.basalt/completions`, and `./.basalt/man` directories are not changing, code changes within packages are unnecessary

### Positives

- More maintainable and less buggy code
- Potentially decrease the total disk space of `.basalt`
- Easier to introspect source code of packages
