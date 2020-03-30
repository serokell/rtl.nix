<!--
SPDX-FileCopyrightText: 2020 Serokell <https://serokell.io/>

SPDX-License-Identifier: MPL-2.0
-->

# rtl.nix

Nix expressions and NixOS modules for [Ride-The-Lightning].

This repository contains everything you need to run RTL with [c-lightning].
In particular, it provides a module for the RTL backend server and a module
that enables the c-lightning REST plugin required by RTL.

[Ride-The-Lightning]: https://github.com/Ride-The-Lightning/RTL
[c-lightning]: https://github.com/ElementsProject/lightning


## Usage

This repository is structured as a “fake flake” and uses [niv] for managing
dependencies. To import it, do:

```nix
let
  rtl_nix = import (builtins.fetchTarball "https://github.com/serokell/rtl.nix/archive/master.tar.gz");
in
  /* ... */
```

(Or use [niv] to pin a specific version rather than `master`.)

### On your Lightning server

Import the plugin module, add the overlay, and enable the plugin:

```nix
{

  imports = /* ... ++ */ [ rtl_nix.modules.clightning_rest ];

  nixpkgs.overlays = /* ... ++ */ [ rtl_nix.overlay ];

  services = {
    clightning = {
      /* ... */
      plugins.rest =  {
        enable = true;
      };
    };
  };

}
```

_Note: we assume you alread have a clightning module imported._

_Note: See the descriptions of configuration options for more details and examples._

After you restart your c-lightning node, it will create a token (macaroon) in
`/var/lib/cl-rest/certs/access.macaroon`. You will need to copy this file to
the RTL server.

### On your RTL server

Import the Ride-The-Lightning module, add the overlay, and enable the service:

```nix
{

  imports = /* ... ++ */ [ rtl_nix.modules.rtl ];

  nixpkgs.overlays = /* ... ++ */ [ rtl_nix.overlay ];

  services = {
    rtl = {
      enable = true;
      passwordHash = "<hash of your password>";
      nodes = [
        /* ... */
      ];  # configure what lightning nodes to talk to
    };
  };

}
```

_Note: See the descriptions of configuration options for more details and examples._

Each individual node configuration is pretty straightforward, just be sure to set
`authentication.macaroonPath` to the path of the macaroon file you copied from the
corresponding Lightning node server.

[niv]: https://github.com/nmattia/niv


## License

[MPL-2.0] © [Serokell]

[MPL-2.0]: https://spdx.org/licenses/MPL-2.0.html
[Serokell]: https://serokell.io/
