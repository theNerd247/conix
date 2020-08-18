pkgs: { lib = rec {

  docs.modules.discussion = ''
    Modules are the core of conix. Their type is defined as:
   
    ```haskell
    Module = { text : String; ... }
    ```
   
    The rest of the attribute set defines the structure of the user's
    content (including the derivations containing the rendered output).
   
    For example the final module describing a single markdown file might
    look like:
   
    ```nix
    { drv = <derivation>; 
      text = "Call me at: 555-123-456"; 
      phone = "555-123-456"; 
    }
    ```

    Here the user has the text for the markdown file; the derivation of the
    built markdown file and some extra data containing the phone number.
   
    Modules are meant to allow the user to describe the textual structure of
    their content and the structure of the rendered in the same data structure.

    The empty module contains nothing. The core functions defined in this file
    treat the missing text value as an empty string to save memory.
  '';

  docs.emptyModule.type = "Module";
  emptyModule 
    = {};

  docs.mergeModules.docstr = ''
    Modules merge by recursiveUpdate but the toplevel text fields
    are concatenated.
  '';
  docs.mergeModules.type = 
    "Module -> Module -> Module";
  mergeModules = a: b:
    (pkgs.lib.attrsets.recursiveUpdate a b) 
    // { text = (a.text or "") + (b.text or ""); };

  docs.mergePages.docstr = '' 
    A Page is the toplevel type used throughout conix. 
  '';
  docs.mergePages.type = 
    "Page -> Page -> Page";
  mergePages 
    = mkModuleA: mkModuleB: x: 
    mergeModules (mkModuleA x) (mkModuleB x);

  docs.foldMapModules.type = "(a -> Module) -> [a] -> Module";
  foldMapModules
    = f: builtins.foldl' (m: x: mergeModules m (f x)) emptyModule;

  docs.foldMapPages.type = "(a -> Page) -> [a] -> Page";
  foldMapPages 
    = f: 
      builtins.foldl' (m: x: mergePages m (f x)) (x: {});

  docs.foldPages.type = "[ Page ] -> Page";
  foldPages
    = foldMapPages (x: x);

  docs.str.docstr = ''
    An alias for `builtins.toString`
    This is a convenience function so users don't clutter up their content
    with long bits of code for small things.
  '';
  docs.str.type = "(IsString t) => String";
  str = builtins.toString;

  docs.text.docstr = ''
    Constructor for creating storing text content.
  '';
  docs.text.type = "(IsString t) => t -> Module";
  text
    = txt: { text = str txt; };

  docs.t.docstr = ''
    This is an alias for `text`.
    A convenience function for creating 
    TODO: it might be a better user experience to rename this to `txt` instead.
  '';
  docs.t.type = docs.text.type;
  t = text;

  docs.toTextModule.docstr = ''
    This is the core function that makes conix work.  It merges the current
    attribute set and preserves the concatenates the toplevel text values. If
    `b` is:
    
     * a string then the `a` has its `text` value concatenated with `b`
     * an attribute set then the resulting attribute set has its `text` field
     set to `a.text + b.text`.
   
    **NOTE:** if `b` is a string then IT MUST NOT CONTAIN INTERPOLATIONS THAT
    REFER TO RECURSIVE ATTRIBUTE VALUES THIS WILL CAUSE INFINITE RECURSION
    ERRORS! For example:
    
      (conix: { favorite = texts [ 
         "My " 
         ({ color = 256; text = "Blue"; })
         " color is very ''${str conix.favorite.color}"
      ];})
   
    will fail with an infinite recursion error. This is due purely because it
    is impossible to determine if a value is a string without first evaluating
    it and in order to construct the equivalent attribute set:
     
     { favorite = 
       { text = "My Blue color is very ''${x.favorite.color}";
         color = 256; 
       }
     }
    One must first evaluate the text. Because the last line contains an
    accessor (`x.favorite.color`) which points to some data inside `favorite`
    we get a infinite recursion error. However, if the data is note defined in
    the same texts list then we can use normal string interpolation with no
    issues:
   
     mergePages
      [ (x: { color.blue = 256; })
   
        (conix: { favorite = texts [ 
           "My " 
           ({ color = conix.color.blue; text = "Blue"; })
           " color is very ''${str conix.color.blue}"
        ];})
      ]
    Will work.
  '';  
  docs.toTextModule.type = "(String | Module)  -> Module";
  toTextModule 
    = x: if builtins.isString x then text x else x;

  docs.texts.docstr = ''
    This is the most common function for constructing content for the user.
    It allows them to write plain text and assignments alongside each other.
    Here's an example:

    ```nix
    conix: { report = conix.lib.texts [
      '''
      The final count for the muffin competition was:
      '''
      (conix.lib.md.list "muffinCount"
        [ "Blue Berry: ''${t (builtins.length conix.muffins.blueBerry)}
          "Whole Grain:  ''${t (builtins.length conix.muffins.wholeGrain)}
        ]
      )
    ]; }
    ```
  '';
  docs.texts.type = "[ String | Module ] -> Module";
  texts 
    = foldMapModules toTextModule;

  docs.label.docstr = ''
    This is a convenience function for users to create new modules within texts
    without needing to manually create modules
  '';
  docs.label.type = "Path -> Module -> Module";
  label 
    = path: x: 
      mergeModules (pkgs.lib.attrsets.setAttrByPath (conix.pkgs.lib.strings.splitString "." path) x) (text x);
};}
