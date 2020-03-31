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

***Note:*** This is currently not implemented/supported.

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
        pattern: '{path}'
```
