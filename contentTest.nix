rec
{

  extend = c: with c; htmlModule "customApi" (module "# Custom API\n\n"
    { addBoo = expr 
        "Content -> Content"
        "Adds prefix boo!"
        (x: [ "boo! " x]);
    });

  pkgs = import <nixpkgs> 
    { overlays = import ./default.nix { inherit extend; }; };

  conix = pkgs.conix;

  h = x: with x; dir "jack" (html "bar" [ 

      { x = 3; }

      (addBoo "foo!")

      ''
      ...or here
      ''

      (markdown "mdListSample" [ "  " (indent 2 
        (list 
          [ "foo"
            "bar"
            "baz"
          ]
        ))
      ])

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
    ]);

  h_ = pkgs.conix.run h;
    
  j = with pkgs.conix;
    _merge
    [ (exp (_merge [ (_text "a -> ") (data.code "jack") ]) 2)
      (exp (_text "a -> b -> a") _text)
    ];

  exp = type: exp: with pkgs.conix;
    _tell { _data = { run = exp; }; _next = type; };
}
