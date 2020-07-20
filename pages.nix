self: super:

{ conix = (super.conix or {}) //
  rec
  { newPage = text: { inherit text; };
    textPage_ = path: text:
      self.lib.attrsets.setAttrByPath path (newPage text);

    textPageWith = path: f: pages: 
      let 
        text = f pages;
      in
        { pages = textPage_ path text; inherit text; };

    textPage = path: text: pages: textPageWith path (_: text) pages;

    buildPages = module: self.lib.fix (pgs: (module pgs).pages);

    mergePages = pagesA: pagesB: pages: 
      let
        pagesAndTextA = pagesA pages;
        pagesAndTextB = pagesB pages;
      in
        { pages = self.lib.attrsets.recursiveUpdate pagesAndTextA.pages pagesAndTextB.pages;
          text = pagesAndTextA.text + pagesAndTextB.text;
        };

    emptyPage = _: { pages = {}; text = ""; };

    collectPages = builtins.foldl' mergePages emptyPage;
  };
}
