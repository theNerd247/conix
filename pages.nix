self: super:

{ conix = (super.conix or {}) //
  rec
  { newPage = contents: { inherit contents; };
    textPage_ = path: text:
      self.lib.attrsets.setAttrByPath path (newPage text);

    textPage = path: text: _: { pages = textPage_ path text; res = text; };

    buildPages = module: self.lib.fix (pgs: (module pgs).pages);
  };
}
