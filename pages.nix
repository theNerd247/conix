self: super:

{ conix = (super.conix or {}) //
  rec
  { 
    textWith 
      # Path -> (Pages -> Text) -> Module
      = path: bindReader (text path);

    text 
      # (ToText a) => Path -> a -> Module
      = path: text: _: 
        let 
          pg = newPage text; 
        in
          newModuleResult (nest path pg) pg.text;

    textsWith 
      # Path -> (Pages -> [ Either Text Module ]) -> Module
      = path: bindReader (texts path);

    texts 
      # Path -> [ Either Text (Module Text) ] -> Module Text
      = path: textOrModules: 
        createPageFromModule path 
        (nestModule path
          (foldMapModules valOrModuleToModule textOrModules)
        ); 

    # NOTE: do not call this if the strings could contain interpolations that
    # contain references to the final page set. This will result in infinite
    # recursion
    valOrModuleToModule 
      # Either a (Module a) -> Module a
      = tOrM: if builtins.isFunction tOrM then tOrM else pureModule tOrM;

    # This is re-exported to make the UI easier for users who use textsWith
    # Hopefully I can find a better fix for the string builtins.isString
    # problem (see github issue #2).
    t = pureModule;

    buildPages 
      # [ Module a ] -> Pages
      = modules: runModule (foldModules modules); 

    # Run a single module and extract the resulting page.
    # This is to make creating single page page sets a convenience and
    # should be used with functions that create a page nested under a
    # given path (like text, textWith, texts, or textsWith).
    single 
      # (Path -> a -> Module a) -> a -> Page
      = mkModule: a: (runModule (mkModule [ "x" ] a)).x;

    runModule 
      # Module a -> Pages
      = module: self.lib.fix (pgs: (module pgs).pages);

    createPageFromModule 
      # Path -> Module Text -> Module Text
      = path: bindModule (text path); 

    mergeModules 
      # Module Text -> Module Text -> Module Text
      = moduleA: moduleB: pages: 
      let
        rA = moduleA pages;
        rB = moduleB pages;
      in
        newModuleResult (mergePages rA.pages rB.pages) (rA.val + rB.val);

    newPage 
      # (ToString a) => a -> Page
      = x: { text = builtins.toString x; };

    mergePages 
      # Pages -> Pages -> Pages
      = self.lib.attrsets.recursiveUpdate;

    emptyModule 
      # Module Text
      = _: { pages = {}; val = ""; };

    pureModule 
      # a -> Module a
      = val: _: { pages = {}; inherit val; };

    pagesModule 
      # Pages -> Module Text
      = pages: _: { inherit pages; val = ""; };

    newModuleResult 
      # Pages -> a -> Module a
      = pages: val: { inherit pages; inherit val; };

    # Set a pure value
    setValue 
      # Path -> a -> Module a
      = path: val: _: newModuleResult (nest path val) val;

    # Sets the text of a module the empty string
    hidden 
      # Module a -> Module Text
      = mapVal (_: "");

    # Nest the pages under a path for a given module
    nestModule
      # Path -> Module a -> Module a
      = path: mapPages (nest path);

    nest 
      # Path -> a -> Pages 
      = self.lib.attrsets.setAttrByPath;

    mapVal 
      # (a -> b) -> Module a -> Module b
      = f: module: pages:
      let
        pagesAndText = module pages; 
      in
        newModuleResult pagesAndText.pages (f pagesAndText.val);

    mapPages 
      # (Pages -> Pages) -> Module a -> Module a
      = f: module: pages:
        let
          pagesAndText = module pages;
        in
          newModuleResult (f pagesAndText.pages) (pagesAndText.val);

    bindReader 
      # (a -> Pages -> b) -> (Pages -> a) -> Pages -> b
      = g: f: pages: g (f pages) pages;

    bindModule 
      # (a -> Module b) -> Module a -> Module b
      = f: module: pages:
      let
        pagesAndText = module pages;
        res = f pagesAndText.val pages;
      in
        newModuleResult (mergePages pagesAndText.pages res.pages) (res.val);

    foldModules 
      # [ Module Text ] -> Module Text
      = foldMapModules (x: x);

    foldMapModules 
      # (a -> Module Text) -> [ a ] -> Module Text
      = f: builtins.foldl' (m: x: mergeModules m (f x)) emptyModule;

    foldMapModulesIx 
      # (Natural -> a -> Module Text) -> [a] -> Module Text
      = f: foldlIx (ix: m: x: mergeModules m (f ix x)) emptyModule;

    foldlIx 
      # (Natural -> b -> a -> b) -> b -> [a] -> b
      = f: initB: as: 
        (builtins.foldl' ({ix, b}: a: {ix = ix+1; b = f ix b a; }) {ix = 0; b = initB;} as).b;
  };
}
