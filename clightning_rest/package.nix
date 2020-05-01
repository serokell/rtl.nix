# SPDX-FileCopyrightText: 2020 Serokell <https://serokell.io/>
#
# SPDX-License-Identifier: MPL-2.0

{ bp, pkgs }:

let
  inherit (builtins) fetchTarball;
in

bp.buildNpmPackage rec {
  version = "0.3.0";
  src = fetchTarball {
    url = "https://github.com/Ride-The-Lightning/c-lightning-rest/archive/v${version}.tar.gz";
    sha256 = "10gfrqhqa7gf1r74dvhpsrgzsl9h7zy007ij3zspi00j5rhhchbq";
  };
  patches = [
    (pkgs.fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/Ride-The-Lightning/c-lightning-REST/pull/38.diff";
      sha256 = "1xyr62livd0vcawwdkilsgssx2bdwzzs7n8ycypk95xyvxi6q66z";
    })
  ];
}
