# Package Installation

This page provides information on how and where packages are installed.

The installation of packages is split into four phases. Each of these phases corresponds to a function in `pkg.sh`

1. Package download `pkg.phase_download_tarball()`
2. Package extraction `pkg.phase_extract_tarball()`
3. Package global integration (recursive) `pkg.phase_local_integration_recursive() "$BASALT_GLOBAL_DATA_DIR..."`
4. Package global integration (non-recursive) `pkg.phase_local_integration_nonrecursive() "$BASALT_GLOBAL_DATA_DIR..."`
5. Package local integration (recursive) `pkg.phase_local_integration_recursive() "$BASALT_LOCAL_PROJECT_DIR..."`
6. Package local integration (non-recursive) `pkg.phase_local_integration_nonrecursive() "$BASALT_LOCAL_PROJECT_DIR..."`

## 1. Package download

During this stage, tarballs files are downloaded from the internet to `$BASALT_GLOBAL_DATA_DIR/store/tarballs`

In most cases, tarballs can be downloaded directly. From the point of view of a consumer, you can access these types of tarballs by specifying a revision like `@v0.3.0'` in `dependencies`. From the point of view of a package maintainer, enable this behavior by authoring a GitHub release based on a git tag of a Git repository. Doing this is most efficient since the whole Git repository does not need to be downloaded.

Sometimes, a package consumer may want to use a revision that is not a release (e.g. `@e5466e6c3998790ebd99768cf0f910e161b84a95`). When this type of revision is specified, Basalt will clone the entire repository, then use `git-archive(1)` to extract the revision in the form of a tarball.

## 2. Package extraction

During this stage, tarball files located in `$BASALT_GLOBAL_DATA_DIR/store/tarballs` are extracted and placed in `$BASALT_GLOBAL_DATA_DIR/store/packages`.

### 3. Global integration (recursive)

For each package in `$BASALT_GLOBAL_DATA_DIR/store/packages`, modifications are done. Find more information about the modifications in "recursive local integration".

### 4. Global integration (non-recursive)

For each package in `$BASALT_GLOBAL_DATA_DIR/store/packages`, modifications are done that don't require recursively resolving subdependencies. Find more information about the modifications in "non-recursive local integration".

### 5. Local integration (recursive)

This step involves creating a `.basalt` directory so the functionality of all dependencies can be properly exposed. The directory is located at `$BASALT_LOCAL_PROJECT_DIR/.basalt` for local dependencies and at `$BASALT_GLOBAL_DATA_DIR/global/.basalt` for global dependencies

```txt
- .basalt/
  - bin/
  - completion/
  - man/
  - packages/
  - transitive/
    - bin/
    - completion/
    - man/
    - packages/
```

### 6. Local integration (non-recursive)

This is similar to the previous step, except it performs functionalities that are inherently non recursive. This includes creating the `./basalt/generated` subdirectory and the files within it:

- Appending version numbers to all functions
- Converting the runtime essence of the `./basalt.toml` file into other files that are either sourceable or easier to parse
