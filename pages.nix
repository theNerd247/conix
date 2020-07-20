self: super:

{ conix = (super.conix or {}) //
  rec
  { newPage = contents: { inherit contents; };
    page = path: text:
      self.lib.attrsets.setAttrByPath path (newPage text);
  };
}
