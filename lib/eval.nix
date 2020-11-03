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
          R.tell (R.onlyData _data);
        text   = text: 
          R.tell (R.onlyText (builtins.toString text));
        indent = {_nSpaces, _next}: 
          R.censor (R.overText (S.indent _nSpaces)) _next;
        local  = _sourcePath: 
          R.tell (R.onlyDrv _sourcePath);
        file   = {_mkFile, _next}: 
          R.censor (R.addDrvFromText _mkFile) _next;
        merge = xs: 
          R.sequence_ xs;
        dir    = {_dirName, _next}: 
          R.censor (R.overDrv (drv: CJ.dir _dirName [drv])) _next;
        using  = r: 
          R.readerJoin r;
        ask    = x:
          R.censor R.noData x;
        nest   = {_path, _next}: 
          let
            path = builtins.splitVersion _path;
          in
            R.censor (R.nestScope path) 
              (R.local (R.unnestScope path) _next);
      }; 

  _eval = lib: expr: 
    let
      #     R -> R * X     F R
      #
      # R * X -> R * X     F (R * X)
      f = R.exe (T.cata C.fmap evalAlg expr);
    in
      pkgs.lib.fix (R.local (x: lib // (R.toReadOnly x)) f);

  _run = lib: expr: (_eval lib expr).drv;
}
