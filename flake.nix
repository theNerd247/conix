{
  inputs = 
  { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  
  outputs = inputs: 
    let
      pkgs = import inputs.nixpkgs { system = "aarch64-darwin"; };
    in
      { packages.aarch64-darwin = 
        { conix = (import ./lib/default.nix pkgs);
        };
      };
}
