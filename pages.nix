self: super:

{ conix = (super.conix or {}) //
  rec
  { 
    textWith 
      # Path -> (Pages -> Text) -> Module
      = path: bindReader (text path);

    text 
      # Path -> Text -> Module
      = path: text: _: newModuleResult (nest path (newPage text)) text;

    textsWith 
      # Path -> (Pages -> [ Either Text Module ]) -> Module
      = path: bindReader (texts path);

    texts 
      # Path -> [ Either Text (Module Text) ] -> Module Text
      = path: textOrModules: 
        createPageFromModule path 
        (mapPages (nest path) 
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
  };
}
