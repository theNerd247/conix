rec
{
  pkgs = import <nixpkgs> {};
  T = import ./types.nix;
  C = import ./content.nix;
  E = import ./eval.nix pkgs;

  s = x: C.tell { x = "foo"; } (C.text "x = ${x.x}");

  u = x: C.tell { x = "foo"; } (C.dir "test"
    [ (C.text "This is a document ${builtins.toString x.y}")
      (C.text "\n with ${x.x} content")
      (C.tell { y = 7; } (C.text ""))
    ]);

  w = _: C.markdown "foo"
     [(C.text "bob")]; 

  y = x: C.markdown "bar" [(u x)];

  z = x: C.markdown "baz" [ (w x) (y x) ]; 

  z_ = E.run z;

  a = x: 
    C.dir "foo"
    [ (C.tell { x = "mate"; } " adf ")
      (C.text " asdf ${x.x} ")
      "foo"
      { y = 7; }
    ];
}
