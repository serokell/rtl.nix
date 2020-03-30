# SPDX-FileCopyrightText: 2020 Serokell <https://serokell.io/>
#
# SPDX-License-Identifier: MPL-2.0

{
  edition = 201911;

  description = "Ride-The-Lightning on nix";

  outputs = { self, nixpkgs, nix-npm-buildpackage }:
    {
      overlay = self: super:
        let
          inherit (builtins) fetchTarball;
          bp = self.callPackage nix-npm-buildpackage {};
        in {
          rtl = import ./rtl/package.nix {
            inherit bp;
            pkgs = self;
          };

          clightning_rest = import ./clightning_rest/package.nix {
            inherit bp;
            pkgs = self;
          };
        };

      modules = {
        rtl = import ./rtl/module.nix;
        clightning_rest = import ./clightning_rest/module.nix;
      };
    };
}
