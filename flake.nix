{
  description = "Reusable development environment templates";

  outputs = { self }:
    let
      cleanTemplate = builtins.path {
        path = ./python+cuda;
        name = "python-cuda-template";
        filter = path: _type:
          let
            name = baseNameOf path;
            excludedNames = [
              ".direnv"
              ".pre-commit-config.yaml"
              "__pycache__"
              "devenv.local.nix"
              "devenv.local.yaml"
              "torch_cuda_trace.json"
            ];
          in
            !(builtins.elem name excludedNames)
            && builtins.match "\\.devenv.*" name == null
            && builtins.match ".*\\.py[co]" name == null;
      };
    in
    {
      templates.python-cuda = {
        path = cleanTemplate;
        description = "Python development environment with PyTorch and CUDA";
        welcomeText = ''
          # Python + CUDA

          Enter the development environment:

              devenv shell

          The environment runs the PyTorch CUDA check when it starts. You can
          run it again with:

              test_torch_cuda
        '';
      };

      templates.default = self.templates.python-cuda;
    };
}
