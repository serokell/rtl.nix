# SPDX-FileCopyrightText: 2020 Serokell <https://serokell.io/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:

let
  nodeParamsType = lib.types.submodule ({ lib, ... }: { options = {
    name = lib.mkOption {
      type = lib.types.str;
      description = ''
        Node display name.
      '';
      example = "c-lightning Testnet # 1";
    };

    url = lib.mkOption {
      type = lib.types.str;
      description = ''
        URL of the REST API.
      '';
      example = "https://192.0.2.1:3001/v1";
    };

    authentication = {
      macaroonPath = lib.mkOption {
        type = lib.types.str;
        description = ''
          Path the the folder containing `access.macaroon` file from cl-rest server.
        '';
      };
      configPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          File path of the c-lightning config file, if RTL server is local to the c-lightning server
        '';
      };
    };
  };});

  mkNode = index: nodeParams: {
    inherit index;
    lnImplementation = "CLT";
    lnNode = nodeParams.name;
    Authentication = nodeParams.authentication;
    Settings = {
      userPersona = "OPERATOR";
      themeMode = "NIGHT";
      enableLogging = true;
      fiatConversion = false;
      lnServerUrl = nodeParams.url;
    };
  };
in

{
  options = {
    services.rtl = {
      enable = lib.mkEnableOption "Ride The Lightning";

      passwordHash = lib.mkOption {
        type = lib.types.str;
        description = ''
          SHA-256 hash of the password for accessing the RTL server.

          Generate with `printf '<password>' | openssl dgst -sha256`.
        '';
      };

      port = lib.mkOption {
        type = lib.types.int;
        default = 3000;
        description = ''
          Port to listen on.
        '';
      };

      defaultNodeIndex = lib.mkOption {
        type = lib.types.int;
        default = 1;
        description = ''
          Default start up node at server restart.
        '';
      };

      nodes = lib.mkOption {
        type = lib.types.listOf nodeParamsType;
        default = [];
        description = ''
          Lightning node to connect with. (Only c-lightning is supported.)
        '';
      };
    };
  };

  config =
    let
      cfg = config.services.rtl;

      rtlConf = {
        inherit (cfg) port defaultNodeIndex;
        multiPassHashed = cfg.passwordHash;
        SSO.rtlSSO = 0;
        nodes = lib.lists.imap1 mkNode cfg.nodes;
      };

      configFile = pkgs.writeTextDir "RTL-Config.json" (builtins.toJSON rtlConf);
    in lib.mkIf cfg.enable {
      systemd.services.rtl = {
        description = "Ride The Lightning backend server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          Environment = "RTL_CONFIG_PATH=${configFile}";
          ExecStart = "${pkgs.nodejs}/bin/node ${pkgs.rtl}/rtl.js";
          DynamicUser = true;
          Restart = "on-failure";
          StateDirectory = "rtl";

          PrivateDevices = true;
          ProtectSystem = "strict";
          ProtectHome = "read-only";
          NoNewPrivileges = true;
        };
      };
    };
}
