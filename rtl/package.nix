# SPDX-FileCopyrightText: 2020 Serokell <https://serokell.io/>
#
# SPDX-License-Identifier: MPL-2.0

{ bp, pkgs }:

let
  inherit (builtins) fetchTarball;

  version = "0.7.0";
  sha256 = "0czk9sbvkhcklayxwf87z9wz58iqj2q578cg18gk7qcq8lklccmk";
in

bp.buildNpmPackage {
  version = "0.7.0";
  src = fetchTarball {
    url = "https://github.com/Ride-The-Lightning/RTL/archive/v${version}.tar.gz";
    inherit sha256;
  };

  npmBuild = "npm run build";

  patchPhase = ''
    # Angular `ng` tries to write config to $HOME
    sed -i 's/"build": "ng analytics off && /"build": "/g' package.json
  '';

  extraEnvVars = {
    PYTHON = "${pkgs.python2}/bin/python";  # For (old) node-gyp
    NG_CLI_ANALYTICS = "false";  # Angular: do not ask to share analytics
  };
}
