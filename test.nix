# Module = ReaderT AttrSet (Writer AttrSet)
# 
# type Pages = AttrSet
# BuildPageSet :: Module -> AttrSet 
let

  # this is the toplevel agreggation of the modules in question
  pkgs = import <nixpkgs> { overlays = (import ./default.nix); };

  # html = pkgs.conix.build.htmlFile 
  #   { name = "test";
  #     text = pages.h.text;
  #   };

  # design = 
  #   pkgs.conix.build.htmlFile 
  #     { name = "design"; 
  #       text = docs.design.text;
  #     };

  #docs = pkgs.conix.build (c: { top = c.lib.refDocs; });

  # pages = pkgs.conix.eval test;

  test = pkgs.conix.evalPages
    [ 
      (x: { c = 8; })
      (x: { d = x.c + 2; })
      (x: { e = x.lib.texts [ "foo" "bar" (x.lib.set "o" x.i) ]; })
      (x: { f = with x.lib; texts [ "${str x.c} - as text" ]; })
      (x: { g = with x.lib; texts [ (t "${str x.g.h} - as text") (label "h" 7) ]; })
      (x: with x.lib; { h = texts [ (t "${str x.h.i} - as text") (label "i" (7 + x.g.h)) ]; })
      (x: with x.lib; { i = table 
          [ "x" "y" "z"]
        [ [ 1    2    3]
          [ (x.i.at 0 0) (x.i.at 0 1)  ((x.i.at 1 0) + (x.i.at 1 1))]
        ];
      })
    ];
in
  { 
    inherit (pkgs) conix;
    inherit test; 
  }
