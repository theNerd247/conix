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

  p = x: with x; pandoc "testPdf" "pdf" "" [ pkgs.texlive.combined.scheme-small ]
    [ '' asdf ''{ x = "mate"; }
      (set { y = 7; })
    ];

  p_ = E.run h;

  h = x: with x; dir "jack" [
    (html "bar" [ 
      { x = 3; } 
      ''...or here

      ''
      (html "baz" "a nested file")''


      ''
      (table 
        [ "foo" "bar" "baz" ]
        [[ 2 3 2] 
         [ (t data.x) 2 3]
        ]
      )''


      ''
      (dotgraph "foo" ''
        digraph {
         L -> a
         L -> b
         a -> c
         b -> c
        }
      '')''


      ''
      (runNixSnippet "foo" ''
        1 + 2
      '')
    ])
  ]; 

  h_ = E.run h;
    
}
