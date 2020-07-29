self: super:

with super.conix;

{ conix = (super.conix or {}) //
  rec
  {
    buildPages 
      # [ (Pages -> Module a) ] -> Pages
      = fs: runModule (pages: foldMapModules (f: f pages) fs); 

    runModule 
      # (Pages -> Module a) -> Pages
      = f:
        let
          toplevel = pgs: let r = f pgs; in (addons pgs) 
            # This should be `// (f pgs)` however, because of the way nix does lazy evaluation
            # we have to to do a hack to get r.pages to be lazy. In this case we construct an
            # attribute set whos values are the nested values in f's thunk.
            # I'm not sure if there's a better fix for this...
            // { pages = r.pages; val = r.val; };
        in
          (self.lib.fix toplevel).pages;

    # these are conix library functions that depend on the toplevel pages
    addons
      = pages:
        super.conix //
        rec
        { 
          textOf = path: at (path ++ [ "text" ]);
          at = path: pureModule (super.lib.attrsets.getAttrFromPath (["pages"] ++ path) pages);
        };
  };
}
