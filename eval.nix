self: super:

with super.conix;

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
          toplevel = mergeModuleFunc mkModule mkLib;
        in
          self.lib.fix toplevel;
  };
}
