# Module = ReaderT AttrSet (Writer AttrSet)
# 
# type Pages = AttrSet
# BuildPageSet :: Module -> AttrSet 
let
  pkgs = import <nixpkgs> { overlays = (import ./conix.nix); };

  foo = conix: conix.text [ "foo" ]
    ''
      # Foo Title

      test text
    '';

  bar = conix: conix.text [ "bar" ]  ''
    # Bar page

    We have ${builtins.toString pages.baz.joe} baz joes;

    Foo content

    ${pages.foo.text} 
  '';

  baz = conix: conix.setValue [ "baz" "joe" ] 3;

  bang = conix: conix.texts [ "baz" "bang" ] [''
    # Bang Title! 

    Here's some text....

    '' (conix.text [ "gnab" ] "Gnab text!!") ''


    ...and after text
  ''];

  blue = conix: conix.texts [ "blue" ] [
    '' # Blue Title 

    ''(conix.hidden (conix.text [ "b" ] "blue-data"))''

      
    Some more text in blue: ''(conix.textOf [ "blue" "b" ])''

    and a table!: 

    ''(conix.table ["s"] ["x"] [["y"]])''

    The end: ''(conix.textOf [ "blue" "s" "row0" "col0"])
  ];

  trows = 
    [ [ 40 2 42 ]
      [ 4 5 9 ]
    ];

  theaders = [ "X" "Y" "Z = X+Y" ];

  tbl = conix: conix.table [ "t" ] theaders trows;

  toplevel = conix: conix.text []
    ''
      # Document Header

      ## Foo

      ${conix.pages.foo.text}

      ## Bar

      ${conix.pages.bar.text}

      ## Bang

      ${conix.pages.baz.bang.text}

      ## Blue

      ${conix.pages.blue.text}

      ## Table

      ${conix.pages.t.text}
    '';

  pages = (pkgs.conix.buildPages [ toplevel foo bar baz bang blue tbl ]).pages;
in
  { inherit pages;
    inherit (pkgs) conix;
  }
