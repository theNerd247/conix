let
  pkgs = import <nixpkgs> { overlays = (import ./conix.nix); };
  foo = pkgs.conix.text [ "foo" ]
    ''
      # Foo Title

      test text
    '';

  bar = pkgs.conix.textWith [ "bar" ] 
    (pages: ''
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

  blue = pkgs.conix.textsWith [ "blue" "bell" ] (pages: [''
    # Blue Bell Title

    Here's bar's text:

    ${pages.bar.text} 

    ''(pkgs.conix.text [ "data" ] "blue's data!" )''


    And that's all folks!

  '']);

  pages = pkgs.conix.buildPages [foo bar baz bang blue];

  pdf = pkgs.conix.build.pdf "test-pdf" [ pages.foo pages.bar pages.baz.bang pages.blue.bell ];
in
  { inherit pdf;
    inherit pages;
  }

