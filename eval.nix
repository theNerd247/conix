self: super:

{ conix = (super.conix or {}) //
  rec
  { 
    # This is the evaluator for the module functions. It's return value is the
    # toplevel attribute set that contains all of the user's content.
    eval 
      # (AttrSet -> AttrSet) -> AttrSet
      = mkModule: 
        let
          mkLib = x: { lib = super.conix.lib x; };
          toplevel = super.conix.mergePages mkModule mkLib;
          finalModule = self.lib.fix toplevel;
        in
          builtins.removeAttrs finalModule ["lib"];

    evalPages
      # [ (AttrSet -> AttrSet) ] -> AttrSet
      = pages: eval (super.conix.foldPages pages);
  };
}
