pkgs:

let
  CJ = import ./copyJoin.nix pkgs;
in

# ResM a = StateT { data :: AttrSet, currentPath :: FilePathString } (Writer String a)
rec
{
  # String -> ResF Derivation
  onlyText = text: _:
    { inherit text; drv = {}; data = {}; };

  # AttrSet -> ResF Derivation
  onlyData = data: _:
    { inherit data; drv = {}; text = ""; };

  # (String -> String) -> ResF a -> ResF a
  overText = f: g: x:
    let
      r = g x;
    in
      { inherit (r) drv data; text = f r.text; };

  # AttrSet -> AttrSet -> AttrSet
  mergeData = pkgs.lib.attrsets.recursiveUpdate; 

  # (Result a -> AttrSet) -> ResF a -> ResF a
  modifyData = g: f: x:
    let
      r = f x;
    in
      { text = r.text;
        drv = r.drv;
        data = g r;
      };

  # ResF a -> ResF a
  noData = modifyData (_: {});

  # Make data defined in the given result locally scoped.
  # That is defined data is brought to global scope when
  # consumed and nested when produced.
  #
  # PathString -> ResF a -> ResF a
  locallyScopedData = pathString: f:
    let
      path = toPathList pathString;
    in
      nestData path (unnestData path f);

  toPathList = builtins.splitVersion;
      
  # Nest the generated data from the given ResF under
  # the provided path.
  nestData = path:
    modifyData ({data,...}: 
        pkgs.lib.attrsets.setAttrByPath path data
    );

  # Bring attributes at a given path to the toplevel before
  # passing down to generation function. This is used to
  # undo the effect of `nestPath`.
  #
  # PathString -> ResF a -> ResF a
  unnestData = path: f: x:
    f (x // {
      data = x.data // (pkgs.lib.attrsets.getAttrFromPath path x.data);
    });

  # Set the currentPath
  addFileUrl = refPathStr: 
    modifyData ({currentPath, data, ...}:
      mergeData 
        data
        (
          pkgs.lib.attrsets.setAttrByPath 
          (toPathList "${refs}.${refPathStr}") 
          currentPath
        )
    );

  # a -> ResF a
  pure = drv: _: { text = ""; inherit drv; data = {}; };

  # (a -> b) -> ResF a -> ResF b
  fmap = f: fmapWith (x: f x.drv);

  # (Result a -> b) -> ResF a -> ResF b
  fmapWith = f: g: x: 
    let
      r = g x;
    in
      { inherit (r) text data;
        drv = f r;
      };

  # Derivation -> Derivation -> Derivation
  mergeDrv = a: b:
    let
      name = a.name or b.name or (builtins.baseNameOf a);
    in
         if a == {} && b == {} then {}
    else if a == {}            then b 
    else if b == {}            then a 
    else CJ.collect name [a b];

  # (ParentData -> ResF a) -> ResF a
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
}
