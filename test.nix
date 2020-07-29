# Module = ReaderT AttrSet (Writer AttrSet)
# 
# type Pages = AttrSet
# BuildPageSet :: Module -> AttrSet 
let
  pkgs = import <nixpkgs> { overlays = (import ./conix.nix); };
  foo = pages: pkgs.conix.text [ "foo" ]
    ''
      # Foo Title

      test text
    '';

  bar = pages: pkgs.conix.text [ "bar" ]  ''
    # Bar page

    We have ${builtins.toString pages.baz.joe} baz joes;

    Foo content

    ${pages.foo.text} 
  '';

  baz = pkgs.conix.setValue [ "baz" "joe" ] 3;

  bang = pages: pkgs.conix.texts [ "baz" "bang" ] [''
    # Bang Title! 

    Here's some text....

    '' (pkgs.conix.text [ "gnab" ] "Gnab text!!") ''


    ...and after text
  ''];

  blue = conix: with pkgs.conix; texts [ "a" ] [
    '' # Blue Title 

    ''(hidden (text [ "b" ] "blue-data"))''

      
    Some more text in blue: ''(conix.textOf [ "a" "b"])''

    and a table!: 

    ''(table ["s"] ["x"] [["y"]])''

    The end: ''(conix.textOf [ "a" "s" "row0" "col0"])
  ];

  trows = 
    [ [ 40 2 42 ]
      [ 4 5 9 ]
    ];

  theaders = [ "X" "Y" "Z = X+Y" ];

  tbl =  pkgs.conix.table [ "t" ] theaders trows;

  pages = pkgs.conix.buildPages [ blue (p: tbl) ];

  xx = (pkgs.conix.single pkgs.conix.texts) [
    "foo"
    tbl
  ];

  builtPages = [ pages.a ];
in
  { inherit pages;
    inherit (pkgs) conix;
  }

