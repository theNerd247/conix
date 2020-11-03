# NOTE: 
#
# Treat all values of attribute `data` for type R and Res as if they
# were possibly bottom values to avoid infinite recursion problems.
# 
# Conceptually every expression could produce a `data` value
# which will be included in the final `data` value (when passed through
# `fix`). Because of this any function that manipulates any `data`
# value should have its return value stored in an attribute set.
#
# As a result I've followed a rule for writing this portion of the 
# library: avoid any {...} or (//) syntax, and explicitely access attribute
# values through dot notation.  This increases boilerplate code, however
# doing so prevents infite recursion issues.

# Res = { data :: AttrSet, drv :: Derivation, text :: String, targetName :: FilePathString, refs :: AttrSet }
# R = { data :: AttrSet, currentPath :: FilePathString }
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
          refs = {};
          drv = {};
          targetName = "";
          text = "";
        };

      # Res -> Res -> Res
      mappend = a: b:
        { 
          data = mergeData a.data b.data;
          refs = mergeData a.refs b.refs;
          drv = mergeDrv a.drv b.drv;
          text = a.text + b.text;
          targetName = a.targetName;
        };
    };

in
  # type ResM a = RW R Res
  (import ./rw.nix monoid) // rec {

    # W -> R
    toReadOnly = currentPath: x: 
    { 
      inherit currentPath;
      data = x.data; 
      refs = x.refs;
    };

    onlyData = data: 
    { 
      text = "";
      drv = {};
      refs = {};
      targetName = "";
      inherit data; 
    };

    onlyText = text: 
    { 
      drv = {};
      data = {};
      refs = {};
      targetName = "";
      inherit text; 
    };

    onlyDrv = drv: 
    { 
      text = "";
      data = {};
      refs = {};
      targetName = "";
      inherit drv; 
    };

    overData = f: x:
    { 
      inherit (x) text drv targetName refs;
      data = f x.data; 
    };

    overText = f: x:
    { 
      inherit (x) drv data targetName refs;
      text = f x.text; 
    };

    overDrv = f: x: 
    { 
      inherit (x) text data targetName refs;
      drv = f x.drv; 
    };

    overTargetName = f: x:
    {
      inherit (x) text data drv refs;
      targetName = f x.targetName;
    };

    overRefs = f: x:
    { 
      inherit (x) text data drv targetName;
      refs = f x.refs;
    };

    addDrvFromText = f: x: 
    { 
      inherit (x) text data targetName refs;
      drv = mergeDrv x.drv (f x.text); 
    };

    noData = overData (_: {});

    # unlike overData, this modifies the data
    # value in reader environment so it is legal
    # to use (//)
    overLocalData = f: x:
      x // { data = f x.data; };

    overLocalCurrentPath = f: x:
      x // { currentPath = f x.currentPath; };

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
    unnestScope = path:
      let
          f = d: d // pkgs.lib.attrsets.getAttrFromPath path d;
      in
        overLocalData f;

    extendCurrentPath = path:
      overLocalCurrentPath (p: p + "/" + path);
}
