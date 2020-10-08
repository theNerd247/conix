pkgs: 

let
  T = import ./types.nix;
  C = import ./content.nix pkgs;
  CJ = import ./copyJoin.nix pkgs;
  R = import ./reader.nix;
  M = import ./monoid.nix;
in

rec
{
  docs.fs.mdFile.type = "RenderType -> ResF Derivation -> ResF Derivation";
  evalRenderType = T.match
    { 
      "markdown" = r: res.fmapWith (x: res.mergeDrv x.drv (mdFile r x));

      # TODO: split this up into the inital encoding. Right now it's 
      # in final encoding so it's difficult on how to handle rendering for more specific cases
      # That is, if we're rendering a pdf then we don't need to keep the drvs because they'll
      # be embedded into the pdf. But if we're rending html then they should be kept within
      # the output directory.
      "pandoc" = r: res.fmapWith (x: res.mergeDrv x.drv (mkPandoc r x));

      "dir" = r: res.fmap (mkDir r);
    };

  # RenderData -> String -> Derivation
  mdFile = {_fileName,...}: {text,...}: 
    pkgs.writeText "${_fileName}.md" text;

  # RenderData -> Derivation -> Derivation
  mkPandoc = r@{_pandocArgs, _buildInputs, _pandocType, _fileName}: {text,...}:
    pkgs.runCommand "${_fileName}.${_pandocType}" { buildInputs = [ pkgs.pandoc ] ++ _buildInputs; }
      ''
        ${pkgs.pandoc}/bin/pandoc -s -o $out ${_pandocArgs} ${mdFile r text}
      '';

  # RenderData -> Derivation -> Derivation
  mkDir = {_fileName, ...}: drv:
    CJ.dir _fileName [drv];

  # data ResF a = AttrSet -> ResF { text :: String, data :: AttrSet, drv :: a}
  res =
    rec
    {
      # String -> ResF Derivation
      onlyText = text: _:
        { inherit text; drv = {}; data = {}; };

      onlyData = data: _:
        { inherit data; drv = {}; text = ""; };

      mergeData = pkgs.lib.attrsets.recursiveUpdate; 

      # AttrSet -> ResF Derivation
      addData = _data: f: r: 
        let
          x = f r;
        in
          { inherit (x) text drv; 
            data = mergeData x.data _data; 
          };

      # a -> ResF a
      pure = drv: _: { text = ""; inherit drv; data = {}; };

      fmap = f: fmapWith (x: f x.drv);

      fmapWith = f: g: x: 
        let
          r = g x;
        in
          { inherit (r) text data;
            drv = f r;
          };


      mergeDrv = a: b:
        if a ? name then
          CJ.collect a.name [a b] 
        else
          b;

      # (Monoid m) => instance Monoid (ResF m)
      monoid =
        {
          mempty = _: { text = ""; drv = {}; data = {}; };
          mappend = f: g: x:
            let
              a = f x;
              b = g x;
            in
            {
              text = a.text + b.text;
              data = mergeData a.data b.data;
              drv = mergeDrv a.drv b.drv;
            };
        };
    };

  docs.fs.evalAlg.type = "ContentF (ResF Derivation) -> ResF Derivation";
  evalAlg = 
    T.match
      { 
        # Evaluate anything that isn't { _type ... } ...
        "tell"  = {_data, _next}: res.addData _data _next;
        "text"  = text: res.onlyText (builtins.toString text);
        "local" = _sourcePath: res.pure _sourcePath;
        "file"  = {_renderType, _next}:
          evalRenderType _renderType _next;
        "merge" = xs: (M (res.monoid)).mconcat xs;
        "using" = r: x: r x x;
      }; 

  docs.eval.eval.type = "Content -> { drv :: Derivation, text :: String, data :: AttrSet }";
  eval = expr: 
    let
      lib = { inherit pkgs; } // C;
      mkRes = C.liftNixValue expr;
    in
      pkgs.lib.fix (a: T.cata C.fmap evalAlg mkRes (lib // { inherit (a) data; }));

  docs.eval.run.type = "Content -> Derivation";
  run = expr: (eval expr).drv;
}
