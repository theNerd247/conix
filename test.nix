# Module = ReaderT AttrSet (Writer AttrSet)
# 
# type Pages = AttrSet
# BuildPageSet :: Module -> AttrSet 
let

  # this is the toplevel agreggation of the modules in question
  pkgs = import <nixpkgs> { overlays = (import ./default.nix); };

  html = pkgs.conix.build.pandoc.htmlFile "test" "" [ pages.h ];

  design = pkgs.conix.eval (pkgs.conix.foldPages pkgs.conix.docs.design);

  pages = pkgs.conix.eval test;

  test = pkgs.conix.foldPages
    [ 
      (x: { c = 8; })
      (x: { d = x.c + 2; })
      (x: { e = x.lib.texts_ [ "foo" "bar" ]; })
      (x: { f = with x.lib; texts_ [ "${str x.c} - as text" ]; })
      (x: { g = with x.lib; texts_ [ (t "${str x.g.h} - as text") (label ["h"] 7) ]; })
      (x: with x.lib; { h = texts_ [ (t "${str x.h.i} - as text") (label ["i"] (7 + x.g.h)) ]; })
      (x: with x.lib; { i = table 
          [ "x" "y" "z"]
        [ [ 1    2    3]
          [ (x.i.at 0 0) (x.i.at 0 1)  ((x.i.at 1 0) + (x.i.at 1 1))]
        ];
      })
      (import ./design/goals.nix)
    ];

    n = pkgs.conix.nixSnippetWith 
        "textNix" 
        (builtins.readFile ./readme/sample.nix) 
        (fp: builtins.readFile "${import fp}/Volunteers.md");
in
  { inherit pages;
    inherit (pkgs) conix;
    inherit html;
    inherit design;
    n = pkgs.writeText "foo.md" pages.design.core.text;
  }
