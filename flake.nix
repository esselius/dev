{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    actions-nix = {
      url = "github:nialov/actions.nix";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "git-hooks-nix";
        flake-parts.follows = "flake-parts";
      };
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    agenix-rekey = {
      url = "github:esselius/agenix-rekey";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        pre-commit-hooks.follows = "git-hooks-nix";
        devshell.follows = "devshell";
      };
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } rec {
    systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
    flake.flakeModule = {
      imports = [
        inputs.actions-nix.flakeModules.default
        inputs.devshell.flakeModule
        inputs.git-hooks-nix.flakeModule
        inputs.agenix-rekey.flakeModule
        ./flake-module
      ];

      dev = {
        actions-nix-lib = inputs.actions-nix.lib;
      };
    };
    imports = [ flake.flakeModule ];

    dev.enable = true;
  };
}
