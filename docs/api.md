# bash-core

## Overview

Core functions for any Bash program

## Index

* [core.trap_add()](#coretrap_add)
* [core.trap_remove()](#coretrap_remove)
* [core.shopt_push()](#coreshopt_push)
* [core.shopt_pop()](#coreshopt_pop)
* [core.err_set()](#coreerr_set)
* [core.err_clear()](#coreerr_clear)
* [core.err_exists()](#coreerr_exists)
* [core.print_stacktrace()](#coreprint_stacktrace)
* [core.print_error()](#coreprint_error)
* [core.print_warn()](#coreprint_warn)
* [core.print_info()](#coreprint_info)
* [core.panic()](#corepanic)
* [core.should_output_color()](#coreshould_output_color)
* [core.get_package_info()](#coreget_package_info)
* [core.init()](#coreinit)
* [core.stacktrace_print()](#corestacktrace_print)

### core.trap_add()

Adds a handler for a particular `trap` signal or event. Noticably,
unlike the 'builtin' trap, this does not override any other existing handlers

#### Example

```bash
some_handler() { printf '%s\n' 'This was called on USR1! ^w^'; }
core.trap_add 'some_handler' 'USR1'
kill -USR1 $$
core.trap_remove 'some_handler' 'USR1'
```

#### Arguments

* **$1** (string): Function to execute on an event. Integers are forbiden
* **$2** (string): Event signal

### core.trap_remove()

Removes a handler for a particular `trap` signal or event. Currently,
if the function doest not exist, it prints an error

#### Example

```bash
some_handler() { printf '%s\n' 'This was called on USR1! ^w^'; }
core.trap_add 'some_handler' 'USR1'
kill -USR1 $$
core.trap_remove 'some_handler' 'USR1'
```

#### Arguments

* **$1** (string): Function to remove
* **$2** (string): Signal that the function executed on

### core.shopt_push()

Modifies current shell options and pushes information to stack, so
it can later be easily undone. Note that it does not check to see if your Bash
version supports the option

#### Example

```bash
core.shopt_push -s extglob
[[ 'variable' == @(foxtrot|golf|echo|variable) ]] && printf '%s\n' 'Woof!'
core.shopt_pop
```

#### Arguments

* **$1** (string): Name of shopt action. Can either be `-u` or `-s`
* **$2** (string): Name of shopt name

### core.shopt_pop()

Modifies current shell options based on most recent item added to stack.

#### Example

```bash
core.shopt_push -s extglob
[[ 'variable' == @(foxtrot|golf|echo|variable) ]] && printf '%s\n' 'Woof!'
core.shopt_pop
```

_Function has no arguments._

### core.err_set()

Sets an error.

#### Arguments

* **$1** (Error): code
* **$2** (Error): message

#### Variables set

* **number** (ERRCODE): Error code
* **string** (ERR): Error message

### core.err_clear()

Clears any of the global error state (sets to empty string).
This means any `core.err_exists` calls after this _will_ `return 1`

_Function has no arguments._

#### Variables set

* **number** (ERRCODE): Error code
* **string** (ERR): Error message

### core.err_exists()

Checks if an error exists. If `ERR` is not empty, then an error
_does_ exist

_Function has no arguments._

### core.print_stacktrace()

Prints stacktrace

#### Example

```bash
err_handler() {
  local exit_code=$?
  core.print_stacktrace
  exit $exit_code
}
core.trap_add 'err_handler' ERR
```

_Function has no arguments._

### core.print_error()

Print an error message to standard error

#### Arguments

* **$1** (string): message

### core.print_warn()

Print a warning message to standard error

#### Arguments

* **$1** (string): message

### core.print_info()

Print an informative message to standard output

#### Arguments

* **$1** (string): message

### core.panic()

Use when a serious fault occurs. It will print the current ERR (if it exists)

### core.should_output_color()

Determine if color should be printed. Note that this doesn't
use tput because simple environment variable checking heuristics suffice

### core.get_package_info()

Gets information from a particular package. If the key does not exist, then the value
is an empty string

#### Arguments

* **$1** (string): The `$BASALT_PACKAGE_DIR` of the caller

#### Variables set

* **directory** (string): The full path to the directory

### core.init()

(DEPRECATED) Initiates global variables used by other functions. Deprecated as
this function is called automatically by functions that use global variables

_Function has no arguments._

### core.stacktrace_print()

(DEPRECATED) Prints stacktrace

#### See also

* [core.print_stacktrace](#coreprint_stacktrace)

