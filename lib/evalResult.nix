# NOTE: SEE NOTE in ./lib/rw.nix
#
# Res = { data :: AttrSet, drv :: Derivation, text :: String }
# R = { data :: AttrSet }
pkgs:

let
  CJ = import ./copyJoin.nix pkgs;

  # AttrSet -> AttrSet -> AttrSet
  mergeData = pkgs.lib.attrsets.recursiveUpdate; 

  # Derivation -> Derivation -> Derivation
  mergeDrv = a: b:
    let
      name = a.name or b.name or (builtins.baseNameOf a);
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
      mempty = 
        { 
          data = {};
          drv = {};
          targetName = "";
          text = "";
        };

      # Res -> Res -> Res
      mappend = a: b:
        { 
          data = mergeData a.data b.data;
          drv = mergeDrv a.drv b.drv;
          text = a.text + b.text;
        };
    };

in
  # type ResM a = RW R Res
  (import ./rw.nix monoid) // rec {

    # W -> R
    toReadOnly = x: 
      { data = x.data; };

    onlyData = data: 
    { 
      text = "";
      drv = {};
      inherit data; 
    };

    onlyText = text: 
    { 
      drv = {};
      data = {};
      inherit text; 
    };

    onlyDrv = drv: 
    { 
      text = "";
      data = {};
      inherit drv; 
    };

    overData = f: x:
    { 
      inherit (x) text drv;
      data = f x.data; 
    };

    overText = f: x:
    { 
      inherit (x) drv data;
      text = f x.text; 
    };

    overDrv = f: x: 
    { 
      inherit (x) text data;
      drv = f x.drv; 
    };

    addDrvFromText = f: x: 
    { 
      inherit (x) text data;
      drv = mergeDrv x.drv (f x.text); 
    };

    noData = overData (_: {});

    # Nest the data and refs under the given operator
    # 
    # AttrPathString -> S -> S
    nestScope = path: x:
      let
        f = pkgs.lib.attrsets.setAttrByPath path;
      in
        overData f x;
    
    # NOTE: for this to be an isomorphism of AttrPathString 
    # `data` and `refs` must ONLY contain data at the given
    # path. If this were not the case then accidental over-
    # writing of attributes in the current scope could occur.
    #
    # E.g.
    #   let 
    #     x = { a = 3; };
    #     y = (nestScope "b" x) // { a = 2; }; # == { a = 2; b = { a = 3; }; }
    #   in
    #     unnestScope "b" z == x != z 
    #
    # AttrPathString -> S -> S
    unnestScope = path: x:
      let
          f = d: d // pkgs.lib.attrsets.getAttrFromPath path d;
      in
        overData f x;
}
