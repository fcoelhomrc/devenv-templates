{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.RUST_BACKTRACE = "1";

  # https://devenv.sh/packages/
  packages = [
    # Inner loop
    pkgs.cargo-nextest      # fast, parallel test runner: cargo nextest run
    pkgs.bacon              # background cargo watcher with a TUI: bacon

    # Benchmarking and profiling
    pkgs.hyperfine          # statistical CLI benchmarking: hyperfine 'cargo run --release'
    pkgs.cargo-flamegraph   # sampling profiles: cargo flamegraph
  ];

  # https://devenv.sh/supported-languages/rust/
  languages.rust = {
    enable = true;

    # "nixpkgs" pins Rust to the nixpkgs revision. The other channels come from
    # rust-overlay (declared in devenv.yaml) and allow picking an exact version.
    channel = "stable";
    version = "latest"; # or a pin such as "1.90.0"

    components = [
      "rustc"
      "cargo"
      "clippy"
      "rustfmt"
      "rust-analyzer"
      # "rust-src"  # let rust-analyzer jump into the standard library sources
    ];

    # Extra cross-compilation targets, e.g. "wasm32-unknown-unknown".
    # targets = [ ];

    # mold links far faster than the default linker. devenv wires it up through
    # RUSTFLAGS; it is Linux-only, so other platforms keep devenv's defaults.
    mold.enable = pkgs.stdenv.isLinux;
  };

  # https://devenv.sh/git-hooks/
  # Off by default: devenv installs hooks into the *enclosing* git repository
  # (it resolves the repo with `git rev-parse --git-dir`, which walks upwards),
  # so enabling them writes to whatever repo happens to contain this project.
  # Opt in by uncommenting, or by putting the same lines in devenv.local.nix.
  # The hooks use the rustfmt/clippy from the toolchain configured above.
  #
  # git-hooks.hooks = {
  #   rustfmt.enable = true;
  #   clippy.enable = true;
  # };

  # https://devenv.sh/processes/
  # processes.dev.exec = "bacon";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  # scripts.ci.exec = ''
  #   cargo fmt --check && cargo clippy -- -D warnings && cargo nextest run
  # '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "cargo fetch";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  # enterTest = ''
  #   cargo nextest run
  # '';

  # See full reference at https://devenv.sh/reference/options/
}
