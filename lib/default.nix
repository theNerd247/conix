pkgs: 

let
  internalLib = (import ./content.nix pkgs)
    // (import ./eval.nix pkgs);

  conix = internalLib._eval 
    ({ inherit pkgs; } // internalLib) 
    (internalLib.liftNixValue (import ./conix.nix));

  api = conix.data // { inherit pkgs; };
in
  rec
  { 
    run = x: (eval x).drv;
    eval = x: internalLib._eval api (internalLib.liftNixValue x);
    #docs = run (api.html "docs" conix.text);
  }
  // api
