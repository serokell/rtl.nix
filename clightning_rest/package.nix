# SPDX-FileCopyrightText: 2020 Serokell <https://serokell.io/>
#
# SPDX-License-Identifier: MPL-2.0

{ bp, pkgs }:

let
  inherit (builtins) fetchTarball;

  version = "0.2.2";
  sha256 = "1bwag3dx21lg3xkrcp4f4r50j812vrg5izaghai7ns3n1yfi7ql6";
in

bp.buildNpmPackage rec {
  version = "0.2.2";
  src = fetchTarball {
    url = "https://github.com/Ride-The-Lightning/c-lightning-rest/archive/v${version}.tar.gz";
  };
  patches = [
    (pkgs.fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/Ride-The-Lightning/c-lightning-REST/pull/37.diff";
      sha256 = "1c9v8fl9l65b40xx4xmz5x60bqlpxhc7pbfqncfhz0db4z9g2dm6";
    })
  ];
}
