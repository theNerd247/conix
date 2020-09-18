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
  docs.fs.mdFile.type = "RenderType -> ResF Derivation -> ResF Derivation";
  evalRenderType = T.match
    { 
      "markdown" = r: x: mdFile r x._text;

      # TODO: split this up into the inital encoding. Right now it's 
      # in final encoding so it's difficult on how to handle rendering for more specific cases
      # That is, if we're rendering a pdf then we don't need to keep the drvs because they'll
      # be embedded into the pdf. But if we're rending html then they should be kept within
      # the output directory.
      "pandoc" = r: res.fmap (x: mkPandoc d (mdFile d x._text));
      "dir" = {_fileName}: res.fmap (CJ.collect _fileName);
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
      onlyText = text: { inherit text; drv = drvMonoid.mempty; data = {}; };

      # AttrSet -> ResF Derivation
      onlyData = data: { text = ""; drv = drvMonoid.mempty; inherit data; };

      # a -> ResF a
      pure = drv: { text = ""; inherit drv; data = {}; };

      fmap = f: x: { inherit (x) text data; drv = f x.drv; };

      # (Monoid m) => instance Monoid (ResF m)
      monoid = {mempty, mappend}:
        {
          mempty = { text = ""; drv = mempty; data = {}; };
          mappend = a: b:
            {
              text = a.text + b.text;
              drv = mappend a.drv b.drv;
              data = pkgs.lib.attrsets.recursiveUpdate a.data b.data;
            };
        };
    };

  drvMonoid = { mempty = {}; mappend = a: b: CJ.collect a.name; };

  docs.fs.evalAlg.type = "ContentF (ResF Derivation) -> ResF Derivation";
  evalAlg = 
    let
      rm = res.monoid drvMonoid;
    in
    T.match
      { 
        "tell"  = {_data, _next}: rm.mappend (res.onlyData _entry) _next;
        "text"  = text: res.onlyText text;
        "local" = _sourcePath: res.pure _sourcePath;
        "file"  = {_content, _renderType}: evalRenderType _renderType _content;
        "merge" = (M rm).mconcat;
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
