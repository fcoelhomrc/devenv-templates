# devenv templates

Reusable project templates built with [devenv](https://devenv.sh/).

## Python + CUDA

This template provides Python, `uv`, PyTorch with CUDA support, CUDA runtime
libraries, cuDNN, and CUDA profiling support. It includes a small program that
checks CUDA execution, automatic mixed precision, and the PyTorch profiler.

Create a new project directory:

```console
nix flake new \
  -t github:fcoelhomrc/devenv-templates#python-cuda \
  my-project
cd my-project
devenv shell
```

Or apply the template to the current directory. Existing files are not
overwritten:

```console
nix flake init \
  -t github:fcoelhomrc/devenv-templates#python-cuda
devenv shell
```

`python-cuda` is also the default template, so this shorter form works:

```console
nix flake new -t github:fcoelhomrc/devenv-templates my-project
```

Show all templates exposed by the repository:

```console
nix flake show github:fcoelhomrc/devenv-templates
```
