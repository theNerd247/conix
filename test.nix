# Module = ReaderT AttrSet (Writer AttrSet)
# 
# type Pages = AttrSet
# BuildPageSet :: Module -> AttrSet 
let

  # this is the toplevel agreggation of the modules in question
  pkgs = import <nixpkgs> { overlays = (import ./default.nix); };

  html = pkgs.conix.build.pandoc.htmlFile "test" "" [ pages.h ];

  pages = pkgs.conix.eval test;

  test = pkgs.conix.fold
    [ 
      (x: { c = 8; })
      (x: { d = x.c + 2; })
      (x: { e = x.lib.texts_ [ "foo" "bar" ]; })
      (x: { f = with x.lib; texts_ [ "${str x.c} - as text" ]; })
      (x: { g = with x.lib; texts_ [ (t "${str x.g.h} - as text") { h = 7; text = " and 7"; } ]; })
      (x: with x.lib; { h = texts_ [ (t "${str x.h.i} - as text") { i = 7 + x.g.h; text = " and ${str x.h.i}"; } ]; })
      (x: with x.lib; { i = table 
          [ "x" "y" "z"]
        [ [ 1    2    3]
          [ (at 0 0 x.i.data) (at 0 1 x.i.data) 4 ]
        ];
      })
    ];

in
  { inherit pages;
    inherit (pkgs) conix;
  }
