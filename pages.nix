self: super:

{ conix = (super.conix or {}) //
  rec
  { 
    text 
      # (ToText a) => Path -> a -> Module
      = path: text:
        let 
          pg = newPage text; 
        in
          newModuleResult (nest path pg) pg.text;

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
      = tOrM: if builtins.isAttrs tOrM then tOrM else pureModule tOrM;

    # This is re-exported to make the UI easier for users who use textsWith
    # Hopefully I can find a better fix for the string builtins.isString
    # problem (see github issue #2).
    t = pureModule;

    buildPages 
      # [ (Pages -> Module a) ] -> Pages
      = fs: runModule (pages: foldMapModules (f: f pages) fs); 

    runModule 
      # (Pages -> Module a) -> Pages
      = f: self.lib.fix (pgs: (mergeModules (textOf pgs) (f pgs)).pages);

    textOf
    = pages: setValue ["textOf"] 
      (path: pureModule (super.lib.attrsets.getAttrFromPath (path ++ [ "text" ]) pages)
      );

    createPageFromModule 
      # Path -> Module Text -> Module Text
      = path: bindModule (text path); 

    mergeModules 
      # Module Text -> Module Text -> Module Text
      = moduleA: moduleB:
        newModuleResult (mergePages moduleA.pages moduleB.pages) (moduleA.val + moduleB.val);

    newPage 
      # (ToString a) => a -> Page
      = x: { text = builtins.toString x; };

    mergePages 
      # Pages -> Pages -> Pages
      = self.lib.attrsets.recursiveUpdate;

    emptyModule 
      # Module Text
      = { pages = {}; val = ""; };

    pureModule 
      # a -> Module a
      = val: { pages = {}; inherit val; };

    pagesModule 
      # Pages -> Module Text
      = pages: { inherit pages; val = ""; };

    newModuleResult 
      # Pages -> a -> Module a
      = pages: val: { inherit pages; inherit val; };

    # Set a pure value
    setValue 
      # Path -> a -> Module a
      = path: val: newModuleResult (nest path val) (builtins.toString val);

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
      = f: module:
        newModuleResult module.pages (f module.val);

    mapPages 
      # (Pages -> Pages) -> Module a -> Module a
      = f: module:
          newModuleResult (f module.pages) (module.val);

    bindReader 
      # (a -> Pages -> b) -> (Pages -> a) -> Pages -> b
      = g: f: pages: g (f pages) pages;

    bindModule 
      # (a -> Module b) -> Module a -> Module b
      = f: module:
        mapPages (mergePages module.pages) (f module.val);

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
