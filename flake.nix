{
  description = "Reusable development environment templates";

  outputs = { self }:
    let
      # Strip build artifacts and machine-local devenv state from a template
      # directory so `nix flake init` only copies checked-in sources.
      cleanTemplate = { path, name, extraExcludedNames ? [ ], extraExcludedPatterns ? [ ] }:
        builtins.path {
          inherit path name;
          filter = filePath: _type:
            let
              baseName = baseNameOf filePath;
              excludedNames = [
                ".direnv"
                ".pre-commit-config.yaml"
                "devenv.local.nix"
                "devenv.local.yaml"
              ] ++ extraExcludedNames;
              excludedPatterns = [ "\\.devenv.*" ] ++ extraExcludedPatterns;
            in
              !(builtins.elem baseName excludedNames)
              && builtins.all (pattern: builtins.match pattern baseName == null) excludedPatterns;
        };
    in
    {
      templates.python = {
        path = cleanTemplate {
          path = ./python;
          name = "python-template";
        };
        description = "Barebones Python development environment";
        welcomeText = ''
          # Python 
            
              devenv shell
        '';
      };


      templates.python-cuda = {
        path = cleanTemplate {
          path = ./python+cuda;
          name = "python-cuda-template";
          extraExcludedNames = [
            "__pycache__"
            "torch_cuda_trace.json"
          ];
          extraExcludedPatterns = [ ".*\\.py[co]" ];
        };
        description = "Python development environment with PyTorch and CUDA";
        welcomeText = ''
          # Python + CUDA

              devenv shell

          The shell runs the PyTorch CUDA check on entry; rerun it with
          `test_torch_cuda`.
        '';
      };

      templates.rust = {
        path = cleanTemplate {
          path = ./rust;
          name = "rust-template";
          extraExcludedNames = [
            "target"
            "flamegraph.svg"
            "perf.data"
            "perf.data.old"
          ];
        };
        description = "Rust development environment with a stable rust-overlay toolchain, mold, and cargo tooling";
        welcomeText = ''
          # Rust

              devenv shell

          Stable rust-overlay toolchain, mold as the linker on Linux, plus
          cargo-nextest, bacon, hyperfine and cargo-flamegraph. The rustfmt and
          clippy git hooks are commented out in devenv.nix; enable them once
          this project is its own git repository.
        '';
      };

      templates.default = self.templates.python-cuda;
    };
}
