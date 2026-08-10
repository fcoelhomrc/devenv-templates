{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [
    # Typical CUDA dependencies
    pkgs.cudaPackages.cuda_cudart  # Runtime
    pkgs.cudaPackages.cudnn        # Deep neural networks
    pkgs.cudaPackages.cuda_nvrtc   # Runtime compiler
    pkgs.cudaPackages.cuda_cupti   # Profiling tools interface
    pkgs.cudaPackages.cudatoolkit  # Toolkit
  ];

  # https://devenv.sh/languages/
  languages.python = {
    enable = true;
    venv.enable = true;
    libraries = [
      # Point CUDA libraries to host CUDA drivers
      "/run/opengl-driver/lib:/run/opengl-driver-32/lib"
    ];
    uv = {
      enable = true;
      sync.enable = true;
    };
  };

  # https://devenv.sh/processes/
  # processes.dev.exec = "${lib.getExe pkgs.watchexec} -n -- ls -la";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.test_torch_cuda.exec = ''
    uv run test_torch_cuda.py
  '';

  # https://devenv.sh/basics/
   enterShell = ''
     test_torch_cuda
   '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  # enterTest = ''
  #   echo "Running tests"
  #   git --version | grep --color=auto "${pkgs.git.version}"
  # '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
