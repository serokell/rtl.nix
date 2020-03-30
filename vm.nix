#!/usr/bin/env nixos-shell

# SPDX-FileCopyrightText: 2020 Serokell <https://serokell.io/>
#
# SPDX-License-Identifier: MPL-2.0

let
  flake = import ./. { exposeFlake = true; };
in

{ pkgs, ... }: {
  imports = with flake.modules; [ clightning_rest rtl ];

  nixpkgs.overlays = [ flake.overlay ];

  services = {
    clightning.plugins.rest = {
      enable = true;
    };

    rtl = {
      enable = true;
      passwordHash = "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824";  # hello
    };
  };

  environment.systemPackages = with pkgs; [ openssl vim ];
}
