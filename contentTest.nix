rec
{

  pkgs = import <nixpkgs> 
    { overlays = import ./default.nix; };

  conix = pkgs.conix;

  pkgs_ = import <nixpkgs> {};

  I = import ./lib/internal.nix pkgs;

  E = import ./lib/eval.nix pkgs;

  T = import ./lib/types.nix;

  R = import ./lib/evalResult.nix pkgs;

  h = x: with x; dir "jack" [

    { p = markdown "foo" [
      "bar"
      (html "bo" { bo = 7; })
    ]; }

    (pdf "bar" (html "bar" [ 

      (meta [
        (css ./static/latex.css)
        "pagetitle: FOO"
      ])

      { x = 3; }''


      ...or here

      ''

      (r data.x)''


      [Go to bo](''(link refs.bo)'')

      ''

      { m = markdown "mdListSample"
        { l = indent 2 (list 
          [ "foo"
            { t = "bar"; }
            "baz"
          ]); 
        };
      }

      (html "baz" "a nested file")''


      ''
      (table 
        [ "foo" "bar" "baz" ]
        [[ 2 3 2] 
         [ (r data.x) 2 3]
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
      '')''


      ''(nest "y" g)''


      ''(r data.y.x)" = 4 != "(r data.x)
    ])) ];

  g = n: with n; [
    { x = 4; } " = " (r data.x)

    (list ["a" "b" "c"])''


    [MDLiST](''(link refs.m)'')''
  ];

  h_ = pkgs.conix.run h;

  a = c: with c; [
    { x = html "a" "boo"; }
    (html "b" "aoo")
  ];

  extendedA = conix.runExtended 
    (x: with x; module (_: {})
      {
        addBoo = expr "" "" (x: [ x "-boo"]);
      }
    )
    (x: with x; html "foo" (addBoo "boo"));
}
