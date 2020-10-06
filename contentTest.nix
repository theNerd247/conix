rec
{
  pkgs = import <nixpkgs> {};
  T = import ./types.nix;
  C = import ./content.nix pkgs;
  E = import ./eval.nix pkgs;
  M = import ./monoid.nix;

  s = x: with x;  ["x = "{ x = "foo"; }];

  u = x: with x; dir "test"
    [ ''This is a document ''{ y = 7; }''

      with ''(t data.x)" content"
      (set { x = "foo"; })
    ];

  w = _: C.markdown "foo" "bob"; 

  y = x: C.markdown "bar" u;

  z = x: C.markdown "baz" [ w y ]; 

  z_ = E.run z;

  a = x: with x;
    [ '' asdf ''{ x = "mate"; }
      (set { y = 7; })
    ];

  b = x: with x;
    [ a ''

      y = ''(t data.y)''

      b = ''{ b = "bar"; }
    ];
}
