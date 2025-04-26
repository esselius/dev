{ lib, ... }:

{
  options.dev = {
    enable = lib.mkEnableOption "Enable dev flake";

    actions-nix-lib = lib.mkOption {
      type = lib.types.attrs;
    };
  };
}
