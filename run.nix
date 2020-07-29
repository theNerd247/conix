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
          toplevel = pgs: (addons pgs) // (f pgs);
        in
          self.lib.fix toplevel;

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
