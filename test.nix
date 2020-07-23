# Module = ReaderT AttrSet (Writer AttrSet)
# 
# type Pages = AttrSet
# BuildPageSet :: Module -> AttrSet 
let
  pkgs = import <nixpkgs> { overlays = (import ./conix.nix); };
  foo = pkgs.conix.text [ "foo" ]
    ''
      # Foo Title

      test text
    '';

  bar = pkgs.conix.textWith [ "bar" ] (pages: ''
    # Bar page

    We have ${builtins.toString pages.baz.joe} baz joes;

    Foo content

    ${pages.foo.text} 
  '');

  baz = pkgs.conix.setAt [ "baz" "joe" ] 3;

  bang = pkgs.conix.texts [ "baz" "bang" ] [''
    # Bang Title! 

    Here's some text....

    '' (pkgs.conix.text [ "gnab" ] "Gnab text!!") ''


    ...and after text
  ''];

  blue = with pkgs.conix; textsWith [ "a" ] (pages: [
    (t '' # Blue Title '') 

    (pkgs.conix.text [ "b" ] "blue-data")

    (t '' Some more text in blue: ${pages.a.b.text} '')
  ]);

  pages = pkgs.conix.builtPages [ foo bar baz bang blue ];

  builtPages = [ pages.foo pages.bar pages.baz.bang pages.a ];

  pdf = pkgs.conix.build.pdf "test-pdf" builtPages;

  md = pkgs.conix.build.markdown "test-md" builtPages;
in
  { inherit pages;
    testDocs = pkgs.symlinkJoin { name = "testDocs"; paths = [ pdf md ]; };
  }

