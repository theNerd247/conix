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

# Res = { data :: AttrSet, drv :: Derivation, text :: String, refs :: AttrSet }
# R = { data :: AttrSet, currentPath :: FilePathString }
pkgs:

let
  CJ = import ./copyJoin.nix pkgs;
  T = import ./types.nix;

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
          text = "";
          exprs = {};
        };

      # Res -> Res -> Res
      mappend = a: b:
        { 
          data = mergeData a.data b.data;
          refs = mergeData a.refs b.refs;
          exprs = mergeData a.exprs b.exprs;
          drv = mergeDrv a.drv b.drv;
          text = a.text + b.text;
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
      exprs = x.exprs;
    };

    onlyData = data: 
    { 
      text = "";
      drv = {};
      refs = {};
      exprs = {};
      inherit data; 
    };

    onlyText = text: 
    { 
      drv = {};
      data = {};
      refs = {};
      exprs = {};
      inherit text; 
    };

    onlyDrv = drv: 
    { 
      text = "";
      data = {};
      refs = {};
      exprs = {};
      inherit drv; 
    };

    onlyRefs = refs:
    {
      text = "";
      data = {};
      drv = {};
      exprs = {};
      inherit refs;
    };

    onlyExpr = exprs:
    {
      text = "";
      data = {};
      drv = {};
      refs = {};
      inherit exprs;
    };

    overData = f: x:
    { 
      inherit (x) text drv refs exprs;
      data = f x.data; 
    };

    overText = f: x:
    { 
      inherit (x) drv data refs exprs;
      text = f x.text; 
    };

    overDrv = f: x: 
    { 
      inherit (x) text data refs exprs;
      drv = f x.drv; 
    };

    overRefs = f: x:
    { 
      inherit (x) text data drv exprs;
      refs = f x.refs;
    };

    overExpr = f: x:
    { 
      inherit (x) text data drv refs;
      exprs = f x.exprs;
    };

    addDrvFromText = f: x: 
    { 
      inherit (x) text data refs exprs;
      drv = mergeDrv x.drv (f x.text); 
    };

    # Modify Res so that no values unsafe side-effects occur that could
    # create infinite recursion.
    noProduce = x: overExpr (_: {}) (overData (_: {}) (overRefs (_: {}) x));

    noProduceOnlyExprs = overExpr (_: {});

    # unlike overData, this modifies the data
    # value in reader environment so it is legal
    # to use (//)
    overLocalData = f: x:
      x // { data = f x.data; };

    overLocalRefs = f: x:
      x // { refs = f x.refs; };

    overLocalCurrentPath = f: x:
      x // { currentPath = f x.currentPath; };

    setAtPathStr = pathString:
      pkgs.lib.attrsets.setAttrByPath (builtins.splitVersion pathString);

    # Nest the data and refs under the given operator
    # 
    # AttrPathString -> S -> S
    nestScope = pathStr: x:
      let
        f = setAtPathStr pathStr;
      in
        overData f (overRefs f x);
    
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
    unnestScope = pathStr: x:
      let
          f = d: d // pkgs.lib.attrsets.getAttrFromPath (builtins.splitVersion pathStr) d;
      in
        overLocalData f (overLocalRefs f x);

    # Extend the current file with the given path removing
    # the basename if it's a file.
    extendCurrentPath = path: overLocalCurrentPath (c: extendPath c path);

    isFile = x: builtins.match ".*[.][[:alnum:]]+$" (builtins.baseNameOf x) == [];

    extendPath = currentPath: path:
      if isFile currentPath && isFile path then (builtins.dirOf currentPath) + "/" + path
      else if isFile currentPath then currentPath + path
      else currentPath + "/" + path;

    # Contruct how a piece of content should be referenced
    # from other content. This should be the most
    targetNameOf = currentPath: refPathStr: T.match
    { 
      use  = x: targetNameOf refPathStr x;
      file = {_fileName,...}: extendPath currentPath _fileName;
      dir  = {_dirName, ...}: extendPath currentPath _dirName;
      _    = x: "${currentPath}#${refPathStr}";
    };

    pathStrToList = p: builtins.filter (x: x != "") (pkgs.lib.splitString "/" p);

    makeRelativePath = currentPath: targetPath:
      let
        coalg = cPath: tPath: with builtins;
          let
            cHead = head cPath;
            tHead = head tPath;
            cTail = if builtins.length cPath == 0 then [] else tail cPath;
            tTail = tail tPath;
          in
                 if length cPath == 0 then builtins.concatStringsSep "/" tPath
            else if cHead == tHead    then coalg cTail tTail
            else                           builtins.concatStringsSep "/" ((builtins.map (_: "..") cTail) ++ tPath);
      in
        "./" + coalg (pathStrToList currentPath) (pathStrToList targetPath);
  }
