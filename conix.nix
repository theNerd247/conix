self: super:
{ conix = (super.conix or {}) // rec
{
  emptyModule = {};

  mergeModule = 
    # AttrSet -> AttrSet -> AttrSet
    self.lib.attrsets.recursiveUpdate;

  mergeModuleFunc 
    # (AttrSet -> AttrSet) -> (AttrSet -> AttrSet) -> AttrSet -> AttrSet
    = mkModuleA: mkModuleB: x: 
    mergeModule (mkModuleA x) (mkModuleB x);

  # FoldMap for module functions 
  foldMap 
    # (a -> AttrSet -> AttrSet) -> [a] -> AttrSet -> AttrSet
    = f: 
      builtins.foldl' (m: x: mergeModuleFunc m (f x)) (x: {});

  # Fold for module functions
  fold
    # [ (AttrSet -> AttrSet) ] -> AttrSet -> AttrSet
    = foldMap (x: x);

  # This is a convenience function so users don't clutter up their content
  # with long bits of code for small things.
  str = builtins.toString;

  # Constructor for creating storing text content.
  text_ 
    # (IsString t) => t -> { text : String }
    = text: { text = str text; };

  modifyText
    # IsString a => forall r. (Text -> a) -> { text : String | r } -> { text : String | r }
    = f: t: t // (text_ (f t.text));

  # A convenience function for creating 
  # TODO: it might be a better user experience to rename this to `txt` instead.
  t = text_;

  # This is the core function that makes conix work.  It merges the current
  # attribute set and preserves the concatenates the toplevel text values. If
  # `b` is:
  # 
  #  * a string then the `a` has its `text` value concatenated with `b`
  #  * an attribute set then the resulting attribute set has its `text` field
  #  set to `a.text + b.text`.
  #
  # **NOTE:** if `b` is a string then IT MUST NOT CONTAIN INTERPOLATIONS THAT
  # REFER TO RECURSIVE ATTRIBUTE VALUES THIS WILL CAUSE INFINITE RECURSION
  # ERRORS! For example:
  # 
  #   (conix: { favorite = texts_ [ 
  #      "My " 
  #      ({ color = 256; text = "Blue"; })
  #      " color is very ${str conix.favorite.color}"
  #   ];})
  #
  # will fail with an infinite recursion error. This is due purely because it
  # is impossible to determine if a value is a string without first evaluating
  # it and in order to construct the equivalent attribute set:
  #  
  #  { favorite = 
  #    { text = "My Blue color is very ${x.favorite.color}";
  #      color = 256; 
  #    }
  #  }
  # One must first evaluate the text. Because the last line contains an
  # accessor (`x.favorite.color`) which points to some data inside `favorite`
  # we get a infinite recursion error. However, if the data is note defined in
  # the same texts_ list then we can use normal string interpolation with no
  # issues:
  #
  #  merge_
  #   [ (x: { color.blue = 256; })
  #
  #     (conix: { favorite = texts_ [ 
  #        "My " 
  #        ({ color = conix.color.blue; text = "Blue"; })
  #        " color is very ${str conix.color.blue}"
  #     ];})
  #   ]
  # Will work.
  # 
  # 
  mergeTexts 
    # forall r. { text : String | r } -> String | { text : String | r }  -> { text : String | r }
    = a: b:
      if builtins.isString b 
      then a // (text_ ((a.text or "") + b))
      else (mergeModule a b) // (text_ ((a.text or "") + b.text)); 

  # The toplevel user API function for creating text blocks that have labelled
  # values inter-mixed. This allows users to content that can be referenced
  # within other parts of their document.
  # 
  # See the documentation for mergeTexts.
  texts_ 
    # forall r. [  String | { text : String | r } ] -> AttrSet
    = builtins.foldl' mergeTexts {};

  foldTextsIx 
    # (forall r. Natural -> a -> { text : String | r } | String) -> [a] -> AttrSet
    = f: foldlIx (ix: m: x: mergeTexts m (f ix x)) {};

  foldlIx 
    # (Natural -> b -> a -> b) -> b -> [a] -> b
    = f: initB: as: 
        (builtins.foldl' ({ix, b}: a: {ix = ix+1; b = f ix b a; }) {ix = 0; b = initB;} as).b;

  # This is a convenience function for users to create new modules within texts
  # without needing to manually create the attribute set with the `text` attribute
  # inside of it.
  label 
    = path: x: 
      (self.lib.attrsets.setAttrByPath path x) // (text_ x);

  # This is a convenience function so users don't have to write:
  #  
  #  conix: conix.fold [...] conix;
  #
  # (Remember: conix.fold [ ... ] : AttrSet -> AttrSet)
  merge
    # [ (AttrSet -> AttrSet) ] -> AttrSet
    = x: fs: fold fs x;

  extendLib = mkLib: f:
    mergeModuleFunc mkLib f;

  lib = x: 
    { inherit 
      label
      str
      t
      texts_
      fold
      foldMap
      foldTextsIx
      foldlIx
      emptyModule
      mergeModule
      mergeModuleFunc;

      merge = merge x;

      pkgs = self;
    };
};}
