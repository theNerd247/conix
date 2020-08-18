self: super:

{ conix = rec
  { 
    docs.build.docstr = ''
      Builds a page that expects the toplevel module to contain an attribute called `drv`.
      Drv typically should be a derivation containing the toplevel render of the content
    '';
    docs.build.type 
      = "Page -> Derivation";
    build
      = page: (eval page).drv;

    docs.eval.docstr 
      = "This is the evaluator for a page and returns the final module.";
    docs.eval.type 
      = "Page -> Module";
    eval 
      = page: 
        let
          mkLib = c:
            [ 
              (import ./conix.nix)
              (import ./meta.nix)
              (import ./git.nix)
              (import ./table.nix)
              (import ./markdown.nix)
              (import ./codeSnippets.nix)
              (import ./textBlock.nix)
              
            ];

          toplevel = super.conix.mergePages page mkLib;
          finalModule = self.lib.fix toplevel;
        in
          builtins.removeAttrs finalModule ["lib"];

    docs.evalPages.docstr = ''
      Convenience functions for collecting multiple pages and evaluating
      them all at once. You might be looking for buildPages.
    '';
    docs.evalPages.type = "[ Page ] -> Module";
    evalPages
      = pages: eval (super.conix.foldPages pages);
  };
}
