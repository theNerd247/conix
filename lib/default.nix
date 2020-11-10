pkgs: {extensions ? {}}:

let
  internalLib = (import ./internal.nix pkgs)
    // (import ./eval.nix pkgs)
    // { inherit pkgs; };

  conix = internalLib._eval 
    internalLib
    (internalLib.liftNixValue 
      [ 
        (import ./conix.nix)
        (import ../tutorials)
        extensions
      ]
    );

  userApi = conix.exprs; #// { inherit run eval; };

  #run = x: (eval x).drv;

  #eval = x: internalLib._eval userApi (internalLib.liftNixValue x);

in
  rec
  { 
    docs = conix.drv;
    evalRes = conix;
    inherit (internalLib) I;
  } // userApi 
