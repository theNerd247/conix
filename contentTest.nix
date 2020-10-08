rec
{
  pkgs = import <nixpkgs> {};
  T = import ./types.nix;
  C = import ./content.nix pkgs;
  E = import ./eval.nix pkgs;
  M = import ./monoid.nix;

  s = x: with x;  ["x = "{ x = "foo"; }];

  # test/
  u = x: with x; dir "test"
    [ ''This is a document ''{ y = 7; }''

      with ''(t data.x)" content"
      (set { x = "foo"; })
    ];

  u_ = E.run u;

  # foo.md
  w = x: with x; markdown "foo" "bob"; 

  # bar.md + test/
  y = x: with x; markdown "bar" u;

  y_ = E.run y;

  # baz * (bar.md + test/ + foo.md)
  z = x: with x; dir "baz" 
    [ w y ]; 

  # Expexcted
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
