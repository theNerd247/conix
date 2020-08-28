pkgs: { lib = rec {

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
    //
    { text = (a.text or "") + (b.text or ""); 
      drvs = (a.drvs or []) ++ (b.drvs or []); 
    };

  docs.mergePages.docstr = '' 
    A Page is the toplevel type used throughout conix. 
  '';
  docs.mergePages.type = 
    "Page -> Page -> Page";
  mergePages 
    = mkModuleA: mkModuleB: x: 
    mergeModules (mkModuleA x) (mkModuleB x);

  docs.foldMapModules.docstr = ''
    Maps elements to a module and merges the modules;
  '';
  docs.foldMapModules.type = "(a -> Module) -> [a] -> Module";
  foldMapModules
    = f: builtins.foldl' (m: x: mergeModules m (f x)) emptyModule;

  docs.foldModules.docstr = "Merges a list of modules";
  docs.foldModules.type = "[Module] -> Module";
  foldModules = foldMapModules (x: x);

  docs.foldMapPages.docstr = "Maps elements to a page and then merges the pages";
  docs.foldMapPages.type = "(a -> Page) -> [a] -> Page";
  foldMapPages 
    = f: builtins.foldl' (m: x: mergePages m (f x)) (x: {});

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
    Converts either text or a module to a module. This is used by the `texts`
    function.  NOTE: Use of this can cause infinite recursion issues. See the
    Infinite Recursion discussion.
  '';
  docs.toTextModule.type = "(String | Module)  -> Module";
  docs.toTextModule.todo = [
    ''It might be worth investigating whether I could use a small typing system
      and if x has no type then assume it's a raw, stringable nix value
    ''
  ];
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
        [ "Blue Berry: ''${t (builtins.length conix.muffins.blueBerry)}"
          "Whole Grain:  ''${t (builtins.length conix.muffins.wholeGrain)}"
        ]
      )
    ]; }
    ```
  '';
  docs.texts.type = "[ String | Module ] -> Module";
  texts 
    = foldMapModules toTextModule;

  docs.nest.docstr = texts [''
    Nest a value into an attribute set with a given path string.
  ''];
  docs.nest.type = "Path -> a -> AttrSet";
  nest = pathStr: x:
    pkgs.lib.attrsets.setAttrByPath (pkgs.lib.strings.splitString "." pathStr) x;

  docs.label.docstr = ''
    This is a convenience function for users to create new modules within texts
    without needing to manually create modules.

    ```nix
    label "foo" 7 ==> { foo = 7; text = "7"; } 
    ```
  '';
  docs.label.type = "Path -> Text -> Module";
  label 
    = path: x: 
    mergeModules (nest path x) (text x);

  docs.set.docstr = ''
    This is like `label` but for nesting a module. We can't have just `label` and check whether the
    input is a string or attribute set (yet? see todo for `toTextModule`) because doing so triggers
    infinite recursion. Thus we need a separate function to achieve the same task.

    ```nix
    set "foo" { text = "bar"; x = 3;} ==> { foo = { text = "bar"; x = 3; } text = "bar"; }
    ```
    '';
  docs.set.type = "Path -> Module -> Module";
  set = path: x: mergeModules (nest path x) ({ text = x.text or ""; drvs = x.drvs or []; });


  # [ Derivation ] -> Module -> Module
  docs.setDrvs.docstr = ''
    Overwrite the derivations for the given module;
    '';
  docs.setDrvs.type = "[Derivation] -> Module -> Module";
  setDrvs = drvs: module: module // { inherit drvs; };

  # [ Derivation ] -> Module -> Module
  docs.setText.docstr = ''
    Overwrite the texts for the given module;
    '';
  docs.setText.type = "String -> Module -> Module";
  setText = text: module: module // { inherit text; };

  docs.hidden.docstr = ''
    Sets the text to an empty string for a module.

    Use this if you only want to keep the drvs and data a module produces.
    '';
  docs.hidden.type = "Module -> Module";
  hidden = module: module // { text = ""; };
};}
