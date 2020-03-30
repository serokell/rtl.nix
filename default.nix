# SPDX-FileCopyrightText: 2020 Serokell <https://serokell.io/>
#
# SPDX-License-Identifier: MPL-2.0

#
# nix-flakes shim
#

let
  sources = builtins.removeAttrs (import ./nix/sources.nix) ["__functor" "niv"];
  # https://github.com/input-output-hk/haskell.nix/blob/master/lib/override-with.nix
  tryOverride = override: default:
    let
      try = builtins.tryEval (builtins.findFile builtins.nixPath override);
    in if try.success then
      builtins.trace "using search host <${override}>" try.value
       else
         default;
  inputs = builtins.mapAttrs (name: s: import (tryOverride "flake-${name}" s)) sources;
  flake = (import ./flake.nix).outputs (inputs // { self = flake; });
in

{ exposeFlake ? true }:

if exposeFlake then
  flake
else
  let
    packages = import <nixpkgs> { overlays = [ flake.overlay ]; };
  in {
    inherit (packages) clightning_rest ride_the_lightning;
  }
