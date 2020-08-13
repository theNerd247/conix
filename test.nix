# Module = ReaderT AttrSet (Writer AttrSet)
# 
# type Pages = AttrSet
# BuildPageSet :: Module -> AttrSet 
let

  # this is the toplevel agreggation of the modules in question
  pkgs = import <nixpkgs> { overlays = (import ./default.nix); };

  html = pkgs.conix.build.htmlFile 
    { name = "test";
      text = pages.h.text;
    };

  design = 
    pkgs.conix.build.htmlFile 
      { name = "design"; 
        text = docs.design.text;
      };

  docs = pkgs.conix.evalPages pkgs.conix.docs;

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
    ];
in
  { inherit pages;
    inherit (pkgs) conix;
    inherit html;
    inherit design;
    inherit docs;
    n = pkgs.conix.build.markdown { name = "goals"; text = docs.design.goals.text; };
  }
