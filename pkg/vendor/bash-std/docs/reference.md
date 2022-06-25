## Index

* [std.find_parent_file()](#stdfind_parent_file)
* [std.find_parent_dir()](#stdfind_parent_dir)
* [std.should_output_color()](#stdshould_output_color)
* [std.get_package_info()](#stdget_package_info)

### std.find_parent_file()

Finds a parent file

#### Arguments

* **$1** (File): name

### std.find_parent_dir()

Finds a parent directory

### std.should_output_color()

Determine if color should be printed. Note that this doesn't
use tput because simple environment variable checking heuristics suffice

### std.get_package_info()

Gets information from a particular package. If the key does not exist, then the value
is an empty string

#### Arguments

* **$1** (string): The `$BASALT_PACKAGE_DIR` of the caller

#### Variables set

* **directory** (string): The full path to the directory

