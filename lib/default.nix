pkgs: 

let
  internalLib = (import ./internal.nix pkgs)
    // (import ./eval.nix pkgs)
    // { inherit pkgs; };


  conix = internalLib._eval 
    internalLib
    (internalLib.liftNixValue (import ./conix.nix));

  userApi = conix.data; 
in
  rec
  { 
    run = x: (eval x).drv;
    eval = x: internalLib._eval userApi (internalLib.liftNixValue x);
    docs = conix.drv;
  } // userApi
