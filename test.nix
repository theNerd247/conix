# Module = ReaderT AttrSet (Writer AttrSet)
# 
# type Pages = AttrSet
# BuildPageSet :: Module -> AttrSet 
let

  # this is the toplevel agreggation of the modules in question
  pkgs = import <nixpkgs> { overlays = (import ./default.nix); };

  docs = pkgs.conix.buildPages [
    (c: { drv = with c.lib; 
      buildBoth "goals" c.lib.docs.goals (markdownFile "goals") (htmlFile "goals" "");
    })
    (import ./design/goals.nix)
  ];

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
      (x: { s = with x.lib; texts [ (sampleConixSnippet "t" "texts [ \"foo\" ]") ]; })
    ];
in
  { 
    inherit (pkgs) conix;
    inherit test; 
    inherit docs;
  }
