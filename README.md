# Include Guards Check (GitHub Action)

This is a [GitHub Action](//help.github.com/en/actions) to check for
`#include` guards in C/C++ header files.

We consider files with extensions `.h`, `.H`, `.hh`, `.hpp`, and `.hxx`
as header files.
In these files we check for the pattern
```c
#ifndef SOME_NAME
#define SOME_NAME
```
where `SOME_NAME` is based on the file name according to a pattern
that can be specified by the user.

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

## Outputs

### `fails`

A space-separated list of files for which the check failed.

## Example usage

Create a workflow file, e.g., `.github/workflows/include-guards.yml`,
with the following content:
```yml
name: test-include-guards

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v2
    - name: Include guards check
      uses: sbeyer/include-guards-check-action@v1.0.0
      with:
        path: 'include/'
        pattern: 'PROJECT_{last_dir}_{file_base}'
```
