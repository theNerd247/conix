self: super:
{ conix = (super.conix or {}) // rec
{
  # Modules are the core of conix. Their type is defined as:
  #
  #  Module = { text : String; ... }
  #
  # The rest of the attribute set defines the structure of the user's
  # content (including the derivations containing the rendered output).
  #
  # For example the final module describing a single markdown file might
  # look like:
  #
  #  { drv = <derivation>; 
  #    text = "Call me at: 555-123-456"; 
  #    phone = "555-123-456"; 
  #  }
  # Here the user has the text for the markdown file; the derivation of the
  # built markdown file and some extra data containing the phone number.
  #
  # Modules are meant to allow the user to describe the textual structure of
  # their content and the structure of the rendered in the same data structure.

  # The empty module contains nothing. The core functions defined in this file
  # treat the missing text value as an empty string to save memory.
  emptyModule 
    = {};

  # Modules merge by recursiveUpdate but the toplevel text fields
  # are concatenated.
  mergeModules = a: b:
    # AttrSet -> AttrSet -> AttrSet
    (self.lib.attrsets.recursiveUpdate a b) 
    // { text = (a.text or "") + (b.text or ""); };

  # A Page is the toplevel type used throughout conix. 
  mergePages 
    # (AttrSet -> AttrSet) -> (AttrSet -> AttrSet) -> AttrSet -> AttrSet
    = mkModuleA: mkModuleB: x: 
    mergeModules (mkModuleA x) (mkModuleB x);

  foldMapModules
    = f: builtins.foldl' (m: x: mergeModules m (f x)) emptyModule;

  foldMapPages 
    # (a -> AttrSet -> AttrSet) -> [a] -> AttrSet -> AttrSet
    = f: 
      builtins.foldl' (m: x: mergePages m (f x)) (x: {});

  foldPages
    # [ (AttrSet -> AttrSet) ] -> AttrSet -> AttrSet
    = foldMapPages (x: x);

  # This is a convenience function so users don't clutter up their content
  # with long bits of code for small things.
  str = builtins.toString;

  # Constructor for creating storing text content.
  text
    # (IsString t) => t -> { text : String }
    = txt: { text = str txt; };

  # A convenience function for creating 
  # TODO: it might be a better user experience to rename this to `txt` instead.
  t = text;

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
  toTextModule 
    # forall r. (String | Module)  -> Module
    = x: if builtins.isString x then text x else x;

  # The toplevel user API function for creating text blocks that have labelled
  # values inter-mixed. This allows users to content that can be referenced
  # within other parts of their document.
  # 
  # See the documentation for mergeTexts.
  texts 
    # forall r. [  String | Module ] -> AttrSet
    = foldMapModules toTextModule;

  # This is a convenience function for users to create new modules within texts
  # without needing to manually create modules
  label 
    # Path -> Module -> Module
    = path: x: 
      (self.lib.attrsets.setAttrByPath path x) // (text x);

  extendLib = mkLib: f:
    mergePages mkLib f;

  lib = x: 
    { inherit 
        emptyModule
        foldMapModules
        foldMapPages
        foldPages
        label
        mergeModules
        str
        t
        texts
      ;

      pkgs = self;
    };
};}
