pkgs: 

let
  T = import ./types.nix;
  C = import ./content.nix;
  CJ = import ./copyJoin.nix pkgs;
  R = import ./reader.nix;
  M = import ./monoid.nix;
in

rec
{
  docs.fs.mdFile.type = "RenderType -> Text -> Derivation";
  evalRenderType = T.match
    { 
      "markdown" = mdFile; 

      # TODO: split this up into the inital encoding. Right now it's 
      # in final encoding so it's difficult on how to handle rendering for more specific cases
      # That is, if we're rendering a pdf then we don't need to keep the drvs because they'll
      # be embedded into the pdf. But if we're rending html then they should be kept within
      # the output directory.
      "pandoc" = r: t: mkPandoc r (mdFile r t);
    };

  # RenderData -> String -> Derivation
  mdFile = {_fileName,...}: pkgs.writeText "${_fileName}.md";

  # RenderData -> Derivation -> Derivation
  mkPandoc = {_pandocArgs, _buildInputs, _pandocType, _fileName}: textFileDrv:
    pkgs.runCommand "${_fileName}.${_pandocType}" { buildInputs = [ pkgs.pandoc ] ++ _buildInputs; }
      ''
        ${pkgs.pandoc}/bin/pandoc -s -o $out ${_pandocArgs} ${textFileDrv}
      '';

  # data ResF a = ResF { text :: String, data :: AttrSet, drv :: a}
  res =
    rec
    {
      # String -> ResF Derivation
      onlyText = text: { inherit text; drv = {}; data = {}; };

      onlyData = data: { inherit data; drv = {}; text = ""; };

      mergeData = pkgs.lib.attrsets.recursiveUpdate; 

      # AttrSet -> ResF Derivation
      addData = _data: x: 
        { inherit (x) text drv; data = mergeData x.data _data; };

      # a -> ResF a
      pure = drv: { text = ""; inherit drv; data = {}; };

      fmap = f: x: { inherit (x) text data; drv = f x.drv; };

      # (Monoid m) => instance Monoid (ResF m)
      monoid = drvDirName:
        {
          mempty = { text = ""; drv = {}; data = {}; };
          mappend = a: b:
            {
              text = a.text + b.text;
              drv = CJ.collect drvDirName [a.drv b.drv]; 
              data = mergeData a.data b.data;
            };
        };
    };

  mkDir = name: (M (res.monoid name)).mconcat;

  docs.fs.evalAlg.type = "ContentF (ResF Derivation) -> ResF Derivation";
  evalAlg = 
    T.match
      { 
        "*"     = x: 
          if builtins.isString x then res.onlyText x else
          if builtins.isAttrs x then res.onlyData x else
          (res.monoid "").mempty;
        "tell"  = {_data, _next}: res.addData _data _next;
        "text"  = text: res.onlyText text;
        "local" = _sourcePath: res.pure _sourcePath;
        "file"  = {_renderType, _next}: 
          mkDir (C.renderTypeFileName _renderType) [(res.pure (evalRenderType _renderType _next.text)) _next];
        "dir" = {_dirName, _next}: mkDir _dirName _next;
      }; 

  docs.eval.eval.type = "(AttrSet -> Content) -> ResF Derivation";
  eval = mkExpr: 
    let
      mkRes = T.cata C.fmap evalAlg;
    in
      pkgs.lib.fix (a: mkRes (mkExpr a.data));

  docs.eval.run.type = "Fix ContentF -> Derivation";
  run = expr: (eval expr).drv;
}
