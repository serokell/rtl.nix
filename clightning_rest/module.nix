# SPDX-FileCopyrightText: 2020 Serokell <https://serokell.io/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:

{
  options = {
    services.clightning.plugins.rest = {
      enable = lib.mkEnableOption "REST APIs for c-lightning";

      port = lib.mkOption {
        type = lib.types.int;
        default = 3001;
        description = ''
          Port to listen on.
        '';
      };

      docPort = lib.mkOption {
        type = lib.types.int;
        default = 4001;
        description = ''
          Port for serving the swagger documentation.
        '';
      };

      protocol = lib.mkOption {
        type = lib.types.enum [ "http" "https" ];
        default = "https";
        description = ''
          Protocol to expose the API over.

          When set to `https` the plugin will use `openssl` to generate
          a self-signed certificate.
        '';
      };

      execMode = lib.mkOption {
        type = lib.types.str;
        default = "PRODUCTION";
        description = ''
          Control for more detailed log info.
        '';
      };

      rpcCommands = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "*" ];
        description = ''
          Enable additional RPC commands for `/rpc` endpoint.
        '';
      };
    };
  };

  config =
    let
      cfg = config.services.clightning.plugins.rest;
      extraConfig = ''
        plugin=${pkgs.clightning_rest}/plugin.js
        rest-port=${toString cfg.port}
        rest-docport=${toString cfg.docPort}
        rest-protocol=${cfg.protocol}
        rest-execmode=${cfg.execMode}
        rest-rpccommands=${lib.concatStringsSep "," cfg.rpcCommands}
      '';
    in lib.mkIf cfg.enable {
      services.clightning = { inherit extraConfig; };
      systemd.services.clightning = {
        path = [ pkgs.openssl ];
        serviceConfig.Environment = [
          "CL_REST_STATE_DIR=/var/lib/cl-rest"
        ];
      };
    };
}
