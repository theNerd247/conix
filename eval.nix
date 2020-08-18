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
    docs.build.type 
      = "Page -> Derivation";
    build
      = page: (builtins.head (builtins.attrValues (eval page))).drv;

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
              (import ./git.nix)
              (import ./table.nix)
              (import ./markdown.nix)
              (import ./codeSnippets.nix)
              (import ./textBlock.nix)
              (import ./builder/markdown.nix)
              (import ./builder/pandoc.nix)
              (import ./docs.nix)
              (import ./readme/default.nix)
              (import ./design/goals.nix)
              (import ./copyJoin.nix)
              (x: core)
              # This is the docs attribute set defined in this file
              (x: { lib.docs = docs; }) 
              page
            ];

          finalModule = self.lib.fix toplevel;
        in
          builtins.removeAttrs finalModule ["lib" "pkgs" "text"];

    docs.evalPages.docstr = ''
      Convenience functions for collecting multiple pages and evaluating
      them all at once. You might be looking for buildPages.
    '';
    docs.evalPages.type = "[ Page ] -> Module";
    evalPages
      = pages: eval (core.lib.foldPages pages);
  };
}
