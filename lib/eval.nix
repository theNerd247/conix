pkgs: 

let
  T = import ./types.nix;
  M = import ./monoid.nix;
  C = import ./internal.nix pkgs;
  CJ = import ./copyJoin.nix pkgs;
  S = import ./textBlock.nix pkgs;
  R = import ./evalResult.nix pkgs;
in

rec
{

  # Make data defined in the given result locally scoped.
  # That is defined data is brought to global scope when
  # consumed and nested when produced.
  #
  # PathString -> ResF a -> ResF a
  locallyScopedData = pathString: x:
    let
      path = builtins.splitVersion pathString;
    in
      sap 
        (modify (unnestScope pathString))
        x
        (modify (nestScope pathString));

  # Nest the data and refs under the given operator
  # 
  # AttrPathString -> S -> S
  nestScope = path: {data, refs}: 
    with pkgs.lib.attrsets;
    { data = setAttrByPath path data;
      refs = setAttrByPath path refs;
    };

  
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
  unnestScope = path: {data, refs}:
    with pkgs.lib.attrsets;
    { 
      data = data // (getAttrFromPath path data);
      refs = data // (getAttrFromPath path refs);
    };

  # type ParentData = { parentPath :: FilePathString, data :: AttrSet }
  # 
  # type Result a = { text :: String, data :: AttrSet, drv :: a, currentPath :: FilePathString }
  #
  # data ResF a = ParentData -> Result a
  #
  docs.fs.evalAlg.type = "ContentF (ResF Derivation) -> ResF Derivation";
  evalAlg = 
    T.match
      { 
        # Evaluate anything that isn't { _type ... } ...
        tell   = _data: 
          R.onlyData _data;
        text   = text: 
          R.onlyText (builtins.toString text);
        indent = {_nSpaces, _next}: 
          R.overText (S.indent _nSpaces) _next;
        local  = _sourcePath: 
          R.pure _sourcePath;
        file   = {_mkFile, _next}: 
          R.fmapWith ({drv, text, ...}: R.mergeDrv drv (_mkFile text)) _next;
        merge  = xs: 
          (M (R.monoid)).mconcat xs;
        dir    = {_dirName, _next}: 
          R.fmap (drv: CJ.dir _dirName [drv]) _next;
        using  = r: 
          R.join r;
        ask    = x: 
          R.noData x;
        nest   = {_path, _next}: 
          R.locallyScopedData _path _next;
        anchor = {_path, _next}:
          R.addFileUrl _path _next;
      }; 

  _eval = lib: expr: 
    pkgs.lib.fix (a: T.cata C.fmap evalAlg expr (lib // { inherit (a) data; }));
    #pkgs.lib.fix (a: T.cata C.fmap evalAlg (C.liftNixValue expr) (lib // { inherit (a) data; }));

  _run = lib: expr: (_eval lib expr).drv;
}
