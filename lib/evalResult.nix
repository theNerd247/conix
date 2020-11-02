# Res = { data :: AttrSet, targetName :: String, drv :: Derivation, text :: String, refs :: AttrSet }
# R = { data :: AttrSet, parentPath :: FilePathString, refs :: AttrSet }
pkgs:

let
  CJ = import ./copyJoin.nix pkgs;

  # AttrSet -> AttrSet -> AttrSet
  mergeData = pkgs.lib.attrsets.recursiveUpdate; 

  # Derivation -> Derivation -> Derivation
  mergeDrv = targetName: a: b:
    let
      name = 
        if targetName != "" then targetName 
        else a.name or b.name or (builtins.baseNameOf a);
    in
         if a == {} && b == {} then {}
    else if a == {}            then b 
    else if b == {}            then a 
    else CJ.collect name [a b];

  monoid = 
    # Monoid instance for the result of evaluating a conix expression
    rec
    {

      # Res
      mempty = x:
        { 
          data = x.data;
          refs = x.refs;
          drv = x.drv;
          targetName = x.targetName;
          text = x.text;
        };

      # Res -> Res -> Res
      mappend = a: b:
        rec
        { 
          data = mergeData a.data b.data;
          refs = mergeData a.refs b.refs;
          targetName = if a.targetName != "" then a.targetName else b.targetName;
          drv = mergeDrv targetName a.drv b.drv;
          text = a.text + b.text;
        };
    };

in
  # type ResM a = RW R Res
  RW = import ./rw.nix monoid;
