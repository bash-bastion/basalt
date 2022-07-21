## Index

* [std.fprint_error()](#stdfprint_error)
* [std.fprint_warn()](#stdfprint_warn)
* [std.fprint_info()](#stdfprint_info)
* [std.find_parent_file()](#stdfind_parent_file)
* [std.find_parent_dir()](#stdfind_parent_dir)
* [std.should_print_color_stdout()](#stdshould_print_color_stdout)
* [std.should_print_color_stderr()](#stdshould_print_color_stderr)
* [std.get_package_info()](#stdget_package_info)

### std.fprint_error()

Prints a formatted error message

#### Arguments

* **$1** (name): of package
* **$2** (message):

### std.fprint_warn()

Prints a formated warning message

#### Arguments

* **$1** (name): of package
* **$2** (message):

### std.fprint_info()

Prints a formated log message

#### Arguments

* **$1** (name): of package
* **$2** (message):

### std.find_parent_file()

Finds a parent file

#### Arguments

* **$1** (File): name

### std.find_parent_dir()

Finds a parent directory

### std.should_print_color_stdout()

Determine if color should be printed to standard output

_Function has no arguments._

### std.should_print_color_stderr()

Determine if color should be printed to standard error

_Function has no arguments._

### std.get_package_info()

Gets information from a particular package. If the key does not exist, then the value
is an empty string

#### Arguments

* **$1** (string): The `$BASALT_PACKAGE_DIR` of the caller

#### Variables set

* **directory** (string): The full path to the directory

