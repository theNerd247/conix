pkgs: 

let
  internalLib = (import ./content.nix pkgs)
    // (import ./eval.nix pkgs)
    // { inherit pkgs; };


  conix = internalLib._eval 
    (import ./module.nix internalLib) 
    (internalLib.liftNixValue (import ./conix.nix));

  userApi = conix.data;
in
  rec
  { 
    run = x: (eval x).drv;
    eval = x: internalLib._eval userApi (internalLib.liftNixValue x);
    #docs = run (api.html "docs" conix.text);
  } // userApi
