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
            DeterminateSystemsNixInstallerAction
            runNixFlakeCheck
          ];
        };
      };
    };

    perSystem = { config, pkgs, ... }: {
      devshells.default = {
        devshell.startup.pre-commit-install.text = config.pre-commit.installationScript;
        packages = [
          pkgs.coreutils # https://github.com/oddlama/agenix-rekey/pull/98
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
