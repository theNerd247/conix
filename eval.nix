self: super:

let
  core = (import ./conix.nix) self;
in

{ conix = rec
  { 
    docs.build.docstr = ''
      Builds a page and collects all of the derivations from the toplevel modules.
      Use this to build the final output of your content.
    '';
    docs.build.type 
      = "Page -> [Derivation]";
    build
      = page: builtins.foldl' 
        (drvs: mod: drvs ++ (mod.drvs or [])) 
        [] 
        (builtins.attrValues (eval page));

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
              (import ./drvs.nix)
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
