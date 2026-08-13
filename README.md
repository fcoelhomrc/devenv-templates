# devenv templates

Reusable project templates built with [devenv](https://devenv.sh/).

```console
nix flake new -t github:fcoelhomrc/devenv-templates#<template> my-project
cd my-project && devenv shell
```

Use `nix flake init -t ...` to apply a template to the current directory instead
(existing files are not overwritten), and `nix flake show
github:fcoelhomrc/devenv-templates` to list everything.

## python-cuda

Python with `uv`, PyTorch with CUDA, cuDNN, and the CUDA profiling libraries.
`test_torch_cuda` checks CUDA execution, AMP and the profiler; it also runs on
shell entry. This is the default template, so `-t github:fcoelhomrc/devenv-templates`
works too.

## rust

A `stable` toolchain from [rust-overlay](https://github.com/oxalica/rust-overlay)
with `clippy`, `rustfmt` and `rust-analyzer`, [mold](https://github.com/rui314/mold)
as the linker on Linux, plus `cargo-nextest`, `bacon`, `hyperfine` and
`cargo-flamegraph`. `src/main.rs` is a sieve with unit tests so the tooling has
something to run against.

`rustfmt`/`clippy` git hooks are available but commented out in `devenv.nix`:
devenv installs them into the enclosing git repository, so enable them only once
the project is its own repo.

## Working on the templates

Test a template from a scratch directory rather than by running `devenv shell`
inside its source directory here — devenv writes state (and, if hooks are on,
git hooks) into the enclosing repository:

```console
nix flake new -t path:$PWD#rust /tmp/rust-check
```
