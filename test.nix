# Module = ReaderT AttrSet (Writer AttrSet)
# 
# type Pages = AttrSet
# BuildPageSet :: Module -> AttrSet 
let

  # this is the toplevel agreggation of the modules in question
  pkgs = import <nixpkgs> { overlays = (import ./default.nix); };

  pages = pkgs.conix.buildPages [ toplevel foo bar baz bang blue tbl ];

  pdf = pkgs.conix.build.pdfFile "foo" (conix: conix.text [] "asdf");

  toplevel = conix: conix.texts [] [
    ''
      # Document Header

      ## Foo

      ''(conix.textOf ["foo"])''

      ## Bar

      ''(conix.textOf ["bar"])''

      ## Bang

      ''(conix.textOf ["baz" "bang"])''

      ## Blue

      ''(conix.textOf ["blue"])''

      ## Table

      ''(conix.textOf ["t"])''
    ''];

  #everything below this could be placed in its own file
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


in
  { inherit pages;
    inherit (pkgs) conix;
    inherit pdf;
  }
