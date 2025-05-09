{ lib, config, ... }:

let
  cfg = config.dev;
in
{
  imports = [
    ./interface.nix
  ];

  config = lib.mkIf cfg.enable {
    flake.actions-nix = {
      pre-commit.enable = true;

      workflows.".github/workflows/main.yaml" = {
        jobs.nix-flake-check = {
          runs-on = "ubuntu-latest";
          timeout-minutes = 60;
          steps = with cfg.actions-nix-lib.steps; [
            actionsCheckout
            { uses = "docker/setup-qemu-action@v3"; }
            { uses = "DeterminateSystems/nix-installer-action@v17"; "with".extra-args = "--extra-conf \"extra-platforms = aarch64-linux\""; }
            runNixFlakeCheck
          ];
        };
      };
    };

    perSystem = { config, ... }: {
      devshells.default = {
        devshell.startup.pre-commit-install.text = config.pre-commit.installationScript;
        packages = [
          config.agenix-rekey.agePackage
          config.agenix-rekey.package
        ];
      };

      pre-commit.settings.hooks = {
        deadnix.enable = true;
        flake-checker.enable = true;
        markdownlint = {
          enable = true;
          settings.configuration = {
            MD013 = {
              code_blocks = false;
            };
          };
        };
        nixpkgs-fmt.enable = true;
        statix.enable = true;
      };
    };
  };
}
