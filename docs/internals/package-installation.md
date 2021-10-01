# Package Installation

This page provides information on how and where packages are installed.

The installation of packages is split into four phases. Each of these phases corresponds to a function in `pkg.sh`

1. Package download
2. Package extraction
3. Package global integration
4. Package local integration

## 1. Package download

During this stage, tarballs files are downloaded from the internet to `$BASALT_GLOBAL_DATA_DIR/store/tarballs`

In most cases, tarballs can be downloaded directly. From the point of view of a consumer, you can access these types of tarballs by specifying a revision like `@v0.3.0'` in `dependencies`. From the point of view of a package maintainer, enable this behavior by authoring a GitHub release based on a release commit of a Git repository. Doing this is most efficient since the whole Git repository does not need to be downloaded

Sometimes, a package consumer may want to use a revision that is not a release (e.g. `@e5466e6c3998790ebd99768cf0f910e161b84a95`). When this type of revision is specified, Basalt will clone the entire repsitory, then use `git-archive(1)` to extract the revision in the form of a tarball

## 2. Package extraction

During this stage, tarball files located in `$BASALT_GLOBAL_DATA_DIR/store/tarballs` are simply extracted and placed in `$BASALT_GLOBAL_DATA_DIR/store/packages`

### 3. Global integration

For each package in `$BASALT_GLOBAL_DATA_DIR/store/packages`, modifications are done. This includes but is not limited to

- Appending version numbers to all functions
- Creating a local `./.basalt` directory (local integration)
- Converting the runtime essence of the `./basalt.toml` file into other files that are either sourcable or easier to parse

### 4. Local integration

The final step involves creating a `.basalt` directory so the functionality of all dependencies can be properly exposed. The directory is located at `./.basalt` for local dependencies and at `BASALT_GLOBAL_DATA_DIR/global/.basalt` for global dependencies

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
