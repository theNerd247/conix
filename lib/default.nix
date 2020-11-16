pkgs:

let
  internalLib = (import ./internal.nix pkgs)
    // (import ./eval.nix pkgs)
    // { inherit pkgs; };

  conix = internalLib._eval 
    internalLib
    (internalLib.liftNixValue 
      [ 
        (import ./readme.nix)
        (import ./conix.nix)
        (import ../tutorials)
        (import ./languageReference.nix)
      ]
    );

  userApi = conix.exprs;
in
  rec
  { 
    docs = conix.drv;
    eRes = conix;
  } // userApi 
