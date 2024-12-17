# Include Guards Check (GitHub Action)

This is a [GitHub Action](//help.github.com/en/actions) to check for
`#include` guards in C/C++ header files.

We consider files with extensions `.h`, `.H`, `.hh`, `.hpp`, `.cuh` and `.hxx`
as header files.
In these files we check for the existence of constructs like
```c
#ifndef SOME_NAME
#define SOME_NAME
```
where `SOME_NAME` is based on the file name according to a pattern
that can be specified by the user.

Note that we do not really parse the preprocessor code, we just perform
simple shell scripting.
That means, you can easily trick the check script into false positives.
However, why should you do that?

## Inputs

### `path`

The base path to look for header files,
for example `src` or `include`.

Default is the root of the repository, i.e., `.`.

### `pattern`

The pattern to construct the macro name based on the file name.

The pattern is a simple string with some replacement fields, i.e.,
substrings in curly braces that will be replaced by (user-specified)
and *macrofied* parts of the file name.
*Macrofication* means that we transform all lower-case letters to
upper-case and replace all non-alphanumeric characters by underscores (`_`).

Here is a list of available replacement field specifiers with an example for
the file `dir1/dir2/dir3/file.fuzz.hpp`:

 * **{path}**: `DIR1_DIR2_DIR3_FILE_FUZZ_HPP`
 * **{file}**: `FILE_FUZZ_HPP`
 * **{file_ext}**: `HPP`
 * **{file_base}**: `FILE_FUZZ`
 * **{dirs}**: `DIR1_DIR2_DIR3`
 * **{first_dir}**: `DIR1`
 * **{last_dir}**: `DIR3`

Note that it is always useful to use your project name as a prefix
to avoid name clashes with header guards of other projects.

Default is `{path}`, which is useful if your path structure is
like `<project name>/<header file>` or
`<project name>/<some category>/<header file>`.

### `only`

The regular expression for paths to check.
Paths not matching this regular expression are ignored.

Three artificial examples:
 * `dir/\(foo\|bar\)\.h` checks `dir/foo.h` and `dir/bar.h` only,
 * `^v[0-9\.]\+/` checks paths beginning with a versional directory only,
 * `/.*/` checks paths with at least two directories only.

By default, all paths are checked.

### `ignore`

The regular expression for paths to ignore.
This is possibly a simpler way (than using `only`) to exclude
files from checking.

By default, no paths are ignored.

## Outputs

### `fails`

A space-separated list of files for which the check failed.

## Example usage

Create a workflow file, e.g., `.github/workflows/include-guards.yml`,
with the following content:
```yml
name: check-include-guards

on: [push, pull_request]

jobs:
  include-guards:
    name: Check include guards
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    - name: Check include guards
      uses: sbeyer/include-guards-check-action@v2.0.0
      with:
        path: 'include/'
        pattern: 'PROJECT_{last_dir}_{file_base}'
```

You can also [glance at other projects using this GitHub Action](//github.com/search?l=YAML&q=include-guards-check-action&type=Code).
