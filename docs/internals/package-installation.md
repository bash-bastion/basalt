# Package Installation

This page provides information on how and where packages are installed.

Installation of packages is split into four phases

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

TODO: expand on this

For each package in `$BASALT_GLOBAL_DATA_DIR/store/packages`, modifications are done. This includes modifying the source code with regular expressions and creating `./basalt_packages` directories for each one

### 4. Local integration

TODO: expand on this

When working with per-project dependencies, the final step involves creating a `./basalt_packages` directory for the current project. It is structured like so

```txt
- basalt_packages/
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
