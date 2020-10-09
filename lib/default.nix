pkgs: 

let
  internalLib = (import ./content.nix pkgs)
    // (import ./eval.nix pkgs);

  lib = { inherit pkgs; } // internalLib;

  conix = internalLib._eval lib (import ./conix.nix);

  api = conix.data // { inherit pkgs; };
in
  rec
  { 
    run = internalLib._run api;
    docs = run (api.html "docs" conix.text);
  }
  // api
