{
  inputs = 
  { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  
  outputs = inputs: 
    { packages.aarch64-darwin = 
      { conix = (import ./lib/default.nix (import inputs.nixpkgs { system = "aarch64-darwin"; }));
      };

      packages.x86_64-linux = 
      { conix = (import ./lib/default.nix (import inputs.nixpkgs { system = "x86_64-linux"; }));
      };
    };
}
