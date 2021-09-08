# Package Installation

TODO: Note that information in this page reflects a future design and not the current implementation

Package management has some similarities to `npm`, with many important differences. This page provides information when installation packages in 'local' mode. 'global' mode behaves a bit differently

## Downloading

When downloading a package, a Git tag _must_ be provided. This ensures that the versions of the package is more traceable (it is more likely for a commit to be replaced (e.g. interactive rebase) compared to a release). Later, supporting revision sums _may_ be supported. But, this will likely entail performing a full clone of the repository, resetting to the revision, and using `git archive` on it.

Packages are downloaded as tarballs because they are much easier to manage compared to Git repositories (this contrasts basalt's previous behavior and Basher). We also edit the contents of the files so the package manager system works, as we'll get to later - this kind of stuff shouldn't be in history, and will be harder to persist if Git is involved

For a particular project folder, the `basalt_packages` directory is structured as such

```txt
- basalt_packages/
  - bin/
  - completion/
  - man/
  - tarballs/
  - packages/
  - transitive/
    - bin/
    - completion/
    - man/
    - tarballs/
    - packages/
```

Packages are directly downloaded to `tarballs`, extracted `packages`, and are transmogrified as detailed below. Unfortunately, some modification needs to be done so different versions of the same transitive package located at different locations in the dependency hierarchy work properly

For each `package`, a `basalt_packages` directory will still be created with the directories `bin`, `completions`, and `man`, containing symlinks resolved properly to their respective location in `transitive/{bin,completions,man}`. (Symlinks are not resolved directly to the package since an extra symlink indirection should make things easier and more maintainable)

## Package transmogrification

Files of all transitive dependencies are transmogrified. They are modified in the following way

- String replacement of consumer functions (functions used from a dependency)
- String replacement of producer functions (functions defined for the current package)

Only the string of the package name is replaced. For example `bash_toml.parse` will be rewritten to `bash_toml_1_2_0`, assuming the current version is `1.2.0`. `bash_toml` is specified as the package name slug in the `basalt.toml` file

Direct dependencies are still transmogrified, but only their consumers functions are replaced

## Final symlinking

Once the package has been downloaded and transmogrified, then it can be properly symlinked so consumers can use it. Packages that are transmogrified are symlinked to the directories contained within `transitive`. Other packages are symlinked to the same directories one level higher
