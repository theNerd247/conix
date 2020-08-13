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

    # TODO: replace this with the full build system.
    # 
    # * The final module defines an AST for the builders.
    # * The `type` attribute will determine which builder to use (1:1 mappping
    # between `type` value and name of builder)
    # * Assume `type = "dir"` is the toplevel.
    # * `type` determines the shape of the functor. 
    # * running a builder is simply a catamorphism over the module.
    # * `dir` evaluator is a symlinkJoin if attrValues > 1 or just running the 
    # first nested evaluator. Fails if no elements given?
    # 
    # `dir` | symlink join
    # `markdown` | writeFile
    # `html` | a = markdown, then pandoc
    # `include` | copy dir
    # `pdf` | a = markdown, then pandoc with latex
    # 
    evalPages
      # [ (AttrSet -> AttrSet) ] -> AttrSet
      = pages: eval (super.conix.foldPages pages);
  };
}
