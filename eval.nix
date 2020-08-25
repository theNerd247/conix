self: super:

let
  core = (import ./conix.nix) self;
in

{ conix = rec
  { 
    docs.build.docstr = ''
      Builds a page that expects the toplevel module to contain an attribute called `drv`.
      Drv typically should be a derivation containing the toplevel render of the content
    '';
    docs.build.todo = [ 
      ''
      The current implementation of build needs to take in a separate set of
      pages that are the actual content from the user. And then a single module
      that defines how to build the top derivation. If done, this may need to
      remove the clunky user interface for needing to define a toplevel
      attribute set with a single name and then turn around and give builders
      (like `markdownFile`) a name - this is redundant.
      ''
    ];
    docs.build.type 
      = "Page -> Derivation";
    build
      = page: (eval page).drv;

    docs.buildPages.docstr = ''
      Merges the pages into one and then calls `build`.
    '';
    docs.buildPages.type = "[ Page ] -> Derivation";
    buildPages = pages: build (core.lib.foldPages pages);

    docs.eval.docstr 
      = "This is the evaluator for a page and returns the final module.";
    docs.eval.type 
      = "Page -> Module";
    eval 
      = page: 
        let
          toplevel = core.lib.foldPages
            [ 
              (x: { pkgs = self; })
              (import ./meta.nix)
              (import ./table.nix)
              (import ./markdown.nix)
              (import ./codeSnippets.nix)
              (import ./textBlock.nix)
              (import ./builder/markdown.nix)
              (import ./builder/pandoc.nix)
              (import ./docs.nix)
              (import ./copyJoin.nix)
              (import ./foldAttr.nix)
              (import ./readme/default.nix)
              (import ./design/goals.nix)
              (x: core)
              # This is the docs attribute set defined in this file
              (x: { lib.docs = docs; }) 
              (c: rec { lib.git = 
                let 
                  git = import ./git.nix; 
                  text =
                  ''
                  { 
                    url = "${git.url}";
                    ref = "${git.ref}";
                    rev = "${git.rev}";
                  }
                  '';
                in
                  git // { inherit text; };
                }
              )
              page
            ];

          finalModule = self.lib.fix toplevel;
        in
          builtins.removeAttrs finalModule ["lib" "pkgs" "text"];

    docs.evalPages.docstr = ''
      Convenience functions for collecting multiple pages and evaluating
      them all at once.
    '';
    docs.evalPages.type = "[ Page ] -> Module";
    evalPages
      = pages: eval (core.lib.foldPages pages);
  };
}
