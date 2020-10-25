pkgs: 

let
  T = import ./types.nix;
  M = import ./monoid.nix;

  C = import ./internal.nix pkgs;
  CJ = import ./copyJoin.nix pkgs;
  S = import ./textBlock.nix pkgs;
in

rec
{
  # data ResF a = AttrSet -> ResF { text :: String, data :: AttrSet, drv :: a}
  res =
    rec
    {
      # String -> ResF Derivation
      onlyText = text: _:
        { inherit text; drv = {}; data = {}; };

      onlyData = data: _:
        { inherit data; drv = {}; text = ""; };

      overText = f: g: x:
        let
          r = g x;
        in
          { inherit (r) drv data; text = f r.text; };

      mergeData = pkgs.lib.attrsets.recursiveUpdate; 

      # AttrSet -> ResF Derivation
      noData = f: x:
        let
          r = f x;
        in
          { text = r.text;
            drv = r.drv;
            data = {};
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
        let
          name = a.name or b.name or (builtins.baseNameOf a);
        in
             if a == {} && b == {} then {}
        else if a == {}            then b 
        else if b == {}            then a 
        else CJ.collect name [a b];

      join = r: x: r x x;

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
        "tell"  = _data: res.onlyData _data;
        "text"  = text: res.onlyText (builtins.toString text);
        "indent" = {_nSpaces, _next}: 
          res.overText (S.indent _nSpaces) _next;
        "local" = _sourcePath: res.pure _sourcePath;
        "file"  = {_mkFile, _next}:
          res.fmapWith (x: res.mergeDrv x.drv (_mkFile x.text)) _next;
        "merge" = xs: (M (res.monoid)).mconcat xs;
        "dir" = {_dirName, _next}: 
          res.fmap (drv: CJ.dir _dirName [drv]) _next;
        "using" = r: res.join r;
        "ref" = x: res.noData x;
      }; 

  _eval = lib: expr: 
    pkgs.lib.fix (a: T.cata C.fmap evalAlg expr (lib // { inherit (a) data; }));
    #pkgs.lib.fix (a: T.cata C.fmap evalAlg (C.liftNixValue expr) (lib // { inherit (a) data; }));

  _run = lib: expr: (_eval lib expr).drv;
}
