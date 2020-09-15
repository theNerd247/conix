pkgs: 

let
  T = import ./types.nix;
  C = import ./content.nix;
  CJ = import ./copyJoin.nix pkgs;
  R = import ./reader.nix;
in

rec
{
  docs.fs.mkFile.type = "RenderType -> ResF [Derivation] -> ResF Derivation";
  evalRenderType = T.match
    { 
      "noFile" = _: res.fmap (_: drvMonoid.mempty);
      "markdown" = mkFileDir mkFile;

      # TODO: split this up into the inital encoding. Right now it's 
      # in final encoding so it's difficult on how to handle rendering for more specific cases
      # That is, if we're rendering a pdf then we don't need to keep the drvs because they'll
      # be embedded into the pdf. But if we're rending html then they should be kept within
      # the output directory.
      "pandoc" = mkFileDir (d: x: mkPandoc d (mkFile d x));
      "dir" = x: res.fmap (mkDir x);
    };

  mkFileDir = f: d: x:
    res.fmap (ds: mkDir d ([(f d x.text)] ++ ds)) x;

  # RenderData -> [Derivation] -> Derivation
  mkDir = {_fileName,...}: CJ.collect _fileName; 

  # RenderData -> String -> Derivation
  mkFile = {_fileName,...}: pkgs.writeText "${_fileName}.md";

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

  drvMonoid = { mempty = {}; mappend = a: _: a; };
  listMonoid = { mempty = []; mappend = a: b: a ++ b; };

  #TODO: refactor the R evaluator from content.eval and make it more generic.
  docs.fs.evalAlg.type = ''
    ContentF (AttrSet -> ResF Derivation) -> (AttrSet -> ResF Derivation)
  '';
  evalAlg = 
    let
      rm = res.monoid drvMonoid;
      lm = res.monoid listMonoid;
    in
    T.match
    { 
      "end" = _: _: rm.mempty;
      "text" = text: _: res.onlyText text;
      "ask" = f: x: f x x;
      "tell" = {_entry, _next}: x: rm.mappend (_next x) (res.onlyData _entry);
      "local" = _sourcePath: _: res.pure _sourcePath;
      "file" = {_content, _renderType}:
        let
          foldMap = ((import ./monoid.nix) (R.monoid lm)).foldMap;

          # R r (ResF a) -> R r (ResF [a])
          toResList = R.fmap (res.fmap (x: if x == {} then [] else [x]));
        in
          R.fmap (evalRenderType _renderType) (foldMap toResList _content);
    };

  docs.eval.eval.type = "Fix ContentF -> ResF Derivation";
  eval = expr: 
    let
      mkRes = T.cata C.fmap evalAlg expr;
    in
      pkgs.lib.fix (a: mkRes a.data);

  docs.eval.run.type = "Fix ContentF -> Derivation";
  run = expr: (eval expr).drv;
}
