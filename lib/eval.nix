pkgs: 

let
  T = import ./types.nix;
  M = import ./monoid.nix;
  I = import ./internal.nix pkgs;
  CJ = import ./copyJoin.nix pkgs;
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
  #
  docs.fs.evalAlg.type = "ContentF (ResF Derivation) -> ResF Derivation";
  evalAlg = 
    T.match
      { 
        # Evaluate anything that isn't { _type ... } ...
        tell   = _data: 
          R.tell (R.onlyData _data);
        expr = _expr:
          R.tell (R.onlyExpr _expr);
        text   = text: 
          R.tell (R.onlyText (builtins.toString text));
        modtxt = {_modify, _next}: 
          R.censor (R.overText _modify) (T.onRes _next);
        local  = _sourcePath: 
          R.tell (R.onlyDrv _sourcePath);
        file   = {_fileName, _mkFile, _next}: 
          R.censor (R.addDrvFromText _mkFile)
          (R.local (R.extendCurrentPath _fileName) (T.onRes _next));
        merge = _nexts:
          R.traverse_ T.onRes _nexts;
        dir    = {_dirName, _next}: 
          R.censor 
          (R.overDrv (drv: CJ.dir _dirName [drv]))
          (R.local (R.extendCurrentPath _dirName) (T.onRes _next));
        using  = f: r: # ContentF (r -> (RW r w a, Content))
          T.onRes (f r) r;
        ask    = _next:
          R.censor R.noProduce (T.onRes _next);
        use = _next:
          R.censor R.noProduceOnlyExprs (T.onRes _next);
        nest   = {_path, _next}: 
          R.censor 
            (R.nestScope _path) 
            (R.local (R.unnestScope _path) (T.onRes _next));
        ref    = {_path, _next}:
          R.lap 
            (T.onRes _next)
            (R.tellWith ({currentPath,...}: 
              let
                t = R.targetNameOf currentPath (builtins.concatStringsSep "." _path) (T.onChild _next);
              in
                R.onlyRefs (pkgs.lib.attrsets.setAttrByPath _path t)
            ));
        link   = _path:
          R.tellWith ({currentPath, ...}:
            R.onlyText (R.makeRelativePath currentPath _path)
          ); 
      };

  _eval = lib: expr: 
    let
      #     R -> R * X     F R
      #
      # R * X -> R * X     F (R * X)
      f = R.exe (T.para I.fmap evalAlg expr);
    in
      pkgs.lib.fix (R.local (x: lib // (R.toReadOnly "./." x)) f);

  _run = lib: expr: (_eval lib expr).drv;
}
